Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8FCDC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 18:04:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BD8F2184E
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 18:04:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="r1OoUil1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BD8F2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC7236B0284; Fri, 24 May 2019 14:04:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9DC06B0286; Fri, 24 May 2019 14:04:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB38E6B0287; Fri, 24 May 2019 14:04:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABBD46B0284
	for <linux-mm@kvack.org>; Fri, 24 May 2019 14:04:19 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id v6so5184287ybs.1
        for <linux-mm@kvack.org>; Fri, 24 May 2019 11:04:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ac3B/Xe+w3ROTUibljmXKgMNFheZh3fEEGPnecMKhL8=;
        b=dpy6zAOn4WjRvbg1iMnVoWWNClaiBdJ72nqB+xqtWq9EfL0X2jHYmbtXlXOHeRGpjW
         mNvYnu+XG6csAwSCXPEgecIsrmONhLqeEWOjgPNyVna8+/S4g/qwtu6rQm/S3VpeQem8
         ddqRfh9Ic9flRWU6+yIqSMGGtr9/mZaHpskJbthhxMiwQJLHliODyQ+q4sG5HJh352G2
         7rSZCMPXBtayPKZRxeGsLXT21zHsn3DiUabOPsJL3mFbWrI/Q2kCLqnHTZY2T9opusjS
         0v3tTxu+23mt9ivfKA6TP73oq9Vxq8tfOJy77ZuS1/r2vEmRpVRFw4oY8DjYz3/7Mc6N
         z7Mw==
X-Gm-Message-State: APjAAAWaY+bImCCBRr9EvTZD2/bxRtCDs86+7v2IFMRYznyFiAx1Drh4
	9y0UhhEIX2GbZebasKTAA/OOWZl9YMQfdL7+7VurlBd4pnOcVDhBYcBoiLUT/Qr54LMBdee/56z
	GMN1LHTaq7JlrhiWpN8YUffmWXlzkOiYZlG+pqIKU2VddNdqDOiLF3Zc9kdBk4KBTig==
X-Received: by 2002:a81:6806:: with SMTP id d6mr1592949ywc.248.1558721059455;
        Fri, 24 May 2019 11:04:19 -0700 (PDT)
X-Received: by 2002:a81:6806:: with SMTP id d6mr1592909ywc.248.1558721058735;
        Fri, 24 May 2019 11:04:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558721058; cv=none;
        d=google.com; s=arc-20160816;
        b=UX0VLO3OACYebAbZ25+PCJzTTwOM36vnm0BHbVJX6aAsXXW6jdWuRAkEhBqfYtgCVk
         YzCPf7VnZoze8SBoiTorIi36cj+/T+kB1gSAXsxS5J7DMeBNENUxl0Qv1jU4tPvK0dE3
         WM1MUDKH/MN1gzMibiDTDpG6/3M6N3zhbPZfe2aRPCK/enP6jeYAYo3kekgFWTrzzfwc
         C82jjpMC7KJHcdZJ2RHeA0hs5Dn9K5UVSLPvw94GOS6/6fhOqZWeI1ixpuvRDCq6J7RS
         40MFDStm+XsJS6oAzrhUm8Qiunp8FurGuo5v5Z38NwYD5qiY6oz/qoYRcJZ0Mcb8caQL
         UUjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ac3B/Xe+w3ROTUibljmXKgMNFheZh3fEEGPnecMKhL8=;
        b=UgMvmXT5VcqqAdPUMdEkqZso04IZAuX+B8lUaYIAJAAVJAIfgxcsRy4GgCOeIzzwKA
         y/YuyW5gbIt4ljn1HlMYvsI9RlBZN4DzVWIjlV3OWmVJGyncppIs4PCIVO/7pH0ka15i
         Lxsgv/rgwg4pNq8b7z2d8ztr8pdUalq6g3h6eONR3NYRFT678BgaWK+TuZlBj1KZ8wHd
         weRInOOwMZpjFjcXfL3sCj3bORmIVJcLpIJ3fb/MEleYizgaKsgfhLV6Wjm2lcV2l68y
         E7e7lM3HlBwVziRqD3WbuDBxLDrTRvjkaq721AfmD7oN3O2RNLojdidsqgmPqY7HHHNj
         /rOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=r1OoUil1;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n2sor1654863ywf.11.2019.05.24.11.04.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 11:04:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=r1OoUil1;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ac3B/Xe+w3ROTUibljmXKgMNFheZh3fEEGPnecMKhL8=;
        b=r1OoUil15z41t05s7Vkc/zjldTqEYgmmxywmhKuW54yfFoy/DzoLQdlPOyYRIwSPds
         sEHDpgwMAcqLq1YXHhMikBuTJisl+J2t2x60kdRX3fh+DCltNpsWy5VjfrYhj93J/WV9
         hrRLr/L897Xl/6cxVjDjl8EB/mnP3sCPl+QE8oW6qtneUdfiqvfxgUyLSqP/wtg/foth
         i+Wxt0gU2HJ0rfVhaCvQ6415HVjOy7xHl2d9q0YhQjQFIqCXXQvxMliZxaEgaiXcRr6u
         Ovm0UwnXvMH3SnusLsATmcCksvmzuf4hl8kotBCewE2zc/q8LmW+uDruXRlmZFlvwfT8
         EPlw==
