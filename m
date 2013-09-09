Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id A8DC36B0031
	for <linux-mm@kvack.org>; Sun,  8 Sep 2013 20:53:07 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B7B723EE1CC
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 09:53:05 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A6D9645DE5D
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 09:53:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8597C45DE56
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 09:53:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 00C381DB8049
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 09:53:04 +0900 (JST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A66B3E08004
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 09:53:04 +0900 (JST)
Message-ID: <522D1BC4.9080500@jp.fujitsu.com>
Date: Mon, 9 Sep 2013 09:52:20 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hotplug: rename the function is_memblock_offlined_cb()
References: <52299848.1000105@huawei.com>
In-Reply-To: <52299848.1000105@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

(2013/09/06 17:54), Xishi Qiu wrote:
> Function is_memblock_offlined() return 1 means memory block is offlined,
> but is_memblock_offlined_cb() return 1 means memory block is not offlined,
> this will confuse somebody, so rename the function.
> Another, use "pfn_to_nid(pfn)" instead of "page_to_nid(pfn_to_page(pfn))".
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---

It looks good to me. But I have one comment.
Please see below.

>   mm/memory_hotplug.c |    6 +++---
>   1 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index ca1dd3a..a95dd28 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -937,7 +937,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>   	arg.nr_pages = nr_pages;
>   	node_states_check_changes_online(nr_pages, zone, &arg);
>

> -	nid = page_to_nid(pfn_to_page(pfn));
> +	nid = pfn_to_nid(pfn);

Please split the cleanup from this patch since the cleanup has
nothing to do with the description of this patch.

Thanks,
Yasuaki Ishimatsu

>
>   	ret = memory_notify(MEM_GOING_ONLINE, &arg);
>   	ret = notifier_to_errno(ret);
> @@ -1657,7 +1657,7 @@ int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
>   }
>
>   #ifdef CONFIG_MEMORY_HOTREMOVE
> -static int is_memblock_offlined_cb(struct memory_block *mem, void *arg)
> +static int check_memblock_offlined_cb(struct memory_block *mem, void *arg)
>   {
>   	int ret = !is_memblock_offlined(mem);
>
> @@ -1794,7 +1794,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
>   	 * if this is not the case.
>   	 */
>   	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
> -				is_memblock_offlined_cb);
> +				check_memblock_offlined_cb);
>   	if (ret) {
>   		unlock_memory_hotplug();
>   		BUG();
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
