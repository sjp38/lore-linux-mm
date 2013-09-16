Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id A8B5C6B0034
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 17:28:15 -0400 (EDT)
Message-ID: <523766E1.1020303@jp.fujitsu.com>
Date: Mon, 16 Sep 2013 16:15:29 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH v5 2/4] mm/vmalloc: revert "mm/vmalloc.c: emit
 the failure message before return"
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com> <1379202342-23140-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1379202342-23140-2-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: liwanp@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/14/2013 7:45 PM, Wanpeng Li wrote:
> Changelog:
>  *v2 -> v3: revert commit 46c001a2 directly
> 
> Don't warning twice in __vmalloc_area_node and __vmalloc_node_range if
> __vmalloc_area_node allocation failure. This patch revert commit 46c001a2
> (mm/vmalloc.c: emit the failure message before return).
> 
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/vmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index d78d117..e3ec8b4 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1635,7 +1635,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  
>  	addr = __vmalloc_area_node(area, gfp_mask, prot, node, caller);
>  	if (!addr)
> -		goto fail;
> +		return NULL;

This is not right fix. Now we have following call stack.

 __vmalloc_node
	__vmalloc_node_range
		__vmalloc_node

Even if we remove a warning of __vmalloc_node_range, we still be able to see double warning
because we call __vmalloc_node recursively.

I haven't catch your point why twice warning is unacceptable though.









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
