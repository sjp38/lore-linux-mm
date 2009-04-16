Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 349905F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 22:26:31 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3G2Qr4r007566
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Apr 2009 11:26:53 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5137645DE53
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 11:26:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D7D145DE4F
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 11:26:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D6FA1E0800B
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 11:26:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CC73E08006
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 11:26:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] proc: export more page flags in /proc/kpageflags
In-Reply-To: <20090415131800.GA11191@localhost>
References: <20090414071159.GV14687@one.firstfloor.org> <20090415131800.GA11191@localhost>
Message-Id: <20090416111108.AC55.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Apr 2009 11:26:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

> > > > On Tue, Apr 14, 2009 at 12:37:10PM +0800, KOSAKI Motohiro wrote:
> > > > > > Export the following page flags in /proc/kpageflags,
> > > > > > just in case they will be useful to someone:
> > > > > > 
> > > > > > - PG_swapcache
> > > > > > - PG_swapbacked
> > > > > > - PG_mappedtodisk
> > > > > > - PG_reserved
> > 
> > PG_reserved should be exported as PG_KERNEL or somesuch.
> 
> PG_KERNEL could be misleading. PG_reserved obviously do not cover all
> (or most) kernel pages. So I'd prefer to export PG_reserved as it is.
> 
> It seems that the vast amount of free pages are marked PG_reserved:

Can I review the document at first?
if no good document for administrator, I can't ack exposing PG_reserved.


> # uname -a
> Linux hp 2.6.30-rc2 #157 SMP Wed Apr 15 19:37:49 CST 2009 x86_64 GNU/Linux
> # echo 1 > /proc/sys/vm/drop_caches
> # ./page-types
>    flags        page-count       MB  symbolic-flags             long-symbolic-flags
> 0x004000            497474     1943  ______________r_____       reserved
> 0x008000              4454       17  _______________o____       compound
> 0x008014                 5        0  __R_D__________o____       referenced,dirty,compound
> 0x000020                 1        0  _____l______________       lru
> 0x000028               310        1  ___U_l______________       uptodate,lru
> 0x00002c                18        0  __RU_l______________       referenced,uptodate,lru
> 0x000068                80        0  ___U_lA_____________       uptodate,lru,active
> 0x00006c               157        0  __RU_lA_____________       referenced,uptodate,lru,active
> 0x002078                 1        0  ___UDlA______b______       uptodate,dirty,lru,active,swapbacked
> 0x00207c                17        0  __RUDlA______b______       referenced,uptodate,dirty,lru,active,swapbacked
> 0x000228                13        0  ___U_l___x__________       uptodate,lru,reclaim
> 0x000400              2085        8  __________B_________       buddy

"freed" is better?
buddy is implementation technique name.

> 0x000804                 1        0  __R________m________       referenced,mmap
> 0x002808                10        0  ___U_______m_b______       uptodate,mmap,swapbacked
> 0x000828              1060        4  ___U_l_____m________       uptodate,lru,mmap
> 0x00082c               215        0  __RU_l_____m________       referenced,uptodate,lru,mmap
> 0x000868               189        0  ___U_lA____m________       uptodate,lru,active,mmap
> 0x002868              4187       16  ___U_lA____m_b______       uptodate,lru,active,mmap,swapbacked
> 0x00286c                30        0  __RU_lA____m_b______       referenced,uptodate,lru,active,mmap,swapbacked
> 0x00086c              1012        3  __RU_lA____m________       referenced,uptodate,lru,active,mmap
> 0x002878                 3        0  ___UDlA____m_b______       uptodate,dirty,lru,active,mmap,swapbacked
> 0x008880               936        3  _______S___m___o____       slab,mmap,compound
> 0x000880              1602        6  _______S___m________       slab,mmap

please don't display mmap and coumpound. it expose SLUB implentation detail.
IOW, if slab flag on, please ignore following flags and mapcount.
	- PG_active
	- PG_error
	- PG_private
	- PG_compound

BTW, if the page don't have PG_lru, following member and flags can be used another meanings.
	- PG_active
	- PG_referenced
	- page::_mapcount
	- PG_swapbacked
	- PG_reclaim
	- PG_unevictable
	- PG_mlocked

