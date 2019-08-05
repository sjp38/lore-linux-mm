Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2953BC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:53:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D34FC20880
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:53:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D34FC20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7311A6B0005; Mon,  5 Aug 2019 13:53:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E1FC6B0006; Mon,  5 Aug 2019 13:53:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D0DF6B0007; Mon,  5 Aug 2019 13:53:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 392706B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 13:53:30 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x17so73323791qkf.14
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 10:53:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jXhjQFJ0ZOzE3bKwin8aUxHfcUkaf9rAB7IY5UBlNj4=;
        b=KmChhsyF7r3svJxXKdum/iIeajUvMpKSKjQSgn9msddw1YPgf6yvgkMLaG1dNC11kO
         VG3HcpgXxGmmh8PPseXBbbzhzmxEKLmRP4w6ALrat5Mtwdch2xbh/J49ZZKpti4IBfrL
         M4Ilz11ioCrE3BHV7zW/wX8sKFR6TDejtTfV9Un57g2Lxbb5dKwJdS2+6BcZdc3aECTa
         tqNQwjP+9DKKEI2lXEVChd15TNZRCqvkrnTcL+6m2h+00uoBk0hwZ4KOshW1XUwtoxfm
         ia3P4fD2zjwf96rvZUmZL4i/VASLNlh+M+DQV9d2VUyY/K8A2ssMBDGiW9mD0PUmsoBn
         dHuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX8ZWz7Orz6MLDEju38tpBCvc4mLmU2gIa/RbRlY4feVCdwO5mJ
	wBLDF3XZ6d4Cx+/bBm/sg9+2RquCuDUEYkHIENcVS7gt2dL6ur0TvKaZydDZi/aEK+m7YdAV/RY
	wgyuoDBKbR544xMxDnY4nYJlFEQgCrHasEo2l63zR582/FpwHYOQHdMjRGqD/ojgiYA==
X-Received: by 2002:ae9:f107:: with SMTP id k7mr39035730qkg.215.1565027610021;
        Mon, 05 Aug 2019 10:53:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXdDPoB8yEsXGAE3wPwCr0FA9EkgNwy7u9KkUNDeB8+8j6bdTsK+lvPmske+d5gZ6u6KkM
X-Received: by 2002:ae9:f107:: with SMTP id k7mr39035686qkg.215.1565027609327;
        Mon, 05 Aug 2019 10:53:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565027609; cv=none;
        d=google.com; s=arc-20160816;
        b=dilLLnLsm/5Y+tZdt2HLn7e5OxEoYQeQBh0n0tXrvsXlmGdINn38xgz9thEnUikY3W
         PBGX1+waf+U7LHiwGbIjmz7HWw0R+3chRWPXPN8x9b/v0QQQECQUC3W63QPuo22XzgNK
         nfv5S+HWfrFV8rQ727bG2O+n2Jql0DgDaNmBVA+9rQzL/QQgTzRiUitoZzGsA/Lq3vYj
         jMuzOfSU4DzCLww7kcoCbfacUy9dSuDpfXEz9EUD4ZP0r+MzKiYFtdEvUt8pyTHL3TNp
         49iKI9WFLEUWpeJyz9FInDqeixUmMzMoO+6yk/jUaTTuy/I9DyW0edq5Nbg+t1I5WEba
         43qQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jXhjQFJ0ZOzE3bKwin8aUxHfcUkaf9rAB7IY5UBlNj4=;
        b=hFdNjVuMMTk9lsz6XFrPzKFGvslzH2fu7AJ2dNRQJ3EllYPp7smR2ctU/XK6EVUBm7
         N/hPgblkxLwH5+ITa/tiwpQZ1PUBTO/n9XlK0yKqk+u/zU3He1iqTwRoHyl7e+tTo1vM
         Weg8IcH7wpFZTBa4exgsi3hit4ZlRYT1ccsby1mKppXyY/kQkUDyDzNGhaYpy1tIEQdv
         Rx34jSxMSylpRtj0vRk2NCEJIXvuGUJ+a6gvktebFIXP14ddwA+jLak366AOWHb9JySW
         SrCjjX48U/pI2Qo4JMyyI8IrJHvRjAdhztb9p5Muf+qoImFfjO1UyAaTBlBEjhTh8tcC
         Ea6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w6si25791509qkj.178.2019.08.05.10.53.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 10:53:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 841A14E8AC;
	Mon,  5 Aug 2019 17:53:28 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 05BE85D704;
	Mon,  5 Aug 2019 17:53:27 +0000 (UTC)
