Received: from toip5.srvr.bell.ca ([209.226.175.88])
          by tomts40-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20071031015252.KLYV1617.tomts40-srv.bellnexxia.net@toip5.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 30 Oct 2007 21:52:52 -0400
Date: Tue, 30 Oct 2007 21:52:51 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [PATCH] local_t Documentation update 2
Message-ID: <20071031015250.GA884@Krystal>
References: <20071028033156.022983073@sgi.com> <20071028033300.240703208@sgi.com> <20071030114933.904a4cf8.akpm@linux-foundation.org> <Pine.LNX.4.64.0710301155240.12746@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710301155240.12746@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, linux-arch@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

local_t Documentation update 2

(this patch seems to have fallen off the grid, but is still providing
useful information. It applies to 2.6.23-mm1.)

Grant Grundler was asking for more detail about correct usage of local atomic
operations and suggested adding the resulting summary to local_ops.txt.

"Please add a bit more detail. If DaveM is correct (he normally is), then
there must be limits on how the local_t can be used in the kernel process
and interrupt contexts. I'd like those rules spelled out very clearly
since it's easy to get wrong and tracking down such a bug is quite painful."

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
---
 Documentation/local_ops.txt |   23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

Index: linux-2.6-lttng/Documentation/local_ops.txt
===================================================================
--- linux-2.6-lttng.orig/Documentation/local_ops.txt	2007-09-04 11:53:23.000000000 -0400
+++ linux-2.6-lttng/Documentation/local_ops.txt	2007-09-04 12:19:31.000000000 -0400
@@ -68,6 +68,29 @@ typedef struct { atomic_long_t a; } loca
   variable can be read when reading some _other_ cpu's variables.
 
 
+* Rules to follow when using local atomic operations
+
+- Variables touched by local ops must be per cpu variables.
+- _Only_ the CPU owner of these variables must write to them.
+- This CPU can use local ops from any context (process, irq, softirq, nmi, ...)
+  to update its local_t variables.
+- Preemption (or interrupts) must be disabled when using local ops in
+  process context to   make sure the process won't be migrated to a
+  different CPU between getting the per-cpu variable and doing the
+  actual local op.
+- When using local ops in interrupt context, no special care must be
+  taken on a mainline kernel, since they will run on the local CPU with
+  preemption already disabled. I suggest, however, to explicitly
+  disable preemption anyway to make sure it will still work correctly on
+  -rt kernels.
+- Reading the local cpu variable will provide the current copy of the
+  variable.
+- Reads of these variables can be done from any CPU, because updates to
+  "long", aligned, variables are always atomic. Since no memory
+  synchronization is done by the writer CPU, an outdated copy of the
+  variable can be read when reading some _other_ cpu's variables.
+
+
 * How to use local atomic operations
 
 #include <linux/percpu.h>
-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
