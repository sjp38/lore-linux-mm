Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF806B03FA
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 19:00:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x23so775066wrb.6
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 16:00:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w48si208394wrc.34.2017.07.05.16.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 16:00:58 -0700 (PDT)
Date: Wed, 5 Jul 2017 16:00:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: disallow early_pfn_to_nid on configurations which
 do not implement it
Message-Id: <20170705160055.013fa5ff34bdf1f6efa4e6ce@linux-foundation.org>
In-Reply-To: <20170704075803.15979-1-mhocko@kernel.org>
References: <20170704075803.15979-1-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Yang Shi <yang.shi@linaro.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue,  4 Jul 2017 09:58:03 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> early_pfn_to_nid will return node 0 if both HAVE_ARCH_EARLY_PFN_TO_NID
> and HAVE_MEMBLOCK_NODE_MAP are disabled. It seems we are safe now
> because all architectures which support NUMA define one of them (with an
> exception of alpha which however has CONFIG_NUMA marked as broken) so
> this works as expected. It can get silently and subtly broken too
> easily, though. Make sure we fail the compilation if NUMA is enabled and
> there is no proper implementation for this function. If that ever
> happens we know that either the specific configuration is invalid
> and the fix should either disable NUMA or enable one of the above
> configs.
> 
> ...
>
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1055,6 +1055,7 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
>  	!defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
>  static inline unsigned long early_pfn_to_nid(unsigned long pfn)
>  {
> +	BUILD_BUG_ON(IS_ENABLED(CONFIG_NUMA));
>  	return 0;
>  }
>  #endif

Wouldn't this be more conventional?

--- a/include/linux/mmzone.h~a
+++ a/include/linux/mmzone.h
@@ -1052,7 +1052,8 @@ static inline struct zoneref *first_zone
 #endif
 
 #if !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) && \
-	!defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
+	!defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
+	!defined(CONFIG_NUMA)
 static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 {
 	return 0;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
