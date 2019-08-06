Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0F42C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:28:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B65A2075B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:28:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B65A2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CBE16B000C; Tue,  6 Aug 2019 17:28:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A22E6B000D; Tue,  6 Aug 2019 17:28:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DF696B000E; Tue,  6 Aug 2019 17:28:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1176B000C
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:28:14 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y66so56752288pfb.21
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:28:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=X6lbqrDEqveuaEiGlKOUKxDW3hHH3MClP20+Dbh+PNA=;
        b=MjSBVgYDdVmUg2RoamC7SeBTOLhPcgrE7YfL7cRiMsjh1cX5usUDutyk5tKrCLzCvl
         PryZBHjA4YMNM+Ne1/9Uw1/8ZUZyh9cFxYRqv5tg9K0ifmo7VLlTDE65l6WPTPqcmGa+
         7irIKQ8XEiTSugXT2+XFdu+3f7tKN0P+BPKL+/nAo8Q6vLprShQsChD+D/NeCM2Bnoxp
         XH6yqcL99p61Y3DK2abbVFVGJQFiGJaSCGyuJNx9T+75vKSg7uRPDiM5gMNxwxpww2PM
         w/Jn2Xefu9Ltc5JxpXqrkI/bqLKiDIe33U42FpICUk1pQui/XeNaWOa2EKxAnrsebnML
         qnfw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWgvsPJiKk/AbX1eaBPlf1ryM7kPa/gn3ApDb/oKGRbnVj9lkme
	kv1a75zfEKGFqyLv9OBVYrabhWZMHG5iNO8+BE8ZY88Aa4YYcWLpGsQAWB75JiGMeIzO4EI9IMs
	lxkVBce8DnNB9NwbqGCZW/Lu+PX3QkxuIvKIBLIoadMyo1HEzX99MU5sVhlRkIhs=
X-Received: by 2002:a63:1020:: with SMTP id f32mr4957059pgl.203.1565126893576;
        Tue, 06 Aug 2019 14:28:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5G3SWwUbry2clkkvEu+wG4AnwDacDzyoo9Rj9uE4qByqEQY/z0xDjVujifjnXZ3zmo2NA
X-Received: by 2002:a63:1020:: with SMTP id f32mr4957017pgl.203.1565126892774;
        Tue, 06 Aug 2019 14:28:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565126892; cv=none;
        d=google.com; s=arc-20160816;
        b=zc0542niFqPNQq/H7D2kgZX1T9d3hUOU0E5HQ6IyRN6i7WwKP2tVVKwViVwArJ9XRc
         cI5GxEiS4qP4/Cm3UO9u5zFfkyfL2/g7CVU30zNtblgYxznu8mYZA0RQEgJWAYSsu7Nm
         DUFJAw7yc/PQgvaUncv4sgStEYKP4ddeAXNBA1MwbAl/ydvGzCxxaMvtEsVV48hIqM5f
         WPyTWn9/+eU4hxyyySn94quVsuPba84RjTuM3jslpdj9f2t4vXZCpywYuZclDjslMFKF
         ITIAIqSw23ykUCNjt467EF+pkSyJfa8R/rUyNICoKkcnjeMBhtCRVWqGLj+kaihMVzvH
         Lhmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=X6lbqrDEqveuaEiGlKOUKxDW3hHH3MClP20+Dbh+PNA=;
        b=bpQqSRU7zpZ2Ymg5oOxfx+cBMwVuQY8s4meB/UagmnJ+lYVi5IWzBu3SfXYKORB4eG
         NFcjrAaIhDIHw3erZm78oe4vwvRnvnIj2+LhEkRSj1u51mEfaxFpmO+JOXO0L1RCy5Ao
         mDIWJOj0+YrbP1V1wdc1xbIMMzvB2DqrSMBdfHdDjOiY0NoaFr96MfJJYuGsiPPupOpk
         SOMMOuhUsxW6nFJ6CL6xEfLCUeFsZvGBnsagInsqH86iT+rOaP7RXp/RnoE6e86SaKcv
         vm3mzcGdieoCblzubi9WjnoP4laK460/PtFEpY1SHnRJoJe/82Q+O3yBbWqxL8I+xLN7
         L71g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id h11si32303580pgr.555.2019.08.06.14.28.12
        for <linux-mm@kvack.org>;
        Tue, 06 Aug 2019 14:28:12 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 66E3A3611D8;
	Wed,  7 Aug 2019 07:28:11 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hv6z2-00059Y-Ao; Wed, 07 Aug 2019 07:27:04 +1000
Date: Wed, 7 Aug 2019 07:27:04 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 17/24] xfs: don't block kswapd in inode reclaim
Message-ID: <20190806212704.GI7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-18-david@fromorbit.com>
 <20190806182131.GE2979@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806182131.GE2979@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=BnAoINNY7SeVK6BmJucA:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 02:21:31PM -0400, Brian Foster wrote:
> On Thu, Aug 01, 2019 at 12:17:45PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > We have a number of reasons for blocking kswapd in XFS inode
> > reclaim, mainly all to do with the fact that memory reclaim has no
> > feedback mechanisms to throttle on dirty slab objects that need IO
> > to reclaim.
> > 
> > As a result, we currently throttle inode reclaim by issuing IO in
> > the reclaim context. The unfortunate side effect of this is that it
> > can cause long tail latencies in reclaim and for some workloads this
> > can be a problem.
> > 
> > Now that the shrinkers finally have a method of telling kswapd to
> > back off, we can start the process of making inode reclaim in XFS
> > non-blocking. The first thing we need to do is not block kswapd, but
> > so that doesn't cause immediate serious problems, make sure inode
> > writeback is always underway when kswapd is running.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  fs/xfs/xfs_icache.c | 17 ++++++++++++++---
> >  1 file changed, 14 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
> > index 0b0fd10a36d4..2fa2f8dcf86b 100644
> > --- a/fs/xfs/xfs_icache.c
> > +++ b/fs/xfs/xfs_icache.c
> > @@ -1378,11 +1378,22 @@ xfs_reclaim_inodes_nr(
> >  	struct xfs_mount	*mp,
> >  	int			nr_to_scan)
> >  {
> > -	/* kick background reclaimer and push the AIL */
> > +	int			sync_mode = SYNC_TRYLOCK;
> > +
> > +	/* kick background reclaimer */
> >  	xfs_reclaim_work_queue(mp);
> > -	xfs_ail_push_all(mp->m_ail);
> >  
> > -	return xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan);
> > +	/*
> > +	 * For kswapd, we kick background inode writeback. For direct
> > +	 * reclaim, we issue and wait on inode writeback to throttle
> > +	 * reclaim rates and avoid shouty OOM-death.
> > +	 */
> > +	if (current_is_kswapd())
> > +		xfs_ail_push_all(mp->m_ail);
> 
> So we're unblocking kswapd from dirty items, but we already kick the AIL
> regardless of kswapd or not in inode reclaim. Why the change to no
> longer kick the AIL in the !kswapd case? Whatever the reasoning, a
> mention in the commit log would be helpful...

Because we used to block reclaim, we never knew how long it would be
before it came back (say it had to write 1024 inode buffers), so
every time we entered reclaim here we kicked the AIL in case we did
get blocked for a long time.

Now kswapd doesn't block at all, we know it's going to enter this
code repeatedly while direct reclaim is blocked, and so we only need
it to kick background inode writeback via kswapd rather than all
reclaim now.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

