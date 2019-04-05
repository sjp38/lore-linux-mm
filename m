Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49765C282DA
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 19:34:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDDCC2146F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 19:34:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="HfgWPH4l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDDCC2146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2094A6B0007; Fri,  5 Apr 2019 15:34:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 191806B0008; Fri,  5 Apr 2019 15:34:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0328B6B000C; Fri,  5 Apr 2019 15:34:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id D03116B0007
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 15:34:43 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id j8so5242606ybh.0
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 12:34:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1sjVKmuXhVLeJPdr6cYXHsdrlxlSdoGqHJzj+qjCJSs=;
        b=PnCdKmsJZaZF4vLGaV6SQYiO33YrCyjRvklG/KhfDq5hDL3/VmW5bTbwWMk+jJvtp5
         +UdtEjpvvASdigLbXkIWs0GYZzJoMu8redGmlYgqfauLf8LN5nsPSibAzDvHCZBrTVBI
         jw1VHveZTj+yi1oBBDjZCK8VUKsdR/xsI0EcYcw1Wt4wzSxKioM+34Jv26X3UxYYV73u
         0X3OoGkqDQ7Lu4bAgrfLamnEOWRhsEXyd2j1aPxIym4KcX3CWQk4KQ/c79xl37GZORE4
         GxfJHnkvJywLnAgVPL2rW6/ILD4Lv1FKttm4ixqtzIuUxCsX7pt7X8S7bvhzGVhaj11c
         gj8w==
X-Gm-Message-State: APjAAAX58lePWg6ksbHmPieoetj3ZxOh5TeaXrh/YhVd4+rme/1dsdua
	4iOVxSCZoIN7z65KUPL/GX6eO4xCAABqgJWNHND19/pwJ8BWINm+thR4OXtyjHDmokLT2qlZIAU
	syje1uFwrFUGB2qyj3GRSM+uQsYTs2SeUhVImzT8NSRF4KiI5QAgnMOghLe/MlNBLvA==
X-Received: by 2002:a25:5984:: with SMTP id n126mr13085932ybb.131.1554492883481;
        Fri, 05 Apr 2019 12:34:43 -0700 (PDT)
X-Received: by 2002:a25:5984:: with SMTP id n126mr13085861ybb.131.1554492882523;
        Fri, 05 Apr 2019 12:34:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554492882; cv=none;
        d=google.com; s=arc-20160816;
        b=Y6MGUqNnW3KKDWcREbcWAwXBM5nVEzQF1uExlFHDRDi0pG9aGscEE1IGyMJUFn+SXE
         /cGuQr9vz2qn8niRh4VNVx4v28dC22iKnVGBXScq1fuFkT5JajJXC7D1zgvSNENuysT/
         7wrw7pYBYRJDz8oJzGKb7RhEoz/alAVImNLbcXF6wK/IGyy/s9I1sC6885bI1HSevi3h
         TQ3OmIIo6tHGMg3RCSGy4hfWWuWV5/VLyfW5IZL5v8lbyDvOfyhCUtmdBlvVDZSjFWiX
         E9sUi8sPHeb6uTkJ/pgdY2itBsKXVp+FNAiFYHqf5GXJynvpRshXahvvmWzEiydHeJg9
         unuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1sjVKmuXhVLeJPdr6cYXHsdrlxlSdoGqHJzj+qjCJSs=;
        b=DK63WvRa1OSWqqabSzfKA9ct0NPoolYOY0+naA2eyQiFuhq/tUBRAOmquN5x7zpTGd
         pxATeKqXhZpqTGEKu+gA8Lp+R04VrXN6Nc7smXBM5lO7BcIaLLsyhww5QR7LZxmGXSkE
         RkAtyQKi8mPiHemhoXAPTuGF9HkeY+00rWVvt/wzxZmJBKSehca2E0mqVozU7ArbkrzU
         WHH8mOHB68qu5BZfuF81ukAkhDVl/hELUkcDOw+m6FzYEf+EYkibS+0l4QzhFoLSW1Xn
         EhFpyUmMFgQjj9lCD5aY1gHiRNVoNFp6LyDWfjTyVrNjkAqApKW1mb2G3KerVPXhmEyq
         +6vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=HfgWPH4l;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a5sor7849855ywb.91.2019.04.05.12.34.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 12:34:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=HfgWPH4l;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1sjVKmuXhVLeJPdr6cYXHsdrlxlSdoGqHJzj+qjCJSs=;
        b=HfgWPH4lmgDv9Qm0wYYM0YSX7p/5J223RCotchxn0ig0HNWwDhe/bfWVmalb193d+I
         lrSYGHixHykp4b+WeCxeycJ/svB6kvxsN+UXOJi1C5bs2uEaNAG3AOfiWt2wgqQERAr0
         1SohWesg5Fv8XldsD5eXKqmrmm3KYjF11BAyd198U2aTSiRg4Lw8/OB99zOrnjTxR8G6
         drwgt3ljZjnPYahC1LoK+Si0axTfGOM53Td8UQoso65gA0S3MTUWEjHiVcMxxsjE59lT
         sUN7s7ubUd0p3Dr/LhZyQ3obCwowCTyhqiBTubree0nTzEcUGCiD4jMql98aqVcjv+kW
         2C+Q==
