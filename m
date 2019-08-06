Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F110FC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 05:34:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D2F0214C6
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 05:34:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D2F0214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 090136B0003; Tue,  6 Aug 2019 01:34:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 042106B0005; Tue,  6 Aug 2019 01:34:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4A3C6B0006; Tue,  6 Aug 2019 01:34:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEFCF6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 01:34:49 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s21so47589819plr.2
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 22:34:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=p0ugPinTk/G6H2s3p7eqd4HWDQnabhYpwt3GHVqzRqU=;
        b=NG1QQSzw1/gudbsKyCUrePDULkklntJhgVRzJwnXejHAGBUwtSqWE8GEm5adi2aIFM
         50KHQlaHFg0mz8wwIe93nAgHGzh7UsVUKUa0wrpM6sMAAAHYIJ+HNZ7aIcor1HbIfga0
         lCMYk2EWOXMkYydp+C9jzCDALvqM9zW0qY3edkJU9d9TIcw71kgBhOvtoy4vKmFNnJb+
         mvqT5ifrJsplze4HS21gt1CusgGW402JQBjwS/vz7LgECf99ytduN3ioll4uLFslyFYf
         wlhnxo0wmOCqimgwgyC2/v1NM75YURmiNiNJaWtWVHeGYYN3cm7OPSRyPpT3FuL/sxoZ
         WXVw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUi9M4dIJwscbtEEJOqcdB5Gp6IazfuAxlSdcnPvFjI9T3t6BPD
	swWhDJYmczU2DVchtCvyvn/Rbh/YuRfakDKtjGKzy8mlDkYA2E5QHQAYbS6VI59RHwc7v7Myc3W
	oLCCrc/SEWuBngIgMdE1fLQ1QC8vNJppebIPa7Qv8ZqrJgBAQ9zqmcODBckjzPRs=
X-Received: by 2002:a17:90a:3aed:: with SMTP id b100mr1336180pjc.63.1565069689346;
        Mon, 05 Aug 2019 22:34:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycHW+f2rbk3O+UrJQ1Igi9tbVvF1a2Gq3d71zogGZNOq0eiTpa98jqaaa9dziBFDvYPS7x
X-Received: by 2002:a17:90a:3aed:: with SMTP id b100mr1336121pjc.63.1565069688282;
        Mon, 05 Aug 2019 22:34:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565069688; cv=none;
        d=google.com; s=arc-20160816;
        b=KhjuTwcDQvoE9HoL3iZiYdQQ9KSXLs1yVE5YOGprfDbV4QaZgGrmuqZQa77+oo3MbN
         GAMWcM+lPOO/avy2Qcufby54hhmLXVsPKKzqb/AX2dflTPY7jvUdolslPMJ1kiXHF9dU
         oOOFH5JLCjCC4VY9OTs5B2FQeRlJwfGytmQGaxZLrox4K8mDwrwElUvVy3ARYxaFIU75
         Opq4UAYO6GT+S7Lu+lIBfBk0YfQeuBuzj+MNrny+H5JTzI0qT6wdS5uSbL8tgHO5e3iZ
         mLgc7iunM+tUaK5E5+DHtP+duNec2SIueB69YVffAd5/Jgl4bvdrnbubovqrnfydrNOT
         hqfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=p0ugPinTk/G6H2s3p7eqd4HWDQnabhYpwt3GHVqzRqU=;
        b=aPm2dqU7SwUXAIb1/zddywPEYxfQHyFBR8ir8A6IyyR3Y+CQug24xGqwJUqozLLUC6
         c8WTJ+A6cs+H8dLf7q6XeYv40Fq2jmktCVm9zkg92UZvrGpPUpHgbT0VrXhrBfkAAdS4
         yvlpljugmrF5kHb8lCU1cV/IEY/GXxFVqXht+PdGegN7H25Q5T35X4ePwrBOkUl/vDM5
         oS/C7wbXvdbBmOym6GUKtPgrBMtkmqB0Q7WSy5OkU+PcqJxzhkkAwhST2UizKUq8ZkFX
         fqdM9wBQBneSJf4caFvZZb1pRkSRZ+mZWtSeKTUiWsPs6SJqX60lKEfGhs2ZVfwrtnN6
         lDvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id f32si13848939pjg.42.2019.08.05.22.34.47
        for <linux-mm@kvack.org>;
        Mon, 05 Aug 2019 22:34:48 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id A50683650E3;
	Tue,  6 Aug 2019 15:34:45 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hus6M-0007a7-6z; Tue, 06 Aug 2019 15:33:38 +1000
