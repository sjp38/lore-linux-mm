Received: from flint.arm.linux.org.uk ([2002:d412:e8ba:1:201:2ff:fe14:8fad])
	by caramon.arm.linux.org.uk with asmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.32)
	id 1BEwDT-0002Ts-4D
	for linux-mm@kvack.org; Sat, 17 Apr 2004 21:15:07 +0100
Received: from rmk by flint.arm.linux.org.uk with local (Exim 4.32)
	id 1BEwDS-0001sT-9L
	for linux-mm@kvack.org; Sat, 17 Apr 2004 21:15:06 +0100
Date: Sat, 17 Apr 2004 21:15:06 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040417211506.C21974@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Marc Singer has been investigating some issues with ARM where we
appear to unmap pages which are in active use by the application.

While Bill Irwin has been looking at them (see
<http://marc.theaimsgroup.com/?l=linux-mm&m=108218227006508&w=2>),
I'm a little concerned about the page aging.

We implement the page age tracking by causing faults when the page is
marked "old".  It turns out that the implementation is "lazy" because
ptep_test_and_clear_young() does not flush the TLB to get rid of the
existing entry.  This means that even though we update the PTE to cause
a fault on the next access, the MMU doesn't see the change until:

(1) the next context switch which change user space mappings, or
(2) there is sufficient TLB replacement to cause older entries to
    be evicted. (where older does not depend on use of that entry.)

This same issue came up with 2.4 kernels, where it appears to be less
of a problem.  IIRC it was decided that the TLB flush when we mark
PTEs "old" was not necessary, even for systems which maintain the page
age state by software means, since we won't evict the page even after
unmapping it until we have unmapped it from all processes.

However, I'm led to believe that the current 2.6 VM is more agressive,
and needs the young bit to prevent pages being thrown out and needing
to be re-read from disk/network.  Essentially, I'm led to believe that
when a page is marked "old", it is up for eviction on the very next
rescan if it hasn't been marked "young".

So, it seems to me that maintaining the PTE age state is far more
important, and a lazy approach is no longer possible.

This in turn means that we need to replace ptep_test_and_clear_young()
with ptep_clear_flush_young(), which in turn means we need the VMA and
address.  However, this implies introducing more code into
page_referenced().

Comments?

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
