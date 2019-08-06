Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FA56C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 12:57:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 501E2214C6
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 12:57:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 501E2214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5E4D6B0005; Tue,  6 Aug 2019 08:57:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E10046B0006; Tue,  6 Aug 2019 08:57:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD6986B0007; Tue,  6 Aug 2019 08:57:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABB746B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 08:57:31 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r58so78849453qtb.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 05:57:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7avQSJ2zsXqe65KhFbaXBPV6ib80y1QqGCQgHxymAyA=;
        b=tY/PRc/99xDYGQrAZfWY12p9QIriYpzoVcNFOdg/xdgfPPPzy8/tArY4M78Ki+HmBP
         YAL0H/5pqJcdY6j3MxYgdF2HOH/u83Sv9dMv3ehjzF40fiDVkz8tRtmkObP642p+mbys
         AFA134Z1uGxT9pBUQ4G6naEMtssunBblCJFko7qLqr5gyJimirDo5ayxIHRXfmbSK+ZI
         jRY1Dbt6jzFvFt7MS49/TOIVTrUpGcFcoE1I8d/5pNwnYFBtfUnoeUpDH5OmNreyCj13
         Xjsbnpin8++I256aNukFxSzSa9K6Od4WBgvQH/O+PPQUONoZSMyLLN7WxNAHryjw+e/t
         2HmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXg4eNdpyyWlwJJhJWEwKYdGNIozswJ1kblbIzWkiZOqFiCDbno
	KlEdJxgM0F90AionvB/+foABFISYf1N83fmh1jSldqwuz1ExQ9HVXVw0Ww59cN8ojI/rilif4t6
	NbE4T8n0ipngudWiATalw5Wd2gUWmuIojXtn+sDtYpisbwgSvGnxDC3PTKAE8c+ViNg==
X-Received: by 2002:ac8:3118:: with SMTP id g24mr2855597qtb.390.1565096251472;
        Tue, 06 Aug 2019 05:57:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYIUf9FZZHMyDPgw0nxa/a7CqQAz+Ik3laCtb3gx9tjnggjm3EPsuj5e/sbLGTS1WDxqUG
X-Received: by 2002:ac8:3118:: with SMTP id g24mr2855562qtb.390.1565096250812;
        Tue, 06 Aug 2019 05:57:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565096250; cv=none;
        d=google.com; s=arc-20160816;
        b=aJkojBOf1Z9q2PZ0GT8XPPgp0WCwgfiACUKpe+gu7sygge0pSpP/ovbva7p+szxlbb
         BukD289q0fEzwcPdxaMmEuJ8ZLik/MWZ3iTD8qWMiTQM/M/HUii8ecjNSX7a/DemQbdz
         YuiUI1Z9QJslY7sEP/WsVISBx190z2YM5isi36VZsoDxaOpE+lJ8hxOY9SKBudn/TUwu
         DNHNffL3QyWFo1SZitm0qlDAWSkLXmcn+fzCkZBJlH8Wht/BXs2cE7BjrbQz6ZVp/Olg
         wYOZEfp3/XvTASTPZ+SS/n2pETruZbkrUaEH4lS5u6DPbTa+nkUUC5NZEmr/p2Hymudd
         rnhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7avQSJ2zsXqe65KhFbaXBPV6ib80y1QqGCQgHxymAyA=;
        b=Z3VVusHaNWR7UwaTNqnSsAW9c0ZXZXLYOH0beos+6aj4RUVK1swZOlzqeh+YPHbgf3
         CiOKrIDrRagxb29aQfKAKHxJkyRKG/8c6DRXCYSOlV2jxnDOyoQAAhOFrV2XMdaNUXVm
         642GEXqwjpH6jfn6VW426gLOoBnrWl8dGIpE5/UzZ/4NTdI9CmNewAD6higs1ZT8pUYl
         XcPP5tbPZ7ELKWz+Q88oxQnN988u5mYo7ljEHzY3z+KXa76KDrxHr5xaTmGN5vTReWN7
         BZlHf65m/4objkQGxC8NG+ORO7oY+EyXqzxOALy9JIFAob7OcXUtLA+tS4kYQii/ew2e
         r4tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w123si12637380qka.228.2019.08.06.05.57.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 05:57:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 03C8D30031AD;
	Tue,  6 Aug 2019 12:57:30 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 78A7C5D784;
	Tue,  6 Aug 2019 12:57:29 +0000 (UTC)
Date: Tue, 6 Aug 2019 08:57:27 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 15/24] xfs: eagerly free shadow buffers to reduce CIL
 footprint
Message-ID: <20190806125727.GD2979@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-16-david@fromorbit.com>
 <20190805180300.GE14760@bfoster>
 <20190805233326.GA7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805233326.GA7777@dread.disaster.area>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Tue, 06 Aug 2019 12:57:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 09:33:26AM +1000, Dave Chinner wrote:
