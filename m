Date: Mon, 25 Sep 2000 16:04:12 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000925160412.G22882@athlon.random>
References: <20000925153050.C22882@athlon.random> <Pine.LNX.4.21.0009251529010.6224-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251529010.6224-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 03:39:51PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 03:39:51PM +0200, Ingo Molnar wrote:
> Andrea, if you really mean this then you should not be let near the VM
> balancing code :-)

What I mean is that the VM balancing is in the lower layer that knows anything
about the per-socket gigabit ethernet skbs limits, the limit should live at the
higher layer. For most code just checking for NULL in GFP is fine (for example
do_anonymous_page). It's the caller (not the VM balancing developer) that
shouldn't be let near his code if it allows his code to fill all the physical
ram with his stuff causing the machine to run OOM.

> > Most dynamic big caches and kernel data can be shrinked dynamically
> > during memory pressure (pheraps except skbs and I agree that for skbs
> > on gigabit ethernet the thing is a little different).
> 
> a big 'except'. You dont need gigabit for that, to the contrary, if the

I talked with Alexey about this and it seems the best way is to have a
per-socket reservation of clean cache in function of the receive window.  So we
don't need an huge atomic pool but we can have a special lru with an irq
spinlock that is able to shrink cache from irq as well.

> about how many D.O.S. attacks there are possible without implicit or
> explicit bean counting.

Again: the bean counting and all the limit happens at the higher layer.  I
shouldn't know anything about it when I play with the lower layer GFP memory
balancing code.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