Date: Tue, 6 Aug 2019 15:33:38 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 14/24] xfs: tail updates only need to occur when LSN
 changes
Message-ID: <20190806053338.GD7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-15-david@fromorbit.com>
 <20190805175325.GD14760@bfoster>
 <20190805232826.GZ7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805232826.GZ7777@dread.disaster.area>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=tDGkv3wj-1Xd4aaGj3EA:9
	a=QHoE4VTwHAm25SPf:21 a=IVeHmRXT_aZo3Dbf:21 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 09:28:26AM +1000, Dave Chinner wrote:
> On Mon, Aug 05, 2019 at 01:53:26PM -0400, Brian Foster wrote:
> > On Thu, Aug 01, 2019 at 12:17:42PM +1000, Dave Chinner wrote:
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > We currently wake anything waiting on the log tail to move whenever
> > > the log item at the tail of the log is removed. Historically this
> > > was fine behaviour because there were very few items at any given
> > > LSN. But with delayed logging, there may be thousands of items at
> > > any given LSN, and we can't move the tail until they are all gone.
> > > 
> > > Hence if we are removing them in near tail-first order, we might be
> > > waking up processes waiting on the tail LSN to change (e.g. log
> > > space waiters) repeatedly without them being able to make progress.
> > > This also occurs with the new sync push waiters, and can result in
> > > thousands of spurious wakeups every second when under heavy direct
> > > reclaim pressure.
> > > 
> > > To fix this, check that the tail LSN has actually changed on the
> > > AIL before triggering wakeups. This will reduce the number of
> > > spurious wakeups when doing bulk AIL removal and make this code much
> > > more efficient.
> > > 
> > > XXX: occasionally get a temporary hang in xfs_ail_push_sync() with
> > > this change - log force from log worker gets things moving again.
> > > Only happens under extreme memory pressure - possibly push racing
> > > with a tail update on an empty log. Needs further investigation.
> > > 
> > > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > > ---
> > 
> > Ok, this addresses the wakeup granularity issue mentioned in the
> > previous patch. Note that I was kind of wondering why we wouldn't base
> > this on the l_tail_lsn update in xlog_assign_tail_lsn_locked() as
> > opposed to the current approach.
> 
> Because I didn't think of it? :)
> 
> There's so much other stuff in this patch set I didn't spend a
> lot of time thinking about other alternatives. this was a simple
> code transformation that did what I wanted, and I went on to burning
> brain cells on other more complex issues that needs to be solved...
> 
> > For example, xlog_assign_tail_lsn_locked() could simply check the
> > current min item against the current l_tail_lsn before it does the
> > assignment and use that to trigger tail change events. If we wanted to
> > also filter out the other wakeups (as this patch does) then we could
> > just pass a bool pointer or something that returns whether the tail
> > actually changed.
> 
> Yeah, I'll have a look at this - I might rework it as additional
> patches now the code is looking at decisions based on LSN rather
> than if the tail log item changed...

Ok, this is not worth the complexity. The wakeup code has to be able
to tell the difference between a changed tail lsn and an empty AIL
so that wakeups can be issued when the AIL is finally emptied.
Unmount (xfs_ail_push_all_sync()) relies on this, and
xlog_assign_tail_lsn_locked() hides the empty AIL from the caller
by returning log->l_last_sync_lsn to the caller.

Hence the wakeup code still has to check for an empty AIL if the
tail has changed if we use the return value of
xlog_assign_tail_lsn_locked() as the tail LSN. At which point, the
logic becomes somewhat convoluted, and it's far simpler to use
__xfs_ail_min_lsn as it returns when the log is empty.

So, nice idea, but it doesn't make the code simpler or easier to
understand....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

