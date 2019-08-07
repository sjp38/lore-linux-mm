Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87FEFC41514
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:31:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D53A21871
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:31:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="ltUuSGLn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D53A21871
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4AD06B0006; Wed,  7 Aug 2019 17:31:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD4F76B0007; Wed,  7 Aug 2019 17:31:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9C856B0008; Wed,  7 Aug 2019 17:31:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9253A6B0006
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 17:31:09 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i26so57492905pfo.22
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 14:31:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NQJ8f3sbtpxQFwytiN3eHpksnWvvNOcO2e4/JMupkqc=;
        b=bhngNVogFzsbbCu7D1QHoqZpGlpG4VJRGFFx0t0awGBDldQ9L6i+gohYtNHNbGfkCm
         rE2Gx1DJ41hnGkQbEcGX600fFF5lRvQ4O3SqORHVe3AWnhm/AO/XBHNX8qwDJj6ZHPtV
         lBXRX6kR5m1OKAMaiXFLYIwz8ai5MaMh12bpA0P14a2Z6uyw5l32XCI1px8azihhTho4
         7S/tQDwoG/JgyPDuUS82PJxG5GB36LBpHIfV+ql7X2ukAy262+9UhY/+iJ/1DyMO/fZL
         JpPS/fL4Ggec7YIUQbct+KtiJR3P7Mh3SeHWCWMKTUtPFQF1AZ2SuyfnwjtnwBGhB2Av
         x8FA==
X-Gm-Message-State: APjAAAWgloRzLwlk2LYbDG2Iy62/oYRoo3WIz4WtUgFwUDdPto5jTT0h
	XOZ9l/UgDZfRD6yUZ3V1lkRiAlxNVbHmXlhmydc9OfULFbP7lNpuQkN7lZ0ukDFhDK1TDzlBrvR
	7cnIv2yKvC7lS6DZfywHdMCW6LGrIu4ksF7Qo9Ehw97mRpoexe1ySOGbCWCLFRjo+7A==
X-Received: by 2002:a17:90a:2ec1:: with SMTP id h1mr451464pjs.119.1565213469278;
        Wed, 07 Aug 2019 14:31:09 -0700 (PDT)
X-Received: by 2002:a17:90a:2ec1:: with SMTP id h1mr451396pjs.119.1565213468462;
        Wed, 07 Aug 2019 14:31:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565213468; cv=none;
        d=google.com; s=arc-20160816;
        b=l2zEo6ETUUtq9iAn1Xe5a2ELG1Q8ObzQaDTj7GsFyVMgLWfX8yCg6A7o18z5XPImMe
         YowBK7v6j6S1a/Kj7zOxKCSg/4IVli7y9QbtqVqW+3Jj4h1zPeFEhJDoTSG9R2bMWQCO
         2zMyHLw206ky2O70kPhJE4GA8y/ve8RpkL6b/Wqmt/o/k4vWWfbNYqdIiAerfagHJw8N
         5x3Pf/R0p70rDbvE3jzJhSny9YteBsMoIv3XpmAOLL8+p50mDBNBeS7NH/M3Jo6WKHE3
         qU6Y1cY1c+rr8RgJEjaQae7oiwONWnscgqjds3ktuvo4EoitATxiEz1QKSHrnw4gm3v8
         hZPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NQJ8f3sbtpxQFwytiN3eHpksnWvvNOcO2e4/JMupkqc=;
        b=BgdNd7mTx9sWqxI3MEcYD4JMfjJQ5IgtccrrtcWXEu0VrwLKOYT5ALzWd44h6IVEqz
         9mhPIBENQGf7pOeUbolIp0RzvFaUqkIOreQmuUX6HOuC8A3XzELSfLgoTkrw4N+2NSuk
         ZPzrTbD6YFvPhcVwZap/u5pfU0Bwd3ojdbsV8YsjSg0J4cZAwutrJWAz7qCEtsI7BtK8
         lJqlwmu3Z4uWJU2WxWuQiRmzeb4BTmU25pb4OQEOTXnVPjcg9x3U6Wdf+a4DdwEhvi4X
         ile/JKcfjj06ZiL7HNyWynLgSzqPu9Km06NNtaMvE5umeRVW97mROKRrcJUcs/yk9d96
         BbTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=ltUuSGLn;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y131sor72725388pfb.27.2019.08.07.14.31.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 14:31:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=ltUuSGLn;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=NQJ8f3sbtpxQFwytiN3eHpksnWvvNOcO2e4/JMupkqc=;
        b=ltUuSGLnwli7uHEKMbcJ+YOm7vx0HT8aK0FqET7xYC6vzOpSEUHRN/AATglHk0+0p+
         zSnAx29U8WuLTI9ExqxwFzPZmo0mHUqAjMn2RgZOIpvSFf2FTljKhjOmlz/PX2bEMaRC
         lFE+Jq8IidL4IM+nVDmMMflaOTHFIJmzC3aOM=
