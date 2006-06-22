Date: Thu, 22 Jun 2006 14:31:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060622213117.32391.92293.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060622213102.32391.19996.sendpatchset@schroedinger.engr.sgi.com>
References: <20060622213102.32391.19996.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 3/4] Use SLAB_DESTROY_BY_RCU
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "Paul E. McKenney" <paulmck@us.ibm.com>, Jens Axboe <axboe@suse.de>, Hugh Dickins <hugh@veritas.com>, Dave Miller <davem@redhat.com>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

files RCU optimization: use SLAB_DESTROY_BY_RCU

Add a constructor for filp_cache in order to avoid having
to deal with races regarding atomic increments during object
handling. Also allows us to set up locks only one time
for multiple uses of the same slab object.

Get rid of the explicit RCU free code.

Modify fget to check that we have gotten the correct element.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17/fs/file_table.c
===================================================================
--- linux-2.6.17.orig/fs/file_table.c	2006-06-22 14:03:57.773630982 -0700
+++ linux-2.6.17/fs/file_table.c	2006-06-22 14:09:51.989993240 -0700
@@ -33,24 +33,35 @@ struct files_stat_struct files_stat = {
 /* public. Not pretty! */
 __cacheline_aligned_in_smp DEFINE_SPINLOCK(files_lock);
 
+static void filp_constructor(void *data, struct kmem_cache *cache,
+			unsigned long flags)
+{
+	struct file *f = data;
+
+	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) !=
+		SLAB_CTOR_CONSTRUCTOR)
+			return;
+
+	memset(f, 0, sizeof(*f));
+	INIT_LIST_HEAD(&f->f_u.fu_list);
+	atomic_set(&f->f_count, 0);
+	rwlock_init(&f->f_owner.lock);
+	eventpoll_init_file(f);
+}
+
 static struct percpu_counter nr_files __cacheline_aligned_in_smp;
 
 void __init files_init_early(void)
 {
 	filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
-}
-
-static inline void file_free_rcu(struct rcu_head *head)
-{
-	struct file *f =  container_of(head, struct file, f_u.fu_rcuhead);
-	kmem_cache_free(filp_cachep, f);
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_DESTROY_BY_RCU,
+			filp_constructor, NULL);
 }
 
 static inline void file_free(struct file *f)
 {
 	percpu_counter_dec(&nr_files);
-	call_rcu(&f->f_u.fu_rcuhead, file_free_rcu);
+	kmem_cache_free(filp_cachep, f);
 }
 
 /*
@@ -115,18 +126,15 @@ struct file *get_empty_filp(void)
 		goto fail;
 
 	percpu_counter_inc(&nr_files);
-	memset(f, 0, sizeof(*f));
 	if (security_file_alloc(f))
 		goto fail_sec;
-
 	tsk = current;
-	INIT_LIST_HEAD(&f->f_u.fu_list);
-	atomic_set(&f->f_count, 1);
-	rwlock_init(&f->f_owner.lock);
 	f->f_uid = tsk->fsuid;
 	f->f_gid = tsk->fsgid;
-	eventpoll_init_file(f);
-	/* f->f_version: 0 */
+	f->f_owner.signum = 0;
+	f->f_version = 0;
+	f->private_data = NULL;
+	atomic_inc(&f->f_count);	/* We reached a definite state */
 	return f;
 
 over:
@@ -202,6 +210,14 @@ struct file fastcall *fget(unsigned int 
 			rcu_read_unlock();
 			return NULL;
 		}
+		/*
+		 * Now we have a stable reference to an object.
+		 * Check if RCU switched it from under us.
+		 */
+		if (unlikely(file != fcheck_files(files, fd))) {
+			put_filp(file);
+			file = NULL;
+		}
 	}
 	rcu_read_unlock();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
