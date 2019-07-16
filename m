Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3021C7618F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:25:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E83B2064B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:25:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="phx1Mq5J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E83B2064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C2986B0269; Tue, 16 Jul 2019 13:25:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 374858E0005; Tue, 16 Jul 2019 13:25:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 262E88E0003; Tue, 16 Jul 2019 13:25:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E5F8E6B0269
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 13:25:06 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 30so13001620pgk.16
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 10:25:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jmmNrLz05OQxiUsEmtCkS8mBmrl8vj668vZ/xiMeIrY=;
        b=QtP3iuuxVyFFasHdb9RpC3Zox/R6lLumv8JTmW/MiVpobtm+ypMFanUBrnE/RcOiji
         TNB6KtostHgLjervRw/8adrPzKIArEYCLmYGOHJFAbsI27AqPA7le4ZqURvvjNPjD/NP
         JG1IQ5mS49QvqQlVqndue8oOVnXeKnbW6WmwpwNB2h43ZVaBduhwpHi9qb7rNRx85Jx0
         rP0rwmyLBufG9s0qU1rBptddl9jvZ2kAH9dHMeLVVJvheZYTDd21n3Ht7hiq3RpIFq0c
         RpaV2cw84M8yQc/bYJkkNVgpuSAZf2U4+MfLLzoNI+HnOOuBpRYFY4256I/hqUio9eBh
         1WsA==
X-Gm-Message-State: APjAAAVRPRtYiZcKdvOS+ekXM0io5E0YzocOdTrm9XitOL2akRCGZ8dw
	CrjBs/XAStIDk/8UOfjIRNxRcA/Wajb1RTInsFLPgYFVJfO3p4nchUkk/z936USoCIhg+mxFaTY
	h8wX1f0Ji+kdLkbMXsWDCnv53DkaLanuIvl7KUoGWdEbqyjNXPB9kWmkVzBC5vAu+zw==
X-Received: by 2002:a63:a35c:: with SMTP id v28mr35466862pgn.144.1563297906466;
        Tue, 16 Jul 2019 10:25:06 -0700 (PDT)
X-Received: by 2002:a63:a35c:: with SMTP id v28mr35466729pgn.144.1563297905463;
        Tue, 16 Jul 2019 10:25:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563297905; cv=none;
        d=google.com; s=arc-20160816;
        b=KV7khLwuuph8gWykeUPyzbWEWH7beixPeZ9mZh95uCqIDNuNkXh/6stZ8kEdV5kdGH
         yKyUrLSWpZSaLOFGI+H+Kzzo7ugL4kDs/+PXjpI/CBkI/PbPaiXubD3b1pkO/QpxEPz2
         pk9W6FQxw1+69qx/ltqVCs6BQhIiGvIjHpO9G3RItWGCDKDIOfydFJUSjPUqIRWyAiDQ
         cbonT0a11DaYEQk6AD+isaoDcc9428gaM8l03dPwBV1TdrTyWRS381UUbyY6SYe5HHvO
         xwMoqmt7d60XmSbx5lcBQrB8cMxIlIIcH24SgcgOmUa06CJbM1Bw+3k6sayAzG8jALqW
         VAog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jmmNrLz05OQxiUsEmtCkS8mBmrl8vj668vZ/xiMeIrY=;
        b=hjsrzF4hGBc898EP6o2s7z5Tb03MbhXfF+R0pxeAaen9m2uJ2afTb03y8O62cVnhT1
         54snAzgnmuR1E/XMWRJyM/bmd1Xv662AkwiyScgu0R9j8Z7ejrEO/7acTjadC8Y0bWDg
         XxZ1TV37oiAaxfS4yKHTumZL41rpMFCA8xIthOd+dGfCsu2n5YQi8D5bbmOVZyVhyXte
         A2M4ZDrh/6O5aonVcP9myT3dEYYSQLV9ZcUEBz9tx2hYNyawDO4HhcUDorcYBhKvUeWL
         2hJaZ2dYYH+SHtvIbH7fprB7jxVYlgMht0BqgaPnKwD3nm0BOalDVi/gr2sJySr62xGl
         Jcaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=phx1Mq5J;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j1sor11096462pgp.68.2019.07.16.10.25.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 10:25:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=phx1Mq5J;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=jmmNrLz05OQxiUsEmtCkS8mBmrl8vj668vZ/xiMeIrY=;
        b=phx1Mq5J6p2gfPq049fRU4kJqr233RVvBA6UMs66Fh5VPoHy5KsLA3yLW7b00Y3rb8
         GTdFxxgsB1P4yFAdo2Qi0lgz4B0At2EUVu95fRfY8Bd7hU1ELdLrEB76Wv/eTo0O/IHK
         cBHGKVh+C260gNquMCThFTjxvff5UR0XDGNu4y01LXooRqWSmV8nFoJlX5Ux8Oc0p4YR
         Ffk+3gQEUfcv+lzY/PFoTBxKXktxFJtv2i/1ZrJEAx+OqMpmcJgHGEZrhE7dlAGzP7Ne
         tVCLPB+rZn10vOY9YPlc33YLioHP5gwh7muhEqrhXj+c2blGXe3qtkyX7eg0lodMWVNf
         3yiA==
