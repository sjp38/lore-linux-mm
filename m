Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E414C6B0269
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 20:54:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so62147242pfg.1
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 17:54:55 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id to7si12239083pac.282.2016.08.24.17.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 17:54:54 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id y134so11950417pfg.0
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 17:54:54 -0700 (PDT)
Date: Wed, 24 Aug 2016 17:54:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: clarify COMPACTION Kconfig text
In-Reply-To: <1471939757-29789-1-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1608241750220.98155@chino.kir.corp.google.com>
References: <1471939757-29789-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 23 Aug 2016, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> The current wording of the COMPACTION Kconfig help text doesn't
> emphasise that disabling COMPACTION might cripple the page allocator
> which relies on the compaction quite heavily for high order requests and
> an unexpected OOM can happen with the lack of compaction. Make sure
> we are vocal about that.
> 

Since when has this been an issue?  I don't believe it has been an issue 
in the past for any archs that don't use thp.

> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/Kconfig | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 78a23c5c302d..0dff2f05b6d1 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -262,7 +262,14 @@ config COMPACTION
>  	select MIGRATION
>  	depends on MMU
>  	help
> -	  Allows the compaction of memory for the allocation of huge pages.
> +          Compaction is the only memory management component to form
> +          high order (larger physically contiguous) memory blocks
> +          reliably. Page allocator relies on the compaction heavily and
> +          the lack of the feature can lead to unexpected OOM killer
> +          invocation for high order memory requests. You shouldnm't
> +          disable this option unless there is really a strong reason for
> +          it and then we are really interested to hear about that at
> +          linux-mm@kvack.org.
>  
>  #
>  # support for page migration

This seems to strongly suggest that all kernels should be built with 
CONFIG_COMPACTION and its requirement, CONFIG_MIGRATION.  Migration has a 
dependency of NUMA or memory hot-remove (not all popular).  Compaction can 
defragment memory within single zone without reliance on NUMA.

This seems like a very bizarre requirement and I'm wondering where we 
regressed from this thp-only behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
