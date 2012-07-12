Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id A06E86B0075
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:40:54 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/16] nbd: Set SOCK_MEMALLOC for access to PFMEMALLOC reserves
Date: Thu, 12 Jul 2012 07:40:30 +0100
Message-Id: <1342075232-29267-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075232-29267-1-git-send-email-mgorman@suse.de>
References: <1342075232-29267-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

Set SOCK_MEMALLOC on the NBD socket to allow access to PFMEMALLOC
reserves so pages backed by NBD, particularly if swap related, can
be cleaned to prevent the machine being deadlocked. It is still
possible that the PFMEMALLOC reserves get depleted resulting in
deadlock but this can be resolved by the administrator by increasing
min_free_kbytes.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 drivers/block/nbd.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index 061427a75d..76bc96f 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -154,6 +154,7 @@ static int sock_xmit(struct nbd_device *nbd, int send, void *buf, int size,
 	struct msghdr msg;
 	struct kvec iov;
 	sigset_t blocked, oldset;
+	unsigned long pflags = current->flags;
 
 	if (unlikely(!sock)) {
 		dev_err(disk_to_dev(nbd->disk),
@@ -167,8 +168,9 @@ static int sock_xmit(struct nbd_device *nbd, int send, void *buf, int size,
 	siginitsetinv(&blocked, sigmask(SIGKILL));
 	sigprocmask(SIG_SETMASK, &blocked, &oldset);
 
+	current->flags |= PF_MEMALLOC;
 	do {
-		sock->sk->sk_allocation = GFP_NOIO;
+		sock->sk->sk_allocation = GFP_NOIO | __GFP_MEMALLOC;
 		iov.iov_base = buf;
 		iov.iov_len = size;
 		msg.msg_name = NULL;
@@ -214,6 +216,7 @@ static int sock_xmit(struct nbd_device *nbd, int send, void *buf, int size,
 	} while (size > 0);
 
 	sigprocmask(SIG_SETMASK, &oldset, NULL);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 
 	return result;
 }
@@ -405,6 +408,7 @@ static int nbd_do_it(struct nbd_device *nbd)
 
 	BUG_ON(nbd->magic != NBD_MAGIC);
 
+	sk_set_memalloc(nbd->sock->sk);
 	nbd->pid = task_pid_nr(current);
 	ret = device_create_file(disk_to_dev(nbd->disk), &pid_attr);
 	if (ret) {
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
