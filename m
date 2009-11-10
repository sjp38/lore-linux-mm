Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BB42A6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 06:39:26 -0500 (EST)
Date: Tue, 10 Nov 2009 13:36:37 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv9 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20091110113637.GB6989@redhat.com>
References: <cover.1257786516.git.mst@redhat.com> <20091109172230.GD4724@redhat.com> <200911101349.09783.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200911101349.09783.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 10, 2009 at 01:49:09PM +1030, Rusty Russell wrote:
> One fix:
> 
> vhost: fix TUN=m VHOST_NET=y
> 
> 	drivers/built-in.o: In function `get_tun_socket':
> 	net.c:(.text+0x15436e): undefined reference to `tun_get_socket'
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  drivers/vhost/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
> --- a/drivers/vhost/Kconfig
> +++ b/drivers/vhost/Kconfig
> @@ -1,6 +1,6 @@
>  config VHOST_NET
>  	tristate "Host kernel accelerator for virtio net (EXPERIMENTAL)"
> -	depends on NET && EVENTFD && EXPERIMENTAL
> +	depends on NET && EVENTFD && TUN && EXPERIMENTAL
>  	---help---
>  	  This kernel module can be loaded in host kernel to accelerate
>  	  guest networking with virtio_net. Not to be confused with virtio_net

In fact, vhost can be built with TUN=n VHOST_NET=y as well
(tun_get_socket is stubbed out in that case).
So I think this is better (it looks strange
until you realize that for tristate variables
boolean logic math does not apply):

--->

From: Michael S. Tsirkin <mst@redhat.com>
Subject: vhost: fix TUN=m VHOST_NET=y

    drivers/built-in.o: In function `get_tun_socket':
    net.c:(.text+0x15436e): undefined reference to `tun_get_socket'

If tun is a module, vhost must be a module, too.
If tun is built-in or disabled, vhost can be built-in.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
index 9f409f4..9e93553 100644
--- a/drivers/vhost/Kconfig
+++ b/drivers/vhost/Kconfig
@@ -1,6 +1,6 @@
 config VHOST_NET
 	tristate "Host kernel accelerator for virtio net (EXPERIMENTAL)"
-	depends on NET && EVENTFD && EXPERIMENTAL
+	depends on NET && EVENTFD && (TUN || !TUN) && EXPERIMENTAL
 	---help---
 	  This kernel module can be loaded in host kernel to accelerate
 	  guest networking with virtio_net. Not to be confused with virtio_net


-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
