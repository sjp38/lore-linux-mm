Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D269A6B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 16:20:52 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b2so11524589pgt.6
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 13:20:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d14si15126141pfl.122.2018.04.25.13.20.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Apr 2018 13:20:50 -0700 (PDT)
Subject: Re: [PATCH v4] fault-injection: introduce kvmalloc fallback options
References: <20180421144757.GC14610@bombadil.infradead.org>
 <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180423151545.GU17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424125121.GA17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804241142340.15660@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424162906.GM17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804241250350.28995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424170349.GQ17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424173836.GR17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>
Date: Wed, 25 Apr 2018 13:20:39 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

On 04/25/2018 01:02 PM, Mikulas Patocka wrote:
> 
> 
> From: Mikulas Patocka <mpatocka@redhat.com>
> Subject: [PATCH v4] fault-injection: introduce kvmalloc fallback options
> 
> This patch introduces a fault-injection option "kvmalloc_fallback". This
> option makes kvmalloc randomly fall back to vmalloc.
> 
> Unfortunatelly, some kernel code has bugs - it uses kvmalloc and then

  Unfortunately,

> uses DMA-API on the returned memory or frees it with kfree. Such bugs were
> found in the virtio-net driver, dm-integrity or RHEL7 powerpc-specific
> code. This options helps to test for these bugs.
> 
> The patch introduces a config option FAIL_KVMALLOC_FALLBACK_PROBABILITY.
> It can be enabled in distribution debug kernels, so that kvmalloc abuse
> can be tested by the users. The default can be overriden with

                                                 overridden

> "kvmalloc_fallback" parameter or in /sys/kernel/debug/kvmalloc_fallback/.
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> 
> ---
>  Documentation/fault-injection/fault-injection.txt |    7 +++++
>  include/linux/fault-inject.h                      |    9 +++---
>  kernel/futex.c                                    |    2 -
>  lib/Kconfig.debug                                 |   15 +++++++++++
>  mm/failslab.c                                     |    2 -
>  mm/page_alloc.c                                   |    2 -
>  mm/util.c                                         |   30 ++++++++++++++++++++++
>  7 files changed, 60 insertions(+), 7 deletions(-)
> 
> Index: linux-2.6/Documentation/fault-injection/fault-injection.txt
> ===================================================================
> --- linux-2.6.orig/Documentation/fault-injection/fault-injection.txt	2018-04-16 21:08:34.000000000 +0200
> +++ linux-2.6/Documentation/fault-injection/fault-injection.txt	2018-04-25 21:36:36.000000000 +0200
> @@ -15,6 +15,12 @@ o fail_page_alloc
>  
>    injects page allocation failures. (alloc_pages(), get_free_pages(), ...)
>  
> +o kvmalloc_faillback

     kvmalloc_fallback

> +
> +  makes the function kvmalloc randonly fall back to vmalloc. This could be used

                                 randomly

> +  to detects bugs such as using DMA-API on the result of kvmalloc or freeing
> +  the result of kvmalloc with free.
> +
>  o fail_futex
>  
>    injects futex deadlock and uaddr fault errors.
> @@ -167,6 +173,7 @@ use the boot option:
>  
>  	failslab=
>  	fail_page_alloc=
> +	kvmalloc_faillback=

	kvmalloc_fallback=

>  	fail_make_request=
>  	fail_futex=
>  	mmc_core.fail_request=<interval>,<probability>,<space>,<times>

> Index: linux-2.6/lib/Kconfig.debug
> ===================================================================
> --- linux-2.6.orig/lib/Kconfig.debug	2018-04-25 15:56:16.000000000 +0200
> +++ linux-2.6/lib/Kconfig.debug	2018-04-25 21:39:45.000000000 +0200
> @@ -1527,6 +1527,21 @@ config FAIL_PAGE_ALLOC
>  	help
>  	  Provide fault-injection capability for alloc_pages().
>  
> +config FAIL_KVMALLOC_FALLBACK_PROBABILITY
> +	int "Default kvmalloc fallback probability"
> +	depends on FAULT_INJECTION
> +	range 0 100
> +	default "0"
> +	help
> +	  This option will make kvmalloc randomly fall back to vmalloc.
> +	  Normally, kvmalloc falls back to vmalloc only rarely, if memory
> +	  is fragmented.
> +
> +	  This option helps to detect hard-to-reproduce driver bugs, for
> +	  example using DMA API on the result of kvmalloc.
> +
> +	  The default may be overriden with the kvmalloc_faillback parameter.

	                     overridden         kvmalloc_fallback

> +
>  config FAIL_MAKE_REQUEST
>  	bool "Fault-injection capability for disk IO"
>  	depends on FAULT_INJECTION && BLOCK

-- 
~Randy
