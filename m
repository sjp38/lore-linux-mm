Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id AFFF16B1401
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 17:56:33 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/15] nbd: Set SOCK_MEMALLOC for access to PFMEMALLOC reserves
Date: Mon,  6 Feb 2012 22:56:16 +0000
Message-Id: <1328568978-17553-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1328568978-17553-1-git-send-email-mgorman@suse.de>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Set SOCK_MEMALLOC on the NBD socket to allow access to PFMEMALLOC
reserves so pages backed by NBD, particularly if swap related, can
be cleaned to prevent the machine being deadlocked. It is still
possible that the PFMEMALLOC reserves get depleted resulting in
deadlock but this can be resolved by the administrator by increasing
min_free_kbytes.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 drivers/block/nbd.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index c3f0ee1..45de594 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -155,6 +155,7 @@ static int sock_xmit(struct nbd_device *lo, int send, void *buf, int size,
 	struct msghdr msg;
 	struct kvec iov;
 	sigset_t blocked, oldset;
+	unsigned long pflags = current->flags;
 
 	if (unlikely(!sock)) {
 		dev_err(disk_to_dev(lo->disk),
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
@@ -215,6 +217,7 @@ static int sock_xmit(struct nbd_device *lo, int send, void *buf, int size,
 	} while (size > 0);
 
 	sigprocmask(SIG_SETMASK, &oldset, NULL);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 
 	return result;
 }
@@ -405,6 +408,7 @@ static int nbd_do_it(struct nbd_device *lo)
 
 	BUG_ON(lo->magic != LO_MAGIC);
 
+	sk_set_memalloc(lo->sock->sk);
 	lo->pid = task_pid_nr(current);
 	ret = device_create_file(disk_to_dev(lo->disk), &pid_attr);
 	if (ret) {
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