and, if the page never interact IO layer, following flags can be used another meanings.
	- PG_uptodate
	- PG_dirty


> 0x0088c0                59        0  ______AS___m___o____       active,slab,mmap,compound
> 0x0008c0                49        0  ______AS___m________       active,slab,mmap
>    total            513968     2007


And, PageAnon() result seems provide good information if the page stay in lru.



> # ./page-areas 0x004000
>     offset      len         KB
>          0       15       60KB
>         31        4       16KB
>        159       97      388KB
>       4096     2213     8852KB
>       6899     2385     9540KB
>       9497        3       12KB
>       9728    14528    58112KB
> 
> > > > > > - PG_private
> > > > > > - PG_private_2
> > > > > > - PG_owner_priv_1
> > > > > > 
> > > > > > - PG_head
> > > > > > - PG_tail
> > > > > > - PG_compound
> > 
> > I would combine these three into a pseudo "large page" flag.
> 
> Very neat idea! Patch updated accordingly.
>  
> However - one pity I observed:
> 
> # ./page-areas 0x008000
>     offset      len         KB
>       3088        4       16KB
> 
> We can no longer tell if the above line means one 4-page hugepage, or two
> 2-page hugepages... Adding PG_COMPOUND_TAIL into the CONFIG_DEBUG_KERNEL block
> can help kernel developers. Or will it be ever cared by administrators?
> 
>     341196        2        8KB
>     341202        2        8KB
>     341262        2        8KB
>     341272        8       32KB
>     341296        8       32KB
>     488448       24       96KB
>     488490        2        8KB
>     488496      320     1280KB
>     488842        2        8KB
>     488848       40      160KB
> 
> > > > > > 
> > > > > > - PG_unevictable
> > > > > > - PG_mlocked
> > > > > > 
> > > > > > - PG_poison
> > 
> > PG_poison is also useful to export. But since it depends on my
> > patchkit I will pull a patch for that into the HWPOISON series.
> 
> That's not a problem - since the PG_poison line is be protected by
> #ifdef CONFIG_MEMORY_FAILURE :-) 
> 
> > > > > > - PG_unevictable
> > > > > > - PG_mlocked
> > > 
> > > this 9 flags shouldn't exported.
> > > I can't imazine administrator use what purpose those flags.
> > 
> > I think an abstraced "PG_pinned" or somesuch flag that combines
> > page lock, unevictable, mlocked would be useful for the administrator.
> 
> The PG_PINNED abstraction risks hiding useful information.
> The administrator may not only care about the pinned pages,
> but also care _why_ they are pinned, i.e. ramfs.. or mlock?
> 
> So it might be good to export them as is, with proper document.
> 
> Here is the v2 patch, with flags for kernel hackers numbered from 32.
> Comments are welcome!

if you can write good document, PG_unevictable is exportable.
but PG_mlock isn't.

that's implementation tecknique of efficient unevictable pages for mlock.
we can change the future.




