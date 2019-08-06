Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C011CC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 12:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DD6720B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 12:53:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DD6720B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 142BE6B0005; Tue,  6 Aug 2019 08:53:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F3E16B0006; Tue,  6 Aug 2019 08:53:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F23696B0007; Tue,  6 Aug 2019 08:53:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D1B146B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 08:53:25 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x1so75527876qkn.6
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 05:53:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=B09XLpKygMgLhCX8OgfIxieG3VuzvG7n23Epd72uYks=;
        b=C8Y6aVPvZrh0BkL46lghNtALGgbqJeFQVYrvZE+mQia4S8F/3loOeY3aLF8wlrhqky
         5jF1Pc3EWWec68dc45RPtoMhsazfGYb04oGL5kpxxDL/jJH3qJyyo/5ZGrZd1lqB7kXj
         zirrXPNkuzU8iWL831Uc/ySogKp/XnDOR4BwuisaIqi6fSUR65esYABJOBbp5stmL4M6
         ehvOXLICVSOunDx0KOJVI38O+QDlCaVtuLpQCXb/wTm1c3wBCGBmoyZDs7FslaXN+oQC
         mUcNOTbLV/n1ZmrtIFluJCIqxn2JhIMQszp2iSIIxiGDVFo6MuHx0fwM5PatWOvtHDSD
         zOvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWOt4zAoW5d2PvG3ms+LFuSPGVp6yphq988Wz2WpXL/HZPD4CLv
	Q6fJoXByaT14cS7I/34iVIh2dry8YiaURj8rpy1W3ryNYt1ZznGf/2vP4R75t01fpDki+sDi263
	gdwCKH15M+YkwvyTIGpAyOvNEPhodTELpKolDBmCkoMKnT/W/Bh1aJhRlyrt2NfUPBQ==
X-Received: by 2002:ac8:38a8:: with SMTP id f37mr2852056qtc.150.1565096005527;
        Tue, 06 Aug 2019 05:53:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9FEFwQzAWfczS+rBehZm5sHA5KbDl6lVZH3Ehp5+K6oaap8zBSAshu5BditYQ5r1PP4SF
X-Received: by 2002:ac8:38a8:: with SMTP id f37mr2852022qtc.150.1565096004855;
        Tue, 06 Aug 2019 05:53:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565096004; cv=none;
        d=google.com; s=arc-20160816;
        b=A/Oe7rJGH0Ctq0HUQZH24ic1RP7PcaNwm+WPSgxeeNLW2O3QRR+OyjAT1EukTQ/5BP
         qDT+CjffRwf4V1elHPNhOWri1d9l9xPq4Cy1tHmVuqpCZwiGdBHdjoY/q0gXTv+aXZwk
         b35UYYKfUgnGzS73dOTCKo6i9IffdDy7v29whbj4Mr3h8lWMbY16aDb14rToBA4DM5MP
         RgHYmqhiW3oyvTxtjjY/olte94pywYzNML30atATHWB49+4VslJmoEv3kpOlItB9SnVC
         g8tZ5i2n2IveiLzIQtwFjGtgYcgOraW9GMmdX7HFOy0apJOgC6Jrxh7BFTFARqOoDd8C
         E8kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=B09XLpKygMgLhCX8OgfIxieG3VuzvG7n23Epd72uYks=;
        b=MXlxboZzSVmJOohe/wkIp78cf2+2qf4UaWM4lixZfRePuSxpz5NhcHt6DPaQRfM/SU
         +OtME1TE4VN/6tvSiV6SoSaBN+GL1bg7MekQdlw2Z4YdBm/FoTKiOPLFh7SXMizBLqfD
         x/yGo/BL4/KxH/ZmQzviIQrALeD2GoXz7W8dxieOKIj1eHfCDUzZ/i9lnfAjWOxfG2K3
         s/fjhpa9YBXWifjFKAXFtUSpzYi3Bp5ZhoML1LBIylfFQ/+b/JE2KldE6QTtjrUGoz3d
         MWvPHS2AuUvr96k0X8nDbJXbeP0EWYlxQ4BlZTbI43BF9GeAj692VSf4Y0dIUPNV2HDC
         a0TA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s52si51647915qts.399.2019.08.06.05.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 05:53:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 197BC30A542E;
	Tue,  6 Aug 2019 12:53:24 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8E8FC6092D;
	Tue,  6 Aug 2019 12:53:23 +0000 (UTC)
