Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B89EC6B0002
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 04:35:04 -0400 (EDT)
Message-ID: <517A3B98.807@parallels.com>
Date: Fri, 26 Apr 2013 12:32:24 +0400
From: "Maxim V. Patlasov" <mpatlasov@parallels.com>
MIME-Version: 1.0
Subject: Re: [fuse-devel] [PATCH 14/14] mm: Account for WRITEBACK_TEMP in
 balance_dirty_pages
References: <20130401103749.19027.89833.stgit@maximpc.sw.ru> <20130401104250.19027.27795.stgit@maximpc.sw.ru> <51793DE6.3000503@parallels.com> <CAJfpegv1zc4oeE=YXrQd0jmzVXB8jjvXkz-_4Nv_ELcvfsa74Q@mail.gmail.com> <517956ED.7060102@parallels.com> <20130425204331.GB16238@tucsk.piliscsaba.szeredi.hu>
In-Reply-To: <20130425204331.GB16238@tucsk.piliscsaba.szeredi.hu>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Kirill Korotaev <dev@parallels.com>, Pavel Emelianov <xemul@parallels.com>, "fuse-devel@lists.sourceforge.net" <fuse-devel@lists.sourceforge.net>, Kernel Mailing List <linux-kernel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux-Fsdevel <linux-fsdevel@vger.kernel.org>, devel@openvz.org, Andrew Morton <akpm@linux-foundation.org>, fengguang.wu@intel.com, mgorman@suse.de, riel@redhat.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.orgAndrew Morton <akpm@linux-foundation.org>

Hi Miklos,

