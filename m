Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 00C0E6B00B2
	for <linux-mm@kvack.org>; Sun, 22 Feb 2009 23:14:36 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
Date: Mon, 23 Feb 2009 15:14:00 +1100
References: <49416494.6040009@goop.org> <200902200441.08541.nickpiggin@yahoo.com.au> <499DAEE4.8010507@goop.org>
In-Reply-To: <499DAEE4.8010507@goop.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902231514.01965.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Friday 20 February 2009 06:11:32 Jeremy Fitzhardinge wrote:
> Nick Piggin wrote:
> > Then what is the point of the vm_unmap_aliases? If you are doing it
> > for security it won't work because other CPUs might still be able
> > to write through dangling TLBs. If you are not doing it for
> > security then it does not need to be done at all.
>
> Xen will make sure any danging tlb entries are flushed before handing
> the page out to anyone else.
>
> > Unless it is something strange that Xen does with the page table
> > structure and you just need to get rid of those?
>
> Yeah.  A pte pointing at a page holds a reference on it, saying that it
> belongs to the domain.  You can't return it to Xen until the refcount is 0.

OK. Then I will remember to find some time to get the interrupt
safe patches working. I wonder why you can't just return it to
Xen when (or have Xen hold it somewhere until) the refcount
reaches 0?

Anyway...

> > Or... what if we just allow a compile and/or boot time flag to direct
> > that it does not want lazy vmap unmapping and it will just revert to
> > synchronous unmapping? If Xen needs lots of flushing anyway it might
> > not be a win anyway.
>
> That may be worth considering.

... in the meantime, shall we just do this for Xen? It is probably
safer and may end up with no worse performance on Xen anyway. If
we get more vmap users and it becomes important, you could look at
more sophisticated ways of doing this. Eg. a page could be flagged
if it potentially has lazy vmaps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
