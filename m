Subject: update_mmu_cache(): fault or not fault ?
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Mon, 26 Sep 2005 16:22:05 +1000
Message-Id: <1127715725.15882.43.camel@gaston>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi !

I been toying with using update_mmu_cache() to actually fill the TLB
entry directly when taking a fault on some PPC CPUs with software TLB
reload (among other optims I have in mind). Most of CPUs with software
TLB reload currently take double TLB faults on linux page faults.

The problem is that want to only ever do that kind of hw TLB pre-fill
when update_mmu_cache() is called as the result an actual fault.
However, for some reasons that I'm not 100% sure about (*)
update_mmu_cache() is called from other places, typically in mm/fremap.c
which aren't directly results of faults.

So I suggest adding an argument to it "int is_fault", that would
basically be '1' on all the call sites in mm/memory.c and '0' in all the
call sites in mm/fremap.c.

Any objection, comment, whatever, before I come up with a patch adding
it to all archs ?

Ben.

(*) I suspect because update_mmu_cache() has historically been hijacked
to do the icache/dcache sync on some architecture, and thus was added to
all call sites that can populate a PTE out of the blue, though it's a
bit dodgy that it's not called in mremap(), thus people with hw execute
permission using that trick should be careful... but then, if you have
execute permission, you probably don't need that trick. This is what
ppc32 and ppc64 old older CPUs do, in an SMP racy way even ;) But that's
a different discussion and I'll have to fix it some day.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
