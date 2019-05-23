Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03161C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:21:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42B3920863
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:21:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="nybCDTO7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42B3920863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D567A6B02A5; Thu, 23 May 2019 15:21:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D08126B02A6; Thu, 23 May 2019 15:21:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF6BA6B02A7; Thu, 23 May 2019 15:21:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 866E06B02A5
	for <linux-mm@kvack.org>; Thu, 23 May 2019 15:21:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id y27so4479072pgk.15
        for <linux-mm@kvack.org>; Thu, 23 May 2019 12:21:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lL8Te4jWRFgZjfe9/dkqTtpuaDV38VTY4jurjNdU+eQ=;
        b=Kuu+mF9048IADBSYDba8TBuJCDCnMPIN8WQ2MMAy7M9ds6ePd/EPZrEz6uX5UR/kam
         6N46u2IJa4NrnpknLYXDMeEMpa9kxIPlKLZ3oYQ97tHRbBnA5ogrglNH5xIyVEr5w+X7
         9E13aZRJUKdbHtGZoIsD3BvNtFbFqooUuJi87Flz+mW5pxWFRmZ5nhjce7Il6IW4NpLs
         f0Fat2xGwG7cRv4lBvwtLRxytxRUlydwXT3ayWwgkHFWKrldy2Guc1aWOesH6e//13qc
         Bh4kv5CEeGDDp0zbBiC1b7BVd1e0G48YQ5cCflUdvUz6PodT2RnPME6+xVBMH+F+2sW2
         pgVw==
X-Gm-Message-State: APjAAAWNwXRcqI1kpy3pnnGOAVOoTBWksyCUD2QiergWKbnAvjf9jSqs
	l9nSlqaINWYQO6yrIKdhJOK9McS0M8J+NrkbZBs5DVx1vYLe0HpHW/K8H7RW+aDTEIzmLgxlO+0
	k5+AS+KBVw94JWrXgTHkeNFW5cTzKztdbC9tZaf7EEvJQc0GE/dJzF/qD9/bdMFipHA==
X-Received: by 2002:a17:90a:238d:: with SMTP id g13mr3710821pje.0.1558639282165;
        Thu, 23 May 2019 12:21:22 -0700 (PDT)
X-Received: by 2002:a17:90a:238d:: with SMTP id g13mr3710710pje.0.1558639281277;
        Thu, 23 May 2019 12:21:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558639281; cv=none;
        d=google.com; s=arc-20160816;
        b=cNOtaJO0/xJZrzhloYj3/eoNralRvq9r1tNHiLDuh1xAFg8bQ8vTIBumI5YPOwXOZ6
         cs+nRB9NYIg5mJGy0QsGT2gS2mK1bVoyHEmF9QvC7yoxFNS4PKbCcFhbTK1Me4fTJ9Jo
         7LNvAkbBAC3OmRb6/IwlGHv4uT24DnNapy4Vqdl7wi9GZh/Giqu7Lcxx8CNXHZsB6m+4
         N5FWwZgK2whLPerHjRCYd+HtJccf25tXWttW02HDQXEUNhyM5fsS1If4dc582SPyzxkc
         ZTQWoUhd7bbElyOJKUEIBpSyx4jB3nEu1VCcrLL97DdrYR92JkAGusC/cumwXt9ZAoL1
         gKFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lL8Te4jWRFgZjfe9/dkqTtpuaDV38VTY4jurjNdU+eQ=;
        b=cqtj9JltDjS9+agK+CtF4O4hZOn06EjBjMHp7VB3ZhxckfJ5wBfu6GfKGnXG1MH3cJ
         iPdwz3OV2Um+Y4BwuIMwsPpLZcQxi6aXFzM050SjrpaHH5xvf9IhQiimIj0A8R+zKxDz
         t3EvI2O8TMUHrZeorqvW4iaCoYXMjeUHiskgAcerxceECJMk6k8a80KePjlL0dkfDLjd
         GY0m/+X9jvAMRk0GoSY5+QY9Kt+NL5wDlOQpEhxRe0foYaSVSBBG0mR603W0J/XeY5Rt
         OoSiFKmPfaX/bjC8UK54h8FuOhjYiXstsY497HMs1Cl1uZuo9yJDVjHoGVJmnM8O+he+
         7f1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=nybCDTO7;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r81sor217124pfc.59.2019.05.23.12.21.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 12:21:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=nybCDTO7;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lL8Te4jWRFgZjfe9/dkqTtpuaDV38VTY4jurjNdU+eQ=;
        b=nybCDTO7aDXRp6lHK7Rp/GekCdBec5nSv1vGPL7AsV7BWGRmMpr8oMX+SWJ6tqCnxp
         jt/EQgZyLg/K/j88u5FLG64/VrSYEosF8XbzFGIvlQJCMjRf0M8DXdqVQ0oUX3nK364w
         suGKmmBrQv6I+Xu5NLhb2xkCUBExbI9Af8wkA7jprY9/X+blZhxGA4E28OjASTZk8GlE
         Iahzb/L+uDs18U0kDAkmUp8qhJLYZ5F4/1UjoTtbJKk0g1iO165I9P6yIWQcw2GkvCbc
         fC/I9mmKEN1y/R3Bfw+KQcW7sGZmQYK5tAWCko8OOqiS3XuYAeb6IO5tzxQ3JFMAX/Md
         bKIA==
