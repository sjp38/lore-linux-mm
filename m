Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3E76B0038
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 19:02:07 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so1552628pdb.33
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 16:02:07 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id c5si4189949pdn.70.2014.12.09.16.02.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 16:02:05 -0800 (PST)
Received: from kw-mxq.gw.nic.fujitsu.com (unknown [10.0.237.131])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C72B53EE0C1
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:02:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id C3611AC06D7
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:02:01 +0900 (JST)
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6286EE08002
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:02:01 +0900 (JST)
Message-ID: <54878D56.4030508@jp.fujitsu.com>
Date: Wed, 10 Dec 2014 09:01:26 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix invalid use of pfn_valid_within in test_pages_in_a_zone
References: <1418153696-167580-1-git-send-email-jcuster@sgi.com>
In-Reply-To: <1418153696-167580-1-git-send-email-jcuster@sgi.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Custer <jcuster@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
Cc: rja@sgi.com, dfults@sgi.com

(2014/12/10 4:34), James Custer wrote:
> Offlining memory by 'echo 0 > /sys/devices/system/memory/memory#/online'
> or reading valid_zones 'cat /sys/devices/system/memory/memory#/valid_zones'

> causes BUG: unable to handle kernel paging request due to invalid use of
> pfn_valid_within. This is due to a bug in test_pages_in_a_zone.

The information is not enough to understand what happened on your system.
Could you show full BUG messages?

> 
> In order to use pfn_valid_within within a MAX_ORDER_NR_PAGES block of pages,
> a valid pfn within the block must first be found. There only needs to be
> one valid pfn found in test_pages_in_a_zone in the first place. So the
> fix is to replace pfn_valid_within with pfn_valid such that the first
> valid pfn within the pageblock is found (if it exists). This works
> independently of CONFIG_HOLES_IN_ZONE.
> 
> Signed-off-by: James Custer <jcuster@sgi.com>
> ---
>   mm/memory_hotplug.c | 11 ++++++-----
>   1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 1bf4807..304c187 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1331,7 +1331,7 @@ int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
>   }
>   
>   /*
> - * Confirm all pages in a range [start, end) is belongs to the same zone.
> + * Confirm all pages in a range [start, end) belong to the same zone.
>    */
>   int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>   {
> @@ -1342,10 +1342,11 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>   	for (pfn = start_pfn;
>   	     pfn < end_pfn;
>   	     pfn += MAX_ORDER_NR_PAGES) {

> -		i = 0;
> -		/* This is just a CONFIG_HOLES_IN_ZONE check.*/
> -		while ((i < MAX_ORDER_NR_PAGES) && !pfn_valid_within(pfn + i))
> -			i++;
> +		/* Find the first valid pfn in this pageblock */
> +		for (i = 0; i < MAX_ORDER_NR_PAGES; i++) {
> +			if (pfn_valid(pfn + i))
> +				break;
> +		}

If CONFIG_HOLES_IN_NODE is set, there is no difference. Am I making a mistake?

Thanks,
Yasuaki Ishimatsu


>   		if (i == MAX_ORDER_NR_PAGES)
>   			continue;
>   		page = pfn_to_page(pfn + i);
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