X-Google-Smtp-Source: APXvYqwGxgNhe0/sR2Bra3VIvf25c+d9ZRZytcuC+KZ8FBRUDOjzqpxCJXpC987qr7W/yk2gPJa5HVzkIHmlaFATPpo=
X-Received: by 2002:a0d:d9d7:: with SMTP id b206mr28725213ywe.398.1558721058115;
 Fri, 24 May 2019 11:04:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190524153148.18481-1-hannes@cmpxchg.org> <20190524160417.GB1075@bombadil.infradead.org>
 <20190524173900.GA11702@cmpxchg.org>
In-Reply-To: <20190524173900.GA11702@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 24 May 2019 11:04:06 -0700
Message-ID: <CALvZod4ZK5X+Tf2BMgwi40XmSTqHW-=wAwSVg_eFrtCf2=rCQw@mail.gmail.com>
Subject: Re: [PATCH] mm: fix page cache convergence regression
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Team <kernel-team@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 10:41 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Fri, May 24, 2019 at 09:04:17AM -0700, Matthew Wilcox wrote:
> > On Fri, May 24, 2019 at 11:31:48AM -0400, Johannes Weiner wrote:
> > > diff --git a/include/linux/xarray.h b/include/linux/xarray.h
> > > index 0e01e6129145..cbbf76e4c973 100644
> > > --- a/include/linux/xarray.h
> > > +++ b/include/linux/xarray.h
> > > @@ -292,6 +292,7 @@ struct xarray {
> > >     spinlock_t      xa_lock;
> > >  /* private: The rest of the data structure is not to be used directly. */
> > >     gfp_t           xa_flags;
> > > +   gfp_t           xa_gfp;
> > >     void __rcu *    xa_head;
> > >  };
> >
> > No.  I'm willing to go for a xa_flag which says to use __GFP_ACCOUNT, but
> > you can't add another element to the struct xarray.
>
> Ok, we can generalize per-tree gfp flags later if necessary.
>
> Below is the updated fix that uses an XA_FLAGS_ACCOUNT flag instead.
>
> ---
> From 63a0dbc571ff38f7c072c62d6bc28192debe37ac Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Fri, 24 May 2019 10:12:46 -0400
> Subject: [PATCH] mm: fix page cache convergence regression
>
> Since a28334862993 ("page cache: Finish XArray conversion"), on most
> major Linux distributions, the page cache doesn't correctly transition
> when the hot data set is changing, and leaves the new pages thrashing
> indefinitely instead of kicking out the cold ones.
>
> On a freshly booted, freshly ssh'd into virtual machine with 1G RAM
> running stock Arch Linux:
>
> [root@ham ~]# ./reclaimtest.sh
> + dd of=workingset-a bs=1M count=0 seek=600
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + ./mincore workingset-a
> 153600/153600 workingset-a
> + dd of=workingset-b bs=1M count=0 seek=600
> + cat workingset-b
> + cat workingset-b
> + cat workingset-b
> + cat workingset-b
> + ./mincore workingset-a workingset-b
> 104029/153600 workingset-a
> 120086/153600 workingset-b
> + cat workingset-b
> + cat workingset-b
> + cat workingset-b
> + cat workingset-b
> + ./mincore workingset-a workingset-b
> 104029/153600 workingset-a
> 120268/153600 workingset-b
>
> workingset-b is a 600M file on a 1G host that is otherwise entirely
> idle. No matter how often it's being accessed, it won't get cached.
>
> While investigating, I noticed that the non-resident information gets
> aggressively reclaimed - /proc/vmstat::workingset_nodereclaim. This is
> a problem because a workingset transition like this relies on the
> non-resident information tracked in the page cache tree of evicted
> file ranges: when the cache faults are refaults of recently evicted
> cache, we challenge the existing active set, and that allows a new
> workingset to establish itself.
>
> Tracing the shrinker that maintains this memory revealed that all page
> cache tree nodes were allocated to the root cgroup. This is a problem,
> because 1) the shrinker sizes the amount of non-resident information
> it keeps to the size of the cgroup's other memory and 2) on most major
> Linux distributions, only kernel threads live in the root cgroup and
> everything else gets put into services or session groups:
>
> [root@ham ~]# cat /proc/self/cgroup
> 0::/user.slice/user-0.slice/session-c1.scope
>
> As a result, we basically maintain no non-resident information for the
> workloads running on the system, thus breaking the caching algorithm.
>
> Looking through the code, I found the culprit in the above-mentioned
> patch: when switching from the radix tree to xarray, it dropped the
> __GFP_ACCOUNT flag from the tree node allocations - the flag that
> makes sure the allocated memory gets charged to and tracked by the
> cgroup of the calling process - in this case, the one doing the fault.
>
> To fix this, allow xarray users to specify per-tree flag that makes
> xarray allocate nodes using __GFP_ACCOUNT. Then restore the page cache
> tree annotation to request such cgroup tracking for the cache nodes.
>
> With this patch applied, the page cache correctly converges on new
> workingsets again after just a few iterations:
>
> [root@ham ~]# ./reclaimtest.sh
> + dd of=workingset-a bs=1M count=0 seek=600
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + ./mincore workingset-a
> 153600/153600 workingset-a
> + dd of=workingset-b bs=1M count=0 seek=600
> + cat workingset-b
> + ./mincore workingset-a workingset-b
> 124607/153600 workingset-a
> 87876/153600 workingset-b
> + cat workingset-b
> + ./mincore workingset-a workingset-b
> 81313/153600 workingset-a
> 133321/153600 workingset-b
> + cat workingset-b
> + ./mincore workingset-a workingset-b
> 63036/153600 workingset-a
> 153600/153600 workingset-b
>
> Cc: stable@vger.kernel.org # 4.20+
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

