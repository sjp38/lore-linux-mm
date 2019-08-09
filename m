Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21C18C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 00:11:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA6322166E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 00:11:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA6322166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DCDE6B0003; Thu,  8 Aug 2019 20:11:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68CA36B0006; Thu,  8 Aug 2019 20:11:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A3136B0007; Thu,  8 Aug 2019 20:11:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 250296B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 20:11:17 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id c9so2354345pgm.18
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 17:11:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5GBLahA9nxsBGuTHcZQ/Dy5peQcCaISm4DdHxGLFNjc=;
        b=WECpN0mRDrr/jiURze2O4pdpJkzDw6l5cLJMlRnreCKMpovFEZeWJs4B03rZ+j2i9r
         v4Y0a2PxCpjoV8Yag7/b9BLnot6zgH6rB2iAZh9ddB/RhDC0xT7tHBxMYG0Q7KpJJbFq
         FNOPwIJ0iiUmJQFlUfvyZzrokD7Z5Lp8H6j9+HBZIww0qeNeoHdoLnMi8vYn2sMCx4xr
         WG2AHl04P8phabXSW2e7aY4kIrsEVX2WPKdl5e9lFDyqzX2xF9psOIWCqzSdrXSlfc21
         UIc34O2fNdwNl+q7up83x9he/b0bpTNO/gL4qQmn92yP+v1qYqjXWVr9fJq4X5FXkQ2x
         Z+pw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWTgE1tDESZnE3LB868FAHIXAjzwq+ew9JNfOsC/jKBQM5VZ3m5
	RcuRzCedM8029UtwPuMKYOreJRJdlixNOx3yi0a68QXf2bzX7+kTPYiS4Wzk8OPzJQpTYw0ZxXS
	vP11uErrPgap/A2LhCRxJFIh0y6NTgYPmQ47DqBynIUZX4J351njqoZ1icxMYwEA=
X-Received: by 2002:a63:484a:: with SMTP id x10mr14891079pgk.430.1565309476624;
        Thu, 08 Aug 2019 17:11:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwA3dONS8xCRI7MZGaDEhBCoCJUiZfn0xL+2JMm+vI+BC3l4PEI1s3wgoiEWW06Onp5VjKA
X-Received: by 2002:a63:484a:: with SMTP id x10mr14891018pgk.430.1565309475698;
        Thu, 08 Aug 2019 17:11:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565309475; cv=none;
        d=google.com; s=arc-20160816;
        b=Bztq73zJkHkRl65ZV15NB50v2FQinupjOZcUGatx+AUKdryqVyhcGp97iQICBd6OHH
         D4vLJrSWHRvW2AthQ11mSWBTWTNJkMKbmK9tUOYSc5vPmFGAnm70zeWnH7hl9iBapiVP
         DmJRHVvh4np1CEGeGzCg97QiaNOMu8Y9+bpWyJmUsh5DyVPpo/kEUyHO/Q8bdfngbbKo
         OUnoRgNmRWM9ym2Hhpi8hhUAiAB1A6ajxirgEF/qNKH6VFuRPxZ8lrVl6MinZveup3DA
         3EfT1FS6g2uq+hxkj13g8ca1v8FRGuhCnTP2tsPc8kYG9qB8PVkcGhfRzJN2e9vnq2Ri
         8bTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5GBLahA9nxsBGuTHcZQ/Dy5peQcCaISm4DdHxGLFNjc=;
        b=K+hDoPOCQ614CgbZzIDeROlp8tMJ4jt8pnETJY4HCbPMMEjcyl3/MPEnfPzypaLzuf
         OoHYnoivlNcKU/kocXYzNJgGaf54wtIMJ+Igb9nzAzjQut06bh1//PVpdp8UximrunsJ
         rGh5vmWdJ/7J3Ndqs3FAt59/f3vtAc35TOSY9sankJj/jjQ704blfPwr010hKx1ZCD4h
         GV15i0tHUuI50gLq7dqgPyRVIm91hCK5PH/GtGDd+2MfLqbxzejl4ZjTIP+vm5wiQjmW
         /JNDfKozmSceeIz1CmM8fOGl3cXWBMW498NoYuGv1BhMl1IbR27VastAEb7jbdU0ECH6
         9k8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id l9si58046141pgm.43.2019.08.08.17.11.15
        for <linux-mm@kvack.org>;
        Thu, 08 Aug 2019 17:11:15 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 2D18943F66E;
	Fri,  9 Aug 2019 10:11:13 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hvsTt-0000ry-Vd; Fri, 09 Aug 2019 10:10:05 +1000
