Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B01BC3A589
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 01:00:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E20F8206C1
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 01:00:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="KcW7SJTC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E20F8206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 829776B0007; Thu, 15 Aug 2019 21:00:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D8A06B0008; Thu, 15 Aug 2019 21:00:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A0146B000A; Thu, 15 Aug 2019 21:00:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0101.hostedemail.com [216.40.44.101])
	by kanga.kvack.org (Postfix) with ESMTP id 42B136B0007
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 21:00:39 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A4E44181AC9AE
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 01:00:38 +0000 (UTC)
X-FDA: 75826485756.14.knot56_22a73b73edf03
X-HE-Tag: knot56_22a73b73edf03
X-Filterd-Recvd-Size: 6108
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 01:00:38 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id 201so3391496qkm.9
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 18:00:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ae7oLtYinKvgCP13tnVSH7l6maTQr55HBH5L3FO3DiI=;
        b=KcW7SJTCvYMKEBr6ZA7ZBCVrwhTBhrxBAzKDZCEQfgTQ1UAU1/yBqq/rXTp4rQSuMJ
         IO3knBqpn2AdA04HAixLj3yCozsg1UAo/yGd5mtobT9P7ox1cF3Az+gzxvSHjtS74RUp
         WvaqkLapT2Ubt9ToChKBB0qe0ngW33kWeP+H8aeA2AYYZE14PPhIZ/S3lqmaw6o7OQOc
         +NqXbwj2Kf5YIU09s9BqFI5Fx6K9MIW9Pox2mvr2sLTsxwPMikvBFCp/EFlqT78uepMz
         rSFX7X+6jzzyCjzCiQ0A93GLozvhXSdE0CeSM6/pkHRgn74yKYamKJEUnwca6vz4+PPL
         iGog==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=ae7oLtYinKvgCP13tnVSH7l6maTQr55HBH5L3FO3DiI=;
        b=lcZRimv6A+qEPlbZS+I3LxkcH+BMMgcmzxEAesI92Y3asQnC+8z+P+kxwugnqw0O5Y
         9P7BI8ix1iBt89Xji5lovcbX2HvDXrDcZ5RhV2uTdydAQdf5qUO9dekSyRT/0cXiLp8n
         LE1deCQBUieKMwHGlWX2v7J7xY3+6l0YXdw4oJ04j3wYjtG7dShaUx2v4KizWXnjtLN7
         6auhpDXslX/hdSIVNdULvnHAWf1BM8CR8W7F5M3CluMjhi23O8ABIGMbG6MbKuPUWAvd
         zA4c7ZgX/p1G9MGPnmF2adDsXMuU6hW+VBTlXnFOkgQknv++krCdYOAlVng6WXBv2UiX
         cuFg==
X-Gm-Message-State: APjAAAWkVe5frnORxClHxxsr1oM1/yBgXjS2bYueZPbQwfwF4NKJzJfH
	QCwQNoM69Cj84nT4n4wFSvzyIw==
X-Google-Smtp-Source: APXvYqyxI9OS6AUw/7wEeJomE7hGeWSroP0/H9Q9E+ZoJynGDvtwyvcA9yHhjJMm3q3CVcLQLGNODw==
X-Received: by 2002:a37:aa57:: with SMTP id t84mr6562963qke.34.1565917237376;
        Thu, 15 Aug 2019 18:00:37 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id t15sm2084806qtr.88.2019.08.15.18.00.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 18:00:36 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyQbc-0002v2-3C; Thu, 15 Aug 2019 22:00:36 -0300
Date: Thu, 15 Aug 2019 22:00:36 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Michal Hocko <mhocko@kernel.org>, Feng Tang <feng.tang@intel.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Linux MM <linux-mm@kvack.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Rientjes <rientjes@google.com>, Wei Wang <wvw@google.com>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>
Subject: Re: [Intel-gfx] [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190816010036.GA9915@ziepe.ca>
References: <20190815155950.GN9477@dhcp22.suse.cz>
 <20190815165631.GK21596@ziepe.ca>
 <20190815174207.GR9477@dhcp22.suse.cz>
 <20190815182448.GP21596@ziepe.ca>
 <20190815190525.GS9477@dhcp22.suse.cz>
 <20190815191810.GR21596@ziepe.ca>
 <20190815193526.GT9477@dhcp22.suse.cz>
 <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
 <20190815202721.GV21596@ziepe.ca>
 <CAKMK7uER0u1TqeJBXarKakphnyZTHOmedOfXXqLGVDE2mE-mAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uER0u1TqeJBXarKakphnyZTHOmedOfXXqLGVDE2mE-mAQ@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 10:49:31PM +0200, Daniel Vetter wrote:
> On Thu, Aug 15, 2019 at 10:27 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > On Thu, Aug 15, 2019 at 10:16:43PM +0200, Daniel Vetter wrote:
> > > So if someone can explain to me how that works with lockdep I can of
> > > course implement it. But afaics that doesn't exist (I tried to explain
> > > that somewhere else already), and I'm no really looking forward to
> > > hacking also on lockdep for this little series.
> >
> > Hmm, kind of looks like it is done by calling preempt_disable()
> 
> Yup. That was v1, then came the suggestion that disabling preemption
> is maybe not the best thing (the oom reaper could still run for a long
> time comparatively, if it's cleaning out gigabytes of process memory
> or what not, hence this dedicated debug infrastructure).

Oh, I'm coming in late, sorry

Anyhow, I was thinking since we agreed this can trigger on some
CONFIG_DEBUG flag, something like

    /* This is a sleepable region, but use preempt_disable to get debugging
     * for calls that are not allowed to block for OOM [.. insert
     * Michal's explanation.. ] */
    if (IS_ENABLED(CONFIG_DEBUG_ATOMIC_SLEEP) && !mmu_notifier_range_blockable(range))
	preempt_disable();
    ops->invalidate_range_start();

And I have also been idly mulling doing something like

   if (IS_ENABLED(CONFIG_DEBUG_NOTIFIERS) && 
       rand &&
       mmu_notifier_range_blockable(range)) {
     range->flags = 0
     if (!ops->invalidate_range_start(range))
	continue

     // Failed, try again as blockable
     range->flags = MMU_NOTIFIER_RANGE_BLOCKABLE
   }
   ops->invalidate_range_start(range);

Which would give coverage for this corner case without forcing OOM.

Jason

