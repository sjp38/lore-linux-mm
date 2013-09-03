Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id CDA8B6B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 01:41:02 -0400 (EDT)
Message-ID: <5225765E.8000402@cn.fujitsu.com>
Date: Tue, 03 Sep 2013 13:40:46 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] mm/vmalloc: move VM_UNINITIALIZED just before
 show_numa_info
References: <1378177220-26218-1-git-send-email-liwanp@linux.vnet.ibm.com> <1378177220-26218-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1378177220-26218-3-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/03/2013 11:00 AM, Wanpeng Li wrote:
> The VM_UNINITIALIZED/VM_UNLIST flag introduced by commit f5252e00(mm: avoid
> null pointer access in vm_struct via /proc/vmallocinfo) is used to avoid
> accessing the pages field with unallocated page when show_numa_info() is
> called. This patch move the check just before show_numa_info in order that
> some messages still can be dumped via /proc/vmallocinfo.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Hmmm, sorry again. Please revert commit
d157a55815ffff48caec311dfb543ce8a79e283e. That said, we could still
do the check in show_numa_info like before.

> ---
>  mm/vmalloc.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index e3ec8b4..c4720cd 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2590,11 +2590,6 @@ static int s_show(struct seq_file *m, void *p)
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
> @@ -2622,6 +2617,11 @@ static int s_show(struct seq_file *m, void *p)
>  	if (v->flags & VM_VPAGES)
>  		seq_printf(m, " vpages");
>  
> +	/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
> +	smp_rmb();
> +	if (v->flags & VM_UNINITIALIZED)
> +		return 0;
> +
>  	show_numa_info(m, v);
>  	seq_putc(m, '\n');
>  	return 0;
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
