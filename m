Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D54A35F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 23:48:54 -0400 (EDT)
Date: Thu, 16 Apr 2009 11:49:18 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] proc: export more page flags in /proc/kpageflags
Message-ID: <20090416034918.GB20162@localhost>
References: <20090414071159.GV14687@one.firstfloor.org> <20090415131800.GA11191@localhost> <20090416111108.AC55.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090416111108.AC55.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 16, 2009 at 10:26:51AM +0800, KOSAKI Motohiro wrote:
> tatus: RO
> Content-Length: 13245
> Lines: 380
> 
> Hi
> 
> > > > > On Tue, Apr 14, 2009 at 12:37:10PM +0800, KOSAKI Motohiro wrote:
> > > > > > > Export the following page flags in /proc/kpageflags,
> > > > > > > just in case they will be useful to someone:
> > > > > > >
> > > > > > > - PG_swapcache
> > > > > > > - PG_swapbacked
> > > > > > > - PG_mappedtodisk
> > > > > > > - PG_reserved
> > >
> > > PG_reserved should be exported as PG_KERNEL or somesuch.
> >
> > PG_KERNEL could be misleading. PG_reserved obviously do not cover all
> > (or most) kernel pages. So I'd prefer to export PG_reserved as it is.
> >
> > It seems that the vast amount of free pages are marked PG_reserved:
> 
> Can I review the document at first?
> if no good document for administrator, I can't ack exposing PG_reserved.

btw, is this the expected behavior to mark so many free pages as PG_reserved?
Last time I looked at it, in 2.6.27, the free pages simply don't have
any flags set.

//Or maybe it's a false reporting of my tool. Will double check.

> > # uname -a
> > Linux hp 2.6.30-rc2 #157 SMP Wed Apr 15 19:37:49 CST 2009 x86_64 GNU/Linux
> > # echo 1 > /proc/sys/vm/drop_caches
> > # ./page-types
> >    flags        page-count       MB  symbolic-flags             long-symbolic-flags
> > 0x004000            497474     1943  ______________r_____       reserved
> > 0x008000              4454       17  _______________o____       compound
> > 0x008014                 5        0  __R_D__________o____       referenced,dirty,compound
> > 0x000020                 1        0  _____l______________       lru
> > 0x000028               310        1  ___U_l______________       uptodate,lru
> > 0x00002c                18        0  __RU_l______________       referenced,uptodate,lru
> > 0x000068                80        0  ___U_lA_____________       uptodate,lru,active
> > 0x00006c               157        0  __RU_lA_____________       referenced,uptodate,lru,active
> > 0x002078                 1        0  ___UDlA______b______       uptodate,dirty,lru,active,swapbacked
> > 0x00207c                17        0  __RUDlA______b______       referenced,uptodate,dirty,lru,active,swapbacked
> > 0x000228                13        0  ___U_l___x__________       uptodate,lru,reclaim
> > 0x000400              2085        8  __________B_________       buddy
> 
> "freed" is better?
> buddy is implementation technique name.

Not compellingly better :-)  I'd expect BUDDY to be a well recognized
technique, something close to LRU.  PG_BUDDY could be documented as:
this page is owned by the buddy system, which manages free memory.

PG_FREED may seem more newbie friendly, but there will be the classical
newbie question: "Why so few freed pages?!" ;-)

It's not likely that an administrator not understanding BUDDY will
understand many of the other exported page flags. He will have to
query the document anyway.  And exporting PG_buddy as it is could
be the best option for proficient users.

> > 0x000804                 1        0  __R________m________       referenced,mmap
> > 0x002808                10        0  ___U_______m_b______       uptodate,mmap,swapbacked
> > 0x000828              1060        4  ___U_l_____m________       uptodate,lru,mmap
> > 0x00082c               215        0  __RU_l_____m________       referenced,uptodate,lru,mmap
> > 0x000868               189        0  ___U_lA____m________       uptodate,lru,active,mmap
> > 0x002868              4187       16  ___U_lA____m_b______       uptodate,lru,active,mmap,swapbacked
> > 0x00286c                30        0  __RU_lA____m_b______       referenced,uptodate,lru,active,mmap,swapbacked
> > 0x00086c              1012        3  __RU_lA____m________       referenced,uptodate,lru,active,mmap
> > 0x002878                 3        0  ___UDlA____m_b______       uptodate,dirty,lru,active,mmap,swapbacked
> > 0x008880               936        3  _______S___m___o____       slab,mmap,compound
> > 0x000880              1602        6  _______S___m________       slab,mmap
> 
> please don't display mmap and coumpound. it expose SLUB implentation detail.
> IOW, if slab flag on, please ignore following flags and mapcount.
>         - PG_active
>         - PG_error
>         - PG_private
>         - PG_compound
> 
> BTW, if the page don't have PG_lru, following member and flags can be used another meanings.
>         - PG_active
>         - PG_referenced
>         - page::_mapcount
>         - PG_swapbacked
>         - PG_reclaim
>         - PG_unevictable
>         - PG_mlocked
> 
> and, if the page never interact IO layer, following flags can be used another meanings.
>         - PG_uptodate
>         - PG_dirty

