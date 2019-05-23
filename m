Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14D05C46470
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:00:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE673217D7
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:00:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Miz1U9o2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE673217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C4D36B027D; Thu, 23 May 2019 15:00:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 575526B0282; Thu, 23 May 2019 15:00:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 464186B0286; Thu, 23 May 2019 15:00:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF4D6B027D
	for <linux-mm@kvack.org>; Thu, 23 May 2019 15:00:36 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 23so1079363pgq.21
        for <linux-mm@kvack.org>; Thu, 23 May 2019 12:00:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/CV1FhBU6ocaD5fOePWATFvyxYduYyIfBpfvSQwN/B8=;
        b=SjM8wVtwZQ1OOj05kQuii6x/qVVoH9x/MNW7NKOwV1sOLmexFUo1kHpphutOMjoHBG
         KD+ZspafdH4ItNLlV2EIaozuPHxfKZ9C5viFagMW4mnOXq8tNiitH/SpQwjiwQe7SfWn
         nf48Emb23miVvmGKUssb/O70Z0VaS25I1CObQVC5lMEiT2jP8Pj1mFVhFMUGelHnBvo/
         FL3jPdh9JtLQloubPAhZKowVqyIMl1zVRDknIQ92Ssb6d1dI4jt4U+kvCzdfiSs/5Nsz
         dUS6kInaXrlyMy0e9gNmLvwZfiWMeKzO+59cwZ+Qnz7s5i65jLrb5+WJl+P3WqFeICNg
         HpkQ==
X-Gm-Message-State: APjAAAW+YabSkuleeTPEXr8BWRBRTAh3B4U2bbVEkq7j1eJluunXaGEI
	xUnOWBYUyDH/Da8YVp25v71v78zcx0aYTwXxJcf48bLN2wNNf5UNq5w1HAccVrewC/ZDEd1mqcZ
	DOpMZ+D3S/1qPDBiwebqTlWG+STNkYqDAhf08f9kM/HS+ibi2Qy9dpHT5W31IcWPOdw==
X-Received: by 2002:a62:2506:: with SMTP id l6mr105374964pfl.250.1558638035652;
        Thu, 23 May 2019 12:00:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTRYE336388Og+qbzW0dL4M3PrYEaKqnOEEAjldj7xlVu2Ey2oBaPOZqqkY1FWsiIXdqLs
X-Received: by 2002:a62:2506:: with SMTP id l6mr105374845pfl.250.1558638034787;
        Thu, 23 May 2019 12:00:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558638034; cv=none;
        d=google.com; s=arc-20160816;
        b=jZWmW+tnyS/WRW6uXpFOGjKC8Sm+XKLIp5+S3i6KSCO2KE6VTpbilN2vHO1FJR/3ds
         IqxRaOHazhwf9XvlGSgfgLyF4VFnDCeVt2q5/6EWnnuz40R4LzpdIEJp695pjgJYzm35
         wYdMgC/6y5Wxj6raqTphlA/l3Js+h+i3zTPVjK1e5j7REpB4EQ2DlCrk/dI69T/gv8v2
         85eE5GMrjjxD5tfIXDvpuY0Obi+Q4mm2Sd5KCAQfWB78Gb/zvVSVgfp21fXWoZsi6Axg
         dphL1CNGP8Ov/wVHSIi/1qT/SyoiO1gYtMbzSR+Iahw+Y86fB9HLUVUBakbRpp2KS9U3
         nwxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/CV1FhBU6ocaD5fOePWATFvyxYduYyIfBpfvSQwN/B8=;
        b=I8jTnjkCA9nAGoR8mUPmFpTFNg1AHtsq9oOlSNt+l3+WjkG2iowuRNkWVH3kCzAano
         8exnFSogLA10OZo053mD8yRE2xlfYdpvj89oXPFI1GDosr00c+H9TU/PtuYYcXiA+RQQ
         s3dBqY0Hm3HEpVHQ0MuSldIeaQ4dlVnigPpV9CbE0aomktFtDS+u7xU7Y0AH5kuYRnZ2
         29YV8Xb5fDK4WfAxI0XacWIbba4U4RT6iLcvCPTlQH5/feUqeLCYUzS/65/f/R+pp+4s
         BQUaLIN2aL+u73SkHs8HSvXqCjdV/mzh+aE2JmFQDQXssDKUkO+wpF3h7veFIDNDE9aq
         TtIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Miz1U9o2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o4si503112pgg.49.2019.05.23.12.00.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 12:00:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Miz1U9o2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/CV1FhBU6ocaD5fOePWATFvyxYduYyIfBpfvSQwN/B8=; b=Miz1U9o2wXcym4Jtn1wzy+VUn
	4BJDF2kiponhBBRN/KFC/M/0I/Qr5ov6lMO9Mf5Zm7DnA/drcPmOna2euyKCsqRj/bZL9uIvcPKhY
	xRqkO46Ak525MvJjJSV98ayqh2zv2tkbQvjt+Oz8ptIzGb2UICnoz/YNjZPrKZFdhOqkwlo9hz5Ag
	V7bHvynIZUjN91dxR3oaRTqX6JHTfWbptGKyB5J28TfrS/yCOgTXrBmitaAhzM+KrELPYl1vC+100
	i4YZjccf377zAwdOuTpxCZufHXIPfo9aPCLr53mVS5BW7O7U0YOVAu4c0RyKUDxyyRjrF3347VNLB
	ImPknIcRg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hTsx7-0004yj-2H; Thu, 23 May 2019 19:00:33 +0000
