Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F15AEC32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:34:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A855721872
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:34:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="fgAle9Op"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A855721872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4848B6B0003; Wed,  7 Aug 2019 17:34:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4353B6B0006; Wed,  7 Aug 2019 17:34:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FCD46B0007; Wed,  7 Aug 2019 17:34:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECC1A6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 17:34:47 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q1so695337pgt.2
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 14:34:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=L+M4+2pGsDRUyWSE4KWHyF4gGN/CTdrXfy8qftEaVU8=;
        b=IeE3s87hWSmYHol8yifw8XgaiDGu3anLy0z5fe1+eZ+mLLO2/2KcZoVfZ0bGKtw9mt
         F553HC3QxfBNi4GHjKt2Hw4gEoEyDupcR8auLsHALXUG/5S/StmMNf6JDGubk92LhzSg
         t+3RWhc51kMsn4SqUkHb7Jlzaai043H1HKorknq2+rjUGsrl+D3pZStI7eV29RsQ4Xx/
         Vt/bOUiVM3bruJ8T708QfO2fnbP34SQSD7ed9hy1ELBVIRXDuet0RgSviSxRTzxlQBhb
         WjmTKoVwOzVDVcBDPuFe5TohmpiQDHI4yw/cBx6+OrqFvsDIBeKZgNaeirE9mg8T9IDO
         PXiA==
X-Gm-Message-State: APjAAAUeMOYVqPPaWBVNxi68HNQwqRsfjVpIdHOl6+q0AiQKKBqBG5iw
	zXJHLKXKncHskR3OVpsB7nW56swslHW/zNKjsL9LPyzpoV05inWyotJyyB0CVXf7gONRpo0lfNB
	NYtDfxWDLaLodAbnk9ht9J9u727vnzl837aNO/87Botyadf3+rTmcY/YCBTSZ3IUvsg==
X-Received: by 2002:a17:902:ba8b:: with SMTP id k11mr10118435pls.107.1565213687576;
        Wed, 07 Aug 2019 14:34:47 -0700 (PDT)
X-Received: by 2002:a17:902:ba8b:: with SMTP id k11mr10118387pls.107.1565213686861;
        Wed, 07 Aug 2019 14:34:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565213686; cv=none;
        d=google.com; s=arc-20160816;
        b=JiG0XsXO7dhpL5rMzC3kpuZLsiURRUxI7k52jEEW6GEw6pQXZBCOA9Tf1dx9DhO/DP
         VanPseI3ZfnF7ZAfne997ee4YaCMM3XH/K3ySsZgvTY5qNJNWKncqI58MeNaDD3IX9ZU
         8RNiDM5SingiPDIBlwHCd6h3WJvTeq9hdm4QE/e2B3B7UNE4dOqCW53Kxkg1AJ5jPxFp
         fPc0LB+id64j3/dySU6V5hNWU+qXLUDeg+hHo/MFz5drly7omoIiqrFeMYH/rgwfPfPH
         4zOiu1IP+F1eYTTjFoHfoGmOUBNACYJm8f6fHdgXCVPuJgFT8WTYcXxtMCFlC3woeMkn
         IaEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=L+M4+2pGsDRUyWSE4KWHyF4gGN/CTdrXfy8qftEaVU8=;
        b=EZP1In0e8bOF7LOpnhUZaFZfw4Ry6gzPFWNmiYGvQPkTP5i2zL3DXn00YG2RzBxY2a
         LeFj7RhxaGyL6SiShIHwKQ8nNgMDrcEUHC2EDcmbeLd3GptWcCyc82kvb0ZWWj94Dnh1
         NpOpkv6Zxh5tZQP1A443eD6JKZqHuA6GY4t/eLAZVYr/zYIsohPpLKF/BoAL0ga4Ep5d
         mupLEHYxOKj7K1Np7l9MsANWSR8BHkXZ3bD8hRVi8SvI3qRVDjyq9XOSnGg/hBiwQDZ9
         f4fMSqxWAdXvEu46ciwbIJqw0/4Rl70SAGHRzy4gI3zj3beZ9WYp40s/U2k2W6mDuccm
         AywQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=fgAle9Op;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 31sor64740052pgy.17.2019.08.07.14.34.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 14:34:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=fgAle9Op;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=L+M4+2pGsDRUyWSE4KWHyF4gGN/CTdrXfy8qftEaVU8=;
        b=fgAle9OpDpnJ7GKQv0WtHbnZoKzcB8hPE4HOnQKm0VzYK81k8Q7cif033smKCs6zXw
         UxFxvbTClbbOkt2DzoYqMPsWd/JtUR6WO/58/L6gGzELqNPyroeUg1AQD8SOr0c1Tt80
         ondZOC7Xw7YyiyOFPPNOS67ELbBfwxbTaqzUZ/2NpGl9wW+yd5G/1UTq5bmKSivBOJNk
         Myiix8N6eWA5kgUgyOtBLebt4+a81tQ5C+Foveh+lL7Te+X1eQ5mi29r6dV5y5lm+CMQ
         inJiYzjr2BoXWtPGe/7WyAz1JuhnIy2buR4K9S+62kEZ8/xkaLWQome9OUbJHLbDCf5y
         3Emw==
