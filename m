Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id CB4E76B0071
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 00:46:58 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E2C2A3EE0C0
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:46:56 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BD43E45DE56
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:46:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E46E45DE50
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:46:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 927FD1DB803A
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:46:56 +0900 (JST)
Received: from g01jpexchyt31.g01.fujitsu.local (g01jpexchyt31.g01.fujitsu.local [10.128.193.114])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 41940E38005
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:46:56 +0900 (JST)
Message-ID: <50AC6AA3.8000806@jp.fujitsu.com>
Date: Wed, 21 Nov 2012 14:46:11 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] x86: Get pg_data_t's memory from other node
References: <1353335246-9127-1-git-send-email-tangchen@cn.fujitsu.com> <1353335246-9127-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1353335246-9127-2-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, rob@landley.net, akpm@linux-foundation.org, laijs@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, yinghai@kernel.org, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

Hi Tang,

2012/11/19 23:27, Tang Chen wrote:
> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> If system can create movable node which all memory of the
> node is allocated as ZONE_MOVABLE, setup_node_data() cannot
> allocate memory for the node's pg_data_t.
> So when memblock_alloc_nid() fails, setup_node_data() retries
> memblock_alloc().
> 
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
> Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
>   arch/x86/mm/numa.c |    9 +++++++--
>   1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 2d125be..ae2e76e 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -224,9 +224,14 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
>   	} else {
>   		nd_pa = memblock_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
>   		if (!nd_pa) {
> -			pr_err("Cannot find %zu bytes in node %d\n",

> +			printk(KERN_WARNING "Cannot find %zu bytes in node %d\n",
>   			       nd_size, nid)

Please change to use pr_warn().

Thanks,
Yasuaki Ishimatsu

> -			return;
> +			nd_pa = memblock_alloc(nd_size, SMP_CACHE_BYTES);
> +			if (!nd_pa) {
> +				pr_err("Cannot find %zu bytes in other node\n",
> +				       nd_size);
> +				return;
> +			}
>   		}
>   		nd = __va(nd_pa);
>   	}
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
