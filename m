Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E50F86B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 04:55:22 -0500 (EST)
Received: by qap15 with SMTP id 15so1224235qap.14
        for <linux-mm@kvack.org>; Mon, 28 Nov 2011 01:55:20 -0800 (PST)
Message-ID: <1322474116.2292.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Subject: Re: [PATCH] net: Fix corruption in /proc/*/net/dev_mcast
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Nov 2011 10:55:16 +0100
In-Reply-To: <20111128181446.2ab784d0@kryten>
References: <1321866845.3831.7.camel@lappy>
	 <1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111128181446.2ab784d0@kryten>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, David Miller <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, Mihai Maruseac <mihai.maruseac@gmail.com>

Le lundi 28 novembre 2011 A  18:14 +1100, Anton Blanchard a A(C)crit :
> Hi,
> 
> > I got the following output when running some tests (I'm not really sure
> > what exactly happened when this bug was triggered):
> > 
> > [13850.947279] =============================================================================
> > [13850.948024] BUG kmalloc-8: Redzone overwritten
> > [13850.948024] -----------------------------------------------------------------------------
> > [13850.948024] 
> > [13850.948024] INFO: 0xffff8800104f6d28-0xffff8800104f6d2b. First byte 0x0 instead of 0xcc
> > [13850.948024] INFO: Allocated in __seq_open_private+0x20/0x5e age=4436 cpu=0 pid=17295
> > [13850.948024] 	__slab_alloc.clone.46+0x3e7/0x456
> > [13850.948024] 	__kmalloc+0x8c/0x110
> > [13850.948024] 	__seq_open_private+0x20/0x5e
> > [13850.948024] 	seq_open_net+0x3b/0x5d
> > [13850.948024] 	dev_mc_seq_open+0x15/0x17
> > [13850.948024] 	proc_reg_open+0xad/0x127
> 
> I just hit this during my testing. Isn't there another bug lurking?
> 
> Anton
> --
> 
> 
> With slub debugging on I see red zone issues in /proc/*/net/dev_mcast:
> 
> =============================================================================
> BUG kmalloc-8: Redzone overwritten
> -----------------------------------------------------------------------------
> 
> INFO: 0xc0000000de9dec48-0xc0000000de9dec4b. First byte 0x0 instead of 0xcc
> INFO: Allocated in .__seq_open_private+0x30/0xa0 age=0 cpu=5 pid=3896
> 	.__kmalloc+0x1e0/0x2d0
> 	.__seq_open_private+0x30/0xa0
> 	.seq_open_net+0x60/0xe0
> 	.dev_mc_seq_open+0x4c/0x70
> 	.proc_reg_open+0xd8/0x260
> 	.__dentry_open.clone.11+0x2b8/0x400
> 	.do_last+0xf4/0x950
> 	.path_openat+0xf8/0x480
> 	.do_filp_open+0x48/0xc0
> 	.do_sys_open+0x140/0x250
> 	syscall_exit+0x0/0x40
> 
> dev_mc_seq_ops uses dev_seq_start/next/stop but only allocates
> sizeof(struct seq_net_private) of private data, whereas it expects
> sizeof(struct dev_iter_state):
> 
> struct dev_iter_state {
> 	struct seq_net_private p;
> 	unsigned int pos; /* bucket << BUCKET_SPACE + offset */
> };
> 
> Create dev_seq_open_ops and use it so we don't have to expose
> struct dev_iter_state.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> ---
> 
> Index: linux-net/include/linux/netdevice.h
> ===================================================================
> --- linux-net.orig/include/linux/netdevice.h	2011-11-28 17:55:51.469508056 +1100
> +++ linux-net/include/linux/netdevice.h	2011-11-28 17:55:52.985535812 +1100
> @@ -2536,6 +2536,8 @@ extern void		net_disable_timestamp(void)
>  extern void *dev_seq_start(struct seq_file *seq, loff_t *pos);
>  extern void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos);
>  extern void dev_seq_stop(struct seq_file *seq, void *v);
> +extern int dev_seq_open_ops(struct inode *inode, struct file *file,
> +			    const struct seq_operations *ops);
>  #endif
>  
>  extern int netdev_class_create_file(struct class_attribute *class_attr);
> Index: linux-net/net/core/dev.c
> ===================================================================
> --- linux-net.orig/net/core/dev.c	2011-11-28 17:55:51.481508276 +1100
> +++ linux-net/net/core/dev.c	2011-11-28 17:55:52.989535885 +1100
> @@ -4282,6 +4282,12 @@ static int dev_seq_open(struct inode *in
>  			    sizeof(struct dev_iter_state));
>  }
>  
> +int dev_seq_open_ops(struct inode *inode, struct file *file,
> +		     const struct seq_operations *ops)
> +{
> +	return seq_open_net(inode, file, ops, sizeof(struct dev_iter_state));
> +}
> +
>  static const struct file_operations dev_seq_fops = {
>  	.owner	 = THIS_MODULE,
>  	.open    = dev_seq_open,
> Index: linux-net/net/core/dev_addr_lists.c
> ===================================================================
> --- linux-net.orig/net/core/dev_addr_lists.c	2011-11-28 17:55:47.845441705 +1100
> +++ linux-net/net/core/dev_addr_lists.c	2011-11-28 17:55:52.989535885 +1100
> @@ -696,8 +696,7 @@ static const struct seq_operations dev_m
>  
>  static int dev_mc_seq_open(struct inode *inode, struct file *file)
>  {
> -	return seq_open_net(inode, file, &dev_mc_seq_ops,
> -			    sizeof(struct seq_net_private));
> +	return dev_seq_open_ops(inode, file, &dev_mc_seq_ops);
>  }
>  
>  static const struct file_operations dev_mc_seq_fops = {


Good catch, thanks !

Problem added by commit f04565ddf52e4 (dev: use name hash for
dev_seq_ops)


Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Mihai Maruseac <mihai.maruseac@gmail.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