Date: Tue, 6 Aug 2019 08:53:21 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 14/24] xfs: tail updates only need to occur when LSN
 changes
Message-ID: <20190806125321.GC2979@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-15-david@fromorbit.com>
 <20190805175325.GD14760@bfoster>
 <20190805232826.GZ7777@dread.disaster.area>
 <20190806053338.GD7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806053338.GD7777@dread.disaster.area>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 06 Aug 2019 12:53:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 03:33:38PM +1000, Dave Chinner wrote:
> On Tue, Aug 06, 2019 at 09:28:26AM +1000, Dave Chinner wrote:
> > On Mon, Aug 05, 2019 at 01:53:26PM -0400, Brian Foster wrote:
> > > On Thu, Aug 01, 2019 at 12:17:42PM +1000, Dave Chinner wrote:
> > > > From: Dave Chinner <dchinner@redhat.com>
> > > > 
> > > > We currently wake anything waiting on the log tail to move whenever
> > > > the log item at the tail of the log is removed. Historically this
> > > > was fine behaviour because there were very few items at any given
> > > > LSN. But with delayed logging, there may be thousands of items at
> > > > any given LSN, and we can't move the tail until they are all gone.
> > > > 
> > > > Hence if we are removing them in near tail-first order, we might be
> > > > waking up processes waiting on the tail LSN to change (e.g. log
> > > > space waiters) repeatedly without them being able to make progress.
> > > > This also occurs with the new sync push waiters, and can result in
> > > > thousands of spurious wakeups every second when under heavy direct
> > > > reclaim pressure.
> > > > 
> > > > To fix this, check that the tail LSN has actually changed on the
> > > > AIL before triggering wakeups. This will reduce the number of
> > > > spurious wakeups when doing bulk AIL removal and make this code much
> > > > more efficient.
> > > > 
> > > > XXX: occasionally get a temporary hang in xfs_ail_push_sync() with
> > > > this change - log force from log worker gets things moving again.
> > > > Only happens under extreme memory pressure - possibly push racing
> > > > with a tail update on an empty log. Needs further investigation.
> > > > 
> > > > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > > > ---
> > > 
> > > Ok, this addresses the wakeup granularity issue mentioned in the
> > > previous patch. Note that I was kind of wondering why we wouldn't base
> > > this on the l_tail_lsn update in xlog_assign_tail_lsn_locked() as
> > > opposed to the current approach.
> > 
> > Because I didn't think of it? :)
> > 
> > There's so much other stuff in this patch set I didn't spend a
> > lot of time thinking about other alternatives. this was a simple
> > code transformation that did what I wanted, and I went on to burning
> > brain cells on other more complex issues that needs to be solved...
> > 
> > > For example, xlog_assign_tail_lsn_locked() could simply check the
> > > current min item against the current l_tail_lsn before it does the
> > > assignment and use that to trigger tail change events. If we wanted to
> > > also filter out the other wakeups (as this patch does) then we could
> > > just pass a bool pointer or something that returns whether the tail
> > > actually changed.
> > 
> > Yeah, I'll have a look at this - I might rework it as additional
> > patches now the code is looking at decisions based on LSN rather
> > than if the tail log item changed...
> 
> Ok, this is not worth the complexity. The wakeup code has to be able
> to tell the difference between a changed tail lsn and an empty AIL
> so that wakeups can be issued when the AIL is finally emptied.
> Unmount (xfs_ail_push_all_sync()) relies on this, and
> xlog_assign_tail_lsn_locked() hides the empty AIL from the caller
> by returning log->l_last_sync_lsn to the caller.
> 

Wouldn't either case just be a wakeup from xlog_assign_tail_lsn_locked()
(which should probably be renamed if we took that approach)? It's called
when we've removed the min item from the AIL and so potentially need to
update the tail lsn. 

> Hence the wakeup code still has to check for an empty AIL if the
> tail has changed if we use the return value of
> xlog_assign_tail_lsn_locked() as the tail LSN. At which point, the
> logic becomes somewhat convoluted, and it's far simpler to use
> __xfs_ail_min_lsn as it returns when the log is empty.
> 
> So, nice idea, but it doesn't make the code simpler or easier to
> understand....
> 

It's not that big of a deal either way. BTW on another quick look, I
think something like xfs_ail_update_tail(ailp, old_tail) is a bit more
self-documenting that xfs_ail_delete_finish(ailp, old_lsn).

Brian

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

