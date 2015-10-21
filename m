Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 291FD82F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:39:23 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so78383688wic.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:39:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o1si12654740wia.25.2015.10.21.07.39.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Oct 2015 07:39:21 -0700 (PDT)
Subject: Re: [PATCH v4 2/4] mm, proc: account for shmem swap in
 /proc/pid/smaps
References: <1443792951-13944-1-git-send-email-vbabka@suse.cz>
 <1443792951-13944-3-git-send-email-vbabka@suse.cz>
 <alpine.LSU.2.11.1510041806040.15067@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5627A397.6090305@suse.cz>
Date: Wed, 21 Oct 2015 16:39:19 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1510041806040.15067@eggly.anvils>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On 10/05/2015 05:01 AM, Hugh Dickins wrote:
> On Fri, 2 Oct 2015, Vlastimil Babka wrote:
>
>> Currently, /proc/pid/smaps will always show "Swap: 0 kB" for shmem-backed
>> mappings, even if the mapped portion does contain pages that were swapped out.
>> This is because unlike private anonymous mappings, shmem does not change pte
>> to swap entry, but pte_none when swapping the page out. In the smaps page
>> walk, such page thus looks like it was never faulted in.
>>
>> This patch changes smaps_pte_entry() to determine the swap status for such
>> pte_none entries for shmem mappings, similarly to how mincore_page() does it.
>> Swapped out pages are thus accounted for.
>>
>> The accounting is arguably still not as precise as for private anonymous
>> mappings, since now we will count also pages that the process in question never
>> accessed, but only another process populated them and then let them become
>> swapped out. I believe it is still less confusing and subtle than not showing
>> any swap usage by shmem mappings at all. Also, swapped out pages only becomee a
>> performance issue for future accesses, and we cannot predict those for neither
>> kind of mapping.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Acked-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>
> Neither Ack nor Nack from me.
>
> I don't want to stand in the way of this patch, if you and others
> believe that it will help to diagnose problems in the field better
> than what's shown at present; but to me it looks dangerously like
> replacing no information by wrong information.
>
> As you acknowledge in the commit message, if a file of 100 pages
> were copied to tmpfs, and 100 tasks map its full extent, but they
> all mess around with the first 50 pages and take no interest in
> the last 50, then it's quite likely that that last 50 will get
> swapped out; then with your patch, 100 tasks are each shown as
> using 50 pages of swap, when none of them are actually using any.

Yeah, but isn't it the same with private memory which was swapped out at 
some point and we don't know if it will be touched or not? The
difference is in private case we know the process touched it at least
once, but that can also mean nothing for the future (or maybe it just
mmapped with MAP_POPULATE and didn't care about half of it).

That's basically what I was trying to say in the changelog. I interpret
the Swap: value as the amount of swap-in potential, if the process was
going to access it, which is what the particular customer also expects 
(see below). In that case showing zero is IMHO wrong and inconsistent 
with the anonymous private mappings.

> It is rather as if we didn't bother to record Rss, and just put
> Size in there instead: you are (for understandable reasons) treating
> the virtual address space as if every page of it had been touched.
>
> But I accept that there may well be a class of processes and problems
> which would be better served by this fiction than the present: I expect
> you have much more experience of helping out in such situations than I.

Well, the customers driving this change would in the best case want to
see the shmem swap accounted continuously and e.g. see it immediately in 
the top output. Fixing (IMHO) the smaps output is the next best thing. 
The use case here is a application that really doesn't like page faults, 
and has background thread that checks and prefaults such areas when they 
are expected to be used soon. So they would like to identify these areas.

> And perhaps you do balance it nicely by going to the opposite extreme
> with SwapPss 0 for all (again for the eminently understandable reason,
> that it would be a whole lot more new code to work out the right number).
> Altogther, you're saying everyone's using more swap than they probably
> are, but that's okay because it's infinitely shared.
>
> I am not at all angling for you or anyone to make the changes necessary
> to make those numbers accurate.  I think there's a point at which we
> stop cluttering up the core kernel code, just for the sake of
> maintaining numbers for a /proc file someone thought was a good idea
> at the time.  But I am hoping that if this patch goes in, you will take
> responsibility for batting away all the complaints that it doesn't work
> as this or that person expected, rather than a long stream of patches
> to refine it.

I don't plan to fix SwapPss, so I can drop the "currently".

> I think the root problem is that we're trying to use /proc/<pid>/smaps
> for something that's independent of <pid> and its maps: a shmem object.
> Would we be better served by a tmpfs-ish filesystem mounted somewhere,
> which gives names to all the objects on the internal mount of tmpfs
> (SysV SHM, memfds etc); and some fincore-ish syscalls which could be
> used to interrogate how much swap any tmpfs file is using in any range?
> (I am not volunteering to write this, not in the foreseeable future.)
>
> I have no idea of the security implications of naming the hidden, it
> may be a non-starter.  And my guess is, it would be nice if it already
> existed, but you need a solution today to some problems that have been
> wasting your time; and grafting it into smaps looks to be good enough.
>
> Some comments on your implementation below.
>
>> ---
>>   Documentation/filesystems/proc.txt |  6 ++--
>>   fs/proc/task_mmu.c                 | 48 ++++++++++++++++++++++++++++++
>>   include/linux/shmem_fs.h           |  6 ++++
>>   mm/shmem.c                         | 61 ++++++++++++++++++++++++++++++++++++++
>>   4 files changed, 119 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
>> index 7ef50cb..82d3657 100644
>> --- a/Documentation/filesystems/proc.txt
>> +++ b/Documentation/filesystems/proc.txt
>> @@ -457,8 +457,10 @@ accessed.
>>   a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
>>   and a page is modified, the file page is replaced by a private anonymous copy.
>>   "Swap" shows how much would-be-anonymous memory is also used, but out on
>> -swap.
>> -"SwapPss" shows proportional swap share of this mapping.
>> +swap. For shmem mappings, "Swap" shows how much of the mapped portion of the
>> +underlying shmem object is on swap.
>
> And for private mappings of tmpfs files?  I expected it to show an
> inderminate mixture of the two, but it looks like you treat the private
> mapping just like a shared one, and take no notice of the COWed pages
> out on swap which would have been reported before.  Oh, no, I think
> I misread, and you add the two together?  I agree that's the easiest
> thing to do, and therefore perhaps the best; but it doesn't fill me
> with conviction that it's the right thing to do.

Thanks for pointing this out, I totally missed this possibility! Well
the current patch is certainly not the right thing to do, as it can
over-account. The most correct solution would have to be implemented 
into the page walk and only check into shmem radix tree for individual 
pages that were not COWed. Michal Hocko suggested I try that, and 
although it does add some overhead (the complexity is n*log(n) AFAICT), 
it's not that bad from preliminary checks. Another advantage is that no 
new shmem code is needed, as we can use the generic find_get_entry(). 
Unless we want to really limit the extra complexity only to the special 
private mapping case with non-zero swap usage of the shmem object etc... 
I'll repost the series with that approach.

Other non-perfect solutions that come to mind:

1) For private mappings, count only the swapents. "Swap:" is no longer
showing full swap-in potential though.
2) For private mappings, do not count swapents. Ditto.
3) Provide two separate counters. The user won't know how much they
overlap, though.

 From these I would be inclined towards 3) as being more universal, 