Date: Mon, 5 Aug 2019 13:53:26 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 14/24] xfs: tail updates only need to occur when LSN
 changes
Message-ID: <20190805175325.GD14760@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-15-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-15-david@fromorbit.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 05 Aug 2019 17:53:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 12:17:42PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> We currently wake anything waiting on the log tail to move whenever
> the log item at the tail of the log is removed. Historically this
> was fine behaviour because there were very few items at any given
> LSN. But with delayed logging, there may be thousands of items at
> any given LSN, and we can't move the tail until they are all gone.
> 
> Hence if we are removing them in near tail-first order, we might be
> waking up processes waiting on the tail LSN to change (e.g. log
> space waiters) repeatedly without them being able to make progress.
> This also occurs with the new sync push waiters, and can result in
> thousands of spurious wakeups every second when under heavy direct
> reclaim pressure.
> 
> To fix this, check that the tail LSN has actually changed on the
> AIL before triggering wakeups. This will reduce the number of
> spurious wakeups when doing bulk AIL removal and make this code much
> more efficient.
> 
> XXX: occasionally get a temporary hang in xfs_ail_push_sync() with
> this change - log force from log worker gets things moving again.
> Only happens under extreme memory pressure - possibly push racing
> with a tail update on an empty log. Needs further investigation.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---

Ok, this addresses the wakeup granularity issue mentioned in the
previous patch. Note that I was kind of wondering why we wouldn't base
this on the l_tail_lsn update in xlog_assign_tail_lsn_locked() as
opposed to the current approach.

For example, xlog_assign_tail_lsn_locked() could simply check the
current min item against the current l_tail_lsn before it does the
assignment and use that to trigger tail change events. If we wanted to
also filter out the other wakeups (as this patch does) then we could
just pass a bool pointer or something that returns whether the tail
actually changed.

Brian