X-Google-Smtp-Source: APXvYqzolr8W2Iv7H9NAdQP2LJzWG37v1LpW8TB3ML8vd7Zcc11Bv520V10CfeBPfFfhU5kPqIXneQ==
X-Received: by 2002:a63:1160:: with SMTP id 32mr100783894pgr.106.1558639280337;
        Thu, 23 May 2019 12:21:20 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::ece])
        by smtp.gmail.com with ESMTPSA id u6sm229294pfa.1.2019.05.23.12.21.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 12:21:19 -0700 (PDT)
Date: Thu, 23 May 2019 15:21:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Shakeel Butt <shakeelb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
Subject: Re: xarray breaks thrashing detection and cgroup isolation
Message-ID: <20190523192117.GA5723@cmpxchg.org>
References: <20190523174349.GA10939@cmpxchg.org>
 <20190523183713.GA14517@bombadil.infradead.org>
 <CALvZod4o0sA8CM961ZCCp-Vv+i6awFY0U07oJfXFDiVfFiaZfg@mail.gmail.com>
 <20190523190032.GA7873@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523190032.GA7873@bombadil.infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 12:00:32PM -0700, Matthew Wilcox wrote:
> On Thu, May 23, 2019 at 11:49:41AM -0700, Shakeel Butt wrote:
> > On Thu, May 23, 2019 at 11:37 AM Matthew Wilcox <willy@infradead.org> wrote:
> > >
> > > On Thu, May 23, 2019 at 01:43:49PM -0400, Johannes Weiner wrote:
> > > > I noticed that recent upstream kernels don't account the xarray nodes
> > > > of the page cache to the allocating cgroup, like we used to do for the
> > > > radix tree nodes.
> > > >
> > > > This results in broken isolation for cgrouped apps, allowing them to
> > > > escape their containment and harm other cgroups and the system with an
> > > > excessive build-up of nonresident information.
> > > >
> > > > It also breaks thrashing/refault detection because the page cache
> > > > lives in a different domain than the xarray nodes, and so the shadow
> > > > shrinker can reclaim nonresident information way too early when there
> > > > isn't much cache in the root cgroup.
> > > >
> > > > I'm not quite sure how to fix this, since the xarray code doesn't seem
> > > > to have per-tree gfp flags anymore like the radix tree did. We cannot
> > > > add SLAB_ACCOUNT to the radix_tree_node_cachep slab cache. And the
> > > > xarray api doesn't seem to really support gfp flags, either (xas_nomem
> > > > does, but the optimistic internal allocations have fixed gfp flags).
> > >
> > > Would it be a problem to always add __GFP_ACCOUNT to the fixed flags?
> > > I don't really understand cgroups.
> > 
> > Does xarray cache allocated nodes, something like radix tree's:
> > 
> > static DEFINE_PER_CPU(struct radix_tree_preload, radix_tree_preloads) = { 0, };
> > 
> > For the cached one, no __GFP_ACCOUNT flag.
> 
> No.  That was the point of the XArray conversion; no cached nodes.
> 
> > Also some users of xarray may not want __GFP_ACCOUNT. That's the
> > reason we had __GFP_ACCOUNT for page cache instead of hard coding it
> > in radix tree.
> 
> This is what I don't understand -- why would someone not want
> __GFP_ACCOUNT?  For a shared resource?  But the page cache is a shared
> resource.  So what is a good example of a time when an allocation should
> _not_ be accounted to the cgroup?

We used to cgroup-account every slab charge to cgroups per default,
until we changed it to a whitelist behavior:

commit b2a209ffa605994cbe3c259c8584ba1576d3310c
Author: Vladimir Davydov <vdavydov@virtuozzo.com>
Date:   Thu Jan 14 15:18:05 2016 -0800

    Revert "kernfs: do not account ino_ida allocations to memcg"
    
    Currently, all kmem allocations (namely every kmem_cache_alloc, kmalloc,
    alloc_kmem_pages call) are accounted to memory cgroup automatically.
    Callers have to explicitly opt out if they don't want/need accounting
    for some reason.  Such a design decision leads to several problems:
    
     - kmalloc users are highly sensitive to failures, many of them
       implicitly rely on the fact that kmalloc never fails, while memcg
       makes failures quite plausible.
    
     - A lot of objects are shared among different containers by design.
       Accounting such objects to one of containers is just unfair.
       Moreover, it might lead to pinning a dead memcg along with its kmem
       caches, which aren't tiny, which might result in noticeable increase
       in memory consumption for no apparent reason in the long run.
    
     - There are tons of short-lived objects. Accounting them to memcg will
       only result in slight noise and won't change the overall picture, but
       we still have to pay accounting overhead.
    
    For more info, see
    
     - http://lkml.kernel.org/r/20151105144002.GB15111%40dhcp22.suse.cz
     - http://lkml.kernel.org/r/20151106090555.GK29259@esperanza
    
    Therefore this patchset switches to the white list policy.  Now kmalloc
    users have to explicitly opt in by passing __GFP_ACCOUNT flag.
    
    Currently, the list of accounted objects is quite limited and only
    includes those allocations that (1) are known to be easily triggered
    from userspace and (2) can fail gracefully (for the full list see patch
    no.  6) and it still misses many object types.  However, accounting only
    those objects should be a satisfactory approximation of the behavior we
    used to have for most sane workloads.

The arguments would be the same here. Additional allocation overhead,
memory allocated on behalf of a shared facility, long-lived objects
pinning random, unrelated cgroups indefinitely.

The page cache is a sufficiently big user whose size can be directly
attributed to workload behavior, and can be controlled / reclaimed
under memory pressure. That's why it's accounted.

The same isn't true for random drivers using xarray, ida etc. It
shouldn't be implicit in the xarray semantics.

