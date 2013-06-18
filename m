Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id E87046B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 21:45:25 -0400 (EDT)
Received: by mail-yh0-f43.google.com with SMTP id b12so1302473yha.2
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 18:45:24 -0700 (PDT)
Date: Mon, 17 Jun 2013 18:45:18 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 14/22] x86, mm, numa: Set memblock nid later
Message-ID: <20130618014518.GX32663@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <1371128589-8953-15-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128589-8953-15-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 13, 2013 at 09:03:01PM +0800, Tang Chen wrote:
> From: Yinghai Lu <yinghai@kernel.org>
> 
> In order to seperate parsing numa info procedure into two steps,

Short "why" would be nice.

> we need to set memblock nid later because it could change memblock
                                   ^
				   in where?

> array, and possible doube memblock.memory array which will allocate
             ^
	     possibly double

> buffer.

 which is bad why?

> Only set memblock nid once for successful path.
> 
> Also rename numa_register_memblks to numa_check_memblks() after
> moving out code of setting memblock nid.
> @@ -676,6 +669,11 @@ void __init x86_numa_init(void)
>  
>  	early_x86_numa_init();
>  
> +	for (i = 0; i < mi->nr_blks; i++) {
> +		struct numa_memblk *mb = &mi->blk[i];
> +		memblock_set_node(mb->start, mb->end - mb->start, mb->nid);
> +	}
> +

Can we please have some comments explaining the new ordering
requirements?  When reading code, how is one supposed to know that the
ordering of operations is all deliberate and fragile?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
