Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id A1A586B0255
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 11:46:12 -0500 (EST)
Received: by wmww144 with SMTP id w144so30240913wmw.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 08:46:12 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id j62si13160408wmd.65.2015.12.03.08.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 08:46:11 -0800 (PST)
Received: by wmec201 with SMTP id c201so36216640wme.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 08:46:11 -0800 (PST)
Date: Thu, 3 Dec 2015 17:46:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] proc: meminfo: estimate available memory more
 conservatively
Message-ID: <20151203164609.GC9271@dhcp22.suse.cz>
References: <1448913622-24198-1-git-send-email-hannes@cmpxchg.org>
 <1448913622-24198-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448913622-24198-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 30-11-15 15:00:22, Johannes Weiner wrote:
> The MemAvailable item in /proc/meminfo is to give users a hint of how
> much memory is allocatable without causing swapping, so it excludes
> the zones' low watermarks as unavailable to userspace.
> 
> However, for a userspace allocation, kswapd will actually reclaim
> until the free pages hit a combination of the high watermark and the
> page allocator's lowmem protection that keeps a certain amount of DMA
> and DMA32 memory from userspace as well.
> 
> Subtract the full amount we know to be unavailable to userspace from
> the number of free pages when calculating MemAvailable.

I am not sure this will make a big or even noticeable difference in the
real life but it makes sense.

> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  fs/proc/meminfo.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 9155a5a..df4661a 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -57,11 +57,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  	/*
>  	 * Estimate the amount of memory available for userspace allocations,
>  	 * without causing swapping.
> -	 *
> -	 * Free memory cannot be taken below the low watermark, before the
> -	 * system starts swapping.
>  	 */
> -	available = i.freeram - wmark_low;
> +	available = i.freeram - totalreserve_pages;
>  
>  	/*
>  	 * Not all the page cache can be freed, otherwise the system will
> -- 
> 2.6.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
