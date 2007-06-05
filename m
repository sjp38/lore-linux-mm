Message-Id: <20070605150523.786600000@chello.nl>
Date: Tue, 05 Jun 2007 17:05:23 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 0/4] no MAX_ARG_PAGES
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Ollie Wild <aaw@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

This patch-set aims at removing the current limit on argv+env space aka.
MAX_ARG_PAGES.

The new mm is created before the binfmt code runs, the stack is placed at the
highest address supported by that architecture.

The argv+env data is then copied from the old mm into the new mm (which is
inactive at that time - this introduces some cache coherency issues).

Then we run the binfmt code, which will compute the final stack address. The
existing stack will be moved downwards (or upwards on PA-RISC) to the desired
place.

This 'trick' heavily relies on the MMU, so for no-MMU archs we stay with the
old approach.

Tested-on: i386, ia64, frv, parisc, ppc64, um, x86_64

Patches against: .22-rc4

-- 
Changes since last time:

 - fixed ia64
     ( va-space constraints )

 - fixed ia64 CONFIG_IA32_SUPPORT
     ( brown paper bags and more va-space constraints)

 - fixed powerpc
     ( address limit on stack extention )

 - removed audit_kill() in favour of audit_panic()

 - nicely spit out the patches

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
