Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DCEC5600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 20:42:50 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o730kDr2000830
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 3 Aug 2010 09:46:13 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 092A245DE7B
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:46:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C283A45DE7A
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:46:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 81580E08002
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:46:12 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 345391DB803A
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:46:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: only build per-node scan_unevictable when NUMA is enabled
In-Reply-To: <1280780612-10548-1-git-send-email-cascardo@holoscopio.com>
References: <1280780612-10548-1-git-send-email-cascardo@holoscopio.com>
Message-Id: <20100803085421.5A5E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  3 Aug 2010 09:46:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Non-NUMA systems do never create these files anyway, since they are only
> created by driver subsystem when NUMA is configured.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>

This patch look good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


However, I'm not sure scan_unevictable feature have enough worth that
we continue to maintain. This feature mean "admins can restore unevictable
even if kernel have some bug". but I haven't seen such situation.

Anyway, I'm waiting Lee's response.


> ---
>  include/linux/swap.h |    5 +++++
>  mm/vmscan.c          |    3 ++-
>  2 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index ff4acea..3c0876d 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -271,8 +271,13 @@ extern void scan_mapping_unevictable_pages(struct address_space *);
>  extern unsigned long scan_unevictable_pages;
>  extern int scan_unevictable_handler(struct ctl_table *, int,
>  					void __user *, size_t *, loff_t *);
> +#ifdef CONFIG_NUMA
>  extern int scan_unevictable_register_node(struct node *node);
>  extern void scan_unevictable_unregister_node(struct node *node);
> +#else
> +static inline int scan_unevictable_register_node(struct node *node) {return 0;}
> +static inline void scan_unevictable_unregister_node(struct node *node) {}
> +#endif
>  
>  extern int kswapd_run(int nid);
>  extern void kswapd_stop(int nid);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b94fe1b..ba8f6fd 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2898,6 +2898,7 @@ int scan_unevictable_handler(struct ctl_table *table, int write,
>  	return 0;
>  }
>  
> +#ifdef CONFIG_NUMA
>  /*
>   * per node 'scan_unevictable_pages' attribute.  On demand re-scan of
>   * a specified node's per zone unevictable lists for evictable pages.
> @@ -2944,4 +2945,4 @@ void scan_unevictable_unregister_node(struct node *node)
>  {
>  	sysdev_remove_file(&node->sysdev, &attr_scan_unevictable_pages);
>  }
> -
> +#endif
> -- 
> 1.7.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
