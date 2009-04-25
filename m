Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AC2C66B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 21:58:36 -0400 (EDT)
Date: Sat, 25 Apr 2009 09:59:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] proc: export more page flags in /proc/kpageflags
	(take 3)
Message-ID: <20090425015911.GA18265@localhost>
References: <20090414071159.GV14687@one.firstfloor.org> <20090415131800.GA11191@localhost> <20090416111108.AC55.A69D9226@jp.fujitsu.com> <20090423022625.GA8822@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="wac7ysb48OaltWcw"
Content-Disposition: inline
In-Reply-To: <20090423022625.GA8822@localhost>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all,

For your convenience, I attached the uptodate code for page-types and
page-areas. Enjoy hacking~

Thanks,
Fengguang

On Thu, Apr 23, 2009 at 10:26:25AM +0800, Wu Fengguang wrote:
> Andi and KOSAKI: can we hopefully reach harmony of opinions on this version?
> 
> Export 9 page flags in /proc/kpageflags, and 8 more for kernel developers.
> 
> 1) for kernel hackers (on CONFIG_DEBUG_KERNEL)
>    - all available page flags are exported, and
>    - exported as is
> 2) for admins and end users
>    - only the more `well known' flags are exported:
> 	11. KPF_MMAP		(pseudo flag) memory mapped page
> 	12. KPF_ANON		(pseudo flag) memory mapped page (anonymous)
> 	13. KPF_SWAPCACHE	page is in swap cache
> 	14. KPF_SWAPBACKED	page is swap/RAM backed
> 	15. KPF_COMPOUND_HEAD	(*)
> 	16. KPF_COMPOUND_TAIL	(*)
> 	17. KPF_UNEVICTABLE	page is in the unevictable LRU list
> 	18. KPF_POISON		hardware detected corruption
> 	19. KPF_NOPAGE		(pseudo flag) no page frame at the address
> 
> 	(*) For compound pages, exporting _both_ head/tail info enables
> 	    users to tell where a compound page starts/ends, and its order.
> 
>    - limit flags to their typical usage scenario, as indicated by KOSAKI:
> 	- LRU pages: only export relevant flags
> 		- PG_lru
> 		- PG_unevictable
> 		- PG_active
> 		- PG_referenced
> 		- page_mapped()
> 		- PageAnon()
> 		- PG_swapcache
> 		- PG_swapbacked
> 		- PG_reclaim
> 	- no-IO pages: mask out irrelevant flags
> 		- PG_dirty
> 		- PG_uptodate
> 		- PG_writeback
> 	- SLAB pages: mask out overloaded flags:
> 		- PG_error
> 		- PG_active
> 		- PG_private
> 	- PG_reclaim: filter out the overloaded PG_readahead
> 
> Note that compound page flags are exported faithfully to end user.  This risks
> exposing internal implementation details of the SLUB allocator, however hiding
> it risks larger impacts:
> 	- admins may wonder where all the compound pages gone - the use of
> 	  compound pages in SLUB might have some real world relevance, so that
> 	  end users want to be aware of this behavior
> 	- admins may be confused on inconsistent number of head/tail segments
> 	  This is because SLUB only marks PG_slab on the compound head page.
> 	  If we mask out PG_head|PG_tail for PG_slab pages, we are actually
> 	  only masking out PG_head flags. Therefore the PG_tail segments will
> 	  outnumber PG_head ones, which puzzled me for some time..
> 
> Here are the admin/linus views of all page flags on a newly booted nfs-root system:
> 
> # ./page-types # for admin
>          flags  page-count       MB  symbolic-flags                     long-symbolic-flags
> 0x000000000000      491449     1919  ____________________________
> 0x000000008000          15        0  _______________H____________       compound_head
> 0x000000010000        4280       16  ________________T___________       compound_tail
> 0x000000000008          17        0  ___U________________________       uptodate
> 0x000000008010           1        0  ____D__________H____________       dirty,compound_head
> 0x000000010010           4        0  ____D___________T___________       dirty,compound_tail
> 0x000000000020           1        0  _____l______________________       lru
> 0x000000000028        2678       10  ___U_l______________________       uptodate,lru
> 0x00000000002c        5244       20  __RU_l______________________       referenced,uptodate,lru
> 0x000000004060           1        0  _____lA_______b_____________       lru,active,swapbacked
> 0x000000004064          13        0  __R__lA_______b_____________       referenced,lru,active,swapbacked
> 0x000000000068         236        0  ___U_lA_____________________       uptodate,lru,active
> 0x00000000006c         927        3  __RU_lA_____________________       referenced,uptodate,lru,active
> 0x000000008080         968        3  _______S_______H____________       slab,compound_head
> 0x000000000080        1539        6  _______S____________________       slab
> 0x000000000400         516        2  __________B_________________       buddy
> 0x000000000828        1142        4  ___U_l_____M________________       uptodate,lru,mmap
> 0x00000000082c         280        1  __RU_l_____M________________       referenced,uptodate,lru,mmap
> 0x000000004860           2        0  _____lA____M__b_____________       lru,active,mmap,swapbacked
> 0x000000000868         366        1  ___U_lA____M________________       uptodate,lru,active,mmap
> 0x00000000086c         623        2  __RU_lA____M________________       referenced,uptodate,lru,active,mmap
> 0x000000005868        3639       14  ___U_lA____Ma_b_____________       uptodate,lru,active,mmap,anonymous,swapbacked
> 0x00000000586c          27        0  __RU_lA____Ma_b_____________       referenced,uptodate,lru,active,mmap,anonymous,swapbacked
>          total      513968     2007
> 
> # ./page-types # for linus, when CONFIG_DEBUG_KERNEL is turned on
>          flags  page-count       MB  symbolic-flags                     long-symbolic-flags
> 0x000000000000      471731     1842  ____________________________
> 0x000100000000       19258       75  ____________________r_______       reserved
> 0x000000008000          15        0  _______________H____________       compound_head
> 0x000000010000        4270       16  ________________T___________       compound_tail
> 0x000000000008           3        0  ___U________________________       uptodate
> 0x000000008014           1        0  __R_D__________H____________       referenced,dirty,compound_head
> 0x000000010014           4        0  __R_D___________T___________       referenced,dirty,compound_tail
> 0x000000000020           1        0  _____l______________________       lru
> 0x000000000028        2626       10  ___U_l______________________       uptodate,lru
> 0x00000000002c        5244       20  __RU_l______________________       referenced,uptodate,lru
> 0x000000000068         238        0  ___U_lA_____________________       uptodate,lru,active
> 0x00000000006c         925        3  __RU_lA_____________________       referenced,uptodate,lru,active
> 0x000000004078           1        0  ___UDlA_______b_____________       uptodate,dirty,lru,active,swapbacked
> 0x00000000407c          13        0  __RUDlA_______b_____________       referenced,uptodate,dirty,lru,active,swapbacked
> 0x000000000228          49        0  ___U_l___I__________________       uptodate,lru,reclaim
> 0x000000000400         523        2  __________B_________________       buddy
> 0x000000000804           1        0  __R________M________________       referenced,mmap
> 0x00000000080c           1        0  __RU_______M________________       referenced,uptodate,mmap
> 0x000000000828        1142        4  ___U_l_____M________________       uptodate,lru,mmap
> 0x00000000082c         280        1  __RU_l_____M________________       referenced,uptodate,lru,mmap
> 0x000000000868         366        1  ___U_lA____M________________       uptodate,lru,active,mmap
> 0x00000000086c         622        2  __RU_lA____M________________       referenced,uptodate,lru,active,mmap
> 0x000000004878           2        0  ___UDlA____M__b_____________       uptodate,dirty,lru,active,mmap,swapbacked
> 0x000000008880         907        3  _______S___M___H____________       slab,mmap,compound_head
> 0x000000000880        1488        5  _______S___M________________       slab,mmap
> 0x0000000088c0          59        0  ______AS___M___H____________       active,slab,mmap,compound_head
> 0x0000000008c0          49        0  ______AS___M________________       active,slab,mmap
> 0x000000001000         465        1  ____________a_______________       anonymous
> 0x000000005008           8        0  ___U________a_b_____________       uptodate,anonymous,swapbacked
> 0x000000005808           4        0  ___U_______Ma_b_____________       uptodate,mmap,anonymous,swapbacked
> 0x00000000580c           1        0  __RU_______Ma_b_____________       referenced,uptodate,mmap,anonymous,swapbacked
> 0x000000005868        3645       14  ___U_lA____Ma_b_____________       uptodate,lru,active,mmap,anonymous,swapbacked
> 0x00000000586c          26        0  __RU_lA____Ma_b_____________       referenced,uptodate,lru,active,mmap,anonymous,swapbacked
>          total      513968     2007
> 
> Kudos to KOSAKI and Andi for the extensive recommendations!
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Alexey Dobriyan <adobriyan@gmail.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  Documentation/vm/pagemap.txt |   65 ++++++++++
>  fs/proc/page.c               |  197 +++++++++++++++++++++++++++------
>  2 files changed, 227 insertions(+), 35 deletions(-)
> 
> --- mm.orig/fs/proc/page.c
> +++ mm/fs/proc/page.c
> @@ -6,6 +6,7 @@
>  #include <linux/mmzone.h>
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
> +#include <linux/backing-dev.h>
>  #include <asm/uaccess.h>
>  #include "internal.h"
>  
> @@ -68,19 +69,167 @@ static const struct file_operations proc
>  
>  /* These macros are used to decouple internal flags from exported ones */
>  
> -#define KPF_LOCKED     0
> -#define KPF_ERROR      1
> -#define KPF_REFERENCED 2
> -#define KPF_UPTODATE   3
> -#define KPF_DIRTY      4
> -#define KPF_LRU        5
> -#define KPF_ACTIVE     6
> -#define KPF_SLAB       7
> -#define KPF_WRITEBACK  8
> -#define KPF_RECLAIM    9
> -#define KPF_BUDDY     10
> +#define KPF_LOCKED		0
> +#define KPF_ERROR		1
> +#define KPF_REFERENCED		2
> +#define KPF_UPTODATE		3
> +#define KPF_DIRTY		4
> +#define KPF_LRU			5
> +#define KPF_ACTIVE		6
> +#define KPF_SLAB		7
> +#define KPF_WRITEBACK		8
> +#define KPF_RECLAIM		9
> +#define KPF_BUDDY		10
> +
> +/* new additions in 2.6.31 */
> +#define KPF_MMAP		11
> +#define KPF_ANON		12
> +#define KPF_SWAPCACHE		13
> +#define KPF_SWAPBACKED		14
> +#define KPF_COMPOUND_HEAD	15
> +#define KPF_COMPOUND_TAIL	16
> +#define KPF_UNEVICTABLE		17
> +#define KPF_POISON		18
> +#define KPF_NOPAGE		19
> +
> +/* kernel hacking assistances */
> +#define KPF_RESERVED		32
> +#define KPF_MLOCKED		33
> +#define KPF_MAPPEDTODISK	34
> +#define KPF_PRIVATE		35
> +#define KPF_PRIVATE2		36
> +#define KPF_OWNER_PRIVATE	37
> +#define KPF_ARCH		38
> +#define KPF_UNCACHED		39
> +
> +/*
> + * Kernel flags are exported faithfully to Linus and his fellow hackers.
> + * Otherwise some details are masked to avoid confusing the end user:
> + * - some kernel flags are completely invisible
> + * - some kernel flags are conditionally invisible on their odd usages
> + */
> +#ifdef CONFIG_DEBUG_KERNEL
> +static inline int genuine_linus(void) { return 1; }
> +#else
> +static inline int genuine_linus(void) { return 0; }
> +#endif
> +
> +#define kpf_copy_bit(uflags, kflags, visible, ubit, kbit)		\
> +	do {								\
> +		if (visible || genuine_linus())				\
> +			uflags |= ((kflags >> kbit) & 1) << ubit;	\
> +	} while (0);
> +
> +/* a helper function _not_ intended for more general uses */
> +static inline int page_cap_writeback_dirty(struct page *page)
> +{
> +	struct address_space *mapping = NULL;
> +
> +	if (!PageSlab(page))
> +		mapping = page_mapping(page);
> +
> +	return !mapping || mapping_cap_writeback_dirty(mapping);
> +}
>  
> -#define kpf_copy_bit(flags, dstpos, srcpos) (((flags >> srcpos) & 1) << dstpos)
> +static u64 get_uflags(struct page *page)
> +{
> +	u64 k;
> +	u64 u;
> +	int io;
> +	int lru;
> +	int slab;
> +
> +	/*
> +	 * pseudo flag: KPF_NOPAGE
> +	 * it differentiates a memory hole from a page with no flags
> +	 */
> +	if (!page)
> +		return 1 << KPF_NOPAGE;
> +
> +	k = page->flags;
> +	u = 0;
> +
> +	io   = page_cap_writeback_dirty(page);
> +	lru  = k & (1 << PG_lru);
> +	slab = k & (1 << PG_slab);
> +
> +	/*
> +	 * pseudo flags for the well known (anonymous) memory mapped pages
> +	 */
> +	if (lru || genuine_linus()) {
> +		if (page_mapped(page))
> +			u |= 1 << KPF_MMAP;
> +		if (PageAnon(page))
> +			u |= 1 << KPF_ANON;
> +	}
> +
> +	/*
> +	 * compound pages: export both head/tail info
> +	 * they together define a compound page's start/end pos and order
> +	 */
> +	if (PageHead(page))
> +		u |= 1 << KPF_COMPOUND_HEAD;
> +	if (PageTail(page))
> +		u |= 1 << KPF_COMPOUND_TAIL;
> +
> +	kpf_copy_bit(u, k, 1,	  KPF_LOCKED,		PG_locked);
> +
> +	kpf_copy_bit(u, k, 1,     KPF_SLAB,		PG_slab);
> +	kpf_copy_bit(u, k, 1,     KPF_BUDDY,		PG_buddy);
> +
> +	kpf_copy_bit(u, k, io,    KPF_ERROR,		PG_error);
> +	kpf_copy_bit(u, k, io,    KPF_DIRTY,		PG_dirty);
> +	kpf_copy_bit(u, k, io,    KPF_UPTODATE,		PG_uptodate);
> +	kpf_copy_bit(u, k, io,    KPF_WRITEBACK,	PG_writeback);
> +
> +	kpf_copy_bit(u, k, 1,     KPF_LRU,		PG_lru);
> +	kpf_copy_bit(u, k, lru,	  KPF_REFERENCED,	PG_referenced);
> +	kpf_copy_bit(u, k, lru,   KPF_ACTIVE,		PG_active);
> +	kpf_copy_bit(u, k, lru,   KPF_RECLAIM,		PG_reclaim);
> +
> +	kpf_copy_bit(u, k, lru,   KPF_SWAPCACHE,	PG_swapcache);
> +	kpf_copy_bit(u, k, lru,   KPF_SWAPBACKED,	PG_swapbacked);
> +
> +#ifdef CONFIG_MEMORY_FAILURE
> +	kpf_copy_bit(u, k, 1,     KPF_POISON,		PG_poison);
> +#endif
> +
> +#ifdef CONFIG_UNEVICTABLE_LRU
> +	kpf_copy_bit(u, k, lru,   KPF_UNEVICTABLE,	PG_unevictable);
> +	kpf_copy_bit(u, k, 0,     KPF_MLOCKED,		PG_mlocked);
> +#endif
> +
> +	kpf_copy_bit(u, k, 0,     KPF_RESERVED,		PG_reserved);
> +	kpf_copy_bit(u, k, 0,     KPF_MAPPEDTODISK,	PG_mappedtodisk);
> +	kpf_copy_bit(u, k, 0,     KPF_PRIVATE,		PG_private);
> +	kpf_copy_bit(u, k, 0,     KPF_PRIVATE2,		PG_private_2);
> +	kpf_copy_bit(u, k, 0,     KPF_OWNER_PRIVATE,	PG_owner_priv_1);
> +	kpf_copy_bit(u, k, 0,     KPF_ARCH,		PG_arch_1);
> +
> +#ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
> +	kpf_copy_bit(u, k, 0,     KPF_UNCACHED,		PG_uncached);
> +#endif
> +
> +	if (!genuine_linus()) {
> +		/*
> +		 * SLAB/SLOB/SLUB overload some page flags which may confuse end user
> +		 */
> +		if (slab) {
> +			u &= ~ ((1 << KPF_ACTIVE)	|
> +				(1 << KPF_ERROR)	|
> +				(1 << KPF_MMAP));
> +		}
> +		/*
> +		 * PG_reclaim could be overloaded as PG_readahead,
> +		 * and we only want to export the first one.
> +		 */
> +		if ((u & ((1 << KPF_RECLAIM) | (1 << KPF_WRITEBACK))) ==
> +			  (1 << KPF_RECLAIM))
> +			u &= ~ (1 << KPF_RECLAIM);
> +	}
> +
> +	return u;
> +};
>  
>  static ssize_t kpageflags_read(struct file *file, char __user *buf,
>  			     size_t count, loff_t *ppos)
> @@ -90,7 +239,6 @@ static ssize_t kpageflags_read(struct fi
>  	unsigned long src = *ppos;
>  	unsigned long pfn;
>  	ssize_t ret = 0;
> -	u64 kflags, uflags;
>  
>  	pfn = src / KPMSIZE;
>  	count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
> @@ -98,32 +246,17 @@ static ssize_t kpageflags_read(struct fi
>  		return -EINVAL;
>  
>  	while (count > 0) {
> -		ppage = NULL;
>  		if (pfn_valid(pfn))
>  			ppage = pfn_to_page(pfn);
> -		pfn++;
> -		if (!ppage)
> -			kflags = 0;
>  		else
> -			kflags = ppage->flags;
> -
> -		uflags = kpf_copy_bit(kflags, KPF_LOCKED, PG_locked) |
> -			kpf_copy_bit(kflags, KPF_ERROR, PG_error) |
> -			kpf_copy_bit(kflags, KPF_REFERENCED, PG_referenced) |
> -			kpf_copy_bit(kflags, KPF_UPTODATE, PG_uptodate) |
> -			kpf_copy_bit(kflags, KPF_DIRTY, PG_dirty) |
> -			kpf_copy_bit(kflags, KPF_LRU, PG_lru) |
> -			kpf_copy_bit(kflags, KPF_ACTIVE, PG_active) |
> -			kpf_copy_bit(kflags, KPF_SLAB, PG_slab) |
> -			kpf_copy_bit(kflags, KPF_WRITEBACK, PG_writeback) |
> -			kpf_copy_bit(kflags, KPF_RECLAIM, PG_reclaim) |
> -			kpf_copy_bit(kflags, KPF_BUDDY, PG_buddy);
> +			ppage = NULL;
>  
> -		if (put_user(uflags, out++)) {
> +		if (put_user(get_uflags(ppage), out)) {
>  			ret = -EFAULT;
>  			break;
>  		}
> -
> +		out++;
> +		pfn++;
>  		count -= KPMSIZE;
>  	}
>  
> --- mm.orig/Documentation/vm/pagemap.txt
> +++ mm/Documentation/vm/pagemap.txt
> @@ -12,9 +12,9 @@ There are three components to pagemap:
>     value for each virtual page, containing the following data (from
>     fs/proc/task_mmu.c, above pagemap_read):
>  
> -    * Bits 0-55  page frame number (PFN) if present
> +    * Bits 0-54  page frame number (PFN) if present
>      * Bits 0-4   swap type if swapped
> -    * Bits 5-55  swap offset if swapped
> +    * Bits 5-54  swap offset if swapped
>      * Bits 55-60 page shift (page size = 1<<page shift)
>      * Bit  61    reserved for future use
>      * Bit  62    page swapped
> @@ -36,7 +36,7 @@ There are three components to pagemap:
>   * /proc/kpageflags.  This file contains a 64-bit set of flags for each
>     page, indexed by PFN.
>  
> -   The flags are (from fs/proc/proc_misc, above kpageflags_read):
> +   The flags are (from fs/proc/page.c, above kpageflags_read):
>  
>       0. LOCKED
>       1. ERROR
> @@ -49,6 +49,65 @@ There are three components to pagemap:
>       8. WRITEBACK
>       9. RECLAIM
>      10. BUDDY
> +    11. MMAP
> +    12. ANON
> +    13. SWAPCACHE
> +    14. SWAPBACKED
> +    15. COMPOUND_HEAD
> +    16. COMPOUND_TAIL
> +    17. UNEVICTABLE
> +    18. POISON
> +    19. NOPAGE
> +
> +Short descriptions to the page flags:
> +
> + 0. LOCKED
> +    page is being locked for exclusive access, eg. by undergoing read/write IO
> +
> + 7. SLAB
> +    page is managed by the SLAB/SLOB/SLUB/SLQB kernel memory allocator
> +
> +10. BUDDY
> +    a free memory block managed by the buddy system allocator
> +    The buddy system organizes free memory in blocks of various orders.
> +    An order N block has 2^N physically contiguous pages, with the BUDDY flag
> +    set for and _only_ for the first page.
> +
> +15. COMPOUND_HEAD
> +16. COMPOUND_TAIL
> +    A compound page with order N consists of 2^N physically contiguous pages.
> +    A compound page with order 2 takes the form of "HTTT", where H donates its
> +    head page and T donates its tail page(s).  The major consumers of compound
> +    pages are hugeTLB pages (Documentation/vm/hugetlbpage.txt), the SLUB etc.
> +    memory allocators and various device drivers.
> +
> +18. POISON
> +    hardware has detected memory corruption on this page
> +
> +19. NOPAGE
> +    no page frame exists at the requested address
> +
> +    [IO related page flags]
> + 1. ERROR     IO error occurred
> + 3. UPTODATE  page has up-to-date data
> +              ie. for file backed page: (in-memory data revision >= on-disk one)
> + 4. DIRTY     page has been written to, hence contains new data
> +              ie. for file backed page: (in-memory data revision >  on-disk one)
> + 8. WRITEBACK page is being synced to disk
> +
> +    [LRU related page flags]
> + 5. LRU         page is in one of the LRU lists
> + 6. ACTIVE      page is in the active LRU list
> +17. UNEVICTABLE page is in the unevictable (non-)LRU list
> +                It is somehow pinned and not a candidate for LRU page reclaims,
> +		eg. ramfs pages, shmctl(SHM_LOCK) and mlock() memory segments
> + 2. REFERENCED  page has been referenced since last LRU list enqueue/requeue
> + 9. RECLAIM     page will be reclaimed soon after its pageout IO completed
> +11. MMAP        a memory mapped page
> +12. ANON        a memory mapped page who is not a file page
> +13. SWAPCACHE   page is mapped to swap space, ie. has an associated swap entry
> +14. SWAPBACKED  page is backed by swap/RAM
> +
>  
>  Using pagemap to do something useful:
>  

--wac7ysb48OaltWcw
Content-Type: text/x-chdr; charset=us-ascii
Content-Disposition: attachment; filename="pagemap.h"

#ifndef _PAGEMAP_H_
#define _PAGEMAP_H_

#define KPF_BYTES		8
#define PROC_KPAGEFLAGS		"/proc/kpageflags"

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

/* copied from kpageflags_read() */

#define KPF_LOCKED              0
#define KPF_ERROR               1
#define KPF_REFERENCED          2
#define KPF_UPTODATE            3
#define KPF_DIRTY               4
#define KPF_LRU                 5
#define KPF_ACTIVE              6
#define KPF_SLAB                7
#define KPF_WRITEBACK           8
#define KPF_RECLAIM             9
#define KPF_BUDDY               10

/* new additions in 2.6.31 */
#define KPF_MMAP                11
#define KPF_ANON                12
#define KPF_SWAPCACHE           13
#define KPF_SWAPBACKED          14
#define KPF_COMPOUND_HEAD       15
#define KPF_COMPOUND_TAIL       16
#define KPF_UNEVICTABLE         17
#define KPF_POISON              18
#define KPF_NOPAGE              19

/* kernel hacking assistances */
#define KPF_RESERVED            32
#define KPF_MLOCKED             33
#define KPF_MAPPEDTODISK        34
#define KPF_PRIVATE             35
#define KPF_PRIVATE2            36
#define KPF_OWNER_PRIVATE       37
#define KPF_ARCH                38
#define KPF_UNCACHED            39

static char *page_flag_names[] = {
	[KPF_LOCKED]		= "L:locked",
	[KPF_ERROR]		= "E:error",
	[KPF_REFERENCED]	= "R:referenced",
	[KPF_UPTODATE]		= "U:uptodate",
	[KPF_DIRTY]		= "D:dirty",
	[KPF_LRU]		= "l:lru",
	[KPF_ACTIVE]		= "A:active",
	[KPF_SLAB]		= "S:slab",
	[KPF_WRITEBACK]		= "W:writeback",
	[KPF_RECLAIM]		= "I:reclaim",
	[KPF_BUDDY]		= "B:buddy",

	[KPF_MMAP]		= "M:mmap",
	[KPF_ANON]		= "a:anonymous",
	[KPF_SWAPCACHE]		= "s:swapcache",
	[KPF_SWAPBACKED]	= "b:swapbacked",
	[KPF_COMPOUND_HEAD]	= "H:compound_head",
	[KPF_COMPOUND_TAIL]	= "T:compound_tail",
	[KPF_UNEVICTABLE]	= "u:unevictable",
	[KPF_POISON]		= "X:poison",
	[KPF_NOPAGE]		= "n:nopage",

	[KPF_RESERVED]		= "r:reserved",
	[KPF_MLOCKED]		= "m:mlocked",
	[KPF_MAPPEDTODISK]	= "d:mappedtodisk",
	[KPF_PRIVATE]		= "P:private",
	[KPF_PRIVATE2]		= "p:private_2",
	[KPF_OWNER_PRIVATE]	= "O:owner_private",
	[KPF_ARCH]		= "h:arch",
	[KPF_UNCACHED]		= "c:uncached",
};


static inline unsigned long pages2kb(unsigned long pages)
{
	return (pages * getpagesize()) >> 10;
}

static inline unsigned long pages2mb(unsigned long pages)
{
	return (pages * getpagesize()) >> 20;
}

#endif /* _PAGEMAP_H_ */

--wac7ysb48OaltWcw
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="page-types.c"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/errno.h>
#include <sys/fcntl.h>

#include "pagemap.h"

#define HASH_SHIFT	13
#define HASH_MASK	((1 << HASH_SHIFT) - 1)
#define HASH_KEY(flags)	(flags & HASH_MASK)

static unsigned long	page_count[1 << HASH_SHIFT];
static uint64_t 	page_flags[1 << HASH_SHIFT];

int hash_index(uint64_t flags)
{
	int i;
	int k = HASH_KEY(flags);

	if (!flags)
		return 0;

	for (i = 1; i < ARRAY_SIZE(page_count); i++, k++) {
		if (!k || k >= ARRAY_SIZE(page_count))
			k = 1;
		if (page_flags[k] == 0) {
			page_flags[k] = flags;
			return k;
		}
		if (page_flags[k] == flags)
			return k;
	}

	exit(1); /* die hard on full hash table */
}

char *page_flag_name(uint64_t flags)
{
	int i, j;
	int bit;
	static char buf[65];

	for (i = 0, j = 0; i < ARRAY_SIZE(page_flag_names); i++) {
		bit = (flags >> i) & 1;
		if (!page_flag_names[i]) {
			if (bit)
				fprintf(stderr, "unkown flag bit %d\n", i);
			continue;
		}
		buf[j++] = bit ? page_flag_names[i][0] : '_';
	}

	return buf;
}

char *page_flag_longname(uint64_t flags)
{
	int i, n;
	static char buf[1024];

	for (i = 0, n = 0; i < ARRAY_SIZE(page_flag_names); i++) {
		if (!page_flag_names[i])
			continue;
		if ((flags >> i) & 1)
		       n += snprintf(buf + n, sizeof(buf) - n, "%s,",
				       page_flag_names[i] + 2);
	}
	if (n)
		n--;
	buf[n] = '\0';

	return buf;
}

static unsigned long nr_pages;
static uint64_t kpageflags[KPF_BYTES * (1<<20)];

unsigned long collect_page_count()
{
	unsigned long n;
	unsigned long i;
	uint64_t flags;
	int fd;

	fd = open(PROC_KPAGEFLAGS, O_RDONLY);
	if (fd < 0) {
		perror(PROC_KPAGEFLAGS);
		exit(1);
	}

	while (1) {
		n = read(fd, kpageflags, sizeof(kpageflags));
		if (n == 0)
			break;
		if (n < 0) {
			perror(PROC_KPAGEFLAGS);
			exit(2);
		}
		if (n % KPF_BYTES != 0) {
			fprintf(stderr, "partial read: %lu bytes\n", n);
			exit(3);
		}
		n = n / KPF_BYTES;

		for (i = 0; i < n; i++) {
			flags = kpageflags[i];
			page_count[hash_index(flags)]++;
		}
		nr_pages += n;
	}

	close(fd);
}

void show_page_count()
{
	int i;

	printf("         flags\tpage-count       MB"
		"  symbolic-flags\t\t\tlong-symbolic-flags\n");

	for (i = 0; i < ARRAY_SIZE(page_count); i++) {
		if (page_count[i])
			printf("0x%012lx\t%10lu %8lu  %s\t%s\n",
				page_flags[i],
				page_count[i],
				pages2mb(page_count[i]),
				page_flag_name(page_flags[i]),
				page_flag_longname(page_flags[i]));
	}

	printf("         total\t%10lu %8lu\n",
			nr_pages, pages2mb(nr_pages));
}

int main(int argc, char *argv[])
{
	collect_page_count();
	show_page_count();
	return 0;
}

--wac7ysb48OaltWcw
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="page-areas.c"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/errno.h>
#include <sys/fcntl.h>

#include "pagemap.h"

static void add_index(unsigned long index)
{
	static unsigned long offset, len;

	if (index == offset + len)
		len++;
	else {
		if (len)
			printf("%10lu %8lu %8luKB\n", offset, len, pages2kb(len));
		offset = index;
		len = 1;
	}
}

static void usage(const char *prog)
{
	printf("Usage: %s page_flags\n", prog);
}

static uint64_t kpageflags[KPF_BYTES * (1<<20)];

int main(int argc, char *argv[])
{
	uint64_t match_flags;
	int	 match_exact;
	unsigned long n;
	unsigned long i;
	char *p;
	int fd;

	if (argc < 2) {
		usage(argv[0]);
		exit(1);
	}

	match_exact = 0;
	p = argv[1];
	if (p[0] == '=') {
		match_exact = 1;
		p++;
	}
	match_flags = strtol(p, 0, 16);

	fd = open(PROC_KPAGEFLAGS, O_RDONLY);
	if (fd < 0) {
		perror(PROC_KPAGEFLAGS);
		exit(1);
	}

	while (1) {
		n = read(fd, kpageflags, sizeof(kpageflags));
		if (n == 0)
			break;
		if (n < 0) {
			perror(PROC_KPAGEFLAGS);
			exit(2);
		}
		if (n % KPF_BYTES != 0) {
			fprintf(stderr, "%s: partial read: %lu bytes\n",
					argv[0], n);
			exit(3);
		}
		n = n / KPF_BYTES;

		printf("    offset      len         KB\n");
		for (i = 0; i < n; i++) {
			if (!match_exact && ((kpageflags[i] & match_flags) == match_flags) ||
			    (match_exact && kpageflags[i] == match_flags))
				add_index(i);
		}
	}
	add_index(0); /* flush the stored range */

	return 0;
}

--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=Makefile

BINS = page-types page-areas

all: $(BINS)

page-types: page-types.c pagemap.h
	gcc -g -o $@ $<

page-areas: page-areas.c pagemap.h
	gcc -g -o $@ $<

clean:
	rm $(BINS)

--wac7ysb48OaltWcw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
