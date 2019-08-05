Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31420C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 23:34:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC38E2070D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 23:34:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC38E2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B96F6B0006; Mon,  5 Aug 2019 19:34:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76A0C6B0007; Mon,  5 Aug 2019 19:34:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 680676B0008; Mon,  5 Aug 2019 19:34:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED746B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 19:34:36 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 28so3183750pgm.12
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 16:34:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XeGtFC+OIFwz0iCmetiIurOyAWFVKGjdylb2ybtOc9I=;
        b=sI29dxUngTUZ+n9d/pPB6b4zEtkpjvmOTM7reCcVGGW1NQtlP7o35iR/Wy451Gq3wT
         j2+Y5+j4q20Qe2Rdg/eFLa3FBrIxDC80Pzel/tFcFFqs5SvfA8DPlx3IRCkjxRNeoN06
         n6SN6mkg37Ga8hRiNgSMIkxo2nzrdkXNFDo7jyIxkIk4oLFnOcAv/XI3pBuR0pL3A8Gu
         PWlarDVDdZYlw7uIBO4oO5HVo4Qs8+kkxrDKx6o9nAcI06gO1Yb6vu8vBKVW6OYJ8E0T
         HZRwzEZJjlPcQjAfr11UW5wTX4HJDlmQJqSnB8K1f6xdA31+EQT9xzxEIKKQ8/+WRN/x
         TI2A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAW/O4gNoKGF7kPhVyGM/zUAe4kUti8sCLg4PyxPtVZ/KBlHb+2h
	vU7hQLL5LowYQRtV/lfLS6fexzg3CnigaDqUVgJxvcNKDTegpSFEX3OlcNPdVK+qoKPGd2D6W9B
	7xfTzE7iznaj+t5ykp5LX5vKDzWqlZkdVcWpzFQnjTIfeDPBmuv1lu2BQhoeGvn0=
X-Received: by 2002:a17:902:b698:: with SMTP id c24mr288394pls.28.1565048075852;
        Mon, 05 Aug 2019 16:34:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzD2g837G3dkUYKHFDhMdrk9nnMy/+9632nmNJNteO6UxL4ur+nRGNFq5KzyItSBxbkIr81
X-Received: by 2002:a17:902:b698:: with SMTP id c24mr288352pls.28.1565048075085;
        Mon, 05 Aug 2019 16:34:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565048075; cv=none;
        d=google.com; s=arc-20160816;
        b=dA5x1Z5oXlqZxZRh89gW2TO4VPHrHKVwyClvkQTI9FfNZTjU450V6lFHuHqMoyfh/Q
         1Ypr7zR5BPqA3O5qHehvxAhP6KU4pi1O0HLHp0+LDDIaqYfxq05PL3qCY03fqQ4GR+wC
         sP+eambs5JKQcB+FVsSIctSzbUKL6s7AmQuhgWL4aOLlK00pafU/IiYb735DBCkk0X8M
         mj3GdchE+xXY5ttQcsZ0lXPubVXYWv9EivPY7L3w0dZM43kbS2SiN7Crm9VV8gYq+xhJ
         AZLLMQ3g4sqLA9fkOHmPT6Q0z0Q32Nk2bfcgypiJ0YyCQOURE48dCq7M/SUyXKyUjbVk
         4m4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XeGtFC+OIFwz0iCmetiIurOyAWFVKGjdylb2ybtOc9I=;
        b=AWnItgGTxHelSNqJu7VD6Vleze9KkOY1bbZvP7XH3duFfGDFlu6vMzTdFkaIf292Cr
         z4CR7MTrCsgaTa6tqusS6saOWFt4HKWHStaNXKgslIUYj9Fs3KpPotmS2p76lmOB1UMn
         8NRotP99ZPvFsUFkcaChg4NEBvxfoHq2rkgULf3uWJiaTfE7q5x7YlbWPx35VkZFNhdV
         n9Y+h40kjVlFhLpaZRBQ10BAZYX5g1eHqWJHCMnzM6EmKTT94re3jpWDDhipR3UEbou1
         gqx1v0Qp+7xoQr3os01+wgBTrD6SwguAHhlWHcj5hW3cx6PrQamMQme+iNO0V18ycvIH
         squA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id 138si44900335pfy.77.2019.08.05.16.34.34
        for <linux-mm@kvack.org>;
        Mon, 05 Aug 2019 16:34:35 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id AD19F43DFB6;
	Tue,  6 Aug 2019 09:34:33 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1humTm-0005Ov-Om; Tue, 06 Aug 2019 09:33:26 +1000
