Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7513B6B0254
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:50:51 -0500 (EST)
Received: by wmec201 with SMTP id c201so151719020wme.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:50:51 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id n123si18043805wmg.124.2015.11.23.01.50.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 01:50:50 -0800 (PST)
Received: by wmww144 with SMTP id w144so88458436wmw.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:50:50 -0800 (PST)
Date: Mon, 23 Nov 2015 10:50:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix up sparse warning in gfpflags_allow_blocking
Message-ID: <20151123095048.GB21436@dhcp22.suse.cz>
References: <1448030459-20990-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448030459-20990-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 20-11-15 09:40:59, Jeff Layton wrote:
> sparse says:
> 
>     include/linux/gfp.h:274:26: warning: incorrect type in return expression (different base types)
>     include/linux/gfp.h:274:26:    expected bool
>     include/linux/gfp.h:274:26:    got restricted gfp_t
> 
> ...add a forced cast to silence the warning.
> 
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  include/linux/gfp.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 6523109e136d..8942af0813e3 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -271,7 +271,7 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
>  
>  static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
>  {
> -	return gfp_flags & __GFP_DIRECT_RECLAIM;
> +	return (bool __force)(gfp_flags & __GFP_DIRECT_RECLAIM);

Wouldn't (gfp_flags & __GFP_DIRECT_RECLAIM) != 0 be easier/better to read?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
