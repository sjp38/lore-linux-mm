Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id EF14C6B0036
	for <linux-mm@kvack.org>; Fri, 24 May 2013 10:18:15 -0400 (EDT)
Date: Fri, 24 May 2013 17:18:37 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 10/11] kernel: drop voluntary schedule from might_fault
Message-ID: <1369404522-12927-10-git-send-email-mst@redhat.com>
References: <cover.1368702323.git.mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1368702323.git.mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

might_fault is called from functions like copy_to_user
which most callers expect to be very fast, like
a couple of instructions.  So functions like memcpy_toiovec call them
many times in a loop.
But might_fault calls might_sleep() and with CONFIG_PREEMPT_VOLUNTARY
this results in a function call.

Let's not do this - just call __might_sleep that produces
a diagnostic for sleep within atomic, but drop
might_preempt().

Here's a test sending traffic between the VM and the host,
host is built with CONFIG_PREEMPT_VOLUNTARY:
Before:
	incoming: 7122.77   Mb/s
	outgoing: 8480.37   Mb/s
after:
	incoming: 8619.24   Mb/s
	outgoing: 9455.42   Mb/s

As a side effect, this fixes an issue pointed
out by Ingo: might_fault might schedule differently
depending on PROVE_LOCKING. Now there's no
preemption point in both cases, so it's consistent.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/kernel.h | 2 +-
 mm/memory.c            | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index e96329c..c514c06 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -198,7 +198,7 @@ void might_fault(void);
 #else
 static inline void might_fault(void)
 {
-	might_sleep();
+	__might_sleep(__FILE__, __LINE__, 0);
 }
 #endif
 
diff --git a/mm/memory.c b/mm/memory.c
index 6dc1882..c1f190f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4222,7 +4222,8 @@ void might_fault(void)
 	if (segment_eq(get_fs(), KERNEL_DS))
 		return;
 
-	might_sleep();
+	__might_sleep(__FILE__, __LINE__, 0);
+
 	/*
 	 * it would be nicer only to annotate paths which are not under
 	 * pagefault_disable, however that requires a larger audit and
-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
