Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 873606B003A
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:18:34 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so8379648eei.0
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:18:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c48si10671995eeb.247.2014.04.15.21.18.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:18:33 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:36 +1000
Subject: [PATCH 06/19] nfsd: set PF_FSTRANS for nfsd threads.
Message-ID: <20140416040336.10604.60493.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>

If a localhost mount is present, then it is easy to deadlock NFS by
nfsd entering direct reclaim and calling nfs_release_page() which
requires nfsd to perform an fsync() (which it cannot do because it is
reclaiming memory).

By setting PF_FSTRANS we stop the memory allocator from ever
attempting any FS operation would could deadlock.

We need this flag set for any thread which is handling a request from
the local host, but we also need to always have it for at least 1 or 2
threads so that we don't end up with all threads blocked in allocation.

When we set PF_FSTRANS we also tell lockdep that we are handling
reclaim so that it can detect deadlocks for us.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/nfssvc.c           |   18 ++++++++++++++++++
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |    6 ++++++
 3 files changed, 25 insertions(+)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 9a4a5f9e7468..6af8bc2daf7d 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -565,6 +565,8 @@ nfsd(void *vrqstp)
 	struct svc_xprt *perm_sock = list_entry(rqstp->rq_server->sv_permsocks.next, typeof(struct svc_xprt), xpt_list);
 	struct net *net = perm_sock->xpt_net;
 	int err;
+	unsigned int pflags = 0;
+	gfp_t reclaim_state = 0;
 
 	/* Lock module and set up kernel thread */
 	mutex_lock(&nfsd_mutex);
@@ -611,14 +613,30 @@ nfsd(void *vrqstp)
 			;
 		if (err == -EINTR)
 			break;
+		if (rqstp->rq_local && !current_test_flags(PF_FSTRANS)) {
+			current_set_flags_nested(&pflags, PF_FSTRANS);
+			atomic_inc(&rqstp->rq_pool->sp_nr_fstrans);
+			reclaim_state = lockdep_set_current_reclaim_state(GFP_KERNEL);
+		}
 		validate_process_creds();
 		svc_process(rqstp);
 		validate_process_creds();
+		if (current_test_flags(PF_FSTRANS) &&
+		    atomic_dec_if_positive(&rqstp->rq_pool->sp_nr_fstrans) >= 0) {
+			current_restore_flags_nested(&pflags, PF_FSTRANS);
+			lockdep_restore_current_reclaim_state(reclaim_state);
+		}
 	}
 
 	/* Clear signals before calling svc_exit_thread() */
 	flush_signals(current);
 
+	if (current_test_flags(PF_FSTRANS)) {
+		current_restore_flags_nested(&pflags, PF_FSTRANS);
+		lockdep_restore_current_reclaim_state(reclaim_state);
+		atomic_dec(&rqstp->rq_pool->sp_nr_fstrans);
+	}
+
 	mutex_lock(&nfsd_mutex);
 	nfsdstats.th_cnt --;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index a0dbbd1e00e9..4b274aba51dd 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -48,6 +48,7 @@ struct svc_pool {
 	struct list_head	sp_threads;	/* idle server threads */
 	struct list_head	sp_sockets;	/* pending sockets */
 	unsigned int		sp_nrthreads;	/* # of threads in pool */
+	atomic_t		sp_nr_fstrans;	/* # threads with PF_FSTRANS */
 	struct list_head	sp_all_threads;	/* all server threads */
 	struct svc_pool_stats	sp_stats;	/* statistics on pool operation */
 	int			sp_task_pending;/* has pending task */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 5de6801cd924..8b13f35b6cbb 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -477,6 +477,12 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		INIT_LIST_HEAD(&pool->sp_threads);
 		INIT_LIST_HEAD(&pool->sp_sockets);
 		INIT_LIST_HEAD(&pool->sp_all_threads);
+		/* The number of threads with PF_FSTRANS set
+		 * should never be reduced below 2, except when
+		 * threads exit.  So we use atomic_dec_if_positive()
+		 * on this value.
+		 */
+		atomic_set(&pool->sp_nr_fstrans, -2);
 		spin_lock_init(&pool->sp_lock);
 	}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
