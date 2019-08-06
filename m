Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54BCBC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 22:23:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DD7F2086D
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 22:23:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DD7F2086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F7896B0003; Tue,  6 Aug 2019 18:23:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A8D96B0006; Tue,  6 Aug 2019 18:23:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 897E16B0007; Tue,  6 Aug 2019 18:23:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 545676B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 18:23:31 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id i134so18531412pgd.11
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 15:23:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OHxWVEDOP78ImK32Kw9h7tfqnmFm79uZH2X336QYRXs=;
        b=kKol8JVD8KU0OdCTE3qrbdR6ppvZlJ+fc081VJ0n2ArTx2TERfwGaTbf/5l3SLGHnj
         jbwVjazo8o4EJ7XE8kJ+o+6FHlWdxr7oMdGEUddexwYuwe8Zj5V62ktomzBUkXE/mpq4
         3TwLNLUSlVZSbkdYoaZ6SqVXKk3vu3/5ywFS547VdagQEOvo0uDGp3hVWWu+WxCJm0H9
         /dr1P6DfJ1xa+gXZBqPYyJuVFFnGKjRRGRUInpqDyR9EQgGkzExfdjHqYRYnhCeJRPG5
         D195hmItDV6Ovl3NQG2Eph2bJmnaEcVW5+7JgyH794eH0+eL4E7Yju09pePhwmBRtGKp
         4w6A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXr7l2/ZvFtYB8gSoUZxX+8P1PFbcTRs1mbalqffHG65YhRuSfy
	brP8aHM4D7Rd8LE/CQQwkI3j9b4mGq/TN6m13hCtOy9v7rILn4dmVac3qYQBmKTjgH4SGiHN0F5
	auClHoikPCMwwxLvHpQFj4ui7Z8nkvG9YeLC7UPNVhrXekRX07hu7Y+fEXkdCD1k=
X-Received: by 2002:a63:506:: with SMTP id 6mr4910356pgf.434.1565130210929;
        Tue, 06 Aug 2019 15:23:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQO3LoaSOCmBTxfld7s2h5w93tZJ6ibDbnbtgiffcVR34qHFvY28qSi2VXgL6AWawNGANx
X-Received: by 2002:a63:506:: with SMTP id 6mr4910310pgf.434.1565130210010;
        Tue, 06 Aug 2019 15:23:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565130210; cv=none;
        d=google.com; s=arc-20160816;
        b=WcEO5l1ZLRvTbhAzapl5T6m9RqEk8W/82moja4OuYnXwdpGfL1UWdMlNrh2haoAo2h
         UsZpVY4vzJn5KwebmoWDCGYqZX4tKT9v7PKribZ6d7JTWP9FJQFDyLwD+iuWD4yyUPIl
         BI8gBYD554K6hqFT+DbYqdDfkBZf4ADHklMtJoQ96jKrFxogSteazdnj8CDZUiZwLtOZ
         a7RE6pmAa3bkoFZFuAE15kjuBE/qSEyJeiL2KAM1LzlUqYBmviJbMDh7DRImgXCXhOY5
         iDXdgtz4HY65c4Ah5VrJgML8zxOTa7Gsgf39rWL5w3bkfOEVSYamCyU6aZO5c/S8Q/I3
         is4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OHxWVEDOP78ImK32Kw9h7tfqnmFm79uZH2X336QYRXs=;
        b=DOzXRXGBiCV0MS7hlku5w64fL7+kQYNq9lO7xMAFtd1IsgZrOyc9Tc0Ua68F4I8kJj
         nUDM6hMcCZvYBEM3cdmBEGThp8bcgTtrPaGY13HfvSijTMm1O517s6EuZMn6m7NcM0q5
         4UhSsIKYEkHdcvl/+mNKb/qp/GSIgvBTaGrdeEWpw+9F4LxoDox1pAuQPJ+bcjPVUnnq
         HGji38jQPddASiKghNWpx0uzvG2a9TkGvLQw/hdCp+rjtlUMmZchYeF6pTf4uTWNdTyP
         3IQ6pNcJkLJ3L5n6o/KESP+GcmEe50RgP/ERsFIE3fEb0ymCXrrf3umj4S1+4ha1WizI
         0qOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id o2si49921617pfp.113.2019.08.06.15.23.29
        for <linux-mm@kvack.org>;
        Tue, 06 Aug 2019 15:23:29 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id C8B133611E5;
	Wed,  7 Aug 2019 08:23:27 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hv7qW-0005QF-J6; Wed, 07 Aug 2019 08:22:20 +1000
Date: Wed, 7 Aug 2019 08:22:20 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 01/24] mm: directed shrinker work deferral
Message-ID: <20190806222220.GL7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-2-david@fromorbit.com>
 <20190802152709.GA60893@bfoster>
 <20190804014930.GR7777@dread.disaster.area>
 <20190805174226.GB14760@bfoster>
 <20190805234318.GB7777@dread.disaster.area>
 <20190806122754.GA2979@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806122754.GA2979@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=Lk4mrrDYMWaqc0wFPJcA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 08:27:54AM -0400, Brian Foster wrote:
> If you add a generic "defer work" knob to the shrinker mechanism, but
> only process it as an "allocation context" check, I expect it could be
> easily misused. For example, some shrinkers may decide to set the the
> flag dynamically based on in-core state.

Which is already the case. e.g. There are shrinkers that don't do
anything because a try-lock fails.  I haven't attempted to change
them, but they are a clear example of how even ->scan_object to
->scan_object the shrinker context can change. 

> This will work when called from
> some contexts but not from others (unrelated to allocation context),
> which is confusing. Therefore, what I'm saying is that if the only
> current use case is to defer work from shrinkers that currently skip
> work due to allocation context restraints, this might be better codified
> with something like the appended (untested) example patch. This may or
> may not be a preferable interface to the flag, but it's certainly not an
> overcomplication...

I don't think this is the right way to go.

I want the filesystem shrinkers to become entirely non-blocking so
that we can dynamically decide on an object-by-object basis whether
we can reclaim the object in GFP_NOFS context.

That is, a clean XFS inode that requires no special cleanup can be
reclaimed even in GFP_NOFS context. The problem we have is that
dentry reclaim can drop the last reference to an inode, causing
inactivation and hence modification. However, if it's only going to
move to the inode LRU and not evict the inode, we can reclaim that
dentry. Similarly for inodes - if evicting the inode is not going to
block or modify the inode, we can reclaim the inode even under
GFP_NOFS constraints. And the same for XFS indoes - it if's clean
we can reclaim it, GFP_NOFS context or not.

IMO, that's the direction we need to be heading in, and in those
cases the "deferred work" tends towards a count of objects we could
not reclaim during the scan because they require blocking work to be
done. i.e. deferred work is a boolean now because the GFP_NOFS
decision is boolean, but it's lays the ground work for deferred work
to be integrated at a much finer-grained level in the shrinker
scanning routines in future...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

