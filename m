Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BC0096B004D
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 22:45:14 -0400 (EDT)
Subject: Filtering bits in set_pte_at()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 31 Oct 2009 13:44:41 +1100
Message-ID: <1256957081.6372.344.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Hi folks !

So I have a little problem on powerpc ... :-)

Due to the way I'm attempting to do my I$/D$ coherency on embedded
processors, I basically need to "filter out" _PAGE_EXEC in set_pte_at()
if the page isn't clean (PG_arch_1) and the set_pte_at() isn't caused by
an exec fault. etc...

The problem with that approach (current upstream) is that the generic
code tends not to read back the PTE, and thus still carries around a PTE
value that doesn't match what was actually written.

For example, we end up with update_mmu_cache() called with an "entry"
argument that has _PAGE_EXEC set while we really didn't write it into
the page tables. This will be problematic when we finally add preloading
directly into the TLB on those processors. There's at least one other
fishy case where huetlbfs would carry the PTE value around and later do
the wrong thing because pte_same() with the loaded one failed.

What do you suggest we do here ? Among the options at hand:

 - Ugly but would probably "just work" with the last amount of changes:
we could make set_pte_at() be a macro on powerpc that modifies it's PTE
value argument :-) (I -did- warn it was ugly !)

 - Another one slightly less bad that would require more work but mostly
mechanical arch header updates would be to make set_pte_at() return the
new value of the PTE, and thus change the callsites to something like:

	entry = set_pte_at(mm, addr, ptep, entry)

 - Any other idea ? We could use another PTE bit (_PAGE_HWEXEC), in
fact, we used to, but we are really short on PTE bits nowadays and I
freed that one up to get _PAGE_SPECIAL... _PAGE_EXEC is trivial to
"recover" from ptep_set_access_flags() on an exec fault or from the VM
prot.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
