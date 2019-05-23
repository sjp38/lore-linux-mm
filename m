Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD766C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:59:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97DA820881
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:59:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="pryOJBhy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97DA820881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A22F6B02AE; Thu, 23 May 2019 15:59:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12CF46B02B0; Thu, 23 May 2019 15:59:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE8586B02B1; Thu, 23 May 2019 15:59:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B1A136B02AE
	for <linux-mm@kvack.org>; Thu, 23 May 2019 15:59:37 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b69so4166727plb.9
        for <linux-mm@kvack.org>; Thu, 23 May 2019 12:59:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QSvXlqZh92CDrRCYBDGQx4eYSubpSF2EcFX3zDPt80M=;
        b=HudDg1piiGxgQZMXUAjHuqVLyyz7au9B888S41TrqFG0WrShT5fezY0XhxG801gHmN
         /U/Z5Iy73wUf1bcpOGHypc3OZfZ/Wp0VbZ7vmREbZDJ3RMmaY7Ww2vKV0mZI3Px/wLqd
         14FAIVN68oP2UVkHcIcT9c7kLdY4gFofZNaaI9hpyKocs0e7RJJ7DMYcIiBQlO7/7G2M
         f15lludTNECEsV2wVh7xRKZEEjJa1Y6Wxwu9E3KfNfjoM1tjTMbz65d+UtN2u9HrxSIW
         zPf3R9mqmjpFMNkCaGF68Wjq1BtaeCHd16DPCp/Gow245GY56HSFSkGHDlEVNx7KjEKu
         CY6g==
X-Gm-Message-State: APjAAAXLI/LmH8Hr/Vv4bcxtHPCuZQPCNwQsuKopgDgFoYk/iNdPDznX
	zar6nEkjW5J9UU4oXpJODJVA0euI92lQra1ialwuvjUtbn7fXDFaGVu+imbCwPJqV7FWAOorPAl
	xlZl+2XZjOGu5kmpcVcDbDGxzVH6wIcI3GrbkMQ5QFsTeC8CKtDXYdl4TfSspAJfMgQ==
X-Received: by 2002:a63:1e5b:: with SMTP id p27mr99694699pgm.213.1558641577265;
        Thu, 23 May 2019 12:59:37 -0700 (PDT)
X-Received: by 2002:a63:1e5b:: with SMTP id p27mr99694598pgm.213.1558641576179;
        Thu, 23 May 2019 12:59:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558641576; cv=none;
        d=google.com; s=arc-20160816;
        b=cccG1WVYKQ/X6jzxljXhKJHxKcOa5+0B6Ep5bGlJTM0HaBWKMRLczlgqe5o/o6nYMv
         r8Vzra7TPt4+6UYMi+lm7RVUeWkNxjOSFfuApy1p7GxZXvcq77JQRaFBnWkyxb7RLJOr
         GVOSW2EQOaagd4xeswBy0rT8foj+unAASha3mX6eR1b5XSCYVzqI7At12qh7YH7ml1qE
         n07xJf4IAuZs+wkRRNou1arYBTTKMMCehMTx9W9hKSF5yobz0r5cTZcwcvCo9o8mYiXt
         hp+dSgTjWfhJRjf1SxeBMeGxU5vFVY9GKt+Gc9vFcuVlT+wrroyL0ej/cLMxWJsjGO7k
         csTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QSvXlqZh92CDrRCYBDGQx4eYSubpSF2EcFX3zDPt80M=;
        b=vRjBP3teCxtWOYd+HkbJRLUt1yXKy9f+2gUjhXo4VuLJIAWlnXArqOHE9OW/fC0K22
         hns5LqHcRXdUeEiGQusLTNaeEtjVEIsUSNUD5tukyQiXllXbPPxe5oTzJrE/IGMDPMDl
         dDNpBTpruvAF1dy7uOUL/9LFl7M7GVDV5/f274Xtbd5rAO8QlA6+qoz9EOHmSIqx7jhq
         1k/09ncvR3vWm0oaDGKTqT1ig4Gfr9MAvxiLczisJu6UmcNjT5ecrMr317iHAPQAicvv
         KkQNRyliLnMQSuXuc/4o5hLcxz1OLABrmjzvn1/7PlCC4NbRsxCo/HYE9HLomkUgfqaZ
         D0JA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=pryOJBhy;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t97sor247013pjb.0.2019.05.23.12.59.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 12:59:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=pryOJBhy;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QSvXlqZh92CDrRCYBDGQx4eYSubpSF2EcFX3zDPt80M=;
        b=pryOJBhyiO7VVwM16n1AKnkekdqfQoNbkE8NZkY8PJq5vw+4UsAvzQdtHQdwJq3EE9
         10TBJcHMjcAABWwN7zkuAe9PMoZJ5y1QDgyK2OSO8mZUeaSkr4W9a8GSwfeoTKbO6PGe
         O5/TpXqS4HdhgD6kTBfj9Fg40LnkDQF2hPsRN/uVaxFgSwSEv9ad4uJTmQgxT4KWXHxn
         UVYru/3Yh1e2bZDk2vLnVUixYqqq0oGOiuiLgSGdxEImjH2Yx57mfmQ/zfZVgrZvCxXA
         yOpN9Ki2QEzd51yxnisPMvCkL3AHQ47kRLVcURAAOyGrYW7AJL+2r0eQkhzqJDZR/zj5
         vioA==
