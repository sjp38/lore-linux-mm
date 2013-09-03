Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id ACC5D6B0034
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 03:24:44 -0400 (EDT)
Message-ID: <52258EAB.8040002@cn.fujitsu.com>
Date: Tue, 03 Sep 2013 15:24:27 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3/4] mm/vmalloc: revert "mm/vmalloc.c: check VM_UNINITIALIZED
 flag in s_show instead of show_numa_info"
References: <1378191706-29696-1-git-send-email-liwanp@linux.vnet.ibm.com> <1378191706-29696-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1378191706-29696-3-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/03/2013 03:01 PM, Wanpeng Li wrote:
> Changelog:
>  *v2 -> v3: revert commit d157a558 directly
> 
> The VM_UNINITIALIZED/VM_UNLIST flag introduced by commit f5252e00(mm: avoid
> null pointer access in vm_struct via /proc/vmallocinfo) is used to avoid
> accessing the pages field with unallocated page when show_numa_info() is
> called. This patch move the check just before show_numa_info in order that
> some messages still can be dumped via /proc/vmallocinfo. This patch revert 
> commit d157a558 (mm/vmalloc.c: check VM_UNINITIALIZED flag in s_show instead 
> of show_numa_info);
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> ---
>  mm/vmalloc.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index e3ec8b4..5368b17 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2562,6 +2562,11 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
>  		if (!counters)
>  			return;
>  
> +		/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
> +		smp_rmb();
> +		if (v->flags & VM_UNINITIALIZED)
> +			return;
> +
>  		memset(counters, 0, nr_node_ids * sizeof(unsigned int));
>  
>  		for (nr = 0; nr < v->nr_pages; nr++)
> @@ -2590,11 +2595,6 @@ static int s_show(struct seq_file *m, void *p)
>  
>  	v = va->vm;
>  
> -	/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
> -	smp_rmb();
> -	if (v->flags & VM_UNINITIALIZED)
> -		return 0;
> -
>  	seq_printf(m, "0x%pK-0x%pK %7ld",
>  		v->addr, v->addr + v->size, v->size);
>  
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
