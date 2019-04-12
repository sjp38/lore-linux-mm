Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED865C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 21:04:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA15420869
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 21:04:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hNryO1YE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA15420869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 421A56B0275; Fri, 12 Apr 2019 17:04:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D02D6B0276; Fri, 12 Apr 2019 17:04:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29A5F6B0277; Fri, 12 Apr 2019 17:04:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E70646B0275
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 17:04:13 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g37so7251071pgl.19
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 14:04:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=47f99Mo+hydUFa/g/RdJ33gOWoAsO4NFmnQJgCAGVXk=;
        b=uWaN7EWzbN2QFdgzp1c3JSQw4k2UEf6kLebrrfjE3JL15j6gnRjKm7gimCZvui8u9a
         DoFH7IkRlVL6wU9afikjrUUWRiPQYFjPVeNJ5VcVT0mJeoPit3bJJiT0u4H+4m07HB0d
         qkj9dUc/dubRY+IW2v1KFrNplKyoDIiXXzCGpax8Rak8BtfQDq+oEVhIu4RBWRPUPyHI
         uwDJRavBPvIADAk+z6tPRcUQf82zsCvdKMfh6an66FtW/7V41jmWXpnvgAuPoFes83A5
         /V2g+amAkw3KNn7SjdzSB/FMw69R8DpIr/143GqidDVSs3QRkSna30K1AWhVpI1fCAkx
         PmDA==
X-Gm-Message-State: APjAAAXJdjvtdydYVq3/VY3wluITVcksz+f4yUE/dGYuMmp8kOee7QET
	yjVHu5t8yi2YmRNLQ5nhYIb92rlrNE/aLTWHNyFQVxSmKB04aCLrPeybEABF8QS+olnyuvu7CJS
	0+xvOB0PF/6QzTT064/t4U6HjJ/OMU555nPoLVHlxok0u3NWs2lBPEwi1cA3AMzOBXw==
X-Received: by 2002:a17:902:e48c:: with SMTP id cj12mr58345001plb.93.1555103053305;
        Fri, 12 Apr 2019 14:04:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwT/I0P4L9oGCLLl9WxtxBn1WuGWi/rlTYP/8O5OEg6El3IV2uI5V9ExogiTzzis95F0me4
X-Received: by 2002:a17:902:e48c:: with SMTP id cj12mr58344894plb.93.1555103052122;
        Fri, 12 Apr 2019 14:04:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555103052; cv=none;
        d=google.com; s=arc-20160816;
        b=FClI2xvHriYH0lRwF0uMgS0fcOg4pZwVaIsyE6cOmCgT/mQWKQD4Q/icOfCT3UegOy
         myrcAVgvdLoGLGsd8DKdJZBBi8NnqK82jiWQEw7R9dLmzbBjj9TP0CMdP2WBsjPmJAT4
         lREJ6HnLby/yl2pfRMRLKsm3kvSXoPtubt8r6yi0mHArMysopDRDu4kW9h8PMoqEQlMv
         YP/U3pmAos58IoaKuIcgtKy8OV5byHCUD7CG7JQmHXtBqqXSvkWFllSDHbTaBejcIC++
         1fpTrnzBMeisSHUPSW1NLQ8zq7k59mR26kPcz3pGz2LWPpYuNBatVpdavciNNGyW3Gra
         4G2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=47f99Mo+hydUFa/g/RdJ33gOWoAsO4NFmnQJgCAGVXk=;
        b=dkFUwmlU6/HabVruZsScWc4wQaGux4FTKkX4UCj72wvsbpOovjqvdg2DxYo2Yh2RNn
         i8WAFnJFniiMFPOUSKrFuYJYEkQnGAo0gy7d273TVpnYpGQotYLcSqWgJ8uFl4IkRS62
         rmMv2xQL9gxMpHkrYyk6VYYhxW5tpMth1LmLUvGtB1Z4Ak3ucsZF4reRbWLGoX90TfFy
         d8LuMh4TqgXLIot0CeDUJU/94WTfkL430OAQg/TtYxAwp160PlS0HjZ+2aEC88QCfX6U
         XIlUSSCBMprYqPTindYdxwNg9I6Uv24ghkDc9F2hBoPaw6pQv1gkGjoB2iKh6zy5QnRb
         n/dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hNryO1YE;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e5si37834567pls.29.2019.04.12.14.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 14:04:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hNryO1YE;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=47f99Mo+hydUFa/g/RdJ33gOWoAsO4NFmnQJgCAGVXk=; b=hNryO1YEnoE8oEpdDtnRTm8cf
	JQ8mTLNe6qyVi3NbhxLCX4hE+lVbiJMP8XxnqGIS/wy4lodGJ2uSCJOLKMN2YHDKO91vuKZWTqu/7
	jAUw3bgOhP8ucd+59v2q08TyCmpbK3hoQu7Ma9sb9owgfQHqDycjvAJuyzGkR1gLoRfb+ozgtYE/S
	knL+iMLMxk+X79PVU1BCkGVacxHq1o1iyHAdYaGbDrI7BxLgxN5Zygn/+RH4yxLRBIuuZIjJLdObd
	SjlkiVbsVlWMecRw3ZfbM64obc731htiPKdvWq2HUCiEmix3qnPZzmUnlNCl1+mNjYo7MyJInnBNE
	QE151ghYw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hF3L1-0004EH-RX; Fri, 12 Apr 2019 21:03:55 +0000