> On Mon, Aug 05, 2019 at 02:03:01PM -0400, Brian Foster wrote:
> > On Thu, Aug 01, 2019 at 12:17:43PM +1000, Dave Chinner wrote:
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > The CIL can pin a lot of memory and effectively defines the lower
> > > free memory boundary of operation for XFS. The way we hang onto
> > > log item shadow buffers "just in case" effectively doubles the
> > > memory footprint of the CIL for dubious reasons.
> > > 
> > > That is, we hang onto the old shadow buffer in case the next time
> > > we log the item it will fit into the shadow buffer and we won't have
> > > to allocate a new one. However, we only ever tend to grow dirty
> > > objects in the CIL through relogging, so once we've allocated a
> > > larger buffer the old buffer we set as a shadow buffer will never
> > > get reused as the amount we log never decreases until the item is
> > > clean. And then for buffer items we free the log item and the shadow
> > > buffers, anyway. Inode items will hold onto their shadow buffer
> > > until they are reclaimed - this could double the inode's memory
> > > footprint for it's lifetime...
> > > 
> > > Hence we should just free the old log item buffer when we replace it
> > > with a new shadow buffer rather than storing it for later use. It's
> > > not useful, get rid of it as early as possible.
> > > 
> > > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > > ---
> > >  fs/xfs/xfs_log_cil.c | 7 +++----
> > >  1 file changed, 3 insertions(+), 4 deletions(-)
> > > 
> > > diff --git a/fs/xfs/xfs_log_cil.c b/fs/xfs/xfs_log_cil.c
> > > index fa5602d0fd7f..1863a9bdf4a9 100644
> > > --- a/fs/xfs/xfs_log_cil.c
> > > +++ b/fs/xfs/xfs_log_cil.c
> > > @@ -238,9 +238,7 @@ xfs_cil_prepare_item(
> > >  	/*
> > >  	 * If there is no old LV, this is the first time we've seen the item in
> > >  	 * this CIL context and so we need to pin it. If we are replacing the
> > > -	 * old_lv, then remove the space it accounts for and make it the shadow
> > > -	 * buffer for later freeing. In both cases we are now switching to the
> > > -	 * shadow buffer, so update the the pointer to it appropriately.
> > > +	 * old_lv, then remove the space it accounts for and free it.
> > >  	 */
> > 
> > The comment above xlog_cil_alloc_shadow_bufs() needs a similar update
> > around how we handle the old buffer when the shadow buffer is used.
> 
> *nod*
> 
> > 
> > >  	if (!old_lv) {
> > >  		if (lv->lv_item->li_ops->iop_pin)
> > > @@ -251,7 +249,8 @@ xfs_cil_prepare_item(
> > >  
> > >  		*diff_len -= old_lv->lv_bytes;
> > >  		*diff_iovecs -= old_lv->lv_niovecs;
> > > -		lv->lv_item->li_lv_shadow = old_lv;
> > > +		kmem_free(old_lv);
> > > +		lv->lv_item->li_lv_shadow = NULL;
> > >  	}
> > 
> > So IIUC this is the case where we allocated a shadow buffer, the item
> > was already pinned (so old_lv is still around) but we ended up using the
> > shadow buffer for this relog. Instead of keeping the old buffer around
> > as a new shadow, we toss it. That makes sense, but if the objective is
> > to not leave dangling shadow buffers around as such, what about the case
> > where we allocated a shadow buffer but didn't end up using it because
> > old_lv was reusable? It looks like we still keep the shadow buffer
> > around in that scenario with a similar lifetime as the swapout scenario
> > this patch removes. Hm?
> 
> Of the top of my head, we shouldn't allocate a new shadow buffer in
> that case (see xlog_cil_alloc_shadow_bufs()). i.e. we check up front
> if the formatted size of the item will fit in the existing buffer,
> and if it does we do not allocate a new shadow buffer as we just
> reuse the existing one. SO we should only have to free a shadow
> buffer when we switch them, not when we overwrite.
> 

We have such a check in xlog_cil_insert_format_items(), so we'd reuse
->li_lv if it will suffice even if we have a shadow buffer available.

> I'll recheck this, but I'm pretty sure overwrite won't leave a
> shadow buffer around.
> 

But before that we have the following logic:

static void
xlog_cil_alloc_shadow_bufs(
	...

	if (!lip->li_lv_shadow ||
	    buf_size > lip->li_lv_shadow->lv_size) {
		...
		lv = kmem_alloc_large(buf_size, KM_SLEEP | KM_NOFS);
		...
		lip->li_lv_shadow = lv;
	} else {
		<reuse shadow>
	}
	...
}

... which always allocates a shadow buffer if one doesn't exist. We
don't look at the currently used (lip->li_lv) buffer at all here. IIUC,
that has to do with the TOCTOU race described in the big comment above
the function.. hm?

Brian

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

