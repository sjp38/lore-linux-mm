Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ABD4C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 16:16:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 545BF218A3
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 16:16:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 545BF218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF12D6B000D; Fri, 29 Mar 2019 12:16:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC7046B000E; Fri, 29 Mar 2019 12:16:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB7E96B0010; Fri, 29 Mar 2019 12:16:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2366B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 12:16:45 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p5so1345168edh.2
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 09:16:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4mkhAVDAmSxhV6NHsQwW4naxzznaTX9qMP1ZYOoyAps=;
        b=KYlX7nXQCWq3oOVt+RSHMWBeSFHN4zRygjxctxEQ2wMVar8NwkdHF4hiC3zoh7rlCF
         wB+vbaCOXwPPx+MyOBhTGa9uhU2xovaGrmFwdBGaQ69H3Pye45LVaIyBMITddfYhWimc
         gCYzT8PrWnj4gFEhMVegphcCWePTFqbnK0AVZ7MK1JBZ2tsyamkUQWdT6Nzm54WtksBz
         QvqfEfyomLcNxHvWpscmttZ2vwfqAkImMo2RuEN9bMaICKiyTW8zG3/80ubdMZj/Btpa
         +tHBSGNRvR01NQLitbsvxU2vkPT08PV4quC9NzZePNVCisWo+0SrBqZ7F9lq0K7k09al
         GeDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXGN4IoKoAz4ngDhbFyk5ArapRTNhu14Lv5Uft0edUm1dA5hOHW
	9hr3FIBR3A2sRJ9eU3fHhs/kQPtE+FaXUsZJ99i8m7wJHaPvpKb8MJZ734UJN7L0rOjly0ovB4b
	mWAR5/6edNqLWXNQ9+tmYS4KLnI9cK1DBd3gJ+BVequguGOZ+vx5HXKoClvySQ2l1Xw==
X-Received: by 2002:a50:a7a6:: with SMTP id i35mr32856446edc.96.1553876204947;
        Fri, 29 Mar 2019 09:16:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBzpodL3REfFqm9koS1WWTUYYhOPkSFEckVNUpBIHszfMIuf6pYdyiywyvuAUwkNCYCMsD
X-Received: by 2002:a50:a7a6:: with SMTP id i35mr32856388edc.96.1553876203909;
        Fri, 29 Mar 2019 09:16:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553876203; cv=none;
        d=google.com; s=arc-20160816;
        b=qGDLu/Qa53Bvi0/4h+4TprHgYv4hU2GybdA2apyi/hp2iGCeeCN4GySg51NZQHcJXD
         3EgvZTxSMXWVbSFlIWY6332B9tyedPDjNaS2/ZU16t3+FmuMcySlwJh4ii074CVCllsT
         dY4wdxLjZlPhQI02h+FHxBgB0lu7LchlIrfJINPa9mLndTWwz2ojigbJjW2r1uIEHWz+
         WXhhzJDNSXQCRlg/3jdKpbA5FZTm8zWw76gEVED1E7wNO79wqWOCwYAg7nyolmyrpow7
         Y+t2Mk2p77Vm9wIPWN84wNMb9399JRAq6hGKQSKuJNsQZaIrrsyiWRBk1Cs4phWDSEHj
         Z3+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4mkhAVDAmSxhV6NHsQwW4naxzznaTX9qMP1ZYOoyAps=;
        b=EBUNgmlFO65AJx8Mjt/blRcz0jnBRuSXi4lWKSp7HBOoMqnzX7odxVKZtm69LZtLag
         mcsia2RGs4EZRh4bZER9rt1a0IxkKoM37ocMnDxw0+R4Jp+299kpFe+Dfdnqqq79a1WF
         3RDHG3gH04POOW/0+54bPe8R46fLr5hEUtVqJZ6k0dRBhutZKjUF+wpDeTv9IRfbNBLx
         qaQxzTkzX6SzYeE5rwdIDF710VsNYTPXpPapyAV2rfE4pZr8fmmvaGGzVUT+HunWNTR0
         UItQ+5VNcg7OJZvLr1/MKbq/RSFR+hqsdFgNe1Yws/YUAijjAnddhbQY8JYKm5bVaaEQ
         oRpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e1si976414ejl.292.2019.03.29.09.16.43
        for <linux-mm@kvack.org>;
        Fri, 29 Mar 2019 09:16:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CA87980D;
	Fri, 29 Mar 2019 09:16:42 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D92FC3F68F;
	Fri, 29 Mar 2019 09:16:40 -0700 (PDT)
Date: Fri, 29 Mar 2019 16:16:38 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>,
	akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org,
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
Message-ID: <20190329161637.GC48010@arrakis.emea.arm.com>
References: <20190327005948.24263-1-cai@lca.pw>
 <20190327084432.GA11927@dhcp22.suse.cz>
 <20190327172955.GB17247@arrakis.emea.arm.com>
 <20190327182158.GS10344@bombadil.infradead.org>
 <20190328145917.GC10283@arrakis.emea.arm.com>
 <20190329120237.GB17624@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329120237.GB17624@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 01:02:37PM +0100, Michal Hocko wrote:
> On Thu 28-03-19 14:59:17, Catalin Marinas wrote:
> [...]
> > >From 09eba8f0235eb16409931e6aad77a45a12bedc82 Mon Sep 17 00:00:00 2001
> > From: Catalin Marinas <catalin.marinas@arm.com>
> > Date: Thu, 28 Mar 2019 13:26:07 +0000
> > Subject: [PATCH] mm: kmemleak: Use mempool allocations for kmemleak objects
> > 
> > This patch adds mempool allocations for struct kmemleak_object and
> > kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
> > under memory pressure. The patch also masks out all the gfp flags passed
> > to kmemleak other than GFP_KERNEL|GFP_ATOMIC.
> 
> Using mempool allocator is better than inventing its own implementation
> but there is one thing to be slightly careful/worried about.
> 
> This allocator expects that somebody will refill the pool in a finit
> time. Most users are OK with that because objects in flight are going
> to return in the pool in a relatively short time (think of an IO) but
> kmemleak is not guaranteed to comply with that AFAIU. Sure ephemeral
> allocations are happening all the time so there should be some churn
> in the pool all the time but if we go to an extreme where there is a
> serious memory leak then I suspect we might get stuck here without any
> way forward. Page/slab allocator would eventually back off even though
> small allocations never fail because a user context would get killed
> sooner or later but there is no fatal_signal_pending backoff in the
> mempool alloc path.

We could improve the mempool code slightly to refill itself (from some
workqueue or during a mempool_alloc() which allows blocking) but it's
really just a best effort for a debug tool under OOM conditions. It may
be sufficient just to make the mempool size tunable (via
/sys/kernel/debug/kmemleak).

> Anyway, I believe this is a step in the right direction and should the
> above ever materializes as a relevant problem we can tune the mempool
> to backoff for _some_ callers or do something similar.
> 
> Btw. there is kmemleak_update_trace call in mempool_alloc, is this ok
> for the kmemleak allocation path?

It's not a problem, maybe only a small overhead in searching an rbtree
in kmemleak but it cannot find anything since the kmemleak metadata is
not tracked. And this only happens if a normal allocation fails and
takes an existing object from the pool.

I thought about passing the mempool back into kmemleak and checking
whether it's one of the two pools it uses but concluded that it's not
worth it.

-- 
Catalin

