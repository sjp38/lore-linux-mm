Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 13BBD6B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 10:38:52 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id a1so19912102wgh.12
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 07:38:51 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id ey12si29480477wid.77.2015.02.17.07.38.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 07:38:50 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id bs8so34631963wib.4
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 07:38:49 -0800 (PST)
Date: Tue, 17 Feb 2015 16:38:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150217153847.GF32017@dhcp22.suse.cz>
References: <20141230112158.GA15546@dhcp22.suse.cz>
 <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150217125315.GA14287@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

On Tue 17-02-15 07:53:15, Johannes Weiner wrote:
[...]
> diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> index a7a3a63bb360..17ced1805d3a 100644
> --- a/fs/xfs/kmem.c
> +++ b/fs/xfs/kmem.c
> @@ -45,20 +45,12 @@ kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
>  void *
>  kmem_alloc(size_t size, xfs_km_flags_t flags)
>  {
> -	int	retries = 0;
>  	gfp_t	lflags = kmem_flags_convert(flags);
> -	void	*ptr;
>  
> -	do {
> -		ptr = kmalloc(size, lflags);
> -		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
> -			return ptr;
> -		if (!(++retries % 100))
> -			xfs_err(NULL,
> -		"possible memory allocation deadlock in %s (mode:0x%x)",
> -					__func__, lflags);
> -		congestion_wait(BLK_RW_ASYNC, HZ/50);
> -	} while (1);
> +	if (!(flags & (KM_MAYFAIL | KM_NOSLEEP)))
> +		lflags |= __GFP_NOFAIL;
> +
> +	return kmalloc(size, lflags);
>  }
>  
>  void *

Yes, I think this is the right thing to do (care to send a patch with
the full changelog?).
We really want to have __GFP_NOFAIL explicit. If for nothing else I hope
we can get lockdep checks for this flag. I am hopelessly unfamiliar with
lockdep but even warning from __lockdep_trace_alloc for this flag and
any lock held in the current's context might be helpful to identify
those places and try to fix them.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
