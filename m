Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 50E696B007D
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:19:59 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e49so8113160eek.25
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:19:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s46si28130546eeg.165.2014.04.15.21.19.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:19:58 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:37 +1000
Subject: [PATCH 18/19] nfsd: set PF_FSTRANS during nfsd4_do_callback_rpc.
Message-ID: <20140416040337.10604.52860.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com

nfsd will sometimes call flush_workqueue on the workqueue running
nfsd4_do_callback_rpc, so we must ensure that it doesn't block in
filesystem reclaim.
So set PF_FSTRANS.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/nfs4callback.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7f05cd140de3..7784b5d4edf0 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -997,6 +997,9 @@ static void nfsd4_do_callback_rpc(struct work_struct *w)
 	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback, cb_work);
 	struct nfs4_client *clp = cb->cb_clp;
 	struct rpc_clnt *clnt;
+	unsigned int pflags;
+
+	current_set_flags_nested(&pflags, PF_FSTRANS);
 
 	if (clp->cl_flags & NFSD4_CLIENT_CB_FLAG_MASK)
 		nfsd4_process_cb_update(cb);
@@ -1005,11 +1008,13 @@ static void nfsd4_do_callback_rpc(struct work_struct *w)
 	if (!clnt) {
 		/* Callback channel broken, or client killed; give up: */
 		nfsd4_release_cb(cb);
+		current_restore_flags_nested(&pflags, PF_FSTRANS);
 		return;
 	}
 	cb->cb_msg.rpc_cred = clp->cl_cb_cred;
 	rpc_call_async(clnt, &cb->cb_msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
 			cb->cb_ops, cb);
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 }
 
 void nfsd4_init_callback(struct nfsd4_callback *cb)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
