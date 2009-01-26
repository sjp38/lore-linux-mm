Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 38C806B0044
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:50:14 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AC23C82C25F
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:51:52 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id u2qNvPDfq+Rg for <linux-mm@kvack.org>;
	Mon, 26 Jan 2009 12:51:52 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C119B82C260
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:51:47 -0500 (EST)
Date: Mon, 26 Jan 2009 12:46:49 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <200901240409.27449.nickpiggin@yahoo.com.au>
Message-ID: <alpine.DEB.1.10.0901261241070.22291@qirst.com>
References: <20090114150900.GC25401@wotan.suse.de> <alpine.DEB.1.10.0901231042380.32253@qirst.com> <20090123161017.GC14517@wotan.suse.de> <200901240409.27449.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, 24 Jan 2009, Nick Piggin wrote:

> > > SLUB can directly free an object to any slab page. "Queuing" on free via
> > > the per cpu slab is only possible if the object came from that per cpu
> > > slab. This is typically only the case for objects that were recently
> > > allocated.
> >
> > Ah yes ok that's right. But then you don't get LIFO allocation
> > behaviour for those cases.
>
> And actually really this all just stems from conceptually in fact you
> _do_ switch to a different queue (from the one being allocated from)
> to free the object if it is on a different page. Because you have a
> set of queues (a queue per-page). So freeing to a different queue is
> where you lose LIFO property.

Yes you basically go for locality instead of LIFO if the free does not hit
the per cpu slab. If the object is not in the per cpu slab then it is
likely that it had a long lifetime and thus LIFOness does not matter
too much. It is likely that many objects from that slab are going to be
freed at the same time. So the first free warms up the "queue" of the page
you are freeing to.

This is an increasingly important feature since memory chips prefer
allocations next to each other. Same page accesses are faster
in recent memory subsystems than random accesses across memory. LIFO used
to be better but we are increasingly getting into locality of access being
very important for access. Especially with the NUMA characteristics of the
existing AMD and upcoming Nehalem processors this will become much more
important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
