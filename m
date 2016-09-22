Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6949C6B0270
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:35:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b130so71622594wmc.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 06:35:03 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id c2si1926355wjd.229.2016.09.22.06.35.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 06:35:02 -0700 (PDT)
Subject: Re: [PATCH 2/4] writeback: allow for dirty metadata accounting
References: <1474405068-27841-1-git-send-email-jbacik@fb.com>
 <1474405068-27841-3-git-send-email-jbacik@fb.com>
 <20160922111801.GK2834@quack2.suse.cz>
From: Josef Bacik <jbacik@fb.com>
Message-ID: <81d2d2e2-6a90-6727-cdb2-8ffcadf93833@fb.com>
Date: Thu, 22 Sep 2016 09:34:40 -0400
MIME-Version: 1.0
In-Reply-To: <20160922111801.GK2834@quack2.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org, hannes@cmpxchg.org

On 09/22/2016 07:18 AM, Jan Kara wrote:
> On Tue 20-09-16 16:57:46, Josef Bacik wrote:
>> Btrfs has no bounds except memory on the amount of dirty memory that we have in
>> use for metadata.  Historically we have used a special inode so we could take
>> advantage of the balance_dirty_pages throttling that comes with using pagecache.
>> However as we'd like to support different blocksizes it would be nice to not
>> have to rely on pagecache, but still get the balance_dirty_pages throttling
>> without having to do it ourselves.
>>
>> So introduce *METADATA_DIRTY_BYTES and *METADATA_WRITEBACK_BYTES.  These are
>> zone and bdi_writeback counters to keep track of how many bytes we have in
>> flight for METADATA.  We need to count in bytes as blocksizes could be
>> percentages of pagesize.  We simply convert the bytes to number of pages where
>> it is needed for the throttling.
>>
>> Signed-off-by: Josef Bacik <jbacik@fb.com>
>> ---
>>  arch/tile/mm/pgtable.c           |   3 +-
>>  drivers/base/node.c              |   6 ++
>>  fs/fs-writeback.c                |   2 +
>>  fs/proc/meminfo.c                |   5 ++
>>  include/linux/backing-dev-defs.h |   2 +
>>  include/linux/mm.h               |   9 +++
>>  include/linux/mmzone.h           |   2 +
>>  include/trace/events/writeback.h |  13 +++-
>>  mm/backing-dev.c                 |   5 ++
>>  mm/page-writeback.c              | 157 +++++++++++++++++++++++++++++++++++----
>>  mm/page_alloc.c                  |  16 +++-
>>  mm/vmscan.c                      |   4 +-
>>  12 files changed, 200 insertions(+), 24 deletions(-)
>>
>> diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
>> index 7cc6ee7..9543468 100644
>> --- a/arch/tile/mm/pgtable.c
>> +++ b/arch/tile/mm/pgtable.c
>> @@ -44,12 +44,13 @@ void show_mem(unsigned int filter)
>>  {
>>  	struct zone *zone;
>>
>> -	pr_err("Active:%lu inactive:%lu dirty:%lu writeback:%lu unstable:%lu free:%lu\n slab:%lu mapped:%lu pagetables:%lu bounce:%lu pagecache:%lu swap:%lu\n",
>> +	pr_err("Active:%lu inactive:%lu dirty:%lu metadata_dirty:%lu writeback:%lu unstable:%lu free:%lu\n slab:%lu mapped:%lu pagetables:%lu bounce:%lu pagecache:%lu swap:%lu\n",
>>  	       (global_node_page_state(NR_ACTIVE_ANON) +
>>  		global_node_page_state(NR_ACTIVE_FILE)),
>>  	       (global_node_page_state(NR_INACTIVE_ANON) +
>>  		global_node_page_state(NR_INACTIVE_FILE)),
>>  	       global_node_page_state(NR_FILE_DIRTY),
>> +	       global_node_page_state(NR_METADATA_DIRTY),
>
> Leftover from previous version? Ah, it is tile architecture so I see how it
> could have passed testing ;)
>

Ah now I understand the kbuild error I got, oops ;)

>> @@ -506,6 +530,10 @@ bool node_dirty_ok(struct pglist_data *pgdat)
>>  	nr_pages += node_page_state(pgdat, NR_FILE_DIRTY);
>>  	nr_pages += node_page_state(pgdat, NR_UNSTABLE_NFS);
>>  	nr_pages += node_page_state(pgdat, NR_WRITEBACK);
>> +	nr_pages += (node_page_state(pgdat, NR_METADATA_DIRTY_BYTES) >>
>> +		     PAGE_SHIFT);
>> +	nr_pages += (node_page_state(pgdat, NR_METADATA_WRITEBACK_BYTES) >>
>> +		     PAGE_SHIFT);
>>
>>  	return nr_pages <= limit;
>>  }
>
> I still don't think this is correct. It currently achieves the same
> behavior as before the patch but once you start accounting something else
> than pagecache pages into these counters, things will go wrong. This
> function is used to control distribution of pagecache pages among NUMA
> nodes and as such it should IMHO only account for pagecache pages...
>
>> @@ -3714,7 +3714,9 @@ static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
>>
>>  	/* If we can't clean pages, remove dirty pages from consideration */
>>  	if (!(node_reclaim_mode & RECLAIM_WRITE))
>> -		delta += node_page_state(pgdat, NR_FILE_DIRTY);
>> +		delta += node_page_state(pgdat, NR_FILE_DIRTY) +
>> +			(node_page_state(pgdat, NR_METADATA_DIRTY_BYTES) >>
>> +			 PAGE_SHIFT);
>>
>>  	/* Watch for any possible underflows due to delta */
>>  	if (unlikely(delta > nr_pagecache_reclaimable))
>
> The same comment as above applies here.
>

Ok that sounds reasonable, I'll make this change.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