>  fs/xfs/xfs_inode_item.c | 18 +++++++++++++-----
>  fs/xfs/xfs_trans_ail.c  | 37 ++++++++++++++++++++++++++++---------
>  fs/xfs/xfs_trans_priv.h |  4 ++--
>  3 files changed, 43 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/xfs/xfs_inode_item.c b/fs/xfs/xfs_inode_item.c
> index 7b942a63e992..16a7d6f752c9 100644
> --- a/fs/xfs/xfs_inode_item.c
> +++ b/fs/xfs/xfs_inode_item.c
> @@ -731,19 +731,27 @@ xfs_iflush_done(
>  	 * holding the lock before removing the inode from the AIL.
>  	 */
>  	if (need_ail) {
> -		bool			mlip_changed = false;
> +		xfs_lsn_t	tail_lsn = 0;
>  
>  		/* this is an opencoded batch version of xfs_trans_ail_delete */
>  		spin_lock(&ailp->ail_lock);
>  		list_for_each_entry(blip, &tmp, li_bio_list) {
>  			if (INODE_ITEM(blip)->ili_logged &&
> -			    blip->li_lsn == INODE_ITEM(blip)->ili_flush_lsn)
> -				mlip_changed |= xfs_ail_delete_one(ailp, blip);
> -			else {
> +			    blip->li_lsn == INODE_ITEM(blip)->ili_flush_lsn) {
> +				/*
> +				 * xfs_ail_delete_finish() only cares about the
> +				 * lsn of the first tail item removed, any others
> +				 * will be at the same or higher lsn so we just
> +				 * ignore them.
> +				 */
> +				xfs_lsn_t lsn = xfs_ail_delete_one(ailp, blip);
> +				if (!tail_lsn && lsn)
> +					tail_lsn = lsn;
> +			} else {
>  				xfs_clear_li_failed(blip);
>  			}
>  		}
> -		xfs_ail_delete_finish(ailp, mlip_changed);
> +		xfs_ail_delete_finish(ailp, tail_lsn);
>  	}
>  
>  	/*
> diff --git a/fs/xfs/xfs_trans_ail.c b/fs/xfs/xfs_trans_ail.c
> index 9e3102179221..00d66175f41a 100644
> --- a/fs/xfs/xfs_trans_ail.c
> +++ b/fs/xfs/xfs_trans_ail.c
> @@ -108,17 +108,25 @@ xfs_ail_next(
>   * We need the AIL lock in order to get a coherent read of the lsn of the last
>   * item in the AIL.
>   */
> +static xfs_lsn_t
> +__xfs_ail_min_lsn(
> +	struct xfs_ail		*ailp)
> +{
> +	struct xfs_log_item	*lip = xfs_ail_min(ailp);
> +
> +	if (lip)
> +		return lip->li_lsn;
> +	return 0;
> +}
> +
>  xfs_lsn_t
>  xfs_ail_min_lsn(
>  	struct xfs_ail		*ailp)
>  {
> -	xfs_lsn_t		lsn = 0;
> -	struct xfs_log_item	*lip;
> +	xfs_lsn_t		lsn;
>  
>  	spin_lock(&ailp->ail_lock);
> -	lip = xfs_ail_min(ailp);
> -	if (lip)
> -		lsn = lip->li_lsn;
> +	lsn = __xfs_ail_min_lsn(ailp);
>  	spin_unlock(&ailp->ail_lock);
>  
>  	return lsn;
> @@ -779,12 +787,20 @@ xfs_trans_ail_update_bulk(
>  	}
>  }
>  
> -bool
> +/*
> + * Delete one log item from the AIL.
> + *
> + * If this item was at the tail of the AIL, return the LSN of the log item so
> + * that we can use it to check if the LSN of the tail of the log has moved
> + * when finishing up the AIL delete process in xfs_ail_delete_finish().
> + */
> +xfs_lsn_t
>  xfs_ail_delete_one(
>  	struct xfs_ail		*ailp,
>  	struct xfs_log_item	*lip)
>  {
>  	struct xfs_log_item	*mlip = xfs_ail_min(ailp);
> +	xfs_lsn_t		lsn = lip->li_lsn;
>  
>  	trace_xfs_ail_delete(lip, mlip->li_lsn, lip->li_lsn);
>  	xfs_ail_delete(ailp, lip);
> @@ -792,17 +808,20 @@ xfs_ail_delete_one(
>  	clear_bit(XFS_LI_IN_AIL, &lip->li_flags);
>  	lip->li_lsn = 0;
>  
> -	return mlip == lip;
> +	if (mlip == lip)
> +		return lsn;
> +	return 0;
>  }
>  
>  void
>  xfs_ail_delete_finish(
>  	struct xfs_ail		*ailp,
> -	bool			do_tail_update) __releases(ailp->ail_lock)
> +	xfs_lsn_t		old_lsn) __releases(ailp->ail_lock)
>  {
>  	struct xfs_mount	*mp = ailp->ail_mount;
>  
> -	if (!do_tail_update) {
> +	/* if the tail lsn hasn't changed, don't do updates or wakeups. */
> +	if (!old_lsn || old_lsn == __xfs_ail_min_lsn(ailp)) {
>  		spin_unlock(&ailp->ail_lock);
>  		return;
>  	}

> diff --git a/fs/xfs/xfs_trans_priv.h b/fs/xfs/xfs_trans_priv.h
> index 5ab70b9b896f..db589bb7468d 100644
> --- a/fs/xfs/xfs_trans_priv.h
> +++ b/fs/xfs/xfs_trans_priv.h
> @@ -92,8 +92,8 @@ xfs_trans_ail_update(
>  	xfs_trans_ail_update_bulk(ailp, NULL, &lip, 1, lsn);
>  }
>  
> -bool xfs_ail_delete_one(struct xfs_ail *ailp, struct xfs_log_item *lip);
> -void xfs_ail_delete_finish(struct xfs_ail *ailp, bool do_tail_update)
> +xfs_lsn_t xfs_ail_delete_one(struct xfs_ail *ailp, struct xfs_log_item *lip);
> +void xfs_ail_delete_finish(struct xfs_ail *ailp, xfs_lsn_t old_lsn)
>  			__releases(ailp->ail_lock);
>  void xfs_trans_ail_delete(struct xfs_ail *ailp, struct xfs_log_item *lip,
>  		int shutdown_type);
> -- 
> 2.22.0
> 

