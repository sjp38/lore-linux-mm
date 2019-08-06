Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA176C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:45:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8056020818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:45:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="BK0x5edz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8056020818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 107006B0005; Tue,  6 Aug 2019 06:45:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 092226B0006; Tue,  6 Aug 2019 06:45:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9B0C6B0008; Tue,  6 Aug 2019 06:45:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B670C6B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 06:45:57 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i27so55645632pfk.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 03:45:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ABKgADdiGa23iy+5xy09f6OBQqR3I/07f0qdbQrp2Ug=;
        b=ermsDNiAZTAThcnPXaoy2ZaXv7fXUACU7V5QmgGY3QeDf64qKCUQUg1yqKss7kYs3y
         zFqYFQo/aK70M8cNdls5BN9g+oZun1cPFQl29tUDml8iFrzjROvN3pWWiKGiwCdYrAU2
         5vpFTSWB6zX9hiYhkbqw8OGEchE2aSNnBj6MHQ/2rUbxN2gp//qC0e4bypd95W8/R2gN
         mrBvv/JYiHRRIN7aclYMlY1qIJ+yftSLy7uxmPjlIgVLnnO9W9iUjFUi1IvcaiA5vXco
         VbYpXM3O2KzI4yRj3BfMEHeFKedz129apqWs4DE47Fo5QFvix1dX5w1TTPQQrIwJ0rgZ
         saxg==
X-Gm-Message-State: APjAAAUd0PSvdaGtcPdIg/kPU+5JqZm6iGIe6e0xJvltseQMdcR943rF
	QoG4nErjxRDY2AnKz4Fvyp0+omw1hmn607sLE1Nt5hJQlrM+GJrrj35wFhpTtxWWtIA2dx0dcbd
	bf/8jtvzf/Mt+XfjLrMfS4b0OOsW3Tijmklw5GGPw6gv+K3vEG+JtismCYE9TY0gneA==
X-Received: by 2002:a17:902:381:: with SMTP id d1mr2482515pld.331.1565088357161;
        Tue, 06 Aug 2019 03:45:57 -0700 (PDT)
X-Received: by 2002:a17:902:381:: with SMTP id d1mr2482475pld.331.1565088356528;
        Tue, 06 Aug 2019 03:45:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565088356; cv=none;
        d=google.com; s=arc-20160816;
        b=kMo6SYKwBHqogQiZEHW6CRP5LsnUfM9N/dbQECaunm8sRBTCuSt/YCpU+CxjvtdM5B
         5+yiUsiGCaHWpOQ+F5O0musXJl75zPC+MYVcdbm6f7JlDgiT0eCcZjeN8Y/34UCdVJQ7
         ecf88PcdRIE/5TbxqsQp9Mcfw40RjKeb/5ie8PInaz+vRqihcxRFNPvSQ0WpxNk8n9qj
         TfTXTxcGVJcp7XEwm4sIBuqvxLajEIX9ilpnZ8TFUmZIJfAd4H1lqc6yE0VEpL8XWiRt
         9sTO6aU2+ddWKPxZQrMy9PRjt56L9plV8F3D/HmHXf5/PlQEwSYIMRuOiVWUAxIU5JwB
         eN4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ABKgADdiGa23iy+5xy09f6OBQqR3I/07f0qdbQrp2Ug=;
        b=Vd9fkz4k0ixWlFzUNn6/vTzsdl6NiuC76R+p5PjQwg/vGKwyDjzxj+CT7mSj7KKVBU
         80ARDE8vMySNGPuKY0XDGZXTUUNRKJS/CQj5gvi60DFqNlHmsWtqdBic+CIz7dlD2mPN
         lWe3nRJe9LPB5kV/bZgFeb/CB2PPKXyCSO/Buht0I73mndFK1ssmsMYWL4rHwPum5ywK
         xZXiOCZAO+hpVgY3cUmVjfmBuGFNXtIFbHAN4Ih364ZVDy1Oe8nvO4B3ldBpBM4FtFpd
         3gAxTwPadBMqXGXPkUWhZ39aZrsxOLawGFCLhcGvBGfH4oblc+SkXJC5uJz3wYFh9jua
         S8LA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=BK0x5edz;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a23sor67226529pfa.54.2019.08.06.03.45.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 03:45:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=BK0x5edz;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ABKgADdiGa23iy+5xy09f6OBQqR3I/07f0qdbQrp2Ug=;
        b=BK0x5edz5Iheer/fK6xR02+EYpWEe73+fBNaVu3psDyEfFgQR4iTDEjMX3llLyVbBQ
         oo5c2wtKKMdHq+s0dbGvvCrA28tZJ7WgRbNvmF9B9TCPhzQEMI365I16VRvzSe8CiyqZ
         ulIdft17U/LPUUnWy2+R0724GxrzxbZjJPUj8=
