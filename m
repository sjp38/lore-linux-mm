Date: Tue, 26 Sep 2000 22:16:26 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000926221626.B19236@athlon.random>
References: <20000925163909.O22882@athlon.random> <Pine.LNX.4.21.0009251640330.9122-100000@elte.hu> <20000925170113.S22882@athlon.random> <20000926211016.A416@bug.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000926211016.A416@bug.ucw.cz>; from pavel@suse.cz on Tue, Sep 26, 2000 at 09:10:16PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Ingo Molnar <mingo@elte.hu>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 26, 2000 at 09:10:16PM +0200, Pavel Machek wrote:
> Hi!
> > > i talked about GFP_KERNEL, not GFP_USER. Even in the case of GFP_USER i
> > 
> > My bad, you're right I was talking about GFP_USER indeed.
> > 
> > But even GFP_KERNEL allocations like the init of a module or any other thing
> > that is static sized during production just checking the retval
> > looks be ok.
> 
> Okay, I'm user on small machine and I'm doing stupid thing: I've got
> 6MB ram, and I keep inserting modules. I insert module_1mb.o. Then I
> insert module_1mb.o. Repeat. How does it end? I think that
> kmalloc(GFP_KERNEL) *has* to return NULL at some point. 

I agree and that's what I said since the first place. GFP_KERNEL must return
null when the system is truly out of memory or the kernel will deadlock at that
time. In the sentence you quoted I meant that both GFP_USER and most GFP_KERNEL
could only keep to check the retval even in the long term to be correct
(checking for NULL, that in turn means GFP_KERNEL _will_ return NULL
eventually).

There's no need of special resource accounting for many static sized data
structure in kernel (this accounting is necessary only for some of the dynamic
things that grows and shrink during production and that can't be reclaimed
synchronously when memory goes low by blocking in the allocator, like
pagetables skbs on gbit ethernet and other things).

Not sure if at the end we'll need to account also the static parts to
get the dynamic part right.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
