Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BE64B6B003D
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 03:44:34 -0400 (EDT)
Date: Thu, 23 Apr 2009 09:48:48 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] proc: export more page flags in /proc/kpageflags (take 3)
Message-ID: <20090423074848.GJ13896@one.firstfloor.org>
References: <20090414071159.GV14687@one.firstfloor.org> <20090415131800.GA11191@localhost> <20090416111108.AC55.A69D9226@jp.fujitsu.com> <20090423022625.GA8822@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090423022625.GA8822@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 23, 2009 at 10:26:25AM +0800, Wu Fengguang wrote:
> Andi and KOSAKI: can we hopefully reach harmony of opinions on this version?

Haven't read the patch sorry, just comments on the text.

> 
> Export 9 page flags in /proc/kpageflags, and 8 more for kernel developers.
> 
> 1) for kernel hackers (on CONFIG_DEBUG_KERNEL)
>    - all available page flags are exported, and
>    - exported as is

So the interface changes based on that option? That would
be unfortunate if true.

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

I think DIRTY should be in that list.

> 
> 	(*) For compound pages, exporting _both_ head/tail info enables
> 	    users to tell where a compound page starts/ends, and its order.
> 
>    - limit flags to their typical usage scenario, as indicated by KOSAKI:
> 	- LRU pages: only export relevant flags
> 		- PG_lru
> 		- PG_unevictable
> 		- PG_active

And active too because it's already exported in /proc/meminfo

> 		- PG_dirty
> 		- PG_uptodate
> 		- PG_writeback
> 	- SLAB pages: mask out overloaded flags:
> 		- PG_error

Error should be exported too, it has straight forward semantics 
and could be useful to the admin.


> 	- admins may wonder where all the compound pages gone - the use of
> 	  compound pages in SLUB might have some real world relevance, so that
> 	  end users want to be aware of this behavior

I'm not sure why it uses compound pages at all. It would be nicer
if compound pages were limited to huge pages, and then start/tail
wouldn't be needed.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