Date: Fri, 12 Apr 2019 14:03:55 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Daniel Colascione <dancol@google.com>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>, yuzhoujian@didichuxing.com,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christian Brauner <christian@brauner.io>,
	Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>,
	lsf-pc@lists.linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
Message-ID: <20190412210355.GC899@bombadil.infradead.org>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org>
 <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
 <CAKOZuetFU4tXE27bxA86zzDfNSCbw83p8fPxfkQ_d_Em0C04Sg@mail.gmail.com>
 <20190411173649.GF22763@bombadil.infradead.org>
 <CAKOZuet8-en+tMYu_QqVCxmkak44T7MnmRgfJBot0+P_A+Qzkw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuet8-en+tMYu_QqVCxmkak44T7MnmRgfJBot0+P_A+Qzkw@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 10:47:50AM -0700, Daniel Colascione wrote:
> On Thu, Apr 11, 2019 at 10:36 AM Matthew Wilcox <willy@infradead.org> wrote:
> > It's not a question of the kernel deciding what the right signal is.
> > The kernel knows whether a signal is fatal to a particular process or not.
> > The question is whether the killing process should do the work of reaping
> > the dying process's resources sometimes, always or never.  Currently,
> > that is never (the process reaps its own resources); Suren is suggesting
> > sometimes, and I'm asking "Why not always?"
> 
> FWIW, Suren's initial proposal is that the oom_reaper kthread do the
> reaping, not the process sending the kill. Are you suggesting that
> sending SIGKILL should spend a while in signal delivery reaping pages
> before returning? I thought about just doing it this way, but I didn't
> like the idea: it'd slow down mass-killing programs like killall(1).
> Programs expect sending SIGKILL to be a fast operation that returns
> immediately.

Suren said that the implementation in this proposal wasn't to be taken
literally.

You've raised some good points here though.  Do mass-killing programs
like kill with a pgid or killall expect the signal-sending process to
be fast, or do they not really care?

From the kernel's point of view, the same work has to be done, no matter
whether the killer or the victim does it.  Should the work be accounted
to the killer or the victim?  It probably doesn't matter.  The victim
doing the work allows for parallelisation, but I'm not convinced that's
important either.

I see another advantage for the killer doing the work -- if the task
is currently blocking on I/O (eg to an NFS mount that has gone away),
the killer can get rid of the task's page tables.  If we have to wait
for the I/O to complete before the victim reaps its own page tables,
we may be waiting forever.

