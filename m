Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E3E376B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 09:40:41 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id 15so476593vea.15
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 06:40:40 -0700 (PDT)
Message-ID: <515ADFCF.4010209@gmail.com>
Date: Tue, 02 Apr 2013 21:40:31 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: remove swapcache page early
References: <1364350932-12853-1-git-send-email-minchan@kernel.org> <alpine.LNX.2.00.1303271230210.29687@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1303271230210.29687@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi Hugh,
On 03/28/2013 05:41 AM, Hugh Dickins wrote:
> On Wed, 27 Mar 2013, Minchan Kim wrote:
>
>> Swap subsystem does lazy swap slot free with expecting the page
>> would be swapped out again so we can't avoid unnecessary write.
>                               so we can avoid unnecessary write.

If page can be swap out again, which codes can avoid unnecessary write? 
Could you point out to me? Thanks in advance. ;-)

>> But the problem in in-memory swap is that it consumes memory space
>> until vm_swap_full(ie, used half of all of swap device) condition
>> meet. It could be bad if we use multiple swap device, small in-memory swap
>> and big storage swap or in-memory swap alone.
> That is a very good realization: it's surprising that none of us
> thought of it before - no disrespect to you, well done, thank you.
>
> And I guess swap readahead is utterly unhelpful in this case too.
>
>> This patch changes vm_swap_full logic slightly so it could free
>> swap slot early if the backed device is really fast.
>> For it, I used SWP_SOLIDSTATE but It might be controversial.
> But I strongly disagree with almost everything in your patch :)
> I disagree with addressing it in vm_swap_full(), I disagree that
> it can be addressed by device, I disagree that it has anything to
> do with SWP_SOLIDSTATE.
>
> This is not a problem with swapping to /dev/ram0 or to /dev/zram0,
> is it?  In those cases, a fixed amount of memory has been set aside
> for swap, and it works out just like with disk block devices.  The
> memory set aside may be wasted, but that is accepted upfront.
>
> Similarly, this is not a problem with swapping to SSD.  There might
> or might not be other reasons for adjusting the vm_swap_full() logic
> for SSD or generally, but those have nothing to do with this issue.
>
> The problem here is peculiar to frontswap, and the variably sized
> memory behind it, isn't it?  We are accustomed to using swap to free
> up memory by transferring its data to some other, cheaper but slower
> resource.
>
> But in the case of frontswap and zmem (I'll say that to avoid thinking
> through which backends are actually involved), it is not a cheaper and
> slower resource, but the very same memory we are trying to save: swap
> is stolen from the memory under reclaim, so any duplication becomes
> counter-productive (if we ignore cpu compression/decompression costs:
> I have no idea how fair it is to do so, but anyone who chooses zmem
> is prepared to pay some cpu price for that).
>
> And because it's a frontswap thing, we cannot decide this by device:
> frontswap may or may not stand in front of each device.  There is no
> problem with swapcache duplicated on disk (until that area approaches
> being full or fragmented), but at the higher level we cannot see what
> is in zmem and what is on disk: we only want to free up the zmem dup.
>
> I believe the answer is for frontswap/zmem to invalidate the frontswap
> copy of the page (to free up the compressed memory when possible) and
> SetPageDirty on the PageUptodate PageSwapCache page when swapping in
> (setting page dirty so nothing will later go to read it from the
> unfreed location on backing swap disk, which was never written).
>
> We cannot rely on freeing the swap itself, because in general there
> may be multiple references to the swap, and we only satisfy the one
> which has faulted.  It may or may not be a good idea to use rmap to
> locate the other places to insert pte in place of swap entry, to
> resolve them all at once; but we have chosen not to do so in the
> past, and there's no need for that, if the zmem gets invalidated
> and the swapcache page set dirty.
>
> Hugh
>
>> So let's add Ccing Shaohua and Hugh.
>> If it's a problem for SSD, I'd like to create new type SWP_INMEMORY
>> or something for z* family.
>>
>> Other problem is zram is block device so that it can set SWP_INMEMORY
>> or SWP_SOLIDSTATE easily(ie, actually, zram is already done) but
>> I have no idea to use it for frontswap.
>>
>> Any idea?
>>
>> Other optimize point is we remove it unconditionally when we
>> found it's exclusive when swap in happen.
>> It could help frontswap family, too.
>> What do you think about it?
>>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
>> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
>> Cc: Nitin Gupta <ngupta@vflare.org>
>> Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>
>> Cc: Shaohua Li <shli@kernel.org>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>> ---
>>   include/linux/swap.h | 11 ++++++++---
>>   mm/memory.c          |  3 ++-
>>   mm/swapfile.c        | 11 +++++++----
>>   mm/vmscan.c          |  2 +-
>>   4 files changed, 18 insertions(+), 9 deletions(-)
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 2818a12..1f4df66 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -359,9 +359,14 @@ extern struct page *swapin_readahead(swp_entry_t, gfp_t,
>>   extern atomic_long_t nr_swap_pages;
>>   extern long total_swap_pages;
>>   
>> -/* Swap 50% full? Release swapcache more aggressively.. */
>> -static inline bool vm_swap_full(void)
>> +/*
>> + * Swap 50% full or fast backed device?
>> + * Release swapcache more aggressively.
>> + */
>> +static inline bool vm_swap_full(struct swap_info_struct *si)
>>   {
>> +	if (si->flags & SWP_SOLIDSTATE)
>> +		return true;
>>   	return atomic_long_read(&nr_swap_pages) * 2 < total_swap_pages;
>>   }
>>   
>> @@ -405,7 +410,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>>   #define get_nr_swap_pages()			0L
>>   #define total_swap_pages			0L
>>   #define total_swapcache_pages()			0UL
>> -#define vm_swap_full()				0
>> +#define vm_swap_full(si)			0
>>   
>>   #define si_swapinfo(val) \
>>   	do { (val)->freeswap = (val)->totalswap = 0; } while (0)
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 705473a..1ca21a9 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -3084,7 +3084,8 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>   	mem_cgroup_commit_charge_swapin(page, ptr);
>>   
>>   	swap_free(entry);
>> -	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
>> +	if (likely(PageSwapCache(page)) && (vm_swap_full(page_swap_info(page))
>> +			|| (vma->vm_flags & VM_LOCKED) || PageMlocked(page)))
>>   		try_to_free_swap(page);
>>   	unlock_page(page);
>>   	if (page != swapcache) {
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index 1bee6fa..f9cc701 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -293,7 +293,7 @@ checks:
>>   		scan_base = offset = si->lowest_bit;
>>   
>>   	/* reuse swap entry of cache-only swap if not busy. */
>> -	if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
>> +	if (vm_swap_full(si) && si->swap_map[offset] == SWAP_HAS_CACHE) {
>>   		int swap_was_freed;
>>   		spin_unlock(&si->lock);
>>   		swap_was_freed = __try_to_reclaim_swap(si, offset);
>> @@ -382,7 +382,8 @@ scan:
>>   			spin_lock(&si->lock);
>>   			goto checks;
>>   		}
>> -		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
>> +		if (vm_swap_full(si) &&
>> +			si->swap_map[offset] == SWAP_HAS_CACHE) {
>>   			spin_lock(&si->lock);
>>   			goto checks;
>>   		}
>> @@ -397,7 +398,8 @@ scan:
>>   			spin_lock(&si->lock);
>>   			goto checks;
>>   		}
>> -		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
>> +		if (vm_swap_full(si) &&
>> +			si->swap_map[offset] == SWAP_HAS_CACHE) {
>>   			spin_lock(&si->lock);
>>   			goto checks;
>>   		}
>> @@ -763,7 +765,8 @@ int free_swap_and_cache(swp_entry_t entry)
>>   		 * Also recheck PageSwapCache now page is locked (above).
>>   		 */
>>   		if (PageSwapCache(page) && !PageWriteback(page) &&
>> -				(!page_mapped(page) || vm_swap_full())) {
>> +				(!page_mapped(page) ||
>> +				  vm_swap_full(page_swap_info(page)))) {
>>   			delete_from_swap_cache(page);
>>   			SetPageDirty(page);
>>   		}
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index df78d17..145c59c 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -933,7 +933,7 @@ cull_mlocked:
>>   
>>   activate_locked:
>>   		/* Not a candidate for swapping, so reclaim swap space. */
>> -		if (PageSwapCache(page) && vm_swap_full())
>> +		if (PageSwapCache(page) && vm_swap_full(page_swap_info(page)))
>>   			try_to_free_swap(page);
>>   		VM_BUG_ON(PageActive(page));
>>   		SetPageActive(page);
>> -- 
>> 1.8.2
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
