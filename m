Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9F24C282CB
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 09:55:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AD4221924
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 09:55:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AD4221924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7B108E0083; Fri,  8 Feb 2019 04:55:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2BA08E0002; Fri,  8 Feb 2019 04:55:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF4A38E0083; Fri,  8 Feb 2019 04:55:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 75BFC8E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 04:55:10 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b3so1216935edi.0
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 01:55:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sqesVHtJeqtci5xZ/dIaJNgH88dDm6/P+QpsFjQgTC8=;
        b=NXQlkxs64/cOxhKlzUDXm3gQ7fEDDowwJBmHslNTxowFgpTzhIfodQbj6IEQmPeA5o
         aBmw3lldGkbL9aYmNgY4JWpcqEe3bkUsYpQk/PhSB+NHLjvAWA9VdYThRk0EjSKXEdNj
         r4/lln3qaXMIskITW5D+dGN0eeHrefOym9x1Ni/wojrVzC8cKTltSr2KOOWjA9+0fQQF
         1sPplRupFZThB9Tr0AeIPBOhy8y5T2aga2Eupyar6x4nMv15fqXEKuAoEzmMzKJSzR3a
         ykOGF5HMywrfJRk+b0M8Hz9Xy90AMxTponexnE7hnn+sfJODDynI+94pz+0N4XuYcipm
         0CIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAubG2zgpc0rybLFYJuurQY3NUrfAnZnt+GbuleXJycc13/cy0wcY
	4xMSGLReVFvhbDo54RuQuAEntZPDc3tI/9uaOnIeuEbxzC7bh/oe8MA+cYuqICKcwc110K1mUn/
	iL5eqcS+++F0atgmaDo+xqo8BMxyDAbzPrh3ILHFLVdIVUnbSODtrHnaTAMbRsqyY6Q==
X-Received: by 2002:a17:906:8249:: with SMTP id f9mr15476224ejx.134.1549619709916;
        Fri, 08 Feb 2019 01:55:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IadglitC9PX8O3kM14lWRXuCRESl79bOCI0PjQyfBQmiHOk/RPceC0aMq+9AmMxlbj5VJbS
X-Received: by 2002:a17:906:8249:: with SMTP id f9mr15476166ejx.134.1549619708775;
        Fri, 08 Feb 2019 01:55:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549619708; cv=none;
        d=google.com; s=arc-20160816;
        b=L9ZhzdjW7RvGTSz1QDkY06OmYeWm2h12c9GCFfpphCp7OQYH79uJ/D2KYxpxm8pJAf
         e3ZqmebhP4xllc6I6wta2vYxS/vCVf3xKp8ZPZLGAYmHzrCzG5L1YSFrx2KWQDf0Gbei
         o2gkNjXQVI8/QnbeLiPf7DEk0nLjgQaRapDtkO9X4yOXWguNeE7g4aJ+fwI/TXJAEhtL
         Nn+H6+gO1av38onXI6WguFx24tfu5bngsBOp5Ur3l+t3VoCl2bUZItbqTR35ghzXw07i
         Ipwsh9t3aPokidPLfRFBwFn18em7iT+l6csQLXLxl5MYpvTfrtZzG3AlgcErRGMKIUvx
         N5yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sqesVHtJeqtci5xZ/dIaJNgH88dDm6/P+QpsFjQgTC8=;
        b=R+iCh0TvxR+9dktF/ZblT/TC79Ay40nEwJj4uSOPycVzIMDCXJMGupBESWfCeTh8fa
         Qmcp4AatQpXaqq0m+gmhlU7aPl5adqkPt71PXC1BpbcXR6r/Kn/7VRsxbXVoiG9PXfCF
         +qKB5go1nAWjrktK4QwFVxXDejOEn4CpPbabno67U68RwJ1OM1tfQFWrHrf7NOj4mk9u
         Wp7sbV16ygrfleCpY2GCV4hTrLvLpVGLt+WXJCF5oEUzuV3aZPHmhf6ZvrLFD6jYCWr9
         9+qHdp4QGbZ7NiAXMq6cRuoOCjWnlBtQHJmnAleRcqadNuzXrpNETRPvaIVnSyZAkPXG
         N1Hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c73si888719edf.450.2019.02.08.01.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 01:55:08 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 11216ABEC;
	Fri,  8 Feb 2019 09:55:08 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 672FA1E3DB5; Fri,  8 Feb 2019 10:55:07 +0100 (CET)
Date: Fri, 8 Feb 2019 10:55:07 +0100
From: Jan Kara <jack@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
	Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>,
	Chris Mason <clm@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	"vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached
 pages"
Message-ID: <20190208095507.GB6353@quack2.suse.cz>
References: <20190130041707.27750-1-david@fromorbit.com>
 <20190130041707.27750-2-david@fromorbit.com>
 <25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com>
 <20190131013403.GI4205@dastard>
 <20190131091011.GP18811@dhcp22.suse.cz>
 <20190131185704.GA8755@castle.DHCP.thefacebook.com>
 <20190131221904.GL4205@dastard>
 <20190207102750.GA4570@quack2.suse.cz>
 <20190207213727.a791db810341cec2c013ba93@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207213727.a791db810341cec2c013ba93@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 07-02-19 21:37:27, Andrew Morton wrote:
