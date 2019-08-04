Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF0C6C433FF
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 01:51:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CC70217D6
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 01:51:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CC70217D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 403A66B0006; Sat,  3 Aug 2019 21:51:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38B906B0007; Sat,  3 Aug 2019 21:51:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2536C6B0008; Sat,  3 Aug 2019 21:51:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DDC0B6B0006
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 21:51:38 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a5so44043338pla.3
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 18:51:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ql6euhQXhUgRSH8xN0SESmBnMIuoK9H8N8CBkDk7xqY=;
        b=DppynsSe2IQMPMUc0DO1BGwVXQ2nCYHnahLT9Ri9X3oF5o/ogmzJp9D+fUy/YJb9Un
         D+LQFWmoEzgNkGwn/1BWdB/MSywgjm1S0K1Dc//VSa8FF+8Ox0SPyYK5kuRd8IaF3dLn
         9BtkXjYKOKyHLG485bmelDzr8l2rG7iYfvxetxqtZzwk4iySzgyIIWQ7DHVI+2sDKnqe
         Ipk6EbabqjzNbDlxYXgxP8W11+qXWRONiP6Y9Xju2kPA0wtBW014LixJy+zOPhza5Inl
         KKv63xcPmebqF4ibm0rYhOzC7KN3KGwcSv9C/JYO/GVI6rLN4h8fZAvmN6gloRQsmI+L
         RPbw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXN8oN3VWNnGZ2z61oGB5wMYsHQdKRPiiXk+qYHeGSohJpu5hLG
	a/CMUuY1ayQpDCH451Q6GRY23vzCru6J+zAmz0PyeluabO1O0rAf1K6DyEeTHESunA7mNkWvwjt
	ZPawvFwL1lP+7ZdV+Q62lIczoEWaHHgsWYV6fbXWP84EEx26ZdfQ7IOXsnk3SiXo=
X-Received: by 2002:a17:90a:ba94:: with SMTP id t20mr11965237pjr.116.1564883498548;
        Sat, 03 Aug 2019 18:51:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyC4WazW4XNxFJ2nt2BSV1YyvgWk7rDiUdyM+7RSN23FsQ8mOHZOQtF71EMsDe8aH5MywJu
X-Received: by 2002:a17:90a:ba94:: with SMTP id t20mr11965212pjr.116.1564883497870;
        Sat, 03 Aug 2019 18:51:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564883497; cv=none;
        d=google.com; s=arc-20160816;
        b=aYu7T6Ta0vIiyafFKWlLovygvgf9j4y3jLKp3gRDeaEBUDGzwc7Wx72KYoq5CtvqSi
         rAoktr9UiT+emBWp3E3gAJz0CZ3RIm2AQT2y5UeaOmc4vru4SVTcJvmu4+MO4JHUGgRV
         dgFzNHDWbEn32to/3d8vzp9sAhNZY9ZiJPMtKabf+Vx1Q5IxmrQ6OBlHBqK6U0tqcrNZ
         tQ6WO3nD5b9onyDV8o2Do85eAnkYUZuLvwxQiMWSLAq5IVP9+rH/hgDm0YPt/0xJnuAK
         MXlnoU85JeOkLldqUIqRJyjQs9gJ3nJ3z2cUqC04L426J3mUnzzw02sxhBhAg87252on
         sEVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ql6euhQXhUgRSH8xN0SESmBnMIuoK9H8N8CBkDk7xqY=;
        b=pye9jS2yepZQb1Lh5NOGw+VoDuJMvd8kHEkE15bT8th30HB8AqtZa+9PWierH0CaMG
         TetlI+Go/Znvqv5nZ1iJO0hEcQCIOLrgFFCq/ozyYm13WPYXRNQ1tgM7K27CEWxWXX1v
         JwR/+sgs2l6/hWRFZcQVFHqYSIRojTH8VNxRRK70sk7NqEMcz/+hIJ+lmags5MdT7CZA
         +mjN5S4BVXzo+8gvkXu7zQEXHAFDLZRK9XhZE9egAVjohzoyLBSgO3Tt7dWL6WOPGg+4
         Vu24raBTLCoql7nES+ulNZrFjw1QkiL+hEyngmET4L/Shm0venKzZCp1E6gEGuHOMuuE
         TDdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id y3si9855514pjv.50.2019.08.03.18.51.37
        for <linux-mm@kvack.org>;
        Sat, 03 Aug 2019 18:51:37 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 946F47E53AD;
	Sun,  4 Aug 2019 11:51:36 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hu5fJ-00054z-LO; Sun, 04 Aug 2019 11:50:29 +1000
Date: Sun, 4 Aug 2019 11:50:29 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 02/24] shrinkers: use will_defer for GFP_NOFS sensitive
 shrinkers
Message-ID: <20190804015029.GS7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-3-david@fromorbit.com>
 <20190802152737.GB60893@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802152737.GB60893@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=clxzVxKhvR3UWeArRMgA:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 11:27:37AM -0400, Brian Foster wrote:
> On Thu, Aug 01, 2019 at 12:17:30PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > For shrinkers that currently avoid scanning when called under
> > GFP_NOFS contexts, conver them to use the new ->will_defer flag
> > rather than checking and returning errors during scans.
> > 
> > This makes it very clear that these shrinkers are not doing any work
> > because of the context limitations, not because there is no work
> > that can be done.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  drivers/staging/android/ashmem.c |  8 ++++----
> >  fs/gfs2/glock.c                  |  5 +++--
> >  fs/gfs2/quota.c                  |  6 +++---
> >  fs/nfs/dir.c                     |  6 +++---
> >  fs/super.c                       |  6 +++---
> >  fs/xfs/xfs_buf.c                 |  4 ++++
> >  fs/xfs/xfs_qm.c                  | 11 ++++++++---
> >  net/sunrpc/auth.c                |  5 ++---
> >  8 files changed, 30 insertions(+), 21 deletions(-)
> > 
> ...
> > diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> > index ca0849043f54..6e0f76532535 100644
> > --- a/fs/xfs/xfs_buf.c
> > +++ b/fs/xfs/xfs_buf.c
> > @@ -1680,6 +1680,10 @@ xfs_buftarg_shrink_count(
> >  {
> >  	struct xfs_buftarg	*btp = container_of(shrink,
> >  					struct xfs_buftarg, bt_shrinker);
> > +
> > +	if (!(sc->gfp_mask & __GFP_FS))
> > +		sc->will_defer = true;
> > +
> >  	return list_lru_shrink_count(&btp->bt_lru, sc);
> >  }
> 
> This hunk looks like a behavior change / bug fix..? The rest of the

Yeah, forgot to move that to the patch that fixes the accounting for
the xfs_buf cache later on in the series. Will fix.

-Dave.
-- 
Dave Chinner
david@fromorbit.com