X-Google-Smtp-Source: APXvYqxFNkJsMbFheL6ancg7wuEV7qoqvVC2Mn2u/kKsu0xAMk+ClLVXVY6G3K63f6CxnzjRFJx4Dw==
X-Received: by 2002:a17:90a:7f02:: with SMTP id k2mr3830549pjl.78.1558641575274;
        Thu, 23 May 2019 12:59:35 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::4958])
        by smtp.gmail.com with ESMTPSA id h32sm164706pgi.55.2019.05.23.12.59.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 12:59:34 -0700 (PDT)
Date: Thu, 23 May 2019 15:59:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Shakeel Butt <shakeelb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
Subject: Re: xarray breaks thrashing detection and cgroup isolation
Message-ID: <20190523195933.GA6404@cmpxchg.org>
References: <20190523174349.GA10939@cmpxchg.org>
 <20190523183713.GA14517@bombadil.infradead.org>
 <CALvZod4o0sA8CM961ZCCp-Vv+i6awFY0U07oJfXFDiVfFiaZfg@mail.gmail.com>
 <20190523190032.GA7873@bombadil.infradead.org>
 <20190523192117.GA5723@cmpxchg.org>
 <20190523194130.GA4598@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523194130.GA4598@bombadil.infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 12:41:30PM -0700, Matthew Wilcox wrote:
> On Thu, May 23, 2019 at 03:21:17PM -0400, Johannes Weiner wrote:
> > On Thu, May 23, 2019 at 12:00:32PM -0700, Matthew Wilcox wrote:
> > > On Thu, May 23, 2019 at 11:49:41AM -0700, Shakeel Butt wrote:
> > > > On Thu, May 23, 2019 at 11:37 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > > > On Thu, May 23, 2019 at 01:43:49PM -0400, Johannes Weiner wrote:
> > > > > > I noticed that recent upstream kernels don't account the xarray nodes
> > > > > > of the page cache to the allocating cgroup, like we used to do for the
> > > > > > radix tree nodes.
> > > > > >
> > > > > > This results in broken isolation for cgrouped apps, allowing them to
> > > > > > escape their containment and harm other cgroups and the system with an
> > > > > > excessive build-up of nonresident information.
> > > > > >
> > > > > > It also breaks thrashing/refault detection because the page cache
> > > > > > lives in a different domain than the xarray nodes, and so the shadow
> > > > > > shrinker can reclaim nonresident information way too early when there
> > > > > > isn't much cache in the root cgroup.
> > > > > >
> > > > > > I'm not quite sure how to fix this, since the xarray code doesn't seem
> > > > > > to have per-tree gfp flags anymore like the radix tree did. We cannot
> > > > > > add SLAB_ACCOUNT to the radix_tree_node_cachep slab cache. And the
> > > > > > xarray api doesn't seem to really support gfp flags, either (xas_nomem
> > > > > > does, but the optimistic internal allocations have fixed gfp flags).
> > > > >
> > > > > Would it be a problem to always add __GFP_ACCOUNT to the fixed flags?
> > > > > I don't really understand cgroups.
> > > 
> > > > Also some users of xarray may not want __GFP_ACCOUNT. That's the
> > > > reason we had __GFP_ACCOUNT for page cache instead of hard coding it
> > > > in radix tree.
> > > 
> > > This is what I don't understand -- why would someone not want
> > > __GFP_ACCOUNT?  For a shared resource?  But the page cache is a shared
> > > resource.  So what is a good example of a time when an allocation should
> > > _not_ be accounted to the cgroup?
> > 
> > We used to cgroup-account every slab charge to cgroups per default,
> > until we changed it to a whitelist behavior:
> > 
> > commit b2a209ffa605994cbe3c259c8584ba1576d3310c
> > Author: Vladimir Davydov <vdavydov@virtuozzo.com>
> > Date:   Thu Jan 14 15:18:05 2016 -0800
> > 
> >     Revert "kernfs: do not account ino_ida allocations to memcg"
> >     
> >     Currently, all kmem allocations (namely every kmem_cache_alloc, kmalloc,
> >     alloc_kmem_pages call) are accounted to memory cgroup automatically.
> >     Callers have to explicitly opt out if they don't want/need accounting
> >     for some reason.  Such a design decision leads to several problems:
> >     
> >      - kmalloc users are highly sensitive to failures, many of them
> >        implicitly rely on the fact that kmalloc never fails, while memcg
> >        makes failures quite plausible.
> 
> Doesn't apply here.  The allocation under spinlock is expected to fail,
> and then we'll use xas_nomem() with the caller's specified GFP flags
> which may or may not include __GFP_ACCOUNT.
> 
> >      - A lot of objects are shared among different containers by design.
> >        Accounting such objects to one of containers is just unfair.
> >        Moreover, it might lead to pinning a dead memcg along with its kmem
> >        caches, which aren't tiny, which might result in noticeable increase
> >        in memory consumption for no apparent reason in the long run.
> 
> These objects are in the slab of radix_tree_nodes, and we'll already be
> accounting page cache nodes to the cgroup, so accounting random XArray
> nodes to the cgroups isn't going to make the problem worse.

There is no single radix_tree_nodes cache. When cgroup accounting is
requested, we clone per-cgroup instances of the slab cache each with
their own object slabs. The reclaimable page cache / shadow nodes do
not share slab pages with other radix tree users.

> >      - There are tons of short-lived objects. Accounting them to memcg will
> >        only result in slight noise and won't change the overall picture, but
> >        we still have to pay accounting overhead.
> 
> XArray nodes are generally not short-lived objects.

I'm not exactly sure what you're trying to argue.

My point is that we cannot have random drivers' internal data
structures charge to and pin cgroups indefinitely just because they
happen to do the modprobing or otherwise interact with the driver.

It makes no sense in terms of performance or cgroup semantics.

