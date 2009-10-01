Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 32BD46B0055
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 01:56:34 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C2B5182C2A8
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 02:06:47 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VtsAwrDg2H96 for <linux-mm@kvack.org>;
	Fri,  2 Oct 2009 02:06:43 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A3B9E82C804
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 02:06:34 -0400 (EDT)
Message-Id: <20091001174033.576397715@gentwo.org>
Date: Thu, 01 Oct 2009 13:40:33 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V3 00/19] Introduce per cpu atomic operations and avoid per cpu address arithmetic
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

V2->V3:
- Available via git tree against latest upstream from
	 git://git.kernel.org/pub/scm/linux/kernel/git/christoph/percpu.git linus
- Rework SLUB per cpu operations. Get rid of dynamic DMA slab creation
  for CONFIG_ZONE_DMA
- Create fallback framework so that 64 bit ops on 32 bit platforms
  can fallback to the use of preempt or interrupt disable. 64 bit
  platforms can use 64 bit atomic per cpu ops.

V1->V2:
- Various minor fixes
- Add SLUB conversion
- Add Page allocator conversion
- Patch against the git tree of today

The patchset introduces various operations to allow efficient access
to per cpu variables for the current processor. Currently there is
no way in the core to calculate the address of the instance
of a per cpu variable without a table lookup. So we see a lot of

	per_cpu_ptr(x, smp_processor_id())

The patchset introduces a way to calculate the address using the offset
that is available in arch specific ways (register or special memory
locations) using

	this_cpu_ptr(x)

In addition macros are provided that can operate on per cpu
variables in a per cpu atomic way. With that scalars in structures
allocated with the new percpu allocator can be modified without disabling
preempt or interrupts. This works by generating a single instruction that
does both the relocation of the address to the proper percpu area and
the RMW action.

F.e.

	this_cpu_add(x->var, 20)

can be used to generate an instruction that uses a segment register for the
relocation of the per cpu address into the per cpu area of the current processor
and then increments the variable by 20. The instruction cannot be interrupted
and therefore the modification is atomic vs the cpu (it either happens or not).
Rescheduling or interrupt can only happen before or after the instruction.

Per cpu atomicness does not provide protection from concurrent modifications from
other processors. In general per cpu data is modified only from the processor
that the per cpu area is associated with. So per cpu atomicness provides a fast
and effective means of dealing with concurrency. It may allow development of
better fastpaths for allocators and other important subsystems.

The per cpu atomic RMW operations can be used to avoid having to dimension pointer
arrays in the allocators (patches for page allocator and slub are provided) and
avoid pointer lookups in the hot paths of the allocators thereby decreasing
latency of critical OS paths. The macros could be used to revise the critical
paths in the allocators to no longer need to disable interrupts (not included).

Per cpu atomic RMW operations are useful to decrease the overhead of counter
maintenance in the kernel. A this_cpu_inc() f.e. can generate a single
instruction that has no needs for registers on x86. preempt on / off can
be avoided in many places.

Patchset will reduce the code size and increase speed of operations for
dynamically allocated per cpu based statistics. A set of patches modifies
the fastpaths of the SLUB allocator reducing code size and cache footprint
through the per cpu atomic operations.

This patch depends on all arches supporting the new per cpu allocator.
IA64 still uses the old percpu allocator. Tejon has patches to fixup IA64
and it was approved by Tony Luck but the IA64 patches have not been merged yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
