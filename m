Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 495256B02E3
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 03:35:41 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id a20so23625245wme.5
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 00:35:41 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id d3si21773724wjm.90.2016.12.20.00.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 00:35:39 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id m203so22875144wma.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 00:35:39 -0800 (PST)
Date: Tue, 20 Dec 2016 09:35:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: throttle show_mem from warn_alloc
Message-ID: <20161220083537.GA3769@dhcp22.suse.cz>
References: <20161215101510.9030-1-mhocko@kernel.org>
 <20161219152125.f77ddf79f3c89e5cdd0e02d6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161219152125.f77ddf79f3c89e5cdd0e02d6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 19-12-16 15:21:25, Andrew Morton wrote:
> On Thu, 15 Dec 2016 11:15:10 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Tetsuo has been stressing OOM killer path with many parallel allocation
> > requests when he has noticed that it is not all that hard to swamp
> > kernel logs with warn_alloc messages caused by allocation stalls. Even
> > though the allocation stall message is triggered only once in 10s there
> > might be many different tasks hitting it roughly around the same time.
> > 
> > A big part of the output is show_mem() which can generate a lot of
> > output even on a small machines. There is no reason to show the state of
> > memory counter for each allocation stall, especially when multiple of
> > them are reported in a short time period. Chances are that not much has
> > changed since the last report. This patch simply rate limits show_mem
> > called from warn_alloc to only dump something once per second. This
> > should be enough to give us a clue why an allocation might be stalling
> > while burst of warnings will not swamp log with too much data.
> > 
> > While we are at it, extract all the show_mem related handling (filters)
> > into a separate function warn_alloc_show_mem. This will make the code
> > cleaner and as a bonus point we can distinguish which part of warn_alloc
> > got throttled due to rate limiting as ___ratelimit dumps the caller.
> 
> These guys don't need file-wide scope...
> 
> --- a/mm/page_alloc.c~mm-throttle-show_mem-from-warn_alloc-fix
> +++ a/mm/page_alloc.c
> @@ -3018,15 +3018,10 @@ static inline bool should_suppress_show_
>  	return ret;
>  }
>  
> -static DEFINE_RATELIMIT_STATE(nopage_rs,
> -		DEFAULT_RATELIMIT_INTERVAL,
> -		DEFAULT_RATELIMIT_BURST);
> -
> -static DEFINE_RATELIMIT_STATE(show_mem_rs, HZ, 1);
> -
>  static void warn_alloc_show_mem(gfp_t gfp_mask)
>  {
>  	unsigned int filter = SHOW_MEM_FILTER_NODES;
> +	static DEFINE_RATELIMIT_STATE(show_mem_rs, HZ, 1);
>  
>  	if (should_suppress_show_mem() || !__ratelimit(&show_mem_rs))
>  		return;
> @@ -3050,6 +3045,8 @@ void warn_alloc(gfp_t gfp_mask, const ch
>  {
>  	struct va_format vaf;
>  	va_list args;
> +	static DEFINE_RATELIMIT_STATE(nopage_rs, DEFAULT_RATELIMIT_INTERVAL,
> +				      DEFAULT_RATELIMIT_BURST);
>  
>  	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
>  	    debug_guardpage_minorder() > 0)
> _
> 

Acked-by: Michal Hocko <mhocko@suse.com>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