X-Google-Smtp-Source: APXvYqxNNQERGxivXJ3Js3Bxfn7FLjsI5wI5vL3fUqwqk1694sNNijt4himTh6hZUPRXthewU9p3Tw==
X-Received: by 2002:a63:dd17:: with SMTP id t23mr8718560pgg.295.1563297902419;
        Tue, 16 Jul 2019 10:25:02 -0700 (PDT)
Received: from localhost ([2620:10d:c090:180::1:dd93])
        by smtp.gmail.com with ESMTPSA id e6sm25465734pfn.71.2019.07.16.10.25.01
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 10:25:01 -0700 (PDT)
Date: Tue, 16 Jul 2019 13:24:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>, Chris Down <chris@chrisdown.name>,
	Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>,
	Dennis Zhou <dennis@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH] mm: Proportional memory.{low,min} reclaim
Message-ID: <20190716172459.GB16575@cmpxchg.org>
References: <20190124014455.GA6396@chrisdown.name>
 <20190128210031.GA31446@castle.DHCP.thefacebook.com>
 <20190128214213.GB15349@chrisdown.name>
 <20190128215230.GA32069@castle.DHCP.thefacebook.com>
 <20190715153527.86a3f6e65ecf5d501252dbf1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190715153527.86a3f6e65ecf5d501252dbf1@linux-foundation.org>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 03:35:27PM -0700, Andrew Morton wrote:
> On Mon, 28 Jan 2019 21:52:40 +0000 Roman Gushchin <guro@fb.com> wrote:
> 
> > > Hmm, this isn't really a common situation that I'd thought about, but it
> > > seems reasonable to make the boundaries when in low reclaim to be between
> > > min and low, rather than 0 and low. I'll add another patch with that. Thanks
> >
> > It's not a stopper, so I'm perfectly fine with a follow-up patch.
> 
> Did this happen?
> 
> I'm still trying to get this five month old patchset unstuck :(.  The
> review status is: 
> 
> [1/3] mm, memcg: proportional memory.{low,min} reclaim
> Acked-by: Johannes
> Reviewed-by: Roman
> 
> [2/3] mm, memcg: make memory.emin the baseline for utilisation determination
> Acked-by: Johannes
> 
> [3/3] mm, memcg: make scan aggression always exclude protection
> Reviewed-by: Roman

I forgot to send out the actual ack-tag on #, so I just did. I was
involved in the discussions that led to that patch, the code looks
good to me, and it's what we've been using internally for a while
without any hiccups.

> I do have a note here that mhocko intended to take a closer look but I
> don't recall whether that happened.

Michal acked #3 in 20190530065111.GC6703@dhcp22.suse.cz. Afaik not the
others, but #3 also doesn't make a whole lot of sense without #1...

> a) say what the hell and merge them or
> b) sit on them for another cycle or
> c) drop them and ask Chris for a resend so we can start again.

Michal, would you have time to take another look this week? Otherwise,
I think everyone who would review them has done so.

