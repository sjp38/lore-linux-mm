Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7B63C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:41:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C2402168B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:41:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FtnxFgFC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C2402168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA8236B02AC; Thu, 23 May 2019 15:41:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E30DF6B02AE; Thu, 23 May 2019 15:41:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAB9E6B02AF; Thu, 23 May 2019 15:41:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90A176B02AC
	for <linux-mm@kvack.org>; Thu, 23 May 2019 15:41:36 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z2so4896668pfb.12
        for <linux-mm@kvack.org>; Thu, 23 May 2019 12:41:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Y4CF8VQ482x9+gF5CsOg/mXlQPERa3qs/eCs0oVRAJ8=;
        b=GVjsed6VHmWYDNT5ae0nm9+0RpjTwQ1vSmaNSdXP5U3likzzID/tN6+Q3LMknuRc21
         cP4kfssk846Hc3KYA6blLd6FNA1uFG42wy8ZOgIxp+o3Kqb4UcCCSAYhbrl224Lw0nN8
         jGywWgUqWEyavB3EAjxaHtFvpLO4xuNXqI+pPhr6rcl6enfT5KDDq80U7HjGSM1o3g2A
         76PEAJS2qjTMHndzBO/9nQQHeCOOj+AGAQBW/2jmJ5GKKQiabN5ny9RxnH8L1SO4DNUB
         5BLXHLW9n0bBx8diCyvncbnyGEYlpFM/TcuKIk0Enuk3ve4ZfA93Z96ISbmWNSKd2Znd
         uBgA==
X-Gm-Message-State: APjAAAXV4Y/z+0aVdQJj/oo8dtQgykGn0gwrH4SXdo9VGPVq4S3BskuL
	aoNwn3j4W8YsN226qB2OxMXBh5aU4pxkBhdvtn8Vp3gx9YbvbpA22e5VU+krioz6MaAjM2BfWTt
	4rLxBtGkvArtINshipnE/qgEbQvfSf8s51pkhsMmwczMKYaabMafZKUM9Rc+Gafn9ZA==
X-Received: by 2002:a17:90a:fa15:: with SMTP id cm21mr3711136pjb.122.1558640496194;
        Thu, 23 May 2019 12:41:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxllOlpRTw/1E2Q2nTRYLi3q9VOjfuxU6f3j+qnqgBDKrJc9K/usYZjha7+zKDK3IJ9Me4r
X-Received: by 2002:a17:90a:fa15:: with SMTP id cm21mr3711039pjb.122.1558640495402;
        Thu, 23 May 2019 12:41:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558640495; cv=none;
        d=google.com; s=arc-20160816;
        b=SbQwKRW8tE2QcECRs34LlEb4GN2X1dYH5rC1++R/UwrkrOeD1YLf/ZJo9fTtLEAOeW
         09a038GGpSthUNtbhUBcmZl7xTO6tsP2Roj1C0y0nqL75imC3CXHVZwewloF+RrS4cp5
         RHMNviG+816OODFDZWZiKGWchq4exMGiBXNB99oClW7nfPgWmkBZuZvvzGVMjdj0iXUH
         U6n2oD5LdLyYL6EFXAcUT8zhlwMy86gzH8mFi6t1fL0+yWHkxRDwk1drEzOcy4NqazxX
         yB+CFGZk0PAkIiwJQ10IPSkgNQcp1LWwpfgQU/RAkR8FX+LUFjWXFk/JlkDIfFjQ3dSU
         Jp0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Y4CF8VQ482x9+gF5CsOg/mXlQPERa3qs/eCs0oVRAJ8=;
        b=R7IBLQz1/IenhHyjX3Pj/UUGzOvSrdbkn4jDfiRnTGzFgQsYWTU3imgI9DYhyztTOH
         8f/+A03+umJ7GH4AtMaUEQ3dUQAQN0U6V+zz+zEa6BoxmtP+qzmJ1sMfMz2lxhg8LF3Z
         /dq5WGVvr3AYnKmS8Capj1VtUXdsYUYk6Flvz6CLUFXSqKVXy9jN2X8LnP8QJ2COQp9p
         bZrV+6QRLZZFGzP/GizxvM26d3bL5BYonkmbS2K4lBVPtgqnSrpVU1/yQCiy7Tvbyqzf
         ZwcBA8TMJyyovVaUojtdKjfHJqyy9ahqs8eA2lRDW8iX/12TjmRrQ3r6G5VPPEacb4Sj
         23eQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FtnxFgFC;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f7si606522plm.427.2019.05.23.12.41.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 12:41:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FtnxFgFC;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Y4CF8VQ482x9+gF5CsOg/mXlQPERa3qs/eCs0oVRAJ8=; b=FtnxFgFCfEdc3mEAZAw8IsXF4
	jQpoZBQ3b80gdnApy4UED7IQOONKMYS3liEa9vqS1CyVy5xj44NkYARQJZJzFhXCmbAN9cLJAJ608
	4GU5MnZJHC16lhg91q/FopB9whBsFo1JoMQ5lrKNF57bReSLM1haCrprcPTP9OeZtlZ37LsiQNprS
	bwFpdZ2W/fn+2lbz0zu+AO4SigjcCkqknzEFb0W/ZgQhQLl05fTV6EKHV4e154+YQOMRD5Cq56KQj
	Yj4UsROp60Rm9vYLIgIjw6l/ItZUFWDZyYwz4+ryzdVyOrM1ewvkWJoDv7Aiqlj+C4h5XpDfleN1E
	JsFu9hqfA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hTtak-000431-T7; Thu, 23 May 2019 19:41:30 +0000