X-Google-Smtp-Source: APXvYqycwCSZRxiQZg5b6w8u5vo5c0fzV5zhn+ILS/tJqsI66etCit/pYaYlIq/y8q2Rld0VAf6CWw==
X-Received: by 2002:aa7:91cc:: with SMTP id z12mr11549407pfa.76.1565213468077;
        Wed, 07 Aug 2019 14:31:08 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id a6sm92456750pfa.162.2019.08.07.14.31.06
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 14:31:07 -0700 (PDT)
Date: Wed, 7 Aug 2019 17:31:05 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
	minchan@kernel.org, namhyung@google.com, paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v5 1/6] mm/page_idle: Add per-pid idle page tracking
 using virtual index
Message-ID: <20190807213105.GA14622@google.com>
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <20190807130402.49c9ea8bf144d2f83bfeb353@linux-foundation.org>
 <20190807204530.GB90900@google.com>
 <20190807135840.92b852e980a9593fe91fbf59@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807135840.92b852e980a9593fe91fbf59@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 01:58:40PM -0700, Andrew Morton wrote:
> On Wed, 7 Aug 2019 16:45:30 -0400 Joel Fernandes <joel@joelfernandes.org> wrote:
> 
> > On Wed, Aug 07, 2019 at 01:04:02PM -0700, Andrew Morton wrote:
> > > On Wed,  7 Aug 2019 13:15:54 -0400 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> > > 
> > > > In Android, we are using this for the heap profiler (heapprofd) which
> > > > profiles and pin points code paths which allocates and leaves memory
> > > > idle for long periods of time. This method solves the security issue
> > > > with userspace learning the PFN, and while at it is also shown to yield
> > > > better results than the pagemap lookup, the theory being that the window
> > > > where the address space can change is reduced by eliminating the
> > > > intermediate pagemap look up stage. In virtual address indexing, the
> > > > process's mmap_sem is held for the duration of the access.
> > > 
> > > So is heapprofd a developer-only thing?  Is heapprofd included in
> > > end-user android loads?  If not then, again, wouldn't it be better to
> > > make the feature Kconfigurable so that Android developers can enable it
> > > during development then disable it for production kernels?
> > 
> > Almost all of this code is already configurable with
> > CONFIG_IDLE_PAGE_TRACKING. If you disable it, then all of this code gets
> > disabled.
> > 
> > Or are you referring to something else that needs to be made configurable?
> 
> Yes - the 300+ lines of code which this patchset adds!
> 
> The impacted people will be those who use the existing
> idle-page-tracking feature but who will not use the new feature.  I
> guess we can assume this set is small...

Yes, I think this set should be small. The code size increase of page_idle.o
is from ~1KB to ~2KB. Most of the extra space is consumed by
page_idle_proc_generic() function which this patch adds. I don't think adding
another CONFIG option to disable this while keeping existing
CONFIG_IDLE_PAGE_TRACKING enabled, is worthwhile but I am open to the
addition of such an option if anyone feels strongly about it. I believe that
once this patch is merged, most like this new interface being added is what
will be used more than the old interface (for some of the usecases) so it
makes sense to keep it alive with CONFIG_IDLE_PAGE_TRACKING.

thanks,

 - Joel

