Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8ED156B003D
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 04:11:03 -0400 (EDT)
Date: Thu, 23 Apr 2009 16:10:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] proc: export more page flags in /proc/kpageflags
	(take 3)
Message-ID: <20090423081047.GA18898@localhost>
References: <20090414071159.GV14687@one.firstfloor.org> <20090415131800.GA11191@localhost> <20090416111108.AC55.A69D9226@jp.fujitsu.com> <20090423022625.GA8822@localhost> <20090423074848.GJ13896@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090423074848.GJ13896@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 23, 2009 at 03:48:48PM +0800, Andi Kleen wrote:
> On Thu, Apr 23, 2009 at 10:26:25AM +0800, Wu Fengguang wrote:
> > Andi and KOSAKI: can we hopefully reach harmony of opinions on this version?
> 
> Haven't read the patch sorry, just comments on the text.
> 
> > 
> > Export 9 page flags in /proc/kpageflags, and 8 more for kernel developers.
> > 
> > 1) for kernel hackers (on CONFIG_DEBUG_KERNEL)
> >    - all available page flags are exported, and
> >    - exported as is
> 
> So the interface changes based on that option? That would
> be unfortunate if true.

To be exact, it's "extend the view" on CONFIG_DEBUG_KERNEL.  The
meanings won't change, you simply see more flags that didn't turn up
when !CONFIG_DEBUG_KERNEL.

> > 2) for admins and end users
> >    - only the more `well known' flags are exported:
> > 	11. KPF_MMAP		(pseudo flag) memory mapped page
> > 	12. KPF_ANON		(pseudo flag) memory mapped page (anonymous)
> > 	13. KPF_SWAPCACHE	page is in swap cache
> > 	14. KPF_SWAPBACKED	page is swap/RAM backed
> > 	15. KPF_COMPOUND_HEAD	(*)
> > 	16. KPF_COMPOUND_TAIL	(*)
> > 	17. KPF_UNEVICTABLE	page is in the unevictable LRU list
> > 	18. KPF_POISON		hardware detected corruption
> > 	19. KPF_NOPAGE		(pseudo flag) no page frame at the address
> 
> I think DIRTY should be in that list.

It has been there.  ERROR, DIRTY and ACTIVE were exported at the time
this interface was initially introduced:

        #define KPF_LOCKED              0
==>     #define KPF_ERROR               1
        #define KPF_REFERENCED          2
        #define KPF_UPTODATE            3
==>     #define KPF_DIRTY               4
        #define KPF_LRU                 5
==>     #define KPF_ACTIVE              6
        #define KPF_SLAB                7
        #define KPF_WRITEBACK           8
        #define KPF_RECLAIM             9
        #define KPF_BUDDY               10

> > 
> > 	(*) For compound pages, exporting _both_ head/tail info enables
> > 	    users to tell where a compound page starts/ends, and its order.
> > 
> >    - limit flags to their typical usage scenario, as indicated by KOSAKI:
> > 	- LRU pages: only export relevant flags
> > 		- PG_lru
> > 		- PG_unevictable
> > 		- PG_active
> 
> And active too because it's already exported in /proc/meminfo

ditto
 
> > 		- PG_dirty
> > 		- PG_uptodate
> > 		- PG_writeback
> > 	- SLAB pages: mask out overloaded flags:
> > 		- PG_error
> 
> Error should be exported too, it has straight forward semantics 
> and could be useful to the admin.

ditto
 
> > 	- admins may wonder where all the compound pages gone - the use of
> > 	  compound pages in SLUB might have some real world relevance, so that
> > 	  end users want to be aware of this behavior
> 
> I'm not sure why it uses compound pages at all. It would be nicer
> if compound pages were limited to huge pages, and then start/tail
> wouldn't be needed.

Good idea.

Would you recommend a good way to identify huge pages?
Test by page order, or by (dtor == free_huge_page)?      

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
