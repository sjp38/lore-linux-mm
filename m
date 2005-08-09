Date: Tue, 9 Aug 2005 21:49:04 +0200 (CEST)
From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
In-Reply-To: <Pine.LNX.4.61.0508091012480.10693@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.61.0508091657400.3743@scrub.home>
References: <42F57FCA.9040805@yahoo.com.au> <200508090710.00637.phillips@arcor.de>
 <1123562392.4370.112.camel@localhost> <42F83849.9090107@yahoo.com.au>
 <20050809080853.A25492@flint.arm.linux.org.uk>
 <Pine.LNX.4.61.0508091012480.10693@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Russell King <rmk+lkml@arm.linux.org.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, ncunningham@cyclades.com, Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 9 Aug 2005, Hugh Dickins wrote:

> PageReserved is about those pages which are managed by PageReserved.
> But quite what it means is unclear, one of the reasons to eliminate it.
> (Why is kernel text PageReserved?)

Short answer: /dev/mem
(Amazing that nobody mentioned it so far...)

To understand PageReserved it probably helps to know its history. One of 
the first users of this was X so it can map the video memory. This flag 
was the only way to distinguish which pages can be mapped this way, as 
remap_page_range() has no idea who owns the page. The vm also used this 
flag to skip these pages.

Later this was also used by drivers to map pages into user space using 
remap_page_range() (as alternative to the nopage handler). Only later came 
VM_RESERVED, IIRC it was first an optimization to avoid scanning these 
mappings.

So the actual meaning of this flag is that if it's set the page structure 
must not be changed and all fields must be treated as reserved. Only the 
owner of the page who did set this flag can do whatever he wants with it.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
