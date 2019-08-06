Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0AB9C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 12:29:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83F322070D
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 12:29:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83F322070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28C2C6B0003; Tue,  6 Aug 2019 08:29:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23D266B0005; Tue,  6 Aug 2019 08:29:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12D096B0006; Tue,  6 Aug 2019 08:29:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3DBD6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 08:29:52 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id r58so78787257qtb.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 05:29:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eZTXpcAjaWGYSkgbmHgFKRkWEgRbwhSgdOWLZgxAQlA=;
        b=TV/PNxWKMxUGlMqcxBOuCZh/DBin/xTvLH6NXimg/dSYxbaLxTc0jX8HHAR7wfDmu/
         bD4Suc6LX5GWD4XQOBywLFsqQLBi3XYWmp/gGNG6wkmromMcaQk/VhuFY0r6zyPWep88
         Fr/nRSKb88/26qitKd4su9lY48+Kt68M246oS1RePDVR1YvVjpQbsIXzJ4MhISkJSoDh
         F7IsPLAYGdUZNX59e7vkcnsvTI4ZVM8YybM4BErZi9qRz9wZezoO9APrb4DtBG0dMjDt
         sbenIEPc8TCRXPkVLEuxBmZWpM1/7duW0V35c4//n8ZuK6PV+FB6iQ9aAw17hOJXpLTW
         Kn2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW2wj32JVIIZQ1gcI+U/M+1IM8/4+x9fWI4RICFo2TELY/ZA/Jb
	jsbhu90IlzYjLRkM8iC6GRu9AAd+9NJqTt7kcXoBb+5ulJ/8oc6iU4YCyWMYZQm9hU5vyigmGnA
	GpfF31DrnP7QvWd6jS7ZIgZuBsEHdIpS2kPmNnGOkUDEdOQ2Q7Ex+JM8o0m38flTkig==
X-Received: by 2002:a0c:e78f:: with SMTP id x15mr2785659qvn.0.1565094592714;
        Tue, 06 Aug 2019 05:29:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzASefqNlC/lxshCcNIYikFjo7qMyIpHVLKuUSOAT4udLXMf5AiAGfbe9yZYPL96uXyQD+5
X-Received: by 2002:a0c:e78f:: with SMTP id x15mr2785620qvn.0.1565094592092;
        Tue, 06 Aug 2019 05:29:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565094592; cv=none;
        d=google.com; s=arc-20160816;
        b=rv60zN9MGZbvUXr0gkfpkN6Fep4ZVu5a3A2N46IOTM1UkFTQSPUycc/5JIjSTIkio9
         ulVBZCA9X1QLIi7gr53rKDpsk1JaMjKwwRdnQX6gWBAyBTOEjAcR9jUjpbkp/cA1f2r5
         8FLbEYx59jEkUw6jb/TrlPDudxJH/+jwZDLu7blVWar+C8cCIqhXxa0f7E0+nQ03kF8A
         +Qg/b0J+iP8C0y+CE3to2UpfLDLsSYmZD59Fo7re7/4swVKkk1d+bpy365o6ELo/PEqW
         +jbGQV3EEgNe3Zl+uMLT3UmDoy2SzwBjRTjPAlUoILDuZ9xdzskoWj9E0sTFqfgMEzSr
         ypAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eZTXpcAjaWGYSkgbmHgFKRkWEgRbwhSgdOWLZgxAQlA=;
        b=Wu0920cHap3vZn90v4rXjdVqRPc5fKXANuhofpr8aryrEMab3zfko5zp0gaJzx3tXD
         Zjig4UM3D+Gz8hwV16lQ28MNRiWNzinh0HbQpKg6bdUEBSD8L547pfkPMtmxOduxDxR9
         qsxTDwzGo0bqfaGLQboIrgJoVMog39HgXMhFnroUpeR5Mt3g523dJYW2lA99CzBVhe4B
         eEn6oPSLJMNaC/ANthP2RW+ZF1j1UKOa3mu56Wh/ffe+6NMeQeYN5+XWKGpn43W+5uk/
         zPi/8wC07WeSgN8Cj44AbK0FQyLX1la1iOyX0rm/h3jiICihK53nMkNnIeWAshGaILui
         Uakw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h67si49216298qke.108.2019.08.06.05.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 05:29:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 40F8D85539;
	Tue,  6 Aug 2019 12:29:51 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B6D6E608A7;
	Tue,  6 Aug 2019 12:29:50 +0000 (UTC)
Date: Tue, 6 Aug 2019 08:29:49 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 13/24] xfs: synchronous AIL pushing
Message-ID: <20190806122949.GB2979@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-14-david@fromorbit.com>
 <20190805175153.GC14760@bfoster>
 <20190805232132.GY7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805232132.GY7777@dread.disaster.area>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 06 Aug 2019 12:29:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 09:21:32AM +1000, Dave Chinner wrote:
