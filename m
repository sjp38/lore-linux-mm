Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09527C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 11:14:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFBF121922
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 11:14:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFBF121922
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F36A6B0006; Wed,  7 Aug 2019 07:14:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A3FD6B0007; Wed,  7 Aug 2019 07:14:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BB606B0008; Wed,  7 Aug 2019 07:14:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8E76B0006
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 07:14:14 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x10so81758034qti.11
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 04:14:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Uds+w+gmw/Ks8qYvE44fRRSSMmaaJ+67SwrXmNoa2fE=;
        b=WkkLPKt5mIgY1ehyyfdFyvXFJCk21hd8iYwzmOH/tjWKMzC0s1SNMWyO9bvZ+Nyseu
         qmQo0NwPO7RgFUhZfW3wEGmW7IIkp9C5zHJ6l27bOZPOqK7ZkNZHEaX+9lWc5Ib5Y86/
         1PlAGqwllzopCwcGUClWpNvZYolnzrLDcXvP4w11TvFgCrYAH2PWnaXKyjr/ONqjFf5v
         WhAOY9wHMcqBmje/KzOvr/Q8jeqEInC/3g/Nfs5Hkqst4XH6n5pIPxJCKB8yZTATblxF
         xTL3sR5i4LbJ2qOSHCMkK0m8KRQp3VLBEATB+HFI0FLB6Kc9ZcOuft9msIOK/9YCbssF
         1rdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWoPqXifb9LpUj3LvHd27lApvwOMCQlorqNOPZ+dSD57BGf6Yec
	MLIrr3ZH2Ew4wJFwieV1JexQ7TYWQZ5p9CMqQ6Zoub+befbJqzLmFR4X4hj9WTH6IEKpCcm4BaA
	PsjpISkb/dPEZkff2hq1Qo+y1j551CDIIQYSssDKe/qEgH9xhsAySRaal+j2+rA9OsA==
X-Received: by 2002:a0c:fa8b:: with SMTP id o11mr7598076qvn.6.1565176454045;
        Wed, 07 Aug 2019 04:14:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy30Oaq6O5u6GJwXHVibn+j1lsbPPo0wroKXeWVeFIgJvMdsjxvBHdISV7PcFXUNGAQfMAx
X-Received: by 2002:a0c:fa8b:: with SMTP id o11mr7598032qvn.6.1565176453340;
        Wed, 07 Aug 2019 04:14:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565176453; cv=none;
        d=google.com; s=arc-20160816;
        b=jxhzdOj6YGaxr/Qt37SWTnT2xtQKG9OC83C7HyA2uVKTn6yBaMRIX5AMN6k1Z5SMkW
         lmn5LfGLYFgij/6XOHpJPBa4PrpjHAynJXB2On4rHHIOggpUTfqZV2o/EVzU52Kb32uM
         ATMuqUqIn+ykZrUer2aiOmiBv09ZnHUD8L92j7HavB2gqmeLM7NSxbJ4fAHz8F3vcErD
         9+oD+G8GCIfv838tctaATZvMrmJFRd9CmoWSwTBeN5Nj25HAMioKgE8wHVt0CXng5ysE
         QqXlo/2ER2haXO+mC2+xH7SYXVY5FWe9PjM0lTlGy506Pqh8m7DOmEgqIxdGIDBZUwy7
         ggsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Uds+w+gmw/Ks8qYvE44fRRSSMmaaJ+67SwrXmNoa2fE=;
        b=mrARVTgwjGgI0TzO1wrRVHuvT1OEoCP27wxHa+wm/Bb40I0TXonQka/jf4/BzlJv64
         FQQgbRPWGDnvr0e2JhhVwNjP3qoF3bSf4xX7SAPTdP76yNR13i4cEfP3y5W+021IlPEE
         RMcWKWyLXHIjwQ0IM3xqGIDJxFhMfnWgUJSGR6fFpA0CHOX/vrruC3UF4kKhyIY7JVym
         H6tx5HCdWhUGTQkJvGLGS+W7CjURkZl50oDCsw/M/Oy6p3kFBdhDqq1YjAgcb1VQPxcC
         LxlUmImJf/28BQe6LlYyXLx6luyZYMkjofEUhQUgU7/uPUW38ihUZWZbqofCXStdxXRo
         Un+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v79si49203865qka.120.2019.08.07.04.14.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 04:14:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8B5863098444;
	Wed,  7 Aug 2019 11:14:12 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 098865D9E1;
	Wed,  7 Aug 2019 11:14:11 +0000 (UTC)
