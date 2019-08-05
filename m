Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A55CC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 23:22:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEB1A2070D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 23:22:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEB1A2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E9BA6B0005; Mon,  5 Aug 2019 19:22:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 772686B0006; Mon,  5 Aug 2019 19:22:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63C0E6B0007; Mon,  5 Aug 2019 19:22:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 25D796B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 19:22:43 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l11so32257207pgc.14
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 16:22:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6blHumaRCdhPS5u5m+f7YbA0ShG4edq49AQfpkaxsfA=;
        b=TaAsgNWKNSpI6PASKdgrrfXQGVGLvBrCadl6qTQ3aw71Q1lqB+QVgTq/kFffltSIeJ
         eloP3oLWTQqGo+vlc/Op2yiAnp9kAneZlrDG6O0SIgv2+tTLjs9JvvPXlgMcMFHdxvv4
         XYW1z2hjlsIO1be75MEtLVIv4BDGNoEeT5l953Fg4GSRIXnt/vKvNr3leUeXP9l1kT8p
         ukCV++SlqyGzq0HDxBCwiuP18Sgs5+XIjOW7d5OaTc1CBFYFerzHFWf3IiGIr/4byH9A
         PkwzdCZ+y5JNZacOJEGdUxS4St8sNj+Zc4rTguI3yS1tPWeXs5fLiXhC5HKv6nJ+GhVb
         YwDg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVcedZdrXJmLUxJLFXjYJkX2Hp5Z3ZL7hinOD94GFdmuVZ1LweG
	d4T+nf0a6h6l9mbRgLlxRpNXTjvisYzzEgTc23u6KfbyQO85ioCpm1121KOuTKmDqZJPLJbRJu3
	m2lpK12DqpyuPo4KWBblBr4ytIlqOSN090d+cIzsxuH8XNVXs2jwg1lT0bow+ejg=
X-Received: by 2002:a63:e901:: with SMTP id i1mr261940pgh.451.1565047362674;
        Mon, 05 Aug 2019 16:22:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwvOuXUqMS3+TBbjhCZnJAPiiJ0IVX3VZc0OBBQJVIoFvyORzM4R+dpN06uVWz6zo2Icn6
X-Received: by 2002:a63:e901:: with SMTP id i1mr261903pgh.451.1565047361612;
        Mon, 05 Aug 2019 16:22:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565047361; cv=none;
        d=google.com; s=arc-20160816;
        b=qJLH21BgCuWQHkP6ohibAhPv4gJm3P4OQRAox4vd5xsag5UlDN6aZdNWLognr8EEEM
         4wXqEVqZkjfTbCrP2G87XMS2pzx8C5a8jSbcr2TPUgB37/5dFEMDd/sgNrDuU7liL94s
         jqX8IVQF7+1MkPGhlD3rlAkEgQoSV9seaWfYW6vQtm45fPdFUXMzFptAH5UCeDJbhtBI
         rtpZRtTmZYqEVOHtYg9ZTDUgBwRVJzmNzyVEkZOQqmy9tGxiArPQ3hLobaWzR+Y0fJ9l
         8JAY1KTUADBm97/izn9fR17ekJT31jOYpOERRq7KogpEt5OuTqBDHkMD2p65HV/lLNIl
         KBPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6blHumaRCdhPS5u5m+f7YbA0ShG4edq49AQfpkaxsfA=;
        b=bEJcdaeMCQ2ZSpGTVbtu96ho0uKMI2j1y2FNGr+gAzKkCgYOx5bHSPD8sQ3FeXnYz5
         AwOc/7cluTv9+cZnc79C4Y8wz3CykuhbzNR7Omq1wwO7wi3zkz7Kt1oE8aV5xUoRboUB
         ciKComz70DHIbPwTixz/lboStG8yTs8GRZjMwbmpmjtGUmPVB6KHJj7DZ1jFbshqHHd5
         1+zrIdBViOuseWueYkDhhgIvHj13LAGgLRV3Khj4O9sQa0phNJGl24Fwm6jQBilOdGDR
         jJ+nJk9Qv0+nBdGHfXq6fuHZNFHnqfk/znHa6aak/61cd2dL1Qh7h9a5W3q/jzpn6qr0
         v9Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id 23si44670726pfi.265.2019.08.05.16.22.41
        for <linux-mm@kvack.org>;
        Mon, 05 Aug 2019 16:22:41 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 461F743DEF8;
	Tue,  6 Aug 2019 09:22:39 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1humIG-0005EA-AB; Tue, 06 Aug 2019 09:21:32 +1000
Date: Tue, 6 Aug 2019 09:21:32 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 13/24] xfs: synchronous AIL pushing
Message-ID: <20190805232132.GY7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-14-david@fromorbit.com>
 <20190805175153.GC14760@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805175153.GC14760@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=-ljn3MnX72N5CFMTOV4A:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 01:51:53PM -0400, Brian Foster wrote:
