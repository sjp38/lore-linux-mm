Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 526D36B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 05:28:45 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z81so45025312wrc.2
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 02:28:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2si12814635wmb.113.2017.07.04.02.28.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 02:28:43 -0700 (PDT)
Subject: Re: [PATCH] mm: disallow early_pfn_to_nid on configurations which do
 not implement it
References: <20170704075803.15979-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <61b4422c-34d7-f46b-2566-779f6a86d917@suse.cz>
Date: Tue, 4 Jul 2017 11:28:42 +0200
MIME-Version: 1.0
In-Reply-To: <20170704075803.15979-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Yang Shi <yang.shi@linaro.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 07/04/2017 09:58 AM, Michal Hocko wrote:
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
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
> Hi,
> I have brought this up earlier [1] because I thought the deferred
> initialization might be broken but then found out that this is not the
> case right now. This is an attempt to prevent any subtly broken users in
> future.
> 
> [1] http://lkml.kernel.org/r/20170630141847.GN22917@dhcp22.suse.cz
> 
>  include/linux/mmzone.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 16532fa0bb64..fc14b8b3f6ce 100644
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