X-Google-Smtp-Source: APXvYqx9Uyn/xw2tiJ8g/Ou75InfUAPJucpury6bca7dwFHlpwvJgJOH8wkakJmYsrVu3gqwJHNNlw==
X-Received: by 2002:a63:1f1b:: with SMTP id f27mr9431471pgf.233.1565213686124;
        Wed, 07 Aug 2019 14:34:46 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:f7c1])
        by smtp.gmail.com with ESMTPSA id y14sm45924523pge.7.2019.08.07.14.34.45
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 14:34:45 -0700 (PDT)
Date: Wed, 7 Aug 2019 17:34:43 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190807213443.GA11227@cmpxchg.org>
References: <20190805193148.GB4128@cmpxchg.org>
 <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
 <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
 <20190806142728.GA12107@cmpxchg.org>
 <20190806143608.GE11812@dhcp22.suse.cz>
 <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org>
 <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org>
 <20190807140130.7418e783654a9c53e6b6cd1b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807140130.7418e783654a9c53e6b6cd1b@linux-foundation.org>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 02:01:30PM -0700, Andrew Morton wrote:
> On Wed, 7 Aug 2019 16:51:38 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > However, eb414681d5a0 ("psi: pressure stall information for CPU,
> > memory, and IO") introduced a memory pressure metric that quantifies
> > the share of wallclock time in which userspace waits on reclaim,
> > refaults, swapins. By using absolute time, it encodes all the above
> > mentioned variables of hardware capacity and workload behavior. When
> > memory pressure is 40%, it means that 40% of the time the workload is
> > stalled on memory, period. This is the actual measure for the lack of
> > forward progress that users can experience. It's also something they
> > expect the kernel to manage and remedy if it becomes non-existent.
> > 
> > To accomplish this, this patch implements a thrashing cutoff for the
> > OOM killer. If the kernel determines a sustained high level of memory
> > pressure, and thus a lack of forward progress in userspace, it will
> > trigger the OOM killer to reduce memory contention.
> > 
> > Per default, the OOM killer will engage after 15 seconds of at least
> > 80% memory pressure. These values are tunable via sysctls
> > vm.thrashing_oom_period and vm.thrashing_oom_level.
> 
> Could be implemented in userspace?
> </troll>

We do in fact do this with oomd.

But it requires a comprehensive cgroup setup, with complete memory and
IO isolation, to protect that daemon from the memory pressure and
excessive paging of the rest of the system (mlock doesn't really cut
it because you need to potentially allocate quite a few proc dentries
and inodes just to walk the process tree and determine a kill target).

In a fleet that works fine, since we need to maintain that cgroup
infra anyway. But for other users, that's a lot of stack for basic
"don't hang forever if I allocate too much memory" functionality.

