Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1ECF26B027A
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:17:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e64so10085839pfk.0
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:17:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j11si534870plt.133.2017.10.20.05.16.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:16:58 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 11/15] nsproxy: convert nsproxy.count to refcount_t
Date: Fri, 20 Oct 2017 15:15:53 +0300
Message-Id: <1508501757-15784-12-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
References: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, acme@kernel.org, alexander.shishkin@linux.intel.com, eparis@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, keescook@chromium.org, tglx@linutronix.de, dvhart@infradead.org, ebiederm@xmission.com, linux-mm@kvack.org, axboe@kernel.dk, Elena Reshetova <elena.reshetova@intel.com>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable nsproxy.count is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 include/linux/nsproxy.h | 6 +++---
 kernel/nsproxy.c        | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index ac0d65b..f862ba8 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -28,7 +28,7 @@ struct fs_struct;
  * nsproxy is copied.
  */
 struct nsproxy {
-	atomic_t count;
+	refcount_t count;
 	struct uts_namespace *uts_ns;
 	struct ipc_namespace *ipc_ns;
 	struct mnt_namespace *mnt_ns;
@@ -74,14 +74,14 @@ int __init nsproxy_cache_init(void);
 
 static inline void put_nsproxy(struct nsproxy *ns)
 {
-	if (atomic_dec_and_test(&ns->count)) {
+	if (refcount_dec_and_test(&ns->count)) {
 		free_nsproxy(ns);
 	}
 }
 
 static inline void get_nsproxy(struct nsproxy *ns)
 {
-	atomic_inc(&ns->count);
+	refcount_inc(&ns->count);
 }
 
 #endif
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index f6c5d33..5bfe691 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -31,7 +31,7 @@
 static struct kmem_cache *nsproxy_cachep;
 
 struct nsproxy init_nsproxy = {
-	.count			= ATOMIC_INIT(1),
+	.count			= REFCOUNT_INIT(1),
 	.uts_ns			= &init_uts_ns,
 #if defined(CONFIG_POSIX_MQUEUE) || defined(CONFIG_SYSVIPC)
 	.ipc_ns			= &init_ipc_ns,
@@ -52,7 +52,7 @@ static inline struct nsproxy *create_nsproxy(void)
 
 	nsproxy = kmem_cache_alloc(nsproxy_cachep, GFP_KERNEL);
 	if (nsproxy)
-		atomic_set(&nsproxy->count, 1);
+		refcount_set(&nsproxy->count, 1);
 	return nsproxy;
 }
 
@@ -225,7 +225,7 @@ void switch_task_namespaces(struct task_struct *p, struct nsproxy *new)
 	p->nsproxy = new;
 	task_unlock(p);
 
-	if (ns && atomic_dec_and_test(&ns->count))
+	if (ns && refcount_dec_and_test(&ns->count))
 		free_nsproxy(ns);
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