although then it's no longer a simple "we're fixing a Swap: 0 value 
which is wrong", but closer to original Jerome's versions, which IIRC 
introduced several shmem-specific counters.

Well at least now I do understand why you don't particularly like this 
approach...

>> +"SwapPss" shows proportional swap share of this mapping. Shmem mappings will
>> +currently show 0 here.
>
> Yes, my heart sank when I remembered SwapPss, and I wondered what you were
> going to do with that.  I was imagining that the Swap number would go into
> SwapPss, but no, I prefer your choice to show 0 there (but depressed to
> see the word "currently", which hints at grand schemes to plumb in another
> radix_tree of swap counts, or more rmap_walks to calculate, or something).
>
>>   "AnonHugePages" shows the ammount of memory backed by transparent hugepage.
>>   "Shared_Hugetlb" and "Private_Hugetlb" show the ammounts of memory backed by
>>   hugetlbfs page which is *not* counted in "RSS" or "PSS" field for historical
>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> index 04999b2..103457c 100644
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -14,6 +14,7 @@
>>   #include <linux/swapops.h>
>>   #include <linux/mmu_notifier.h>
>>   #include <linux/page_idle.h>
>> +#include <linux/shmem_fs.h>
>>
>>   #include <asm/elf.h>
>>   #include <asm/uaccess.h>
>> @@ -657,6 +658,51 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
>>   }
>>   #endif /* HUGETLB_PAGE */
>>
>> +#ifdef CONFIG_SHMEM
>
> Correct.
>
>> +static unsigned long smaps_shmem_swap(struct vm_area_struct *vma)
>> +{
>> +	struct inode *inode;
>> +	unsigned long swapped;
>> +	pgoff_t start, end;
>> +
>> +	if (!vma->vm_file)
>> +		return 0;
>> +
>> +	inode = file_inode(vma->vm_file);
>> +
>> +	if (!shmem_mapping(inode->i_mapping))
>> +		return 0;
>
> Someone somewhere may ask for an ops method,
> but that someone will certainly not be me.
>
>> +
>> +	/*
>> +	 * The easier cases are when the shmem object has nothing in swap, or
>> +	 * we have the whole object mapped. Then we can simply use the stats
>> +	 * that are already tracked by shmem.
>> +	 */
>> +	swapped = shmem_swap_usage(inode);
>> +
>> +	if (swapped == 0)
>> +		return 0;
>
> You are absolutely right to go for that optimization, but please
> please do it all inside one call to shmem.c: all you need is one
> shmem_swap_usage(inode, start, end)
> or
> shmem_swap_usage(vma).

OK.

>> +
>> +	if (vma->vm_end - vma->vm_start >= inode->i_size)
>
> That must be wrong.  It's probably right for all normal processes,
> and you may not be interested in the rest; but anyone can set up
> a mapping from end of file onwards, which won't intersect with the
> swap at all.  Just a little more thought on that test would be good.

Uh right, thanks for pointing out.

>> +		return swapped;
>> +
>> +	/*
>> +	 * Here we have to inspect individual pages in our mapped range to
>> +	 * determine how much of them are swapped out. Thanks to RCU, we don't
>> +	 * need i_mutex to protect against truncating or hole punching.
>> +	 */
>> +	start = linear_page_index(vma, vma->vm_start);
>> +	end = linear_page_index(vma, vma->vm_end);
>> +
>> +	return shmem_partial_swap_usage(inode->i_mapping, start, end);
>> +}
>> +#else
>> +static unsigned long smaps_shmem_swap(struct vm_area_struct *vma)
>> +{
>> +	return 0;
>> +}
>> +#endif
>> +
>>   static int show_smap(struct seq_file *m, void *v, int is_pid)
>>   {
>>   	struct vm_area_struct *vma = v;
>> @@ -674,6 +720,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>>   	/* mmap_sem is held in m_start */
>>   	walk_page_vma(vma, &smaps_walk);
>>
>> +	mss.swap += smaps_shmem_swap(vma);
>> +
>
> So, I think here you add the private swap to the object swap.

Yes, through ignorance.

>>   	show_map_vma(m, vma, is_pid);
>>
>>   	seq_printf(m,
>> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
>> index 50777b5..12519e4 100644
>> --- a/include/linux/shmem_fs.h
>> +++ b/include/linux/shmem_fs.h
>> @@ -60,6 +60,12 @@ extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
>>   extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
>>   extern int shmem_unuse(swp_entry_t entry, struct page *page);
>>
>> +#ifdef CONFIG_SWAP
>
> As Andrew said, better just drop the #ifdef here.
>
>> +extern unsigned long shmem_swap_usage(struct inode *inode);
>> +extern unsigned long shmem_partial_swap_usage(struct address_space *mapping,
>> +						pgoff_t start, pgoff_t end);
>> +#endif
>> +
>>   static inline struct page *shmem_read_mapping_page(
>>   				struct address_space *mapping, pgoff_t index)
>>   {
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index b543cc7..b0e9e30 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -360,6 +360,67 @@ static int shmem_free_swap(struct address_space *mapping,
>>   }
>>
>>   /*
>> + * Determine (in bytes) how much of the whole shmem object is swapped out.
>> + */
>> +unsigned long shmem_swap_usage(struct inode *inode)
>> +{
>> +	struct shmem_inode_info *info = SHMEM_I(inode);
>> +	unsigned long swapped;
>> +
>> +	/* Mostly an overkill, but it's not atomic64_t */
>> +	spin_lock(&info->lock);
>
> Entirely overkill, what's atomic64_t got to do with it?
> info->swapped is an unsigned long, 32-bit on 32-bit, 64-bit on 64-bit,
> there are no atomicity issues.  READ_ONCE if you like, but I can't even
> see where it would read twice, or what bad consequence could result.

Right, I was wrongly thinking that the counter would be 64bit also on
32bit machines and thus not atomically readable...

>> +	swapped = info->swapped;
>> +	spin_unlock(&info->lock);
>> +
>> +	return swapped << PAGE_SHIFT;
>> +}
>> +
>> +/*
>> + * Determine (in bytes) how many pages within the given range are swapped out.
>> + *
>> + * Can be called without i_mutex or mapping->tree_lock thanks to RCU.
>
> Correct.
>
>> + */
>> +unsigned long shmem_partial_swap_usage(struct address_space *mapping,
>> +						pgoff_t start, pgoff_t end)
>> +{
>> +	struct radix_tree_iter iter;
>> +	void **slot;
>> +	struct page *page;
>> +	unsigned long swapped = 0;
>> +
>> +	rcu_read_lock();
>> +
>> +restart:
>> +	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
>> +		if (iter.index >= end)
>> +			break;
>> +
>> +		page = radix_tree_deref_slot(slot);
>> +
>> +		/*
>> +		 * This should only be possible to happen at index 0, so we
>> +		 * don't need to reset the counter, nor do we risk infinite
>> +		 * restarts.
>> +		 */
>> +		if (radix_tree_deref_retry(page))
>> +			goto restart;
>> +
>> +		if (radix_tree_exceptional_entry(page))
>> +			swapped++;
>> +
>> +		if (need_resched()) {
>> +			cond_resched_rcu();
>> +			start = iter.index + 1;
>> +			goto restart;
>> +		}
>> +	}
>> +
>> +	rcu_read_unlock();
>> +
>> +	return swapped << PAGE_SHIFT;
>> +}
>
> This is what you most wanted me to look at, but it looks perfect to me
> (aside from my wanting one call into shmem.c instead of two).

Thanks!

> Hugh
>
>> +
>> +/*
>>    * SysV IPC SHM_UNLOCK restore Unevictable pages to their evictable lists.
>>    */
>>   void shmem_unlock_mapping(struct address_space *mapping)
>> --
>> 2.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
