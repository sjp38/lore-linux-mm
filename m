Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id EE9586B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 18:04:51 -0400 (EDT)
Received: by ghrr1 with SMTP id r1so753386ghr.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 15:04:51 -0700 (PDT)
Message-ID: <5064CD7F.1040507@gmail.com>
Date: Thu, 27 Sep 2012 18:04:47 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] slub, hotplug: ignore unrelated node's hot-adding
 and hot-removing
References: <1348728470-5580-1-git-send-email-laijs@cn.fujitsu.com> <1348728470-5580-3-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1348728470-5580-3-git-send-email-laijs@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, kosaki.motohiro@gmail.com

(9/27/12 2:47 AM), Lai Jiangshan wrote:
> SLUB only fucus on the nodes which has normal memory, so ignore the other
> node's hot-adding and hot-removing.
> 
> Aka: if some memroy of a node(which has no onlined memory) is online,
> but this new memory onlined is not normal memory(HIGH memory example),
> we should not allocate kmem_cache_node for SLUB.
> 
> And if the last normal memory is offlined, but the node still has memroy,
> we should remove kmem_cache_node for that node.(current code delay it when
> all of the memory is offlined)
> 
> so we only do something when marg->status_change_nid_normal > 0.
> marg->status_change_nid is not suitable here.
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> ---
>  mm/slub.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 2fdd96f..2d78639 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3577,7 +3577,7 @@ static void slab_mem_offline_callback(void *arg)
>  	struct memory_notify *marg = arg;
>  	int offline_node;
>  
> -	offline_node = marg->status_change_nid;
> +	offline_node = marg->status_change_nid_normal;
>  
>  	/*
>  	 * If the node still has available memory. we need kmem_cache_node
> @@ -3610,7 +3610,7 @@ static int slab_mem_going_online_callback(void *arg)
>  	struct kmem_cache_node *n;
>  	struct kmem_cache *s;
>  	struct memory_notify *marg = arg;
> -	int nid = marg->status_change_nid;
> +	int nid = marg->status_change_nid_normal;
>  	int ret = 0;

Looks reasonable. I think slab need similar fix too.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