04/26/2013 12:43 AM, Miklos Szeredi D?D,N?DuN?:
> On Thu, Apr 25, 2013 at 08:16:45PM +0400, Maxim V. Patlasov wrote:
>> As Mel Gorman pointed out, fuse daemon diving into
>> balance_dirty_pages should not kick flusher judging on
>> NR_WRITEBACK_TEMP. Essentially, all we need in balance_dirty_pages
>> is:
>>
>>      if (I'm not fuse daemon)
>>          nr_dirty += global_page_state(NR_WRITEBACK_TEMP);
> I strongly dislike the above.

The above was well-discussed on mm track of LSF/MM. Everybody seemed to 
agree with solution above. I'm cc-ing some guys who were involved in 
discussion, mm mailing list and Andrew as well. For those who don't 
follow from the beginning here is an excerpt:

> 04/25/2013 07:49 PM, Miklos Szeredi D?D,N?DuN?:
>> On Thu, Apr 25, 2013 at 4:29 PM, Maxim V. Patlasov
>> <mpatlasov@parallels.com>  wrote:
>>>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>>>> index 0713bfb..c47bcd4 100644
>>>> --- a/mm/page-writeback.c
>>>> +++ b/mm/page-writeback.c
>>>> @@ -1235,7 +1235,8 @@ static void balance_dirty_pages(struct address_space
>>>> *mapping,
>>>>                    */
>>>>                   nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
>>>>
>>>> global_page_state(NR_UNSTABLE_NFS);
>>>> -               nr_dirty = nr_reclaimable +
>>>> global_page_state(NR_WRITEBACK);
>>>> +               nr_dirty = nr_reclaimable +
>>>> global_page_state(NR_WRITEBACK) +
>>>> +                       global_page_state(NR_WRITEBACK_TEMP);
>>>>                   global_dirty_limits(&background_thresh, &dirty_thresh);
>>> Please drop this patch. As we discussed in LSF/MM, the fix above is correct,
>>> but it's not enough: we also need to ensure disregard of NR_WRITEBACK_TEMP
>>> when balance_dirty_pages() is called from fuse daemon. I'll send a separate
>>> patch-set soon.
>> Please elaborate.  From a technical perspective "fuse daemon" is very
>> hard to define, so anything that relies on whether something came from
>> the fuse daemon or not is conceptually broken.
> As Mel Gorman pointed out, fuse daemon diving into balance_dirty_pages
> should not kick flusher judging on NR_WRITEBACK_TEMP. Essentially, all
> we need in balance_dirty_pages is:
>
>       if (I'm not fuse daemon)
>           nr_dirty += global_page_state(NR_WRITEBACK_TEMP);
>
> The way how to identify fuse daemon was not thoroughly scrutinized
> during LSF/MM. Firstly, I thought it would be enough to set a
> per-process flag handling fuse device open. But now I understand that
> fuse daemon may be quite a complicated multi-threaded multi-process
> construction. I'm going to add new FUSE_NOTIFY to allow fuse daemon
> decide when it works on behalf of draining writeout-s. Having in mind
> that fuse-lib is multi-threaded, I'm also going to inherit the flag on
> copy_process(). Does it make sense for you?
>
> Also, another patch will put this ad-hoc FUSE_NOTIFY under fusermount
> control. This will prevent malicious unprivileged fuse mounts from
> setting the flag for malicious purposes.

And returning back to the last Miklos' mail...

>
> What about something like the following untested patch?
>
> The idea is that fuse filesystems should not go over the bdi limit even if the
> global limit hasn't been reached.

This might work, but kicking flusher every time someone write to fuse 
mount and dives into balance_dirty_pages looks fishy. However, setting 
ad-hoc inode flag for files on fuse makes much more sense than my 
approach of identifying fuse daemons (a feeble hope that userspace 
daemons would notify in-kernel fuse saying "I'm fuse daemon, please 
disregard NR_WRITEBACK_TEMP for me"). Let's combine our suggestions: 
mark fuse inodes with AS_FUSE_WRITEBACK flag and convert what you 
strongly dislike above to:

if (test_bit(AS_FUSE_WRITEBACK, &mapping->flags))
nr_dirty += global_page_state(NR_WRITEBACK_TEMP);

Thanks,
Maxim

>
> Thanks,
> Miklos
>
> diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
> index 137185c..195ee45 100644
> --- a/fs/fuse/inode.c
> +++ b/fs/fuse/inode.c
> @@ -291,6 +291,7 @@ struct inode *fuse_iget(struct super_block *sb, u64 nodeid,
>   		inode->i_flags |= S_NOATIME|S_NOCMTIME;
>   		inode->i_generation = generation;
>   		inode->i_data.backing_dev_info = &fc->bdi;
> +		set_bit(AS_STRICTLIMIT, &inode->i_data.flags);
>   		fuse_init_inode(inode, attr);
>   		unlock_new_inode(inode);
>   	} else if ((inode->i_mode ^ attr->mode) & S_IFMT) {
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 0e38e13..97f6a0c 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -25,6 +25,7 @@ enum mapping_flags {
>   	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
>   	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
>   	AS_BALLOON_MAP  = __GFP_BITS_SHIFT + 4, /* balloon page special map */
> +	AS_STRICTLIMIT	= __GFP_BITS_SHIFT + 5, /* strict dirty limit */
>   };
>   
>   static inline void mapping_set_error(struct address_space *mapping, int error)
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index efe6814..91a9e6e 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1226,6 +1226,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>   	unsigned long dirty_ratelimit;
>   	unsigned long pos_ratio;
>   	struct backing_dev_info *bdi = mapping->backing_dev_info;
> +	int strictlimit = test_bit(AS_STRICTLIMIT, &mapping->flags);
>   	unsigned long start_time = jiffies;
>   
>   	for (;;) {
> @@ -1250,7 +1251,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>   		 */
>   		freerun = dirty_freerun_ceiling(dirty_thresh,
>   						background_thresh);
> -		if (nr_dirty <= freerun) {
> +		if (nr_dirty <= freerun && !strictlimit) {
>   			current->dirty_paused_when = now;
>   			current->nr_dirtied = 0;
>   			current->nr_dirtied_pause =
> @@ -1297,7 +1298,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>   		}
>   
>   		dirty_exceeded = (bdi_dirty > bdi_thresh) &&
> -				  (nr_dirty > dirty_thresh);
> +				  ((nr_dirty > dirty_thresh) || strictlimit);
>   		if (dirty_exceeded && !bdi->dirty_exceeded)
>   			bdi->dirty_exceeded = 1;
>   
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