Date: Thu, 23 May 2019 12:00:32 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
Subject: Re: xarray breaks thrashing detection and cgroup isolation
Message-ID: <20190523190032.GA7873@bombadil.infradead.org>
References: <20190523174349.GA10939@cmpxchg.org>
 <20190523183713.GA14517@bombadil.infradead.org>
 <CALvZod4o0sA8CM961ZCCp-Vv+i6awFY0U07oJfXFDiVfFiaZfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod4o0sA8CM961ZCCp-Vv+i6awFY0U07oJfXFDiVfFiaZfg@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 11:49:41AM -0700, Shakeel Butt wrote:
> On Thu, May 23, 2019 at 11:37 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Thu, May 23, 2019 at 01:43:49PM -0400, Johannes Weiner wrote:
> > > I noticed that recent upstream kernels don't account the xarray nodes
> > > of the page cache to the allocating cgroup, like we used to do for the
> > > radix tree nodes.
> > >
> > > This results in broken isolation for cgrouped apps, allowing them to
> > > escape their containment and harm other cgroups and the system with an
> > > excessive build-up of nonresident information.
> > >
> > > It also breaks thrashing/refault detection because the page cache
> > > lives in a different domain than the xarray nodes, and so the shadow
> > > shrinker can reclaim nonresident information way too early when there
> > > isn't much cache in the root cgroup.
> > >
> > > I'm not quite sure how to fix this, since the xarray code doesn't seem
> > > to have per-tree gfp flags anymore like the radix tree did. We cannot
> > > add SLAB_ACCOUNT to the radix_tree_node_cachep slab cache. And the
> > > xarray api doesn't seem to really support gfp flags, either (xas_nomem
> > > does, but the optimistic internal allocations have fixed gfp flags).
> >
> > Would it be a problem to always add __GFP_ACCOUNT to the fixed flags?
> > I don't really understand cgroups.
> 
> Does xarray cache allocated nodes, something like radix tree's:
> 
> static DEFINE_PER_CPU(struct radix_tree_preload, radix_tree_preloads) = { 0, };
> 
> For the cached one, no __GFP_ACCOUNT flag.

No.  That was the point of the XArray conversion; no cached nodes.

> Also some users of xarray may not want __GFP_ACCOUNT. That's the
> reason we had __GFP_ACCOUNT for page cache instead of hard coding it
> in radix tree.

This is what I don't understand -- why would someone not want
__GFP_ACCOUNT?  For a shared resource?  But the page cache is a shared
resource.  So what is a good example of a time when an allocation should
_not_ be accounted to the cgroup?

