Message-Id: <20070306013815.951032000@taijtu.programming.kicks-ass.net>
Date: Tue, 06 Mar 2007 02:38:15 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 0/5] Lockless vma lookups
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@engr.sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

mmap_sem is a scalability problem on LargeSMP due to cacheline bouncing
and -rt due to is RW nature.

The following (rough) patches implement an alternative approach to handling
vmas.

The RB-tree is discarted in favour of an B+tree like structure because RB-tree
rotations are RCU unfriendly and the in-place nodes as used don't help.

This allows for RCU lookups of vmas, furthermore they are pinned using a 
reference count. Modifiers of the vma structure will have to wait till it
drops.

The code as presented is nowhere near done; but it boots to a full KDE desktop
on my i386-up laptop and reached user-space and compiles a kernel on 
x86_64-smp (its having trouble starting a fancy X desktop though).

I'm posting this as a request for comments on the general direction.

Post early, avoid isolation, blabla ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
