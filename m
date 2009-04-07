Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BECE95F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 11:09:55 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Message-Id: <20090407509.382219156@firstfloor.org>
Subject: [PATCH] [0/16] POISON: Intro
Date: Tue,  7 Apr 2009 17:09:56 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


Upcoming Intel CPUs have support for recovering from some memory errors. This
requires the OS to declare a page "poisoned", kill the processes associated
with it and avoid using it in the future. This patchkit implements
the necessary infrastructure in the VM.

To quote the overview comment:

 * High level machine check handler. Handles pages reported by the
 * hardware as being corrupted usually due to a 2bit ECC memory or cache
 * failure.
 *
 * This focusses on pages detected as corrupted in the background.
 * When the current CPU tries to consume corruption the currently
 * running process can just be killed directly instead. This implies
 * that if the error cannot be handled for some reason it's safe to
 * just ignore it because no corruption has been consumed yet. Instead
 * when that happens another machine check will happen.
 *
 * Handles page cache pages in various states. The tricky part
 * here is that we can access any page asynchronous to other VM
 * users, because memory failures could happen anytime and anywhere,
 * possibly violating some of their assumptions. This is why this code
 * has to be extremely careful. Generally it tries to use normal locking
 * rules, as in get the standard locks, even if that means the
 * error handling takes potentially a long time.
 *
 * Some of the operations here are somewhat inefficient and have non
 * linear algorithmic complexity, because the data structures have not
 * been optimized for this case. This is in particular the case
 * for the mapping from a vma to a process. Since this case is expected
 * to be rare we hope we can get away with this.

The code consists of a the high level handler in mm/memory-failure.c, 
a new page poison bit and various checks in the VM to handle poisoned
pages.

The main target right now is KVM guests, but it works for all kinds
of applications.

For the KVM use there was need for a new signal type so that
KVM can inject the machine check into the guest with the proper
address. This in theory allows other applications to handle
memory failures too. The expection is that near all applications
won't do that, but some very specialized ones might. 

This is not fully complete yet, in particular there are still ways
to access poison through various ways (crash dump, /proc/kcore etc.)
that need to be plugged too.

Also undoubtedly the high level handler still has bugs and cases
it cannot recover from. For example nonlinear mappings deadlock right now
and a few other cases lose references. Huge pages are not supported
yet. Any additional testing, reviewing etc. welcome. 

The patch series requires the earlier x86 MCE feature series for the x86
specific action optional part. The code can be tested without the x86 specific
part using the injector, this only requires to enable the Kconfig entry
manually in some Kconfig file (by default it is implicitely enabled
by the architecture)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
