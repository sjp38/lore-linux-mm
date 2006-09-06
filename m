Message-Id: <20060906133955.138336000@chello.nl>
References: <20060906131630.793619000@chello.nl>>
Date: Wed, 06 Sep 2006 15:16:43 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 13/21] nbd: use swapdev hook to make swap deadlock free
Content-Disposition: inline; filename=nbd_vmio.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

Use sk_set_vmio() on the nbd socket.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Daniel Phillips <phillips@google.com>
CC: Pavel Machek <pavel@ucw.cz>
---
 drivers/block/nbd.c |   22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

Index: linux-2.6/drivers/block/nbd.c
===================================================================
--- linux-2.6.orig/drivers/block/nbd.c
+++ linux-2.6/drivers/block/nbd.c
@@ -135,7 +135,6 @@ static int sock_xmit(struct socket *sock
 	spin_unlock_irqrestore(&current->sighand->siglock, flags);
 
 	do {
-		sock->sk->sk_allocation = GFP_NOIO;
 		iov.iov_base = buf;
 		iov.iov_len = size;
 		msg.msg_name = NULL;
@@ -525,6 +524,7 @@ static int nbd_ioctl(struct inode *inode
 			if (S_ISSOCK(inode->i_mode)) {
 				lo->file = file;
 				lo->sock = SOCKET_I(inode);
+				lo->sock->sk->sk_allocation = GFP_NOIO;
 				error = 0;
 			} else {
 				fput(file);
@@ -594,10 +594,30 @@ static int nbd_ioctl(struct inode *inode
 	return -EINVAL;
 }
 
+static int nbd_swapdev(struct gendisk *disk, int enable)
+{
+	struct nbd_device *lo = disk->private_data;
+
+	if (enable) {
+		sk_adjust_memalloc(0, TX_RESERVE_PAGES);
+		if (!sk_set_vmio(lo->sock->sk))
+			printk(KERN_WARNING
+				"failed to set SOCK_VMIO on NBD socket\n");
+	} else {
+		if (!sk_clear_vmio(lo->sock->sk))
+			printk(KERN_WARNING
+				"failed to clear SOCK_VMIO on NBD socket\n");
+		sk_adjust_memalloc(0, -TX_RESERVE_PAGES);
+	}
+
+	return 0;
+}
+
 static struct block_device_operations nbd_fops =
 {
 	.owner =	THIS_MODULE,
 	.ioctl =	nbd_ioctl,
+	.swapdev =	nbd_swapdev,
 };
 
 /*

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
