Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 04D066B004D
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 07:34:05 -0500 (EST)
Date: Tue, 3 Nov 2009 14:31:12 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv6 1/3] tun: export underlying socket
Message-ID: <20091103123112.GA4961@redhat.com>
References: <cover.1257193660.git.mst@redhat.com> <20091102222612.GB15184@redhat.com> <200911031312.33580.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200911031312.33580.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 03, 2009 at 01:12:33PM +0100, Arnd Bergmann wrote:
> On Monday 02 November 2009, Michael S. Tsirkin wrote:
> > Tun device looks similar to a packet socket
> > in that both pass complete frames from/to userspace.
> > 
> > This patch fills in enough fields in the socket underlying tun driver
> > to support sendmsg/recvmsg operations, and message flags
> > MSG_TRUNC and MSG_DONTWAIT, and exports access to this socket
> > to modules.  Regular read/write behaviour is unchanged.
> > 
> > This way, code using raw sockets to inject packets
> > into a physical device, can support injecting
> > packets into host network stack almost without modification.
> > 
> > First user of this interface will be vhost virtualization
> > accelerator.
> 
> You mentioned before that you wanted to export the socket
> using some ioctl function returning an open file descriptor,
> which seemed to be a cleaner approach than this one.

Note that a similar feature can be implemented on top of tun_get_socket,
as seen from patch below.

> What was your reason for changing?

It turns out socket structure is really bound to specific a file, so we
can not have 2 files referencing the same socket.  Instead, as I say
above, it's possible to make sendmsg/recvmsg work on tap file directly.

For vhost, the advantage of such a feature over using tun_get_socket
directly would be that vhost module won't depend on tun module then.  I
have implemented this (patch below), but decided to go with the simple
thing first.  Since no userspace-visible changes are involved, let's do
this by small steps: it will be easier to figure out when vhost
is upstream.


---

Note: patch below aplies on top of patch tun: export underlying socket.
It is not intended for merge yet.

net: convert tun device to socket

Add callback to file_ops to retrieve socket from
file structure. Use this to make tun character device
accept sendmsg/recvmsg calls.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b58095a..53e1806 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1405,7 +1405,8 @@ static const struct file_operations tun_fops = {
 	.unlocked_ioctl = tun_chr_ioctl,
 	.open	= tun_chr_open,
 	.release = tun_chr_close,
-	.fasync = tun_chr_fasync
+	.fasync = tun_chr_fasync,
+	.get_socket = tun_get_socket,
 };
 
 static struct miscdevice tun_miscdev = {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2620a8c..f2b381f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1506,6 +1506,9 @@ struct file_operations {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
+#ifdef CONFIG_NET
+	struct socket *(*get_socket)(struct file *file);
+#endif
 };
 
 struct inode_operations {
diff --git a/net/socket.c b/net/socket.c
index 9dff31c..700efcb 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -119,6 +119,11 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 			        struct pipe_inode_info *pipe, size_t len,
 				unsigned int flags);
 
+static struct socket *sock_get_socket(struct file *file)
+{
+	return file->private_data;	/* set in sock_map_fd */
+}
+
 /*
  *	Socket files have a set of 'special' operations as well as the generic file ones. These don't appear
  *	in the operation structures but are done directly via the socketcall() multiplexor.
@@ -141,6 +146,7 @@ static const struct file_operations socket_file_ops = {
 	.sendpage =	sock_sendpage,
 	.splice_write = generic_splice_sendpage,
 	.splice_read =	sock_splice_read,
+	.get_socket =   sock_get_socket,
 };
 
 /*
@@ -416,8 +422,8 @@ int sock_map_fd(struct socket *sock, int flags)
 
 static struct socket *sock_from_file(struct file *file, int *err)
 {
-	if (file->f_op == &socket_file_ops)
-		return file->private_data;	/* set in sock_map_fd */
+	if (file->f_op->get_socket)
+		return file->f_op->get_socket(file);
 
 	*err = -ENOTSOCK;
 	return NULL;


-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