Good point. I also noticed many of these conditional flags.
The perceived solution would be to do some filtering if
!CONFIG_DEBUG_KERNEL, to not confuse too many administrators.
For kernel developers we want to be faithful :-)

> 
> > 0x0088c0                59        0  ______AS___m___o____       active,slab,mmap,compound
> > 0x0008c0                49        0  ______AS___m________       active,slab,mmap
> >    total            513968     2007
> 
> 
> And, PageAnon() result seems provide good information if the page stay in lru.

Good point! Will add this bit.

> > # ./page-areas 0x004000
> >     offset      len         KB
> >          0       15       60KB
> >         31        4       16KB
> >        159       97      388KB
> >       4096     2213     8852KB
> >       6899     2385     9540KB
> >       9497        3       12KB
> >       9728    14528    58112KB
> >
> > > > > > > - PG_private
> > > > > > > - PG_private_2
> > > > > > > - PG_owner_priv_1
> > > > > > >
> > > > > > > - PG_head
> > > > > > > - PG_tail
> > > > > > > - PG_compound
> > >
> > > I would combine these three into a pseudo "large page" flag.
> >
> > Very neat idea! Patch updated accordingly.
> >
> > However - one pity I observed:
> >
> > # ./page-areas 0x008000
> >     offset      len         KB
> >       3088        4       16KB
> >
> > We can no longer tell if the above line means one 4-page hugepage, or two
> > 2-page hugepages... Adding PG_COMPOUND_TAIL into the CONFIG_DEBUG_KERNEL block
> > can help kernel developers. Or will it be ever cared by administrators?
> >
> >     341196        2        8KB
> >     341202        2        8KB
> >     341262        2        8KB
> >     341272        8       32KB
> >     341296        8       32KB
> >     488448       24       96KB
> >     488490        2        8KB
> >     488496      320     1280KB
> >     488842        2        8KB
> >     488848       40      160KB
> >
> > > > > > >
> > > > > > > - PG_unevictable
> > > > > > > - PG_mlocked
> > > > > > >
> > > > > > > - PG_poison
> > >
> > > PG_poison is also useful to export. But since it depends on my
> > > patchkit I will pull a patch for that into the HWPOISON series.
> >
> > That's not a problem - since the PG_poison line is be protected by
> > #ifdef CONFIG_MEMORY_FAILURE :-)
> >
> > > > > > > - PG_unevictable
> > > > > > > - PG_mlocked
> > > >
> > > > this 9 flags shouldn't exported.
> > > > I can't imazine administrator use what purpose those flags.
> > >
> > > I think an abstraced "PG_pinned" or somesuch flag that combines
> > > page lock, unevictable, mlocked would be useful for the administrator.
> >
> > The PG_PINNED abstraction risks hiding useful information.
> > The administrator may not only care about the pinned pages,
> > but also care _why_ they are pinned, i.e. ramfs.. or mlock?
> >
> > So it might be good to export them as is, with proper document.
> >
> > Here is the v2 patch, with flags for kernel hackers numbered from 32.
> > Comments are welcome!
> 
> if you can write good document, PG_unevictable is exportable.
> but PG_mlock isn't.
> 
> that's implementation tecknique of efficient unevictable pages for mlock.
> we can change the future.

Yup. That's in line with my vague feeling. For PG_unevictable we can
say that the page is owned by the unevictable (non-)lru and not a
candidate for LRU page reclaims. But for PG_mlock it's more about an
assistant for kernel optimizations and there are no guarantees...

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
