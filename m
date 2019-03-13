Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCD5FC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:36:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FB602087C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:36:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FB602087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC6D08E0004; Wed, 13 Mar 2019 10:36:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C76928E0001; Wed, 13 Mar 2019 10:36:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B422C8E0004; Wed, 13 Mar 2019 10:36:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB1D8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 10:36:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x47so1011186eda.8
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 07:36:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pb2LhFbExs3nNra6kNtHd+/OsnC5ydhq5f0Rc0CLgt0=;
        b=gspOCOq3C5lCVp01m6r/Wniky8R3d58/gmcKsYqHoxAcSSKCeSStMpl8r/BVZqgFoS
         DdUS/zT0/jQ9cStpKUYoe21kEHrpaUThK1wibeXKPgV0aCp+LuP8uz2rxWT3hkuaazOu
         dv/OMjzkWylsnqkOGfubk794nZ4vrHfJlaNOJfdNVrlzqfthxqSyX1leqWYUzfa6sDaG
         n8gsc5VgQOZo0teKZ1Xea5TSTb7S5+OCIvLTd+TnsPQzeZDNbKDQEDmJt0+TUW6DgmME
         eW1S2WjS5hgcJhyxF7yjms6NRnCoWd1iL3bwKRZ2DxcJ8txQeX9CG4ZA2LrSjrVcoaNR
         Svxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAWA+MBWpqFXF3TmmgRuGBm+H5v9EqnFySOYdZeAqVa/tcMQKNAA
	4HzYSmHm5eHp3vSlgq1LQN4GMyNvIIdciMOMAawuqgkocsFSuEwM0ZisOAXFU2mw41Ov4Lh0RTI
	2PE3BHrzgjsISHeuSGF/uWuLZwUiZ57NQuvHLbAQzQN6V6lS5rMzNGe+0uwN0H5l42A==
X-Received: by 2002:a17:906:3050:: with SMTP id d16mr30098066ejd.200.1552487764954;
        Wed, 13 Mar 2019 07:36:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyixze6C6jVEwxlJ7xKci53lCdrl2CfuXq7rLa5xEo01EV8S04/DaQE/8rkn6VK3H+AM93Q
X-Received: by 2002:a17:906:3050:: with SMTP id d16mr30098018ejd.200.1552487764045;
        Wed, 13 Mar 2019 07:36:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552487764; cv=none;
        d=google.com; s=arc-20160816;
        b=TVhkg5Pd/ugAFqzlrgtECML/RbR8Yu7dyY6/2yiNNCJhZg28O6g3aHBg1HaPIEhfnH
         gCDZHqSa/QXhPUJ/kLnBFCVMURTG5375XTvobV3tgosbwuTftlZTvGAVeV+/RWeIFPbL
         AuQFtFWMkL9vCBlCNLKxws8/mTaLrqvLApICCkh5XrJN8uHzDlDvXX9tf9M3D/Wc4z/W
         HzTaXtLJZL0jYbZ6CLuFpemuOZ5M/QfQ7kIpG2ACOAJmJycUv72xgpzGkJoDJmMSgFnJ
         0YBr30IkgNNW4KYAtj8wOGPd2jNVLsC+SsjzU2dsq/4NXOVBN8v40+ZjzSWMl3GOpHtY
         lFlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pb2LhFbExs3nNra6kNtHd+/OsnC5ydhq5f0Rc0CLgt0=;
        b=K93f0x6h+yxAjAUjeDW/3JhwSPJQsqNU/RRE75K5R5k8zh1kvN06jIbjECxbvZk2mq
         C3UvDI4cXPrrE7DNHA9DHkzQ/9AMvRxY1eLpJ9vXt5mawzl51dJ51CmpiOS1tFbzHFDE
         0P3vP+M8Hkl80TIiJiBBmrBhMZQZkUDQl7OWdwUdw+hr3Dlri9g/56dCVAWRQkEdISrp
         cTibA/oDDxDyc9aS+ZgQCeBeSpNqv6LFxM3ztFhDGeKcGtWo1MhYUEgw+Tm6VHJOaZe5
         QHb91wzZLD46c/y1IwcqgvYiVnlIWsrrsTy7jirrJaMFcYtqufJPSxS2+Lt8TKUgSDlG
         40Sw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g11si413371edf.313.2019.03.13.07.36.03
        for <linux-mm@kvack.org>;
        Wed, 13 Mar 2019 07:36:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 02F6280D;
	Wed, 13 Mar 2019 07:36:03 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9FD403F614;
	Wed, 13 Mar 2019 07:36:01 -0700 (PDT)
