From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 25 Aug 2006 17:40:17 +0200
Message-Id: <20060825154017.24271.20362.sendpatchset@twins>
In-Reply-To: <20060825153946.24271.42758.sendpatchset@twins>
References: <20060825153946.24271.42758.sendpatchset@twins>
Subject: [PATCH 3/4] nbd: deadlock prevention for NBD
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Indan Zupancic <indan@nul.nu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Use sk_set_vmio() on the nbd socket.

Limit each request to 1 page, so that the request throttling also limits the
number of in-flight pages and force the IO scheduler to NOOP as anything else
doesn't make sense anyway.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Daniel Phillips <phillips@google.com>
---
 drivers/block/nbd.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

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
@@ -361,8 +360,16 @@ static void nbd_do_it(struct nbd_device 
 
 	BUG_ON(lo->magic != LO_MAGIC);
 
+	sk_adjust_memalloc(0, 1);
+	if (sk_set_vmio(lo->sock->sk))
+		printk(KERN_WARNING
+		       "failed to set SOCK_VMIO on NBD socket\n");
+
 	while ((req = nbd_read_stat(lo)) != NULL)
 		nbd_end_request(req);
+
+	sk_adjust_memalloc(0, -1);
+
 	return;
 }
 
@@ -525,6 +533,7 @@ static int nbd_ioctl(struct inode *inode
 			if (S_ISSOCK(inode->i_mode)) {
 				lo->file = file;
 				lo->sock = SOCKET_I(inode);
+				lo->sock->sk->sk_allocation = GFP_NOIO;
 				error = 0;
 			} else {
 				fput(file);
@@ -628,11 +637,16 @@ static int __init nbd_init(void)
 		 * every gendisk to have its very own request_queue struct.
 		 * These structs are big so we dynamically allocate them.
 		 */
-		disk->queue = blk_init_queue(do_nbd_request, &nbd_lock);
+		disk->queue = blk_init_queue_node_elv(do_nbd_request,
+				&nbd_lock, -1, "noop");
 		if (!disk->queue) {
 			put_disk(disk);
 			goto out;
 		}
+		blk_queue_pin_elevator(disk->queue);
+		blk_queue_max_segment_size(disk->queue, PAGE_SIZE);
+		blk_queue_max_hw_segments(disk->queue, 1);
+		blk_queue_max_phys_segments(disk->queue, 1);
 	}
 
 	if (register_blkdev(NBD_MAJOR, "nbd")) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
