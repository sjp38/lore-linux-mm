Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32EB36B0274
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:35:46 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y6so38068995lff.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 06:35:46 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 15si2407815wmx.136.2016.09.22.06.35.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 06:35:43 -0700 (PDT)
Subject: Re: [PATCH 3/4] writeback: convert WB_WRITTEN/WB_DIRITED counters to
 bytes
References: <1474405068-27841-1-git-send-email-jbacik@fb.com>
 <1474405068-27841-4-git-send-email-jbacik@fb.com>
 <20160922113426.GM2834@quack2.suse.cz>
From: Josef Bacik <jbacik@fb.com>
Message-ID: <95a62ba8-1ecc-0dc6-0f63-5995e55eecc2@fb.com>
Date: Thu, 22 Sep 2016 09:35:31 -0400
MIME-Version: 1.0
In-Reply-To: <20160922113426.GM2834@quack2.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org, hannes@cmpxchg.org

On 09/22/2016 07:34 AM, Jan Kara wrote:
> On Tue 20-09-16 16:57:47, Josef Bacik wrote:
>> These are counters that constantly go up in order to do bandwidth calculations.
>> It isn't important what the units are in, as long as they are consistent between
>> the two of them, so convert them to count bytes written/dirtied, and allow the
>> metadata accounting stuff to change the counters as well.
>>
>> Signed-off-by: Josef Bacik <jbacik@fb.com>
>> ---
>>  fs/fuse/file.c                   |  4 ++--
>>  include/linux/backing-dev-defs.h |  4 ++--
>>  include/linux/backing-dev.h      |  2 +-
>>  mm/backing-dev.c                 |  8 ++++----
>>  mm/page-writeback.c              | 26 ++++++++++++++++----------
>>  5 files changed, 25 insertions(+), 19 deletions(-)
>>
>> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
>> index f394aff..3f5991e 100644
>> --- a/fs/fuse/file.c
>> +++ b/fs/fuse/file.c
>> @@ -1466,7 +1466,7 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
>>  	for (i = 0; i < req->num_pages; i++) {
>>  		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
>>  		dec_node_page_state(req->pages[i], NR_WRITEBACK_TEMP);
>> -		wb_writeout_inc(&bdi->wb);
>> +		wb_writeout_inc(&bdi->wb, PAGE_SIZE);
>
> Nitpick: Rename this to wb_writeout_add()? You have to change all the call
> sites anyway and it is more consistent with other naming.
>
>> @@ -2523,6 +2523,7 @@ void account_metadata_dirtied(struct page *page, struct backing_dev_info *bdi,
>>  	__mod_node_page_state(page_pgdat(page), NR_METADATA_DIRTY_BYTES,
>>  			      bytes);
>>  	__add_wb_stat(&bdi->wb, WB_METADATA_DIRTY_BYTES, bytes);
>> +	__add_wb_stat(&bdi->wb, WB_DIRTIED_BYTES, bytes);
>>  	current->nr_dirtied++;
>>  	task_io_account_write(bytes);
>>  	this_cpu_inc(bdp_ratelimits);
>> @@ -2593,6 +2594,7 @@ void account_metadata_end_writeback(struct page *page,
>>  	__add_wb_stat(&bdi->wb, WB_METADATA_WRITEBACK_BYTES, -bytes);
>>  	__mod_node_page_state(page_pgdat(page), NR_METADATA_WRITEBACK_BYTES,
>>  					 -bytes);
>> +	__add_wb_stat(&bdi->wb, WB_WRITTEN_BYTES, bytes);
>>  	local_irq_restore(flags);
>>  }
>>  EXPORT_SYMBOL(account_metadata_end_writeback);
>
> It seems it would make sense to move this patch to be second in the
> series so that above two functions could do the right thing from the
> beginning.
>

Yup that's fair, I'll move this around and rename wb_writeout_inc.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
