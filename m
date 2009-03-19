Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C7DD86B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 21:32:18 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
Date: Thu, 19 Mar 2009 12:32:04 +1100
References: <49C148AF.5050601@goop.org>
In-Reply-To: <49C148AF.5050601@goop.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903191232.05459.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>, Avi Kivity <avi@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Hi Jeremy,

I think you got most of your questions already hashed out, but
I could make a suggestion...

On Thursday 19 March 2009 06:17:03 Jeremy Fitzhardinge wrote:
> Hi Nick,
>
> The comment in arch/x86/mm/gup.c:gup_get_pte() says:
>
> 	[...] What
> 	 * we do have is the guarantee that a pte will only either go from not
> 	 * present to present, or present to not present or both -- it will not
> 	 * switch to a completely different present page without a TLB flush in
> 	 * between; something that we are blocking by holding interrupts off.
>
>
> Disabling the interrupt will prevent the tlb flush IPI from coming in
> and flushing this cpu's tlb, but I don't see how it will prevent some
> other cpu from actually updating the pte in the pagetable, which is what
> we're concerned about here.

Yes, I don't believe it is possible to have a *new* pte installed until
the flush is done.


> Is this the only reason to disable
> interrupts?  Would we need to do it for the !PAE cases?

It has to pin page tables, and pin pages as well.


> Also, assuming that disabling the interrupt is enough to get the
> guarantees we need here, there's a Xen problem because we don't use IPIs
> for cross-cpu tlb flushes (well, it happens within Xen).  I'll have to
> think a bit about how to deal with that, but I'm thinking that we could
> add a per-cpu "tlb flushes blocked" flag, and maintain some kind of
> per-cpu deferred tlb flush count so we can get around to doing the flush
> eventually.
>
> But I want to make sure I understand the exact algorithm here.

FWIW, powerpc actually can flush tlbs without IPIs, and it also has
a gup_fast. powerpc RCU frees its page _tables_ so we can walk them,
and then I use speculative page references in order to be able to
take a reference on the page without having it pinned.

Turning gup_get_pte into a pvop would be a bit nasty because on !PAE
it is just a single load, and even on PAE it is pretty cheap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
