Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4656B6B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 03:35:33 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp09.in.ibm.com (8.13.1/8.13.1) with ESMTP id n148I4Fj002556
	for <linux-mm@kvack.org>; Wed, 4 Feb 2009 13:48:04 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n148ZXx52011168
	for <linux-mm@kvack.org>; Wed, 4 Feb 2009 14:05:33 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n148ZR7k022932
	for <linux-mm@kvack.org>; Wed, 4 Feb 2009 19:35:27 +1100
Date: Wed, 4 Feb 2009 14:05:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] use __GFP_NOWARN in page cgroup allocation
Message-ID: <20090204083524.GJ4456@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090204170944.c93772d2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090204170944.c93772d2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, heiko.carstens@de.ibm.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-02-04 17:09:44]:

> This was recommended in
> "kmalloc-return-null-instead-of-link-failure.patch added to -mm tree" thread
> in the last month.
> Thanks,
> -Kame
> =
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> page_cgroup's page allocation at init/memory hotplug uses kmalloc() and
> vmalloc(). If kmalloc() failes, vmalloc() is used.
> 
> This is because vmalloc() is very limited resource on 32bit systems.
> We want to use kmalloc() first.
> 
> But in this kind of call, __GFP_NOWARN should be specified.
> 
> Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> Index: mmotm-2.6.29-Feb03/mm/page_cgroup.c
> ===================================================================
> --- mmotm-2.6.29-Feb03.orig/mm/page_cgroup.c
> +++ mmotm-2.6.29-Feb03/mm/page_cgroup.c
> @@ -114,7 +114,8 @@ static int __init_refok init_section_pag
>  		nid = page_to_nid(pfn_to_page(pfn));
>  		table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
>  		if (slab_is_available()) {
> -			base = kmalloc_node(table_size, GFP_KERNEL, nid);
> +			base = kmalloc_node(table_size,
> +					GFP_KERNEL | __GFP_NOWARN, nid);

Thanks for getting to this.

>  			if (!base)
>  				base = vmalloc_node(table_size, nid);
>  		} else {

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