X-Google-Smtp-Source: APXvYqxk+cL+z20oWBBFdNBy37Mukg0IUnBl8tYoZHrHcuTh6/tRYi4d+gW2Ki0eiXpsR6xBfKjr5A==
X-Received: by 2002:a81:91d7:: with SMTP id i206mr12039871ywg.87.1554492877686;
        Fri, 05 Apr 2019 12:34:37 -0700 (PDT)
Received: from localhost ([2620:10d:c091:180::777e])
        by smtp.gmail.com with ESMTPSA id 23sm7668952ywq.91.2019.04.05.12.34.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 05 Apr 2019 12:34:36 -0700 (PDT)
Date: Fri, 5 Apr 2019 15:34:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm:workingset use real time to judge activity of the
 file page
Message-ID: <20190405193435.GA16947@cmpxchg.org>
References: <1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com>
 <20190404163914.GA4229@cmpxchg.org>
 <CAGWkznHeGeiHWSF-gPmSW=AWQcEybHroOuP4CSbW4rKq12LtNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGWkznHeGeiHWSF-gPmSW=AWQcEybHroOuP4CSbW4rKq12LtNw@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 05, 2019 at 07:23:46AM +0800, Zhaoyang Huang wrote:
> On Fri, Apr 5, 2019 at 12:39 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
> >
> > On Thu, Apr 04, 2019 at 11:30:17AM +0800, Zhaoyang Huang wrote:
> > > From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> > >
> > > In previous implementation, the number of refault pages is used
> > > for judging the refault period of each page, which is not precised as
> > > eviction of other files will be affect a lot on current cache.
> > > We introduce the timestamp into the workingset's entry and refault ratio
> > > to measure the file page's activity. It helps to decrease the affection
> > > of other files(average refault ratio can reflect the view of whole system
> > > 's memory).
> >
> > I don't understand what exactly you're saying here, can you please
> > elaborate?
> >
> > The reason it's using distances instead of absolute time is because
> > the ordering of the LRU is relative and not based on absolute time.
> >
> > E.g. if a page is accessed every 500ms, it depends on all other pages
> > to determine whether this page is at the head or the tail of the LRU.
> >
> > So when you refault, in order to determine the relative position of
> > the refaulted page in the LRU, you have to compare it to how fast that
> > LRU is moving. The absolute refault time, or the average time between
> > refaults, is not comparable to what's already in memory.
> How do you know how long time did these pages' dropping taken.Actruly,
> a quick dropping of large mount of pages will be wrongly deemed as
> slow dropping instead of the exact hard situation.That is to say, 100
> pages per million second or per second have same impaction on
> calculating the refault distance, which may cause less protection on
> this page cache for former scenario and introduce page thrashing.
> especially when global reclaim, a round of kswapd reclaiming that
> waked up by a high order allocation or large number of single page
> allocations may cause such things as all pages within the node are
> counted in the same lru. This commit can decreasing above things by
> comparing refault time of single page with avg_refault_time =
> delta_lru_reclaimed_pages/ avg_refault_retio (refault_ratio =
> lru->inactive_ages / time).

When something like a higher-order allocation drops a large number of
file pages, it's *intentional* that the pages that were evicted before
them become less valuable and less likely to be activated on
refault. There is a finite amount of in-memory LRU space and the pages
that have been evicted the most recently have precedence because they
have the highest proven access frequency.

Of course, when a large amount of the cache that was pushed out in
between is not re-used again, and don't claim their space in memory,
it would be great if we could then activate the older pages that *are*
re-used again in their stead.

But that would require us being able to look into the future. When an
old page refaults, we don't know if a younger page is still going to
refault with a shorter refault distance or not. If it won't, then we
were right to activate it. If it will refault, then we put something
on the active list whose reuse frequency is too low to be able to fit
into memory, and we thrash the hottest pages in the system.

As Matthew says, you are fairly randomly making refault activations
more aggressive (especially with that timestamp unpacking bug), and
while that expectedly boosts workload transition / startup, it comes
at the cost of disrupting stable states because you can flood a very
active in-ram workingset with completely cold cache pages simply
because they refault uniformly wrt each other.

