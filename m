Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B19726B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 15:17:10 -0400 (EDT)
Message-ID: <49C148AF.5050601@goop.org>
Date: Wed, 18 Mar 2009 12:17:03 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Question about x86/mm/gup.c's use of disabled interrupts
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Hi Nick,

The comment in arch/x86/mm/gup.c:gup_get_pte() says:

	[...] What
	 * we do have is the guarantee that a pte will only either go from not
	 * present to present, or present to not present or both -- it will not
	 * switch to a completely different present page without a TLB flush in
	 * between; something that we are blocking by holding interrupts off.


Disabling the interrupt will prevent the tlb flush IPI from coming in 
and flushing this cpu's tlb, but I don't see how it will prevent some 
other cpu from actually updating the pte in the pagetable, which is what 
we're concerned about here.  Is this the only reason to disable 
interrupts?  Would we need to do it for the !PAE cases?

Also, assuming that disabling the interrupt is enough to get the 
guarantees we need here, there's a Xen problem because we don't use IPIs 
for cross-cpu tlb flushes (well, it happens within Xen).  I'll have to 
think a bit about how to deal with that, but I'm thinking that we could 
add a per-cpu "tlb flushes blocked" flag, and maintain some kind of 
per-cpu deferred tlb flush count so we can get around to doing the flush 
eventually.

But I want to make sure I understand the exact algorithm here.

(I couldn't find an instance of a pte update going from present->present 
anyway; the only caller of set_pte_present is set_pte_vaddr which only 
operates on kernel mappings, so perhaps this is moot.  Oh, look, 
native_set_pte_present thinks its only called on user mappings...  In 
fact set_pte_present seems to have completely lost its rationale for 
existing.)

Thanks,
    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