> On Thu, Aug 01, 2019 at 12:17:41PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Provide an interface to push the AIL to a target LSN and wait for
> > the tail of the log to move past that LSN. This is used to wait for
> > all items older than a specific LSN to either be cleaned (written
> > back) or relogged to a higher LSN in the AIL. The primary use for
> > this is to allow IO free inode reclaim throttling.
> > 
> > Factor the common AIL deletion code that does all the wakeups into a
> > helper so we only have one copy of this somewhat tricky code to
> > interface with all the wakeups necessary when the LSN of the log
> > tail changes.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  fs/xfs/xfs_inode_item.c | 12 +------
> >  fs/xfs/xfs_trans_ail.c  | 69 +++++++++++++++++++++++++++++++++--------
> >  fs/xfs/xfs_trans_priv.h |  6 +++-
> >  3 files changed, 62 insertions(+), 25 deletions(-)
> > 
> ...
> > diff --git a/fs/xfs/xfs_trans_ail.c b/fs/xfs/xfs_trans_ail.c
> > index 6ccfd75d3c24..9e3102179221 100644
> > --- a/fs/xfs/xfs_trans_ail.c
> > +++ b/fs/xfs/xfs_trans_ail.c
> > @@ -654,6 +654,37 @@ xfs_ail_push_all(
> >  		xfs_ail_push(ailp, threshold_lsn);
> >  }
> >  
> > +/*
> > + * Push the AIL to a specific lsn and wait for it to complete.
> > + */
> > +void
> > +xfs_ail_push_sync(
> > +	struct xfs_ail		*ailp,
> > +	xfs_lsn_t		threshold_lsn)
> > +{
> > +	struct xfs_log_item	*lip;
> > +	DEFINE_WAIT(wait);
> > +
> > +	spin_lock(&ailp->ail_lock);
> > +	while ((lip = xfs_ail_min(ailp)) != NULL) {
> > +		prepare_to_wait(&ailp->ail_push, &wait, TASK_UNINTERRUPTIBLE);
> > +		if (XFS_FORCED_SHUTDOWN(ailp->ail_mount) ||
> > +		    XFS_LSN_CMP(threshold_lsn, lip->li_lsn) <= 0)
> > +			break;
> > +		/* XXX: cmpxchg? */
> > +		while (XFS_LSN_CMP(threshold_lsn, ailp->ail_target) > 0)
> > +			xfs_trans_ail_copy_lsn(ailp, &ailp->ail_target, &threshold_lsn);
> 
> Why the need to repeatedly copy the ail_target like this? If the push

It's a hack because the other updates are done unlocked and this
doesn't contain the memroy barriers needed to make it correct
and race free.

Hence the comment "XXX: cmpxchg" to ensure that:

	a) we only ever move the target forwards;
	b) we resolve update races in an obvious, simple manner; and
	c) we can get rid of the possibly incorrect memory
	   barriers around this (unlocked) update.

RFC. WIP. :)

> target only ever moves forward, we should only need to do this once at
> the start of the function. In fact I'm kind of wondering why we can't
> just call xfs_ail_push(). If we check the tail item after grabbing the
> spin lock, we should be able to avoid any races with the waker, no?

I didn't use xfs_ail_push() because of having to prepare to wait
between determining if the AIL is empty and checking if we need
to update the target.

I also didn't want to affect the existing xfs_ail_push() as I was
modifying the xfs_ail_push_sync() code to do what was needed.
Eventually they can probably come back together, but for now I'm not
100% sure that the code is correct and race free.

> > +void
> > +xfs_ail_delete_finish(
> > +	struct xfs_ail		*ailp,
> > +	bool			do_tail_update) __releases(ailp->ail_lock)
> > +{
> > +	struct xfs_mount	*mp = ailp->ail_mount;
> > +
> > +	if (!do_tail_update) {
> > +		spin_unlock(&ailp->ail_lock);
> > +		return;
> > +	}
> > +
> 
> Hmm.. so while what we really care about here are tail updates, this
> logic is currently driven by removing the min ail log item. That seems
> like a lot of potential churn if we're waking the pusher on every object
> written back covered by a single log record / checkpoint. Perhaps we
> should implement a bit more coarse wakeup logic such as only when the
> tail lsn actually changes, for example?

You mean the next patch?

> FWIW, it also doesn't look like you've handled the case of relogged
> items moving the tail forward anywhere that I can see, so we might be
> missing some wakeups here. See xfs_trans_ail_update_bulk() for
> additional AIL manipulation.

Good catch. That might be the race the next patch exposes :)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

