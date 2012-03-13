Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id DDB9B6B004A
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 22:48:27 -0400 (EDT)
Received: by dadv6 with SMTP id v6so152627dad.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 19:48:27 -0700 (PDT)
Date: Tue, 13 Mar 2012 11:48:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Fwd: Control page reclaim granularity
Message-ID: <20120313024818.GA7125@barrios>
References: <4F5D95AF.1020108@openvz.org>
 <20120312081413.GA10923@gmail.com>
 <20120312134226.GA5120@barrios>
 <4F5E05AD.20200@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F5E05AD.20200@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>

On Mon, Mar 12, 2012 at 06:18:21PM +0400, Konstantin Khlebnikov wrote:
> Minchan Kim wrote:
> >On Mon, Mar 12, 2012 at 04:14:14PM +0800, Zheng Liu wrote:
> >>On 03/12/2012 02:20 PM, Konstantin Khlebnikov wrote:
> >>>Minchan Kim wrote:
> >>>>On Mon, Mar 12, 2012 at 10:06:09AM +0800, Zheng Liu wrote:
> >>>>>On Mon, Mar 12, 2012 at 09:29:34AM +0900, Minchan Kim wrote:
> >>>>>>I forgot to Ccing you.
> >>>>>>Sorry.
> >>>>>>
> >>>>>>---------- Forwarded message ----------
> >>>>>>From: Minchan Kim<minchan@kernel.org>
> >>>>>>Date: Mon, Mar 12, 2012 at 9:28 AM
> >>>>>>Subject: Re: Control page reclaim granularity
> >>>>>>To: Minchan Kim<minchan@kernel.org>, linux-mm<linux-mm@kvack.org>,
> >>>>>>linux-kernel<linux-kernel@vger.kernel.org>, Konstantin Khlebnikov<
> >>>>>>khlebnikov@openvz.org>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com
> >>>>>>
> >>>>>>
> >>>>>>On Fri, Mar 09, 2012 at 12:54:03AM +0800, Zheng Liu wrote:
> >>>>>>>Hi Minchan,
> >>>>>>>
> >>>>>>>Sorry, I forgot to say that I don't subscribe linux-mm and
> >>>>>>>linux-kernel
> >>>>>>>mailing list.  So please Cc me.
> >>>>>>>
> >>>>>>>IMHO, maybe we should re-think about how does user use mmap(2).  I
> >>>>>>>describe the cases I known in our product system.  They can be
> >>>>>>>categorized into two cases.  One is mmaped all data files into memory
> >>>>>>>and sometime it uses write(2) to append some data, and another uses
> >>>>>>>mmap(2)/munmap(2) and read(2)/write(2) to manipulate the files.  In
> >>>>>>>the
> >>>>>>>second case,  the application wants to keep mmaped page into memory
> >>>>>>>and
> >>>>>>>let file pages to be reclaimed firstly.  So, IMO, when application
> >>>>>>>uses
> >>>>>>>mmap(2) to manipulate files, it is possible to imply that it wants
> >>>>>>>keep
> >>>>>>>these mmaped pages into memory and do not be reclaimed.  At least
> >>>>>>>these
> >>>>>>>pages do not be reclaimed early than file pages.  I think that
> >>>>>>>maybe we
> >>>>>>>can recover that routine and provide a sysctl parameter to let the
> >>>>>>>user
> >>>>>>>to set this ratio between mmaped pages and file pages.
> >>>>>>
> >>>>>>I am not convinced why we should handle mapped page specially.
> >>>>>>Sometimem, someone may use mmap by reducing buffer copy compared to
> >>>>>>read
> >>>>>>system call.
> >>>>>>So I think we can't make sure mmaped pages are always win.
> >>>>>>
> >>>>>>My suggestion is that it would be better to declare by user explicitly.
> >>>>>>I think we can implement it by madvise and fadvise's WILLNEED option.
> >>>>>>Current implementation is just readahead if there isn't a page in
> >>>>>>memory
> >>>>>>but I think
> >>>>>>we can promote from inactive to active if there is already a page in
> >>>>>>memory.
> >>>>>>
> >>>>>>It's more clear and it couldn't be affected by kernel page reclaim
> >>>>>>algorithm change
> >>>>>>like this.
> >>>>>
> >>>>>Thank you for your advice.  But I still have question about this
> >>>>>solution.  If we improve the madvise(2) and fadvise(2)'s WILLNEED
> >>>>>option,  it will cause an inconsistently status for pages that be
> >>>>>manipulated by madvise(2) and/or fadvise(2).  For example, when I call
> >>>>>madvise with WILLNEED flag, some pages will be moved into active list if
> >>>>>they already have been in memory, and other pages will be read into
> >>>>>memory and be saved in inactive list if they don't be in memory.  Then
> >>>>>pages that are in inactive list are possible to be reclaim.  So from the
> >>>>>view of users, it is inconsistent because some pages are in memory and
> >>>>>some pages are reclaimed.  But actually the user hopes that all of pages
> >>>>>can be kept in memory.  IMHO, this inconsistency is weird and makes
> >>>>>users
> >>>>>puzzled.
> >>>>
> >>>>Now problem is that
> >>>>
> >>>>1. User want to keep pages which are used once in a while in memory.
> >>>>2. Kernel want to reclaim them because they are surely reclaim target
> >>>>     pages in point of view by LRU.
> >>>>
> >>>>The most desriable approach is that user should use mlock to guarantee
> >>>>them in memory. But mlock is too big overhead and user doesn't want to
> >>>>keep
> >>>>memory all pages all at once.(Ie, he want demand paging when he need
> >>>>the page)
> >>>>Right?
> >>>>
> >>>>madvise, it's a just hint for kernel and kernel doesn't need to make
> >>>>sure madvise's behavior.
> >>>>In point of view, such inconsistency might not be a big problem.
> >>>>
> >>>>Big problem I think now is that user should use madvise(WILLNEED)
> >>>>periodically because such
> >>>>activation happens once when user calls madvise. If user doesn't use
> >>>>page frequently after
> >>>>user calls it, it ends up moving into inactive list and even could be
> >>>>reclaimed.
> >>>>It's not good. :-(
> >>>>
> >>>>Okay. How about adding new VM_WORKINGSET?
> >>>>And reclaimer would give one more round trip in active/inactive list
> >>>>erwhen reclaim happens
> >>>>if the page is referenced.
> >>>>
> >>>>Sigh. We have no room for new VM_FLAG in 32 bit.
> >>>p
> >>>It would be nice to mark struct address_space with this flag and export
> >>>AS_UNEVICTABLE somehow.
> >>>Maybe we can reuse file-locking engine for managing these bits =)
> >>
> >>Make sense to me.  We can mark this flag in struct address_space and check
> >>it in page_refereneced_file().  If this flag is set, it will be cleard and
> >
> >Disadvantage is that we could set reclaim granularity as per-inode.
> >I want to set it as per-vma, not per-inode.
> 
> But with per-inode flag we can tune all files, not only memory-mapped.

