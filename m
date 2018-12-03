Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id A683C6B6A22
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 11:29:13 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id l16so1581752lfc.8
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 08:29:13 -0800 (PST)
Received: from asavdk4.altibox.net (asavdk4.altibox.net. [109.247.116.15])
        by mx.google.com with ESMTPS id j13-v6si11494961lji.67.2018.12.03.08.29.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 08:29:12 -0800 (PST)
Date: Mon, 3 Dec 2018 17:29:08 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH v2 5/6] arch: simplify several early memory allocations
Message-ID: <20181203162908.GB4244@ravnborg.org>
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
 <1543852035-26634-6-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543852035-26634-6-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

Hi Mike.

> index c37955d..2a17665 100644
> --- a/arch/sparc/kernel/prom_64.c
> +++ b/arch/sparc/kernel/prom_64.c
> @@ -34,16 +34,13 @@
>  
>  void * __init prom_early_alloc(unsigned long size)
>  {
> -	unsigned long paddr = memblock_phys_alloc(size, SMP_CACHE_BYTES);
> -	void *ret;
> +	void *ret = memblock_alloc(size, SMP_CACHE_BYTES);
>  
> -	if (!paddr) {
> +	if (!ret) {
>  		prom_printf("prom_early_alloc(%lu) failed\n", size);
>  		prom_halt();
>  	}
>  
> -	ret = __va(paddr);
> -	memset(ret, 0, size);
>  	prom_early_allocated += size;
>  
>  	return ret;

memblock_alloc() calls memblock_alloc_try_nid().
And if allocation fails then memblock_alloc_try_nid() calls panic().
So will we ever hit the prom_halt() code?

Do we have a panic() implementation that actually returns?


> diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
> index 3c8aac2..52884f4 100644
> --- a/arch/sparc/mm/init_64.c
> +++ b/arch/sparc/mm/init_64.c
> @@ -1089,16 +1089,13 @@ static void __init allocate_node_data(int nid)
>  	struct pglist_data *p;
>  	unsigned long start_pfn, end_pfn;
>  #ifdef CONFIG_NEED_MULTIPLE_NODES
> -	unsigned long paddr;
>  
> -	paddr = memblock_phys_alloc_try_nid(sizeof(struct pglist_data),
> -					    SMP_CACHE_BYTES, nid);
> -	if (!paddr) {
> +	NODE_DATA(nid) = memblock_alloc_node(sizeof(struct pglist_data),
> +					     SMP_CACHE_BYTES, nid);
> +	if (!NODE_DATA(nid)) {
>  		prom_printf("Cannot allocate pglist_data for nid[%d]\n", nid);
>  		prom_halt();
>  	}
> -	NODE_DATA(nid) = __va(paddr);
> -	memset(NODE_DATA(nid), 0, sizeof(struct pglist_data));
>  
>  	NODE_DATA(nid)->node_id = nid;
>  #endif

Same here.

I did not look at the other cases.

	Sam