Date: Fri, 9 Aug 2019 10:10:05 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 22/24] xfs: track reclaimable inodes using a LRU list
Message-ID: <20190809001005.GW7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-23-david@fromorbit.com>
 <20190808163653.GB24551@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808163653.GB24551@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=16FmFycsKCjbgrCA0BcA:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 12:36:53PM -0400, Brian Foster wrote:
> On Thu, Aug 01, 2019 at 12:17:50PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Now that we don't do IO from the inode reclaim code, there is no
> > need to optimise inode scanning order for optimal IO
> > characteristics. The AIL takes care of that for us, so now reclaim
> > can focus on selecting the best inodes to reclaim.
> > 
> > Hence we can change the inode reclaim algorithm to a real LRU and
> > remove the need to use the radix tree to track and walk inodes under
> > reclaim. This frees up a radix tree bit and simplifies the code that
> > marks inodes are reclaim candidates. It also simplifies the reclaim
> > code - we don't need batching anymore and all the reclaim logic
> > can be added to the LRU isolation callback.
> > 
> > Further, we get node aware reclaim at the xfs_inode level, which
> > should help the per-node reclaim code free relevant inodes faster.
> > 
> > We can re-use the VFS inode lru pointers - once the inode has been
> > reclaimed from the VFS, we can use these pointers ourselves. Hence
> > we don't need to grow the inode to change the way we index
> > reclaimable inodes.
> > 
> > Start by adding the list_lru tracking in parallel with the existing
> > reclaim code. This makes it easier to see the LRU infrastructure
> > separate to the reclaim algorithm changes. Especially the locking
> > order, which is ip->i_flags_lock -> list_lru lock.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  fs/xfs/xfs_icache.c | 31 +++++++------------------------
> >  fs/xfs/xfs_icache.h |  1 -
> >  fs/xfs/xfs_mount.h  |  1 +
> >  fs/xfs/xfs_super.c  | 31 ++++++++++++++++++++++++-------
> >  4 files changed, 32 insertions(+), 32 deletions(-)
> > 
> ...
> > diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
> > index a59d3a21be5c..b5c4c1b6fd19 100644
> > --- a/fs/xfs/xfs_super.c
> > +++ b/fs/xfs/xfs_super.c
> ...
> > @@ -1801,7 +1817,8 @@ xfs_fs_nr_cached_objects(
> >  	/* Paranoia: catch incorrect calls during mount setup or teardown */
> >  	if (WARN_ON_ONCE(!sb->s_fs_info))
> >  		return 0;
> > -	return xfs_reclaim_inodes_count(XFS_M(sb));
> > +
> > +	return list_lru_shrink_count(&XFS_M(sb)->m_inode_lru, sc);
> 
> Do we not need locking here,

No locking is needed - we have no global lock that protects the
list_lru that we could use to serialise the count - that would
completely destroy the scalability advantages the list_lru provide.
As it is, shrinker counts have always been inherently racy and so we
don't really care for accuracy anywhere in the shrinker code. Hence
there is no need to attempt to be accurate here, just like didn't
attempt to be accurate for the per AG reclaimable inode count
aggregation that this replaces.

> or are we just skipping it because this
> apparently maintains a count field and accuracy isn't critical? If the
> latter, a one liner comment would be useful.

I don't think it needs comments as they would be stating the
obvious.  We don't have comments explaining this in any other
shrinker - it's jsut assumed that anyone working with shrinkers
already knows that the counts are not required to be exactly
accurate...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

