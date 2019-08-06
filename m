Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 282B4C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:19:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0CA120B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:19:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="hT7m/kPE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0CA120B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A4AE6B000D; Tue,  6 Aug 2019 07:19:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72E076B000E; Tue,  6 Aug 2019 07:19:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A7586B0010; Tue,  6 Aug 2019 07:19:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE996B000D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:19:25 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d6so48115037pls.17
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:19:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jNBh4Uwy6QLd0fk5I8Y9B9xP/9fw2xkjlyVlCT+yndM=;
        b=OWfKiLNkAPI3vgmjQyJxICUNs91jSCZpIrLjSSXN5HQPQ9EJflCKj5MEXsEUZkndzG
         9S6Doz2mvifEf3QUG+NtcMvBa+CmzpSUITERCWkQ0g9RuyE15qFn2lWYZ2MxO/kqSKvY
         y1GHaOe5gTEVUzp2QEQG4mGNAV+TZIBc5OVRYQ3SJNM3zAg+EHlj2mnaHErdAzF4MJO+
         J5R/AqMYJLXMQTfig48BiFHUMd4zwIrH1cI28P3aeHuRpCKxyMxbzIWiwE4hmlED8Hoj
         YM5MzAB+dDp0dn7dS53hwBuYrW9bF1hMkpVALfTNr4ieFXNEj5AHWG8FQsHe8rp7WKrg
         hFfQ==
X-Gm-Message-State: APjAAAXkn8PnK9qUmxx4JxGter1Ue42fNfk1e5gt3n9Szx8LGFPiSQQa
	NikcfNLygEBcsExPI3wN4RpJffrEfx2kQR7GHHiUEU4rmcLEwY5pxH9A3Bhq4ox3pR+9lATJowb
	0JYoc/wOPYjkaB2f3QLJUBvBI13ESZt2nAxlS5jEPNiHjemskUpVASBb9VtrO5JEYxA==
X-Received: by 2002:a17:902:b696:: with SMTP id c22mr2658532pls.305.1565090364731;
        Tue, 06 Aug 2019 04:19:24 -0700 (PDT)
X-Received: by 2002:a17:902:b696:: with SMTP id c22mr2658489pls.305.1565090364068;
        Tue, 06 Aug 2019 04:19:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565090364; cv=none;
        d=google.com; s=arc-20160816;
        b=wk3vp+5A2UUjuidmG4h9B1U9ia8S42QHzRFXI6VnKoBC52kgewQha/LACc8ZgubGVS
         ljkQfMH3SIBgqnZGj6cJXMauSQ8H+mGNz4j/ALvpDTBGzmGaRdBXjsJYaZTS1qG+Ujyv
         H/cn5no4XpNwvXJYXyXugFR8owLWAZwU28czRRhVw+k0ffVTIv3BMDUO+OObUWbImG2Q
         zYGKW1fWvWPpiSmOb5ulOUzS03UJWkqXYv2E4zMJguuQyRAHHmgMEgXyq+fEjasNGAU8
         0gbUeYRAgWrwmwSHQFDCYIk2xOLLRbhjM05Wk5naRt+4jpEPixFrUHtgos/M3JoXZ9RM
         n6MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jNBh4Uwy6QLd0fk5I8Y9B9xP/9fw2xkjlyVlCT+yndM=;
        b=ZG9hbvm2LsSl/wcM6QHgL54iYya+qOLlOH5SN7tbOFvumdekHXmEnhxANLKGHupHDX
         kAr6ahDSo81bYLOQqS7JowKz93T/9Sccbg5ftYXaIz3uHCEjlBsMLt8HWqd4hpSP/IoW
         Bfe2STHSG7Q5s28fDCZM2yMHIcnQjGsMi7YgxGGwvlKwJxa3J2ybXaFoqO0EXeuabhEH
         /fCc5axcbGsNI2coD9Xn7o+7JY/88sxCmo/JGH4AxzSCXZnJiXopSsnsi9TU/zhg+dJM
         khTiZpmaV6XkGhEBbcx76cQhU71RKVaXy2UX7UuE7VwGgOA31u0t+7Kdh1gU5rgjl2W0
         YbSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b="hT7m/kPE";
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v11sor24690944pju.18.2019.08.06.04.19.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 04:19:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b="hT7m/kPE";
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=jNBh4Uwy6QLd0fk5I8Y9B9xP/9fw2xkjlyVlCT+yndM=;
        b=hT7m/kPEBbfuocAKw5Xl9iF6rszGIOiOU1pdk9Yl9uQaoSvBKVDI9XOMkrfdb7LwCJ
         TwHeWzeGX8FvyMCo3V+QlzvodG0odf5bOEzj1zCP1QE3OBESAFt9TvXGZ4VZEvsAcJtG
         tqZe0a8M+Hv2lAOkMv1yerWslMxtF2wkEcWqQ=