Date: Tue, 6 Aug 2019 09:33:26 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 15/24] xfs: eagerly free shadow buffers to reduce CIL
 footprint
Message-ID: <20190805233326.GA7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-16-david@fromorbit.com>
 <20190805180300.GE14760@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805180300.GE14760@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=tOhbtF5n6OYojUpaYb4A:9
	a=rpP84s9rEpv7uqfw:21 a=V6fs5rSqgyewu9bL:21 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 02:03:01PM -0400, Brian Foster wrote:
> On Thu, Aug 01, 2019 at 12:17:43PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > The CIL can pin a lot of memory and effectively defines the lower
> > free memory boundary of operation for XFS. The way we hang onto
> > log item shadow buffers "just in case" effectively doubles the
> > memory footprint of the CIL for dubious reasons.
> > 
> > That is, we hang onto the old shadow buffer in case the next time
> > we log the item it will fit into the shadow buffer and we won't have
> > to allocate a new one. However, we only ever tend to grow dirty
> > objects in the CIL through relogging, so once we've allocated a
> > larger buffer the old buffer we set as a shadow buffer will never
> > get reused as the amount we log never decreases until the item is
> > clean. And then for buffer items we free the log item and the shadow
> > buffers, anyway. Inode items will hold onto their shadow buffer
> > until they are reclaimed - this could double the inode's memory
> > footprint for it's lifetime...
> > 
> > Hence we should just free the old log item buffer when we replace it
> > with a new shadow buffer rather than storing it for later use. It's
> > not useful, get rid of it as early as possible.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  fs/xfs/xfs_log_cil.c | 7 +++----
> >  1 file changed, 3 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/xfs/xfs_log_cil.c b/fs/xfs/xfs_log_cil.c
> > index fa5602d0fd7f..1863a9bdf4a9 100644
> > --- a/fs/xfs/xfs_log_cil.c
> > +++ b/fs/xfs/xfs_log_cil.c
> > @@ -238,9 +238,7 @@ xfs_cil_prepare_item(
> >  	/*
> >  	 * If there is no old LV, this is the first time we've seen the item in
> >  	 * this CIL context and so we need to pin it. If we are replacing the
> > -	 * old_lv, then remove the space it accounts for and make it the shadow
> > -	 * buffer for later freeing. In both cases we are now switching to the
> > -	 * shadow buffer, so update the the pointer to it appropriately.
> > +	 * old_lv, then remove the space it accounts for and free it.
> >  	 */
> 
> The comment above xlog_cil_alloc_shadow_bufs() needs a similar update
> around how we handle the old buffer when the shadow buffer is used.

*nod*

> 
> >  	if (!old_lv) {
> >  		if (lv->lv_item->li_ops->iop_pin)
> > @@ -251,7 +249,8 @@ xfs_cil_prepare_item(
> >  
> >  		*diff_len -= old_lv->lv_bytes;
> >  		*diff_iovecs -= old_lv->lv_niovecs;
> > -		lv->lv_item->li_lv_shadow = old_lv;
> > +		kmem_free(old_lv);
> > +		lv->lv_item->li_lv_shadow = NULL;
> >  	}
> 
> So IIUC this is the case where we allocated a shadow buffer, the item
> was already pinned (so old_lv is still around) but we ended up using the
> shadow buffer for this relog. Instead of keeping the old buffer around
> as a new shadow, we toss it. That makes sense, but if the objective is
> to not leave dangling shadow buffers around as such, what about the case
> where we allocated a shadow buffer but didn't end up using it because
> old_lv was reusable? It looks like we still keep the shadow buffer
> around in that scenario with a similar lifetime as the swapout scenario
> this patch removes. Hm?

Of the top of my head, we shouldn't allocate a new shadow buffer in
that case (see xlog_cil_alloc_shadow_bufs()). i.e. we check up front
if the formatted size of the item will fit in the existing buffer,
and if it does we do not allocate a new shadow buffer as we just
reuse the existing one. SO we should only have to free a shadow
buffer when we switch them, not when we overwrite.

I'll recheck this, but I'm pretty sure overwrite won't leave a
shadow buffer around.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