Date: Wed, 7 Aug 2019 07:14:10 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 17/24] xfs: don't block kswapd in inode reclaim
Message-ID: <20190807111410.GB19707@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-18-david@fromorbit.com>
 <20190806182131.GE2979@bfoster>
 <20190806212704.GI7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806212704.GI7777@dread.disaster.area>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 07 Aug 2019 11:14:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 07:27:04AM +1000, Dave Chinner wrote:
> On Tue, Aug 06, 2019 at 02:21:31PM -0400, Brian Foster wrote:
> > On Thu, Aug 01, 2019 at 12:17:45PM +1000, Dave Chinner wrote:
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > We have a number of reasons for blocking kswapd in XFS inode
> > > reclaim, mainly all to do with the fact that memory reclaim has no
> > > feedback mechanisms to throttle on dirty slab objects that need IO
> > > to reclaim.
> > > 
> > > As a result, we currently throttle inode reclaim by issuing IO in
> > > the reclaim context. The unfortunate side effect of this is that it
> > > can cause long tail latencies in reclaim and for some workloads this
> > > can be a problem.
> > > 
> > > Now that the shrinkers finally have a method of telling kswapd to
> > > back off, we can start the process of making inode reclaim in XFS
> > > non-blocking. The first thing we need to do is not block kswapd, but
> > > so that doesn't cause immediate serious problems, make sure inode
> > > writeback is always underway when kswapd is running.
> > > 
> > > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > > ---
> > >  fs/xfs/xfs_icache.c | 17 ++++++++++++++---
> > >  1 file changed, 14 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
> > > index 0b0fd10a36d4..2fa2f8dcf86b 100644
> > > --- a/fs/xfs/xfs_icache.c
> > > +++ b/fs/xfs/xfs_icache.c
> > > @@ -1378,11 +1378,22 @@ xfs_reclaim_inodes_nr(
> > >  	struct xfs_mount	*mp,
> > >  	int			nr_to_scan)
> > >  {
> > > -	/* kick background reclaimer and push the AIL */
> > > +	int			sync_mode = SYNC_TRYLOCK;
> > > +
> > > +	/* kick background reclaimer */
> > >  	xfs_reclaim_work_queue(mp);
> > > -	xfs_ail_push_all(mp->m_ail);
> > >  
> > > -	return xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan);
> > > +	/*
> > > +	 * For kswapd, we kick background inode writeback. For direct
> > > +	 * reclaim, we issue and wait on inode writeback to throttle
> > > +	 * reclaim rates and avoid shouty OOM-death.
> > > +	 */
> > > +	if (current_is_kswapd())
> > > +		xfs_ail_push_all(mp->m_ail);
> > 
> > So we're unblocking kswapd from dirty items, but we already kick the AIL
> > regardless of kswapd or not in inode reclaim. Why the change to no
> > longer kick the AIL in the !kswapd case? Whatever the reasoning, a
> > mention in the commit log would be helpful...
> 
> Because we used to block reclaim, we never knew how long it would be
> before it came back (say it had to write 1024 inode buffers), so
> every time we entered reclaim here we kicked the AIL in case we did
> get blocked for a long time.
> 
> Now kswapd doesn't block at all, we know it's going to enter this
> code repeatedly while direct reclaim is blocked, and so we only need
> it to kick background inode writeback via kswapd rather than all
> reclaim now.
> 

Got it. Can you include this reasoning in the commit log description
please?

Brian

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

