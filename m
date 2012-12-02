Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id B31656B005D
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 10:11:49 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so1391789pad.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 07:11:49 -0800 (PST)
Message-ID: <50BB6F8C.1060800@gmail.com>
Date: Sun, 02 Dec 2012 23:11:08 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/5] x86: get pg_data_t's memory from other node
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1353667445-7593-2-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On 11/23/2012 06:44 PM, Tang Chen wrote:
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
> ---
>  arch/x86/mm/numa.c |   11 ++++++++---
>  1 files changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 2d125be..734bbd2 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -224,9 +224,14 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
>  	} else {
>  		nd_pa = memblock_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
>  		if (!nd_pa) {
> -			pr_err("Cannot find %zu bytes in node %d\n",
> -			       nd_size, nid);
> -			return;
> +			pr_warn("Cannot find %zu bytes in node %d\n",
> +				nd_size, nid);
> +			nd_pa = memblock_alloc(nd_size, SMP_CACHE_BYTES);
> +			if (!nd_pa) {
> +				pr_err("Cannot find %zu bytes in other node\n",
> +				       nd_size);
> +				return;
> +			}
Hi Tang,
	Seems memblock_alloc_try_nid() serves the same purpose, so you may just
simply replace memblock_alloc_nid() with memblock_alloc_try_nid().

Regards!
Gerry

>  		}
>  		nd = __va(nd_pa);
>  	}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
