Message-ID: <48501D7C.5050600@goop.org>
Date: Wed, 11 Jun 2008 19:46:20 +0100
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [rfc][patch] mm: vmap rewrite
References: <20080605102015.GA11366@wotan.suse.de> <484AC779.1070803@goop.org> <20080610025312.GC19404@wotan.suse.de>
In-Reply-To: <20080610025312.GC19404@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> It's harder than that even, because we don't own the page flags, so then
> clearing the PG_kalias bit would require that we make all page flags ops
> atomic in all parts of the kernel. Obviously not going to happen.
>
> The other thing we could do is have vmap layer keep some p->v translations
> around (actually it doesn't even need to go all the way to v, just a single
> bit would suffice) So I guess this would be like another page flag, but
> without the atomicity problem and without me getting angry at using another
> flag ;) Still, I'd rather not do this and slow everything else down.
>   

Yeah.  It's a bit awkward to maintain a secondary structure just to deal 
with the confluence of two edge cases (running Xen + reusing an aliased 
page in a pagetable).

> It could be switched on at runtime if Xen is running perhaps. Or the other
> thing Xen could do is keep a cache of unaliased page table pages. You
> could fill it up N pages at a time, and just do a single unmap_aliases call
> to sanitize them all; also, clean pages returned from pagetables could be
> reused. Like the quicklists things.
>   

Hm, that wouldn't be too bad (so long as it doesn't end up hiding 
gigabytes of memory away from the rest of the system ;).

> Or: doesn't the host have to do its own alias check anyway? In case of an
> AWOL guest? Why not just reuse that and trap back into the guest to fix it
> up?

That's possible, but awkward.  In many cases these updates will be 
batched, so it would become a matter of issuing a batch, then picking 
through the results to see what worked and what failed.  I suppose I 
could just do the simple flush and then if that turns out too expensive, 
do the submit-and-retry approach.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
