Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 34FCE6B000E
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 13:50:30 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v14so8337623pgq.11
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 10:50:30 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0051.outbound.protection.outlook.com. [104.47.40.51])
        by mx.google.com with ESMTPS id s78si5118548pfj.259.2018.03.25.10.50.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Mar 2018 10:50:28 -0700 (PDT)
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: [PATCH 0/2] smp: don't kick CPUs running idle or nohz_full tasks 
Date: Sun, 25 Mar 2018 20:50:02 +0300
Message-Id: <20180325175004.28162-1-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: Yury Norov <ynorov@caviumnetworks.com>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

kick_all_cpus_sync() is used to broadcast IPIs to all online CPUs to force
them sync caches, TLB etc. It is is called only 3 times - from mm/slab,
arm64 and powerpc code.

With framework introduced in patch b8c17e6664c46 ("rcu: Maintain special
bits at bottom of ->dynticks counter") we can delay synchrosization work
for CPUs in extended quiescent state (idle or nohz_full userspace). 

As Paul E. McKenney wrote: 

--

Currently, IPIs are used to force other CPUs to invalidate their TLBs
in response to a kernel virtual-memory mapping change.  This works, but 
degrades both battery lifetime (for idle CPUs) and real-time response
(for nohz_full CPUs), and in addition results in unnecessary IPIs due to
the fact that CPUs executing in usermode are unaffected by stale kernel
mappings.  It would be better to cause a CPU executing in usermode to
wait until it is entering kernel mode to do the flush, first to avoid
interrupting usemode tasks and second to handle multiple flush requests
with a single flush in the case of a long-running user task.

--

For mm/slab and arm64 it looks safe to delay synchronization. This is done
in patch #2 by introducing kick_active_cpus_sync() function. For powerpc -
I'm not sure, and I'd like to ask powerpc people, is it safe to do same
also for that code? If so, we can completely drop kick_all_cpus_sync().

Yury Norov (2):
  rcu: declare rcu_eqs_special_set() in public header
  smp: introduce kick_active_cpus_sync()

 arch/arm64/kernel/insn.c |  2 +-
 include/linux/rcutree.h  |  1 +
 include/linux/smp.h      |  2 ++
 kernel/smp.c             | 24 ++++++++++++++++++++++++
 mm/slab.c                |  2 +-
 5 files changed, 29 insertions(+), 2 deletions(-)

-- 
2.14.1
