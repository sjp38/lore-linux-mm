Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5C72A90008E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 06:41:49 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/12] nbd: Set SOCK_MEMALLOC for access to PFMEMALLOC reserves
Date: Thu, 14 Apr 2011 11:41:37 +0100
Message-Id: <1302777698-28237-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1302777698-28237-1-git-send-email-mgorman@suse.de>
References: <1302777698-28237-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Set SOCK_MEMALLOC on the NBD socket to allow access to PFMEMALLOC
reserves so pages backed by NBD, particularly if swap related,
can be cleaned to prevent the machine being deadlocked. It is
still possible that the PFMEMALLOC reserves get depleted resulting
in deadlock but this can be resolved by the administrator by
increasing min_free_kbytes.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 drivers/block/nbd.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index e6fc716..322cef8 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -156,6 +156,7 @@ static int sock_xmit(struct nbd_device *lo, int send, void *buf, int size,
 	struct msghdr msg;
 	struct kvec iov;
 	sigset_t blocked, oldset;
+	unsigned long pflags = current->flags;
 
 	if (unlikely(!sock)) {
 		printk(KERN_ERR "%s: Attempted %s on closed socket in sock_xmit\n",
@@ -168,8 +169,9 @@ static int sock_xmit(struct nbd_device *lo, int send, void *buf, int size,
 	siginitsetinv(&blocked, sigmask(SIGKILL));
 	sigprocmask(SIG_SETMASK, &blocked, &oldset);
 
+	current->flags |= PF_MEMALLOC;
 	do {
-		sock->sk->sk_allocation = GFP_NOIO;
+		sock->sk->sk_allocation = GFP_NOIO | __GFP_MEMALLOC;
 		iov.iov_base = buf;
 		iov.iov_len = size;
 		msg.msg_name = NULL;
@@ -214,6 +216,7 @@ static int sock_xmit(struct nbd_device *lo, int send, void *buf, int size,
 	} while (size > 0);
 
 	sigprocmask(SIG_SETMASK, &oldset, NULL);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 
 	return result;
 }
@@ -404,6 +407,8 @@ static int nbd_do_it(struct nbd_device *lo)
 
 	BUG_ON(lo->magic != LO_MAGIC);
 
+	sk_set_memalloc(lo->sock->sk);
+
 	lo->pid = current->pid;
 	ret = sysfs_create_file(&disk_to_dev(lo->disk)->kobj, &pid_attr.attr);
 	if (ret) {
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