> On Thu, 7 Feb 2019 11:27:50 +0100 Jan Kara <jack@suse.cz> wrote:
> 
> > On Fri 01-02-19 09:19:04, Dave Chinner wrote:
> > > Maybe for memcgs, but that's exactly the oppose of what we want to
> > > do for global caches (e.g. filesystem metadata caches). We need to
> > > make sure that a single, heavily pressured cache doesn't evict small
> > > caches that lower pressure but are equally important for
> > > performance.
> > > 
> > > e.g. I've noticed recently a significant increase in RMW cycles in
> > > XFS inode cache writeback during various benchmarks. It hasn't
> > > affected performance because the machine has IO and CPU to burn, but
> > > on slower machines and storage, it will have a major impact.
> > 
> > Just as a data point, our performance testing infrastructure has bisected
> > down to the commits discussed in this thread as the cause of about 40%
> > regression in XFS file delete performance in bonnie++ benchmark.
> > 
> 
> Has anyone done significant testing with Rik's maybe-fix?

I will give it a spin with bonnie++ today. We'll see what comes out.

								Honza

> 
> 
> 
> From: Rik van Riel <riel@surriel.com>
> Subject: mm, slab, vmscan: accumulate gradual pressure on small slabs
> 
> There are a few issues with the way the number of slab objects to scan is
> calculated in do_shrink_slab.  First, for zero-seek slabs, we could leave
> the last object around forever.  That could result in pinning a dying
> cgroup into memory, instead of reclaiming it.  The fix for that is
> trivial.
> 
> Secondly, small slabs receive much more pressure, relative to their size,
> than larger slabs, due to "rounding up" the minimum number of scanned
> objects to batch_size.
> 
> We can keep the pressure on all slabs equal relative to their size by
> accumulating the scan pressure on small slabs over time, resulting in
> sometimes scanning an object, instead of always scanning several.
> 
> This results in lower system CPU use, and a lower major fault rate, as
> actively used entries from smaller caches get reclaimed less aggressively,
> and need to be reloaded/recreated less often.
> 
> [akpm@linux-foundation.org: whitespace fixes, per Roman]
> [riel@surriel.com: couple of fixes]
>   Link: http://lkml.kernel.org/r/20190129142831.6a373403@imladris.surriel.com
> Link: http://lkml.kernel.org/r/20190128143535.7767c397@imladris.surriel.com
> Fixes: 4b85afbdacd2 ("mm: zero-seek shrinkers")
> Fixes: 172b06c32b94 ("mm: slowly shrink slabs with a relatively small number of objects")
> Signed-off-by: Rik van Riel <riel@surriel.com>
> Tested-by: Chris Mason <clm@fb.com>
> Acked-by: Roman Gushchin <guro@fb.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Jonathan Lemon <bsd@fb.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: <stable@vger.kernel.org>
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
> 
> --- a/include/linux/shrinker.h~mmslabvmscan-accumulate-gradual-pressure-on-small-slabs
> +++ a/include/linux/shrinker.h
> @@ -65,6 +65,7 @@ struct shrinker {
>  
>  	long batch;	/* reclaim batch size, 0 = default */
>  	int seeks;	/* seeks to recreate an obj */
> +	int small_scan;	/* accumulate pressure on slabs with few objects */
>  	unsigned flags;
>  
>  	/* These are for internal use */
> --- a/mm/vmscan.c~mmslabvmscan-accumulate-gradual-pressure-on-small-slabs
> +++ a/mm/vmscan.c
> @@ -488,18 +488,30 @@ static unsigned long do_shrink_slab(stru
>  		 * them aggressively under memory pressure to keep
>  		 * them from causing refetches in the IO caches.
>  		 */
> -		delta = freeable / 2;
> +		delta = (freeable + 1) / 2;
>  	}
>  
>  	/*
>  	 * Make sure we apply some minimal pressure on default priority
> -	 * even on small cgroups. Stale objects are not only consuming memory
> +	 * even on small cgroups, by accumulating pressure across multiple
> +	 * slab shrinker runs. Stale objects are not only consuming memory
>  	 * by themselves, but can also hold a reference to a dying cgroup,
>  	 * preventing it from being reclaimed. A dying cgroup with all
>  	 * corresponding structures like per-cpu stats and kmem caches
>  	 * can be really big, so it may lead to a significant waste of memory.
>  	 */
> -	delta = max_t(unsigned long long, delta, min(freeable, batch_size));
> +	if (!delta && shrinker->seeks) {
> +		unsigned long nr_considered;
> +
> +		shrinker->small_scan += freeable;
> +		nr_considered = shrinker->small_scan >> priority;
> +
> +		delta = 4 * nr_considered;
> +		do_div(delta, shrinker->seeks);
> +
> +		if (delta)
> +			shrinker->small_scan -= nr_considered << priority;
> +	}
>  
>  	total_scan += delta;
>  	if (total_scan < 0) {
> _
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