X-Google-Smtp-Source: APXvYqywqnwTAaGR6Bs8KS7aVh05Rc6pWzLeu7k4oiw+pFIGujdN2uTYttGBWidHSRA8eyinnS/N7A==
X-Received: by 2002:a17:90a:c20e:: with SMTP id e14mr2839075pjt.0.1565090363666;
        Tue, 06 Aug 2019 04:19:23 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id w16sm109123479pfj.85.2019.08.06.04.19.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 04:19:22 -0700 (PDT)
Date: Tue, 6 Aug 2019 07:19:21 -0400
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
Message-ID: <20190806111921.GB117316@google.com>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-4-joel@joelfernandes.org>
 <20190806084357.GK11812@dhcp22.suse.cz>
 <20190806104554.GB218260@google.com>
 <20190806105149.GT11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806105149.GT11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 12:51:49PM +0200, Michal Hocko wrote:
> On Tue 06-08-19 06:45:54, Joel Fernandes wrote:
> > On Tue, Aug 06, 2019 at 10:43:57AM +0200, Michal Hocko wrote:
> > > On Mon 05-08-19 13:04:50, Joel Fernandes (Google) wrote:
> > > > During idle tracking, we see that sometimes faulted anon pages are in
> > > > pagevec but are not drained to LRU. Idle tracking considers pages only
> > > > on LRU. Drain all CPU's LRU before starting idle tracking.
> > > 
> > > Please expand on why does this matter enough to introduce a potentially
> > > expensinve draining which has to schedule a work on each CPU and wait
> > > for them to finish.
> > 
> > Sure, I can expand. I am able to find multiple issues involving this. One
> > issue looks like idle tracking is completely broken. It shows up in my
> > testing as if a page that is marked as idle is always "accessed" -- because
> > it was never marked as idle (due to not draining of pagevec).
> > 
> > The other issue shows up as a failure in my "swap test", with the following
> > sequence:
> > 1. Allocate some pages
> > 2. Write to them
> > 3. Mark them as idle                                    <--- fails
> > 4. Introduce some memory pressure to induce swapping.
> > 5. Check the swap bit I introduced in this series.      <--- fails to set idle
> >                                                              bit in swap PTE.
> > 
> > Draining the pagevec in advance fixes both of these issues.
> 
> This belongs to the changelog.

Sure, will add.


> > This operation even if expensive is only done once during the access of the
> > page_idle file. Did you have a better fix in mind?
> 
> Can we set the idle bit also for non-lru pages as long as they are
> reachable via pte?

Not at the moment with the current page idle tracking code. PageLRU(page)
flag is checked in page_idle_get_page().

Even if we could set it for non-LRU, the idle bit (page flag) would not be
cleared if page is not on LRU because page-reclaim code (page_referenced() I
believe) would not clear it. This whole mechanism depends on page-reclaim. Or
did I miss your point?


thanks,

 - Joel

