Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 05CB66B03B3
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 07:30:37 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k6so1198800wre.3
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 04:30:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u127si24029251wmf.107.2017.04.05.04.30.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 04:30:35 -0700 (PDT)
Date: Wed, 5 Apr 2017 13:30:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] treewide: convert PF_MEMALLOC manipulations to new
 helpers
Message-ID: <20170405113030.GL6035@dhcp22.suse.cz>
References: <20170405074700.29871-1-vbabka@suse.cz>
 <20170405074700.29871-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170405074700.29871-4-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-block@vger.kernel.org, nbd-general@lists.sourceforge.net, open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org, Josef Bacik <jbacik@fb.com>, Lee Duncan <lduncan@suse.com>, Chris Leech <cleech@redhat.com>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>

On Wed 05-04-17 09:46:59, Vlastimil Babka wrote:
> We now have memalloc_noreclaim_{save,restore} helpers for robust setting and
> clearing of PF_MEMALLOC. Let's convert the code which was using the generic
> tsk_restore_flags(). No functional change.

It would be really great to revisit why those places outside of the mm
proper really need this flag. I know this is a painful exercise but I
wouldn't be surprised if there were abusers there.

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Josef Bacik <jbacik@fb.com>
> Cc: Lee Duncan <lduncan@suse.com>
> Cc: Chris Leech <cleech@redhat.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  drivers/block/nbd.c      | 7 ++++---
>  drivers/scsi/iscsi_tcp.c | 7 ++++---
>  net/core/dev.c           | 7 ++++---
>  net/core/sock.c          | 7 ++++---
>  4 files changed, 16 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
> index 03ae72985c79..929fc548c7fb 100644
> --- a/drivers/block/nbd.c
> +++ b/drivers/block/nbd.c
> @@ -18,6 +18,7 @@
>  #include <linux/module.h>
>  #include <linux/init.h>
>  #include <linux/sched.h>
> +#include <linux/sched/mm.h>
>  #include <linux/fs.h>
>  #include <linux/bio.h>
>  #include <linux/stat.h>
> @@ -210,7 +211,7 @@ static int sock_xmit(struct nbd_device *nbd, int index, int send,
>  	struct socket *sock = nbd->socks[index]->sock;
>  	int result;
>  	struct msghdr msg;
> -	unsigned long pflags = current->flags;
> +	unsigned int noreclaim_flag;
>  
>  	if (unlikely(!sock)) {
>  		dev_err_ratelimited(disk_to_dev(nbd->disk),
> @@ -221,7 +222,7 @@ static int sock_xmit(struct nbd_device *nbd, int index, int send,
>  
>  	msg.msg_iter = *iter;
>  
> -	current->flags |= PF_MEMALLOC;
> +	noreclaim_flag = memalloc_noreclaim_save();
>  	do {
>  		sock->sk->sk_allocation = GFP_NOIO | __GFP_MEMALLOC;
>  		msg.msg_name = NULL;
> @@ -244,7 +245,7 @@ static int sock_xmit(struct nbd_device *nbd, int index, int send,
>  			*sent += result;
>  	} while (msg_data_left(&msg));
>  
> -	tsk_restore_flags(current, pflags, PF_MEMALLOC);
> +	memalloc_noreclaim_restore(noreclaim_flag);
>  
>  	return result;
>  }
> diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
> index 4228aba1f654..4842fc0e809d 100644
> --- a/drivers/scsi/iscsi_tcp.c
> +++ b/drivers/scsi/iscsi_tcp.c
> @@ -30,6 +30,7 @@
>  #include <linux/types.h>
>  #include <linux/inet.h>
>  #include <linux/slab.h>
> +#include <linux/sched/mm.h>
>  #include <linux/file.h>
>  #include <linux/blkdev.h>
>  #include <linux/delay.h>
> @@ -371,10 +372,10 @@ static inline int iscsi_sw_tcp_xmit_qlen(struct iscsi_conn *conn)
>  static int iscsi_sw_tcp_pdu_xmit(struct iscsi_task *task)
>  {
>  	struct iscsi_conn *conn = task->conn;
> -	unsigned long pflags = current->flags;
> +	unsigned int noreclaim_flag;
>  	int rc = 0;
>  
> -	current->flags |= PF_MEMALLOC;
> +	noreclaim_flag = memalloc_noreclaim_save();
>  
>  	while (iscsi_sw_tcp_xmit_qlen(conn)) {
>  		rc = iscsi_sw_tcp_xmit(conn);
> @@ -387,7 +388,7 @@ static int iscsi_sw_tcp_pdu_xmit(struct iscsi_task *task)
>  		rc = 0;
>  	}
>  
> -	tsk_restore_flags(current, pflags, PF_MEMALLOC);
> +	memalloc_noreclaim_restore(noreclaim_flag);
>  	return rc;
>  }
>  
> diff --git a/net/core/dev.c b/net/core/dev.c
> index fde8b3f7136b..e0705a126b24 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -81,6 +81,7 @@
>  #include <linux/hash.h>
>  #include <linux/slab.h>
>  #include <linux/sched.h>
> +#include <linux/sched/mm.h>
>  #include <linux/mutex.h>
>  #include <linux/string.h>
>  #include <linux/mm.h>
> @@ -4227,7 +4228,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
>  	int ret;
>  
>  	if (sk_memalloc_socks() && skb_pfmemalloc(skb)) {
> -		unsigned long pflags = current->flags;
> +		unsigned int noreclaim_flag;
>  
>  		/*
>  		 * PFMEMALLOC skbs are special, they should
> @@ -4238,9 +4239,9 @@ static int __netif_receive_skb(struct sk_buff *skb)
>  		 * Use PF_MEMALLOC as this saves us from propagating the allocation
>  		 * context down to all allocation sites.
>  		 */
> -		current->flags |= PF_MEMALLOC;
> +		noreclaim_flag = memalloc_noreclaim_save();
>  		ret = __netif_receive_skb_core(skb, true);
> -		tsk_restore_flags(current, pflags, PF_MEMALLOC);
> +		memalloc_noreclaim_restore(noreclaim_flag);
>  	} else
>  		ret = __netif_receive_skb_core(skb, false);
>  
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 392f9b6f96e2..0b2d06b4c308 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -102,6 +102,7 @@
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
>  #include <linux/sched.h>
> +#include <linux/sched/mm.h>
>  #include <linux/timer.h>
>  #include <linux/string.h>
>  #include <linux/sockios.h>
> @@ -372,14 +373,14 @@ EXPORT_SYMBOL_GPL(sk_clear_memalloc);
>  int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
>  {
>  	int ret;
> -	unsigned long pflags = current->flags;
> +	unsigned int noreclaim_flag;
>  
>  	/* these should have been dropped before queueing */
>  	BUG_ON(!sock_flag(sk, SOCK_MEMALLOC));
>  
> -	current->flags |= PF_MEMALLOC;
> +	noreclaim_flag = memalloc_noreclaim_save();
>  	ret = sk->sk_backlog_rcv(sk, skb);
> -	tsk_restore_flags(current, pflags, PF_MEMALLOC);
> +	memalloc_noreclaim_restore(noreclaim_flag);
>  
>  	return ret;
>  }
> -- 
> 2.12.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