Date: Thu, 23 May 2019 12:41:30 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shakeel Butt <shakeelb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
Subject: Re: xarray breaks thrashing detection and cgroup isolation
Message-ID: <20190523194130.GA4598@bombadil.infradead.org>
References: <20190523174349.GA10939@cmpxchg.org>
 <20190523183713.GA14517@bombadil.infradead.org>
 <CALvZod4o0sA8CM961ZCCp-Vv+i6awFY0U07oJfXFDiVfFiaZfg@mail.gmail.com>
 <20190523190032.GA7873@bombadil.infradead.org>
 <20190523192117.GA5723@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523192117.GA5723@cmpxchg.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 03:21:17PM -0400, Johannes Weiner wrote:
> On Thu, May 23, 2019 at 12:00:32PM -0700, Matthew Wilcox wrote:
> > On Thu, May 23, 2019 at 11:49:41AM -0700, Shakeel Butt wrote:
> > > On Thu, May 23, 2019 at 11:37 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > > On Thu, May 23, 2019 at 01:43:49PM -0400, Johannes Weiner wrote:
> > > > > I noticed that recent upstream kernels don't account the xarray nodes
> > > > > of the page cache to the allocating cgroup, like we used to do for the
> > > > > radix tree nodes.
> > > > >
> > > > > This results in broken isolation for cgrouped apps, allowing them to
> > > > > escape their containment and harm other cgroups and the system with an
> > > > > excessive build-up of nonresident information.
> > > > >
> > > > > It also breaks thrashing/refault detection because the page cache
> > > > > lives in a different domain than the xarray nodes, and so the shadow
> > > > > shrinker can reclaim nonresident information way too early when there
> > > > > isn't much cache in the root cgroup.
> > > > >
> > > > > I'm not quite sure how to fix this, since the xarray code doesn't seem
> > > > > to have per-tree gfp flags anymore like the radix tree did. We cannot
> > > > > add SLAB_ACCOUNT to the radix_tree_node_cachep slab cache. And the
> > > > > xarray api doesn't seem to really support gfp flags, either (xas_nomem
> > > > > does, but the optimistic internal allocations have fixed gfp flags).
> > > >
> > > > Would it be a problem to always add __GFP_ACCOUNT to the fixed flags?
> > > > I don't really understand cgroups.
> > 
> > > Also some users of xarray may not want __GFP_ACCOUNT. That's the
> > > reason we had __GFP_ACCOUNT for page cache instead of hard coding it
> > > in radix tree.
> > 
> > This is what I don't understand -- why would someone not want
> > __GFP_ACCOUNT?  For a shared resource?  But the page cache is a shared
> > resource.  So what is a good example of a time when an allocation should
> > _not_ be accounted to the cgroup?
> 
> We used to cgroup-account every slab charge to cgroups per default,
> until we changed it to a whitelist behavior:
> 
> commit b2a209ffa605994cbe3c259c8584ba1576d3310c
> Author: Vladimir Davydov <vdavydov@virtuozzo.com>
> Date:   Thu Jan 14 15:18:05 2016 -0800
> 
>     Revert "kernfs: do not account ino_ida allocations to memcg"
>     
>     Currently, all kmem allocations (namely every kmem_cache_alloc, kmalloc,
>     alloc_kmem_pages call) are accounted to memory cgroup automatically.
>     Callers have to explicitly opt out if they don't want/need accounting
>     for some reason.  Such a design decision leads to several problems:
>     
>      - kmalloc users are highly sensitive to failures, many of them
>        implicitly rely on the fact that kmalloc never fails, while memcg
>        makes failures quite plausible.

Doesn't apply here.  The allocation under spinlock is expected to fail,
and then we'll use xas_nomem() with the caller's specified GFP flags
which may or may not include __GFP_ACCOUNT.

>      - A lot of objects are shared among different containers by design.
>        Accounting such objects to one of containers is just unfair.
>        Moreover, it might lead to pinning a dead memcg along with its kmem
>        caches, which aren't tiny, which might result in noticeable increase
>        in memory consumption for no apparent reason in the long run.

These objects are in the slab of radix_tree_nodes, and we'll already be
accounting page cache nodes to the cgroup, so accounting random XArray
nodes to the cgroups isn't going to make the problem worse.

>      - There are tons of short-lived objects. Accounting them to memcg will
>        only result in slight noise and won't change the overall picture, but
>        we still have to pay accounting overhead.

XArray nodes are generally not short-lived objects.

