Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BA3CD6B004D
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 07:12:56 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv6 1/3] tun: export underlying socket
Date: Tue, 3 Nov 2009 13:12:33 +0100
References: <cover.1257193660.git.mst@redhat.com> <20091102222612.GB15184@redhat.com>
In-Reply-To: <20091102222612.GB15184@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200911031312.33580.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: virtualization@lists.linux-foundation.org
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

On Monday 02 November 2009, Michael S. Tsirkin wrote:
> Tun device looks similar to a packet socket
> in that both pass complete frames from/to userspace.
> 
> This patch fills in enough fields in the socket underlying tun driver
> to support sendmsg/recvmsg operations, and message flags
> MSG_TRUNC and MSG_DONTWAIT, and exports access to this socket
> to modules.  Regular read/write behaviour is unchanged.
> 
> This way, code using raw sockets to inject packets
> into a physical device, can support injecting
> packets into host network stack almost without modification.
> 
> First user of this interface will be vhost virtualization
> accelerator.

You mentioned before that you wanted to export the socket
using some ioctl function returning an open file descriptor,
which seemed to be a cleaner approach than this one.

What was your reason for changing?

> index 3f5fd52..404abe0 100644
> --- a/include/linux/if_tun.h
> +++ b/include/linux/if_tun.h
> @@ -86,4 +86,18 @@ struct tun_filter {
>         __u8   addr[0][ETH_ALEN];
>  };
>  
> +#ifdef __KERNEL__
> +#if defined(CONFIG_TUN) || defined(CONFIG_TUN_MODULE)
> +struct socket *tun_get_socket(struct file *);
> +#else
> +#include <linux/err.h>
> +#include <linux/errno.h>
> +struct file;
> +struct socket;
> +static inline struct socket *tun_get_socket(struct file *f)
> +{
> +       return ERR_PTR(-EINVAL);
> +}
> +#endif /* CONFIG_TUN */
> +#endif /* __KERNEL__ */
>  #endif /* __IF_TUN_H */

Is this a leftover from testing? Exporting the function for !__KERNEL__
seems pointless.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