I don't oppose per-inode setting but I believe we need file range or mmapped vma,
still. One file may have different characteristic part, something is working set
something is streaming part.

> See, attached patch. Currently I thinking about managing code,
> file-locking engine really fits perfectly =)

file-locking engine?
You consider fcntl as interface for it?
What do you mean?

> 
> >
> >>the function returns referenced>  1.  Then this page can be promoted into
> >>activate list.  But I prefer to set/clear this flag in madvise.
> >
> >Hmm, My idea is following as,
> >If we can set new VM flag into VMA or something, reclaimer can check it when shrink_[in]active_list
> >and he can prevent to deactivate/reclaim if he takes a look the page is in VMA which
> >are set by new VM flag and the page is referenced recently at least once.
> >It means it gives one more round trip in his list(ie, active/inactive list)
> >rather than activation so that the page would become less reclaimable.
> >
> >>
> >>PS, I have subscribed linux-mm mailing list. :-)
> >
> >Congratulations! :)
> >
> >>
> >>Regards,
> >>Zheng
> >
> >--
> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >the body to majordomo@kvack.org.  For more info on Linux MM,
> >see: http://www.linux-mm.org/ .
> >Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> >Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
> 

> mm: introduce mapping AS_WORKINGSET flag
> 
> From: Konstantin Khlebnikov <khlebnikov@openvz.org>
> 
> This patch introduces new flag AS_WORKINGSET in mapping->flags.
> If it set reclaimer will activates all pages for this inode after first usage.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> ---
>  include/linux/pagemap.h |   16 ++++++++++++++++
>  mm/vmscan.c             |   15 ++++++++++++---
>  2 files changed, 28 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index cfaaa69..c15fc17 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -24,6 +24,7 @@ enum mapping_flags {
>  	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
>  	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
>  	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
> +	AS_WORKINGSET	= __GFP_BITS_SHIFT + 4,	/* promote pages activation */
>  };
>  
>  static inline void mapping_set_error(struct address_space *mapping, int error)
> @@ -53,6 +54,21 @@ static inline int mapping_unevictable(struct address_space *mapping)
>  	return !!mapping;
>  }
>  
> +static inline void mapping_set_workingset(struct address_space *mapping)
> +{
> +	set_bit(AS_WORKINGSET, &mapping->flags);
> +}
> +
> +static inline void mapping_clear_workingset(struct address_space *mapping)
> +{
> +	clear_bit(AS_WORKINGSET, &mapping->flags);
> +}
> +
> +static inline int mapping_test_workingset(struct address_space *mapping)
> +{
> +	return mapping && test_bit(AS_WORKINGSET, &mapping->flags);
> +}
> +
>  static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
>  {
>  	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 57b9658..5ccbe8c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -701,6 +701,7 @@ enum page_references {
>  };
>  
>  static enum page_references page_check_references(struct page *page,
> +						  struct address_space *mapping,
>  						  struct mem_cgroup_zone *mz,
>  						  struct scan_control *sc)
>  {
> @@ -721,6 +722,13 @@ static enum page_references page_check_references(struct page *page,
>  	if (vm_flags & VM_LOCKED)
>  		return PAGEREF_RECLAIM;
>  
> +	/*
> +	 * Activate workingset page if referenced at least once.
> +	 */
> +	if (mapping_test_workingset(mapping) &&
> +	    (referenced_ptes || referenced_page))
> +		return PAGEREF_ACTIVATE;
> +
>  	if (referenced_ptes) {
>  		if (PageAnon(page))
>  			return PAGEREF_ACTIVATE;
> @@ -828,7 +836,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			}
>  		}
>  
> -		references = page_check_references(page, mz, sc);
> +		mapping = page_mapping(page);
> +
> +		references = page_check_references(page, mapping, mz, sc);
>  		switch (references) {
>  		case PAGEREF_ACTIVATE:
>  			goto activate_locked;
> @@ -848,11 +858,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				goto keep_locked;
>  			if (!add_to_swap(page))
>  				goto activate_locked;
> +			mapping = &swapper_space;
>  			may_enter_fs = 1;
>  		}
>  
> -		mapping = page_mapping(page);
> -
>  		/*
>  		 * The page is mapped into the page tables of one or more
>  		 * processes. Try to unmap it here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