> Thanks,
> Fengguang
> ---
> 
> Export all available page flags in /proc/kpageflags, plus two pseudo ones. 
> This increases the total number of exported page flags to 26.
> 
> TODO: more document
> 
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Alexey Dobriyan <adobriyan@gmail.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/proc/page.c |  122 +++++++++++++++++++++++++++++++++++------------
>  1 file changed, 91 insertions(+), 31 deletions(-)
> 
> --- mm.orig/fs/proc/page.c
> +++ mm/fs/proc/page.c
> @@ -68,20 +68,96 @@ static const struct file_operations proc
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
> +#define KPF_SWAPCACHE		12
> +#define KPF_SWAPBACKED		13
> +#define KPF_RESERVED		14
> +#define KPF_COMPOUND		15
> +#define KPF_UNEVICTABLE		16
> +#define KPF_MLOCKED		17
> +#define KPF_POISON		18
> +#define KPF_NOPAGE		19
> +
> +/* kernel hacking assistances */
> +#define KPF_MAPPEDTODISK	32
> +#define KPF_PRIVATE		33
> +#define KPF_PRIVATE2		34
> +#define KPF_OWNER_PRIVATE	35
> +#define KPF_ARCH		36
> +#define KPF_UNCACHED		37
>  
>  #define kpf_copy_bit(flags, dstpos, srcpos) (((flags >> srcpos) & 1) << dstpos)
>  
> +u64 get_uflags(struct page *page)
> +{
> +	u64 kflags;
> +	u64 uflags;
> +
> +	if (!page)
> +		return 1 << KPF_NOPAGE;
> +
> +	kflags = page->flags;
> +	uflags = 0;
> +
> +	if (page_mapped(page))
> +		uflags |= 1 << KPF_MMAP;
> +
> +	uflags |= kpf_copy_bit(kflags, KPF_LOCKED,	PG_locked);
> +	uflags |= kpf_copy_bit(kflags, KPF_ERROR,	PG_error);
> +	uflags |= kpf_copy_bit(kflags, KPF_REFERENCED,	PG_referenced);
> +	uflags |= kpf_copy_bit(kflags, KPF_UPTODATE,	PG_uptodate);
> +	uflags |= kpf_copy_bit(kflags, KPF_DIRTY,	PG_dirty);
> +	uflags |= kpf_copy_bit(kflags, KPF_LRU,		PG_lru)	;
> +	uflags |= kpf_copy_bit(kflags, KPF_ACTIVE,	PG_active);
> +	uflags |= kpf_copy_bit(kflags, KPF_SLAB,	PG_slab);
> +	uflags |= kpf_copy_bit(kflags, KPF_WRITEBACK,	PG_writeback);
> +	uflags |= kpf_copy_bit(kflags, KPF_RECLAIM,	PG_reclaim);
> +	uflags |= kpf_copy_bit(kflags, KPF_BUDDY,	PG_buddy);
> +
> +	uflags |= kpf_copy_bit(kflags, KPF_SWAPCACHE,	PG_swapcache);
> +	uflags |= kpf_copy_bit(kflags, KPF_SWAPBACKED,	PG_swapbacked);
> +	uflags |= kpf_copy_bit(kflags, KPF_RESERVED,	PG_reserved);
> +#ifdef CONFIG_PAGEFLAGS_EXTENDED
> +	uflags |= kpf_copy_bit(kflags, KPF_COMPOUND,	PG_head);
> +	uflags |= kpf_copy_bit(kflags, KPF_COMPOUND,	PG_tail);
> +#else
> +	uflags |= kpf_copy_bit(kflags, KPF_COMPOUND,	PG_compound);
> +#endif
> +#ifdef CONFIG_UNEVICTABLE_LRU
> +	uflags |= kpf_copy_bit(kflags, KPF_UNEVICTABLE,	PG_unevictable);
> +	uflags |= kpf_copy_bit(kflags, KPF_MLOCKED,	PG_mlocked);
> +#endif
> +#ifdef CONFIG_MEMORY_FAILURE
> +	uflags |= kpf_copy_bit(kflags, KPF_POISON,	PG_poison);
> +#endif
> +
> +#ifdef CONFIG_DEBUG_KERNEL
> +	uflags |= kpf_copy_bit(kflags, KPF_MAPPEDTODISK, PG_mappedtodisk);
> +	uflags |= kpf_copy_bit(kflags, KPF_PRIVATE,	PG_private);
> +	uflags |= kpf_copy_bit(kflags, KPF_PRIVATE2,	PG_private_2);
> +	uflags |= kpf_copy_bit(kflags, KPF_OWNER_PRIVATE, PG_owner_priv_1);
> +	uflags |= kpf_copy_bit(kflags, KPF_ARCH,	PG_arch_1);
> +#ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
> +	uflags |= kpf_copy_bit(kflags, KPF_UNCACHED,	PG_uncached);
> +#endif
> +#endif
> +
> +	return uflags;
> +};
> +
>  static ssize_t kpageflags_read(struct file *file, char __user *buf,
>  			     size_t count, loff_t *ppos)
>  {
> @@ -90,7 +166,6 @@ static ssize_t kpageflags_read(struct fi
>  	unsigned long src = *ppos;
>  	unsigned long pfn;
>  	ssize_t ret = 0;
> -	u64 kflags, uflags;
>  
>  	pfn = src / KPMSIZE;
>  	count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
> @@ -98,32 +173,17 @@ static ssize_t kpageflags_read(struct fi
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
> 
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
