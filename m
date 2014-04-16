Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3646B005A
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:19:17 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so8210281eek.18
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:19:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si28115112eer.177.2014.04.15.21.19.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:19:16 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:36 +1000
Subject: [PATCH 12/19] NET: set PF_FSTRANS while holding rtnl_lock
Message-ID: <20140416040336.10604.81658.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com, netdev@vger.kernel.org

As rtnl_mutex can be taken while holding sk_lock, and sk_lock can be
taken while performing memory reclaim (at least when loop-back NFS is
active), any memory allocation under rtnl_mutex must avoid __GFP_FS,
which is most easily done by setting PF_MEMALLOC.


        CPU0                    CPU1
        ----                    ----
   lock(rtnl_mutex);
                                lock(sk_lock-AF_INET);
                                lock(rtnl_mutex);
   <Memory allocation/reclaim>
     lock(sk_lock-AF_INET);

  *** DEADLOCK ***

1/ rtnl_mutex is taken while holding sk_lock:

    [<ffffffff81abb442>] rtnl_lock+0x12/0x20
    [<ffffffff81b28c3a>] ip_mc_leave_group+0x2a/0x160
    [<ffffffff81aec70b>] do_ip_setsockopt.isra.18+0x96b/0xed0
    [<ffffffff81aecc97>] ip_setsockopt+0x27/0x90
    [<ffffffff81b151c6>] udp_setsockopt+0x16/0x30
    [<ffffffff81a9144f>] sock_common_setsockopt+0xf/0x20
    [<ffffffff81a907de>] SyS_setsockopt+0x5e/0xc0

2/ memory is allocated under rtnl_mutex:
    [<ffffffff8166eb41>] kobject_set_name_vargs+0x21/0x70
    [<ffffffff81840d92>] dev_set_name+0x42/0x50
    [<ffffffff81ac5e97>] netdev_register_kobject+0x57/0x130
    [<ffffffff81aaf574>] register_netdevice+0x354/0x550
    [<ffffffff81aaf785>] register_netdev+0x15/0x30


Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/core/rtnetlink.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 120eecc0f5a4..6870211e93a6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -61,15 +61,18 @@ struct rtnl_link {
 };
 
 static DEFINE_MUTEX(rtnl_mutex);
+static int rtnl_pflags;
 
 void rtnl_lock(void)
 {
 	mutex_lock(&rtnl_mutex);
+	current_set_flags_nested(&rtnl_pflags, PF_FSTRANS);
 }
 EXPORT_SYMBOL(rtnl_lock);
 
 void __rtnl_unlock(void)
 {
+	current_restore_flags_nested(&rtnl_pflags, PF_FSTRANS);
 	mutex_unlock(&rtnl_mutex);
 }
 
@@ -82,7 +85,11 @@ EXPORT_SYMBOL(rtnl_unlock);
 
 int rtnl_trylock(void)
 {
-	return mutex_trylock(&rtnl_mutex);
+	if (mutex_trylock(&rtnl_mutex)) {
+		current_set_flags_nested(&rtnl_pflags, PF_FSTRANS);
+		return 1;
+	}
+	return 0;
 }
 EXPORT_SYMBOL(rtnl_trylock);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
