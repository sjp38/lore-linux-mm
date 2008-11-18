Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAI1Ghg0023289
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 18 Nov 2008 10:16:43 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 83BE945DD72
	for <linux-mm@kvack.org>; Tue, 18 Nov 2008 10:16:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 52FD745DD6C
	for <linux-mm@kvack.org>; Tue, 18 Nov 2008 10:16:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 39FC11DB803A
	for <linux-mm@kvack.org>; Tue, 18 Nov 2008 10:16:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E4D601DB8040
	for <linux-mm@kvack.org>; Tue, 18 Nov 2008 10:16:42 +0900 (JST)
Date: Tue, 18 Nov 2008 10:16:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] memcg: fix argument for kunmap_atomic
Message-Id: <20081118101601.58a4f41e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081118002719.532ce4cf.d-nishimura@mtf.biglobe.ne.jp>
References: <20081118002719.532ce4cf.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Nov 2008 00:27:19 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> kunmap_atomic() should take kmapped address as argument.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

I have to adimit test was not enough...Sigh..

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
> This patch is fix for memcg-swap-cgroup-for-remembering-usage.patch
> 
>  mm/page_cgroup.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index b0ea401..9c6ead1 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -350,7 +350,7 @@ struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
>  	sc += pos;
>  	old = sc->val;
>  	sc->val = mem;
> -	kunmap_atomic(mappage, KM_USER0);
> +	kunmap_atomic((void *)sc, KM_USER0);
>  	spin_unlock_irqrestore(&ctrl->lock, flags);
>  	return old;
>  }
> @@ -384,7 +384,7 @@ struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
>  	sc = kmap_atomic(mappage, KM_USER0);
>  	sc += pos;
>  	ret = sc->val;
> -	kunmap_atomic(mappage, KM_USER0);
> +	kunmap_atomic((void *)sc, KM_USER0);
>  	spin_unlock_irqrestore(&ctrl->lock, flags);
>  	return ret;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
