Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3DD016B006E
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:19:38 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so8299604eek.2
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:19:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si28164055eer.27.2014.04.15.21.19.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:19:37 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:37 +1000
Subject: [PATCH 15/19] nfsd: set PF_FSTRANS when client_mutex is held.
Message-ID: <20140416040336.10604.67828.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com

When loop-back NFS with NFSv4 is in use, client_mutex might be needed
to reclaim memory, so any memory allocation while client_mutex is held
must avoid __GFP_FS, so best to set PF_FSTRANS.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/nfs4state.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d5d070fbeb35..7b7fbcbe20cb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -75,6 +75,7 @@ static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner
 
 /* Currently used for almost all code touching nfsv4 state: */
 static DEFINE_MUTEX(client_mutex);
+static unsigned int client_mutex_pflags;
 
 /*
  * Currently used for the del_recall_lru and file hash table.  In an
@@ -93,6 +94,7 @@ void
 nfs4_lock_state(void)
 {
 	mutex_lock(&client_mutex);
+	current_set_flags_nested(&client_mutex_pflags, PF_FSTRANS);
 }
 
 static void free_session(struct nfsd4_session *);
@@ -127,6 +129,7 @@ static __be32 nfsd4_get_session_locked(struct nfsd4_session *ses)
 void
 nfs4_unlock_state(void)
 {
+	current_restore_flags_nested(&client_mutex_pflags, PF_FSTRANS);
 	mutex_unlock(&client_mutex);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