X-Google-Smtp-Source: APXvYqyKhAOOvSnRzmdX9OiAK7Cu7h4b/c73qpWbsn3JUV5APW6ELiBP2MjwevD8QijB6PWnNqvwJA==
X-Received: by 2002:aa7:90d4:: with SMTP id k20mr2919746pfk.78.1565088356112;
        Tue, 06 Aug 2019 03:45:56 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id b126sm126571952pfa.126.2019.08.06.03.45.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 03:45:55 -0700 (PDT)
Date: Tue, 6 Aug 2019 06:45:54 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, minchan@kernel.org,
	namhyung@google.com, paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 4/5] page_idle: Drain all LRU pagevec before idle
 tracking
Message-ID: <20190806104554.GB218260@google.com>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-4-joel@joelfernandes.org>
 <20190806084357.GK11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806084357.GK11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 10:43:57AM +0200, Michal Hocko wrote:
> On Mon 05-08-19 13:04:50, Joel Fernandes (Google) wrote:
> > During idle tracking, we see that sometimes faulted anon pages are in
> > pagevec but are not drained to LRU. Idle tracking considers pages only
> > on LRU. Drain all CPU's LRU before starting idle tracking.
> 
> Please expand on why does this matter enough to introduce a potentially
> expensinve draining which has to schedule a work on each CPU and wait
> for them to finish.

Sure, I can expand. I am able to find multiple issues involving this. One
issue looks like idle tracking is completely broken. It shows up in my
testing as if a page that is marked as idle is always "accessed" -- because
it was never marked as idle (due to not draining of pagevec).

The other issue shows up as a failure in my "swap test", with the following
sequence:
1. Allocate some pages
2. Write to them
3. Mark them as idle                                    <--- fails
4. Introduce some memory pressure to induce swapping.
5. Check the swap bit I introduced in this series.      <--- fails to set idle
                                                             bit in swap PTE.

Draining the pagevec in advance fixes both of these issues.

This operation even if expensive is only done once during the access of the
page_idle file. Did you have a better fix in mind?

thanks,

 - Joel


> > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> > ---
> >  mm/page_idle.c | 6 ++++++
> >  1 file changed, 6 insertions(+)
> > 
> > diff --git a/mm/page_idle.c b/mm/page_idle.c
> > index a5b00d63216c..2972367a599f 100644
> > --- a/mm/page_idle.c
> > +++ b/mm/page_idle.c
> > @@ -180,6 +180,8 @@ static ssize_t page_idle_bitmap_read(struct file *file, struct kobject *kobj,
> >  	unsigned long pfn, end_pfn;
> >  	int bit, ret;
> >  
> > +	lru_add_drain_all();
> > +
> >  	ret = page_idle_get_frames(pos, count, NULL, &pfn, &end_pfn);
> >  	if (ret == -ENXIO)
> >  		return 0;  /* Reads beyond max_pfn do nothing */
> > @@ -211,6 +213,8 @@ static ssize_t page_idle_bitmap_write(struct file *file, struct kobject *kobj,
> >  	unsigned long pfn, end_pfn;
> >  	int bit, ret;
> >  
> > +	lru_add_drain_all();
> > +
> >  	ret = page_idle_get_frames(pos, count, NULL, &pfn, &end_pfn);
> >  	if (ret)
> >  		return ret;
> > @@ -428,6 +432,8 @@ ssize_t page_idle_proc_generic(struct file *file, char __user *ubuff,
> >  	walk.private = &priv;
> >  	walk.mm = mm;
> >  
> > +	lru_add_drain_all();
> > +
> >  	down_read(&mm->mmap_sem);
> >  
> >  	/*
> > -- 
> > 2.22.0.770.g0f2c4a37fd-goog
> 
> -- 
> Michal Hocko
> SUSE Labs

