Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4A016B0592
	for <linux-mm@kvack.org>; Wed,  9 May 2018 17:09:22 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g7-v6so24824747wrb.19
        for <linux-mm@kvack.org>; Wed, 09 May 2018 14:09:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s14-v6si2765389eds.258.2018.05.09.14.09.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 14:09:21 -0700 (PDT)
Date: Wed, 9 May 2018 23:09:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: allow deferred page init for vmemmap only
Message-ID: <20180509210920.GZ32366@dhcp22.suse.cz>
References: <20180509191713.23794-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509191713.23794-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, rostedt@goodmis.org, fengguang.wu@intel.com, dennisszhou@gmail.com

On Wed 09-05-18 15:17:13, Pavel Tatashin wrote:
> It is unsafe to do virtual to physical translations before mm_init() is
> called if struct page is needed in order to determine the memory section
> number (see SECTION_IN_PAGE_FLAGS). This is because only in mm_init() we
> initialize struct pages for all the allocated memory when deferred struct
> pages are used.
> 
> My recent fix exposed this problem, because it greatly reduced number of
> pages that are initialized before mm_init(), but the problem existed even
> before my fix, as Fengguang Wu found.
> 
> Since FLATMEM is already disallowed for deferred struct pages, it makes
> sense to allow deferred struct pages only on systems with
> SPARSEMEM_VMEMMAP.

This doesn't really explain why CONFIG_SPARSMEM or DISCONTIG has the
problem.

> The problems are discussed in these threads:
> http://lkml.kernel.org/r/20180418135300.inazvpxjxowogyge@wfg-t540p.sh.intel.com
> http://lkml.kernel.org/r/20180419013128.iurzouiqxvcnpbvz@wfg-t540p.sh.intel.com
> http://lkml.kernel.org/r/20180426202619.2768-1-pasha.tatashin@oracle.com

Using references is good but there should be a highlevel summary in the
chaneglog as well.

> Fixes: 3a80a7fa7989 ("mm: meminit: initialise a subset of struct pages if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set")
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  mm/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index d5004d82a1d6..1cd32d67ca30 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -635,7 +635,7 @@ config DEFERRED_STRUCT_PAGE_INIT
>  	bool "Defer initialisation of struct pages to kthreads"
>  	default n
>  	depends on NO_BOOTMEM
> -	depends on !FLATMEM
> +	depends on SPARSEMEM_VMEMMAP
>  	help
>  	  Ordinarily all struct pages are initialised during early boot in a
>  	  single thread. On very large machines this can take a considerable
> -- 
> 2.17.0
> 

-- 
Michal Hocko
SUSE Labs
