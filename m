Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id DC6CF6B0072
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 12:26:19 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so297284bkc.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 09:26:19 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 13/16] lockd: use new hashtable implementation
Date: Tue, 14 Aug 2012 18:24:47 +0200
Message-Id: <1344961490-4068-14-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

Switch lockd to use the new hashtable implementation. This reduces the amount of
generic unrelated code in lockd.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 fs/lockd/svcsubs.c |   58 +++++++++++++++++++++++++--------------------------
 1 files changed, 28 insertions(+), 30 deletions(-)

diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 0deb5f6..26c90c8 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -20,6 +20,7 @@
 #include <linux/lockd/share.h>
 #include <linux/module.h>
 #include <linux/mount.h>
+#include <linux/hashtable.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVCSUBS
 
@@ -28,8 +29,7 @@
  * Global file hash table
  */
 #define FILE_HASH_BITS		7
-#define FILE_NRHASH		(1<<FILE_HASH_BITS)
-static struct hlist_head	nlm_files[FILE_NRHASH];
+static DEFINE_HASHTABLE(nlm_files, FILE_HASH_BITS);
 static DEFINE_MUTEX(nlm_file_mutex);
 
 #ifdef NFSD_DEBUG
@@ -68,7 +68,7 @@ static inline unsigned int file_hash(struct nfs_fh *f)
 	int i;
 	for (i=0; i<NFS2_FHSIZE;i++)
 		tmp += f->data[i];
-	return tmp & (FILE_NRHASH - 1);
+	return tmp;
 }
 
 /*
@@ -86,17 +86,17 @@ nlm_lookup_file(struct svc_rqst *rqstp, struct nlm_file **result,
 {
 	struct hlist_node *pos;
 	struct nlm_file	*file;
-	unsigned int	hash;
+	unsigned int	key;
 	__be32		nfserr;
 
 	nlm_debug_print_fh("nlm_lookup_file", f);
 
-	hash = file_hash(f);
+	key = file_hash(f);
 
 	/* Lock file table */
 	mutex_lock(&nlm_file_mutex);
 
-	hlist_for_each_entry(file, pos, &nlm_files[hash], f_list)
+	hash_for_each_possible(nlm_files, file, pos, f_list, file_hash(f))
 		if (!nfs_compare_fh(&file->f_handle, f))
 			goto found;
 
@@ -123,7 +123,7 @@ nlm_lookup_file(struct svc_rqst *rqstp, struct nlm_file **result,
 		goto out_free;
 	}
 
-	hlist_add_head(&file->f_list, &nlm_files[hash]);
+	hash_add(nlm_files, &file->f_list, key);
 
 found:
 	dprintk("lockd: found file %p (count %d)\n", file, file->f_count);
@@ -147,8 +147,8 @@ static inline void
 nlm_delete_file(struct nlm_file *file)
 {
 	nlm_debug_print_file("closing file", file);
-	if (!hlist_unhashed(&file->f_list)) {
-		hlist_del(&file->f_list);
+	if (hash_hashed(&file->f_list)) {
+		hash_del(&file->f_list);
 		nlmsvc_ops->fclose(file->f_file);
 		kfree(file);
 	} else {
@@ -253,27 +253,25 @@ nlm_traverse_files(void *data, nlm_host_match_fn_t match,
 	int i, ret = 0;
 
 	mutex_lock(&nlm_file_mutex);
-	for (i = 0; i < FILE_NRHASH; i++) {
-		hlist_for_each_entry_safe(file, pos, next, &nlm_files[i], f_list) {
-			if (is_failover_file && !is_failover_file(data, file))
-				continue;
-			file->f_count++;
-			mutex_unlock(&nlm_file_mutex);
-
-			/* Traverse locks, blocks and shares of this file
-			 * and update file->f_locks count */
-			if (nlm_inspect_file(data, file, match))
-				ret = 1;
-
-			mutex_lock(&nlm_file_mutex);
-			file->f_count--;
-			/* No more references to this file. Let go of it. */
-			if (list_empty(&file->f_blocks) && !file->f_locks
-			 && !file->f_shares && !file->f_count) {
-				hlist_del(&file->f_list);
-				nlmsvc_ops->fclose(file->f_file);
-				kfree(file);
-			}
+	hash_for_each_safe(nlm_files, i, pos, next, file, f_list) {
+		if (is_failover_file && !is_failover_file(data, file))
+			continue;
+		file->f_count++;
+		mutex_unlock(&nlm_file_mutex);
+
+		/* Traverse locks, blocks and shares of this file
+		 * and update file->f_locks count */
+		if (nlm_inspect_file(data, file, match))
+			ret = 1;
+
+		mutex_lock(&nlm_file_mutex);
+		file->f_count--;
+		/* No more references to this file. Let go of it. */
+		if (list_empty(&file->f_blocks) && !file->f_locks
+		 && !file->f_shares && !file->f_count) {
+			hash_del(&file->f_list);
+			nlmsvc_ops->fclose(file->f_file);
+			kfree(file);
 		}
 	}
 	mutex_unlock(&nlm_file_mutex);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