> On Mon, Aug 05, 2019 at 01:51:53PM -0400, Brian Foster wrote:
> > On Thu, Aug 01, 2019 at 12:17:41PM +1000, Dave Chinner wrote:
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > Provide an interface to push the AIL to a target LSN and wait for
> > > the tail of the log to move past that LSN. This is used to wait for
> > > all items older than a specific LSN to either be cleaned (written
> > > back) or relogged to a higher LSN in the AIL. The primary use for
> > > this is to allow IO free inode reclaim throttling.
> > > 
> > > Factor the common AIL deletion code that does all the wakeups into a
> > > helper so we only have one copy of this somewhat tricky code to
> > > interface with all the wakeups necessary when the LSN of the log
> > > tail changes.
> > > 
> > > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > > ---
> > >  fs/xfs/xfs_inode_item.c | 12 +------
> > >  fs/xfs/xfs_trans_ail.c  | 69 +++++++++++++++++++++++++++++++++--------
> > >  fs/xfs/xfs_trans_priv.h |  6 +++-
> > >  3 files changed, 62 insertions(+), 25 deletions(-)
> > > 
> > ...
> > > diff --git a/fs/xfs/xfs_trans_ail.c b/fs/xfs/xfs_trans_ail.c
> > > index 6ccfd75d3c24..9e3102179221 100644
> > > --- a/fs/xfs/xfs_trans_ail.c
> > > +++ b/fs/xfs/xfs_trans_ail.c
> > > @@ -654,6 +654,37 @@ xfs_ail_push_all(
> > >  		xfs_ail_push(ailp, threshold_lsn);
> > >  }
> > >  
> > > +/*
> > > + * Push the AIL to a specific lsn and wait for it to complete.
> > > + */
> > > +void
> > > +xfs_ail_push_sync(
> > > +	struct xfs_ail		*ailp,
> > > +	xfs_lsn_t		threshold_lsn)
> > > +{
> > > +	struct xfs_log_item	*lip;
> > > +	DEFINE_WAIT(wait);
> > > +
> > > +	spin_lock(&ailp->ail_lock);
> > > +	while ((lip = xfs_ail_min(ailp)) != NULL) {
> > > +		prepare_to_wait(&ailp->ail_push, &wait, TASK_UNINTERRUPTIBLE);
> > > +		if (XFS_FORCED_SHUTDOWN(ailp->ail_mount) ||
> > > +		    XFS_LSN_CMP(threshold_lsn, lip->li_lsn) <= 0)
> > > +			break;
> > > +		/* XXX: cmpxchg? */
> > > +		while (XFS_LSN_CMP(threshold_lsn, ailp->ail_target) > 0)
> > > +			xfs_trans_ail_copy_lsn(ailp, &ailp->ail_target, &threshold_lsn);
> > 
> > Why the need to repeatedly copy the ail_target like this? If the push
> 
> It's a hack because the other updates are done unlocked and this
> doesn't contain the memroy barriers needed to make it correct
> and race free.
> 
> Hence the comment "XXX: cmpxchg" to ensure that:
> 
> 	a) we only ever move the target forwards;
> 	b) we resolve update races in an obvious, simple manner; and
> 	c) we can get rid of the possibly incorrect memory
> 	   barriers around this (unlocked) update.
> 
> RFC. WIP. :)
> 

Ack..

> > target only ever moves forward, we should only need to do this once at
> > the start of the function. In fact I'm kind of wondering why we can't
> > just call xfs_ail_push(). If we check the tail item after grabbing the
> > spin lock, we should be able to avoid any races with the waker, no?
> 
> I didn't use xfs_ail_push() because of having to prepare to wait
> between determining if the AIL is empty and checking if we need
> to update the target.
> 
> I also didn't want to affect the existing xfs_ail_push() as I was
> modifying the xfs_ail_push_sync() code to do what was needed.
> Eventually they can probably come back together, but for now I'm not
> 100% sure that the code is correct and race free.
> 

Ok, just chalk this up to general feedback around seeing if we can
improve the factoring between the several AIL pushing functions we now
have once this mechanism is working/correct.

> > > +void
> > > +xfs_ail_delete_finish(
> > > +	struct xfs_ail		*ailp,
> > > +	bool			do_tail_update) __releases(ailp->ail_lock)
> > > +{
> > > +	struct xfs_mount	*mp = ailp->ail_mount;
> > > +
> > > +	if (!do_tail_update) {
> > > +		spin_unlock(&ailp->ail_lock);
> > > +		return;
> > > +	}
> > > +
> > 
> > Hmm.. so while what we really care about here are tail updates, this
> > logic is currently driven by removing the min ail log item. That seems
> > like a lot of potential churn if we're waking the pusher on every object
> > written back covered by a single log record / checkpoint. Perhaps we
> > should implement a bit more coarse wakeup logic such as only when the
> > tail lsn actually changes, for example?
> 
> You mean the next patch?
> 

Yep, hadn't got to that point yet. FWIW, I think the next patch should
probably come before this one so there isn't a transient state with
whatever behavior results from this patch by itself.

Brian

> > FWIW, it also doesn't look like you've handled the case of relogged
> > items moving the tail forward anywhere that I can see, so we might be
> > missing some wakeups here. See xfs_trans_ail_update_bulk() for
> > additional AIL manipulation.
> 
> Good catch. That might be the race the next patch exposes :)
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

