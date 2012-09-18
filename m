Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 2DD2B6B005A
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 20:12:05 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1A8F93EE0C0
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 09:12:03 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F07C945DE50
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 09:12:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AB27B45DE55
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 09:12:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 99D3B1DB8042
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 09:12:02 +0900 (JST)
Received: from g01jpexchyt04.g01.fujitsu.local (g01jpexchyt04.g01.fujitsu.local [10.128.194.43])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D25B41DB803F
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 09:12:01 +0900 (JST)
Message-ID: <5057BC2F.3020008@jp.fujitsu.com>
Date: Tue, 18 Sep 2012 09:11:27 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND] memory hotplug: fix a double register section
 info bug
References: <5052A7DF.4050301@gmail.com> <50530E39.5020100@jp.fujitsu.com> <20120914131428.1f530681.akpm@linux-foundation.org>
In-Reply-To: <20120914131428.1f530681.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: qiuxishi <qiuxishi@gmail.com>, mgorman@suse.de, tony.luck@intel.com, Jiang Liu <jiang.liu@huawei.com>, qiuxishi@huawei.com, bessel.wang@huawei.com, wujianguo@huawei.com, paul.gortmaker@windriver.com, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, rientjes@google.com, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wen Congyang <wency@cn.fujitsu.com>

2012/09/15 5:14, Andrew Morton wrote:
> On Fri, 14 Sep 2012 20:00:09 +0900
> Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:
>
>>> @@ -187,9 +184,10 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
>>>    	end_pfn = pfn + pgdat->node_spanned_pages;
>>>
>>>    	/* register_section info */
>>> -	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION)
>>> -		register_page_bootmem_info_section(pfn);
>>> -
>>> +	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
>>> +		if (pfn_valid(pfn) && (pfn_to_nid(pfn) == node))
>>
>> I cannot judge whether your configuration is correct or not.
>> Thus if it is correct, I want a comment of why the node check is
>> needed. In usual configuration, a node does not span the other one.
>> So it is natural that "pfn_to_nid(pfn) is same as "pgdat->node_id".
>> Thus we may remove the node check in the future.
>
> yup.  How does this look?

Looks good to me.

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

>
> --- a/mm/memory_hotplug.c~memory-hotplug-fix-a-double-register-section-info-bug-fix
> +++ a/mm/memory_hotplug.c
> @@ -185,6 +185,12 @@ void register_page_bootmem_info_node(str
>
>   	/* register_section info */
>   	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> +		/*
> +		 * Some platforms can assign the same pfn to multiple nodes - on
> +		 * node0 as well as nodeN.  To avoid registering a pfn against
> +		 * multiple nodes we check that this pfn does not already
> +		 * reside in some other node.
> +		 */
>   		if (pfn_valid(pfn) && (pfn_to_nid(pfn) == node))
>   			register_page_bootmem_info_section(pfn);
>   	}
> _
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
