Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 24AF76B0098
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:36:43 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200908051136.682859934@firstfloor.org>
In-Reply-To: <200908051136.682859934@firstfloor.org>
Subject: [PATCH] [14/19] HWPOISON: Add PR_MCE_KILL prctl to control early kill behaviour per process
Message-Id: <20090805093641.DB176B15D8@basil.firstfloor.org>
Date: Wed,  5 Aug 2009 11:36:41 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>


This allows processes to override their early/late kill
behaviour on hardware memory errors.

Typically applications which are memory error aware is
better of with early kill (see the error as soon
as possible), all others with late kill (only
see the error when the error is really impacting execution)

There's a global sysctl, but this way an application
can set its specific policy.

We're using two bits, one to signify that the process
stated its intention and that 

I also made the prctl future proof by enforcing
the unused arguments are 0.

The state is inherited to children for now. I've
been considering to reset it on exec, but not done for
now (TBD).

Note this makes us officially run out of process flags
on 32bit, but the next patch can easily add another field.

Manpage patch will be supplied separately.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/prctl.h |    2 ++
 include/linux/sched.h |    2 ++
 kernel/sys.c          |   22 ++++++++++++++++++++++
 3 files changed, 26 insertions(+)

Index: linux/include/linux/sched.h
===================================================================
--- linux.orig/include/linux/sched.h
+++ linux/include/linux/sched.h
@@ -1674,6 +1674,7 @@ extern cputime_t task_gtime(struct task_
 #define PF_EXITPIDONE	0x00000008	/* pi exit done on shut down */
 #define PF_VCPU		0x00000010	/* I'm a virtual CPU */
 #define PF_FORKNOEXEC	0x00000040	/* forked but didn't exec */
+#define PF_MCE_PROCESS  0x00000080      /* process policy on mce errors */
 #define PF_SUPERPRIV	0x00000100	/* used super-user privileges */
 #define PF_DUMPCORE	0x00000200	/* dumped core */
 #define PF_SIGNALED	0x00000400	/* killed by a signal */
@@ -1693,6 +1694,7 @@ extern cputime_t task_gtime(struct task_
 #define PF_SPREAD_PAGE	0x01000000	/* Spread page cache over cpuset */
 #define PF_SPREAD_SLAB	0x02000000	/* Spread some slab caches over cpuset */
 #define PF_THREAD_BOUND	0x04000000	/* Thread bound to specific cpu */
+#define PF_MCE_EARLY    0x08000000      /* Early kill for mce process policy */
 #define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
 #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not count it as freezeable */
Index: linux/kernel/sys.c
===================================================================
--- linux.orig/kernel/sys.c
+++ linux/kernel/sys.c
@@ -1528,6 +1528,28 @@ SYSCALL_DEFINE5(prctl, int, option, unsi
 				current->timer_slack_ns = arg2;
 			error = 0;
 			break;
+		case PR_MCE_KILL:
+			if (arg4 | arg5)
+				return -EINVAL;
+			switch (arg2) {
+			case 0:
+				if (arg3 != 0)
+					return -EINVAL;
+				current->flags &= ~PF_MCE_PROCESS;
+				break;
+			case 1:
+				current->flags |= PF_MCE_PROCESS;
+				if (arg3 != 0)
+					current->flags |= PF_MCE_EARLY;
+				else
+					current->flags &= ~PF_MCE_EARLY;
+				break;
+			default:
+				return -EINVAL;
+			}
+			error = 0;
+			break;
+
 		default:
 			error = -EINVAL;
 			break;
Index: linux/include/linux/prctl.h
===================================================================
--- linux.orig/include/linux/prctl.h
+++ linux/include/linux/prctl.h
@@ -88,4 +88,6 @@
 #define PR_TASK_PERF_COUNTERS_DISABLE		31
 #define PR_TASK_PERF_COUNTERS_ENABLE		32
 
+#define PR_MCE_KILL	33
+
 #endif /* _LINUX_PRCTL_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
