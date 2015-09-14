Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 747C66B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 15:40:45 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so146026459wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:40:45 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id i2si20723028wjx.103.2015.09.14.12.40.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 12:40:44 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so156888119wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:40:43 -0700 (PDT)
Date: Mon, 14 Sep 2015 21:40:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] memcg: drop unnecessary cold-path tests from
 __memcg_kmem_bypass()
Message-ID: <20150914194042.GB26273@dhcp22.suse.cz>
References: <20150913201416.GC25369@htj.duckdns.org>
 <20150913201442.GD25369@htj.duckdns.org>
 <20150913201509.GE25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150913201509.GE25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Sun 13-09-15 16:15:09, Tejun Heo wrote:
> __memcg_kmem_bypass() decides whether a kmem allocation should be
> bypassed to the root memcg.  Some conditions that it tests are valid
> criteria regarding who should be held accountable; however, there are
> a couple unnecessary tests for cold paths - __GFP_FAIL and
> fatal_signal_pending().
> 
> The previous patch updated try_charge() to handle both __GFP_FAIL and
> dying tasks correctly and the only thing these two tests are doing is
> making accounting less accurate and sprinkling tests for cold path
> conditions in the hot paths.  There's nothing meaningful gained by
> these extra tests.
> 
> This patch removes the two unnecessary tests from
> __memcg_kmem_bypass().
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memcontrol.h |   14 --------------
>  1 file changed, 14 deletions(-)
> 
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -780,24 +780,10 @@ static inline bool __memcg_kmem_bypass(g
>  {
>  	if (!memcg_kmem_enabled())
>  		return true;
> -
>  	if (gfp & __GFP_NOACCOUNT)
>  		return true;
> -	/*
> -	 * __GFP_NOFAIL allocations will move on even if charging is not
> -	 * possible. Therefore we don't even try, and have this allocation
> -	 * unaccounted. We could in theory charge it forcibly, but we hope
> -	 * those allocations are rare, and won't be worth the trouble.
> -	 */
> -	if (gfp & __GFP_NOFAIL)
> -		return true;
>  	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
>  		return true;
> -
> -	/* If the test is dying, just let it go. */
> -	if (unlikely(fatal_signal_pending(current)))
> -		return true;
> -
>  	return false;
>  }
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
