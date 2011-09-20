Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 308E09000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 10:09:59 -0400 (EDT)
Message-ID: <4E789EA2.8070709@redhat.com>
Date: Tue, 20 Sep 2011 10:09:38 -0400
From: Josef Bacik <josef@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 4/4] Btrfs: pass __GFP_WRITE for buffered write page allocations
References: <1316526315-16801-1-git-send-email-jweiner@redhat.com> <1316526315-16801-5-git-send-email-jweiner@redhat.com> <20110920135631.GB16338@redhat.com>
In-Reply-To: <20110920135631.GB16338@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 09/20/2011 09:56 AM, Johannes Weiner wrote:
> On Tue, Sep 20, 2011 at 03:45:15PM +0200, Johannes Weiner wrote:
>> Tell the page allocator that pages allocated for a buffered write are
>> expected to become dirty soon.
>>
>> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
>> ---
>>  fs/btrfs/file.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
>> index e7872e4..ea1b892 100644
>> --- a/fs/btrfs/file.c
>> +++ b/fs/btrfs/file.c
>> @@ -1084,7 +1084,7 @@ static noinline int prepare_pages(struct btrfs_root *root, struct file *file,
>>  again:
>>  	for (i = 0; i < num_pages; i++) {
>>  		pages[i] = find_or_create_page(inode->i_mapping, index + i,
>> -					       GFP_NOFS);
>> +					       GFP_NOFS | __GFP_WRITE);
> 
> Btw and unrelated to this particular series, I think this should use
> grab_cache_page_write_begin() in the first place.
> 
> Most grab_cache_page calls were replaced recently (a94733d "Btrfs: use
> find_or_create_page instead of grab_cache_page") to be able to pass
> GFP_NOFS, but the pages are now also no longer __GFP_HIGHMEM and
> __GFP_MOVABLE, which irks both x86_32 and memory hotplug.
> 
> It might be better to change grab_cache_page instead to take a flags
> argument that allows passing AOP_FLAG_NOFS and revert the sites back
> to this helper?

So I can do

pages[i] = grab_cache_page_write_begin(inode->i_mapping, index + i,
				       AOP_FLAG_NOFS);

right?  All we need is nofs, so I can just go through and change
everybody to that.  I'd rather not have to go through and change
grab_cache_page() to take a flags argument and change all the callers, I
have a bad habit of screwing stuff like that up :).  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