Date: Wed, 13 Mar 2019 14:35:53 +0000
From: Mark Rutland <mark.rutland@arm.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Qian Cai <cai@lca.pw>,
	Jason Gunthorpe <jgg@mellanox.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
Message-ID: <20190313143552.GA39315@lakrids.cambridge.arm.com>
References: <20190310183051.87303-1-cai@lca.pw>
 <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
 <20190311122100.GF22862@mellanox.com>
 <1552312822.7087.11.camel@lca.pw>
 <CAK8P3a0QB7+oPz4sfbW_g2EGZZmC=LMEnkMNLCW_FD=fEZoQPA@mail.gmail.com>
 <20190313091844.GA24390@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313091844.GA24390@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 10:18:44AM +0100, Peter Zijlstra wrote:
> On Mon, Mar 11, 2019 at 03:20:04PM +0100, Arnd Bergmann wrote:
> > On Mon, Mar 11, 2019 at 3:00 PM Qian Cai <cai@lca.pw> wrote:
> > >
> > > On Mon, 2019-03-11 at 12:21 +0000, Jason Gunthorpe wrote:
> > > > On Sun, Mar 10, 2019 at 08:58:15PM -0700, Davidlohr Bueso wrote:
> > > > > On Sun, 10 Mar 2019, Qian Cai wrote:
> > > >
> > > > Not saying this patch shouldn't go ahead..
> > > >
> > > > But is there a special reason the atomic64*'s on ppc don't use the u64
> > > > type like other archs? Seems like a better thing to fix than adding
> > > > casts all over the place.
> 
> s64 if anything, atomic stuff is signed (although since we have -fwrapv
> it doesn't matter one whit).
> 
> > > A bit of history here,
> > >
> > > https://patchwork.kernel.org/patch/7344011/#15495901
> > 
> > Ah, I had already forgotten about that discussion.
> > 
> > At least the atomic_long part we discussed there has been resolved now
> > as part of commit b5d47ef9ea5c ("locking/atomics: Switch to generated
> > atomic-long").
> > 
> > Adding Mark Rutland to Cc, maybe he has some ideas of how to use
> > the infrastructure he added to use consistent types for atomic64()
> > on the remaining 64-bit architectures.
> 
> A quick count shows there's only 5 definitions of atomic64_t in the
> tree, it would be trivial to align them on type.
> 
> $ git grep "} atomic64_t"
> arch/arc/include/asm/atomic.h:} atomic64_t;
> arch/arm/include/asm/atomic.h:} atomic64_t;
> arch/x86/include/asm/atomic64_32.h:} atomic64_t;
> include/asm-generic/atomic64.h:} atomic64_t;
> include/linux/types.h:} atomic64_t;
> 
> Note that the one used in _most_ cases, is the one from linux/types.h,
> and that is using 'long'. The others, all typically on ILP32 platforms,
> obviously must use long long.
> 
> I have no objection to changing the types.h one to long long or all of
> them to s64. It really shouldn't matter at all.

I think that using s64 consistently (with any necessary alignment
annotation) makes the most sense. That's unambigious, and what the
common headers now use.

Now that the scripted atomics are merged, I'd like to move arches over
to arch_atomic_*(), so the argument and return types will become s64
everywhere.

Thanks,
Mark.

