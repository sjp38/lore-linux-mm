Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BE5E95F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 20:43:24 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] SLQB slab allocator
Date: Tue, 3 Feb 2009 12:42:54 +1100
References: <20090114150900.GC25401@wotan.suse.de> <200901240409.27449.nickpiggin@yahoo.com.au> <alpine.DEB.1.10.0901261241070.22291@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0901261241070.22291@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902031242.56206.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 27 January 2009 04:46:49 Christoph Lameter wrote:
> On Sat, 24 Jan 2009, Nick Piggin wrote:
> > > > SLUB can directly free an object to any slab page. "Queuing" on free
> > > > via the per cpu slab is only possible if the object came from that
> > > > per cpu slab. This is typically only the case for objects that were
> > > > recently allocated.
> > >
> > > Ah yes ok that's right. But then you don't get LIFO allocation
> > > behaviour for those cases.
> >
> > And actually really this all just stems from conceptually in fact you
> > _do_ switch to a different queue (from the one being allocated from)
> > to free the object if it is on a different page. Because you have a
> > set of queues (a queue per-page). So freeing to a different queue is
> > where you lose LIFO property.
>
> Yes you basically go for locality instead of LIFO if the free does not hit
> the per cpu slab. If the object is not in the per cpu slab then it is
> likely that it had a long lifetime and thus LIFOness does not matter
> too much. It is likely that many objects from that slab are going to be
> freed at the same time. So the first free warms up the "queue" of the page
> you are freeing to.

I don't really understand this. It is easy to lose cache hotness information.
Free two objects from different pages. The first one to be freed is likely
to be cache hot, but it will not be allocated again (any time soon).


> This is an increasingly important feature since memory chips prefer
> allocations next to each other. Same page accesses are faster
> in recent memory subsystems than random accesses across memory.

DRAM chips? How about avoiding the problem and keeping the objects in cache
so you don't have to go to RAM.


> LIFO used
> to be better but we are increasingly getting into locality of access being
> very important for access.

Locality of access includes temporal locality. Which is very important. Which
SLUB doesn't do as well at.


> Especially with the NUMA characteristics of the
> existing AMD and upcoming Nehalem processors this will become much more
> important.

Can you demonstrate that LIFO used to be better but no longer is? What
NUMA characteristics are you talking about?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
