Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9FEC36B00AF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 08:41:14 -0500 (EST)
Received: by mail-la0-f50.google.com with SMTP id hz20so871479lab.23
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 05:41:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si708220laf.102.2014.11.04.05.41.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 05:41:13 -0800 (PST)
Date: Tue, 4 Nov 2014 14:41:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: embed the memcg pointer directly into struct page
Message-ID: <20141104134110.GD22207@dhcp22.suse.cz>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
 <54589017.9060604@jp.fujitsu.com>
 <20141104132701.GA18441@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141104132701.GA18441@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 04-11-14 08:27:01, Johannes Weiner wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: move page->mem_cgroup bad page handling into generic code fix
> 
> Remove obsolete memory saving recommendations from the MEMCG Kconfig
> help text.

The memory overhead is still there. So I do not think it is good to
remove the message altogether. The current overhead might be 4 or 8B
depending on the configuration. What about
"
	Note that setting this option might increase fixed memory
	overhead associated with each page descriptor in the system.
	The memory overhead depends on the architecture and other
	configuration options which have influence on the size and
	alignment on the page descriptor (struct page). Namely
	CONFIG_SLUB has a requirement for page alignment to two words
	which in turn means that 64b systems might not see any memory
	overhead as the additional data fits into alignment. On the
	other hand 32b systems might see 8B memory overhead.
"

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  init/Kconfig | 12 ------------
>  1 file changed, 12 deletions(-)
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index 01b7f2a6abf7..d68d8b0780b3 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -983,18 +983,6 @@ config MEMCG
>  	  Provides a memory resource controller that manages both anonymous
>  	  memory and page cache. (See Documentation/cgroups/memory.txt)
>  
> -	  Note that setting this option increases fixed memory overhead
> -	  associated with each page of memory in the system. By this,
> -	  8(16)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
> -	  usage tracking struct at boot. Total amount of this is printed out
> -	  at boot.
> -
> -	  Only enable when you're ok with these trade offs and really
> -	  sure you need the memory resource controller. Even when you enable
> -	  this, you can set "cgroup_disable=memory" at your boot option to
> -	  disable memory resource controller and you can avoid overheads.
> -	  (and lose benefits of memory resource controller)
> -
>  config MEMCG_SWAP
>  	bool "Memory Resource Controller Swap Extension"
>  	depends on MEMCG && SWAP
> -- 
> 2.1.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
