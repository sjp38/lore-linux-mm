Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A38F5C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:21:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70A3222BF5
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:21:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70A3222BF5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C44E8E000A; Wed, 24 Jul 2019 10:21:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09C318E0002; Wed, 24 Jul 2019 10:21:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF3A88E000A; Wed, 24 Jul 2019 10:21:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A30158E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:21:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i44so30336781eda.3
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:21:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tfiZf3FnbtNZYPJuZcMNmX1qt34YRctiSE8E3pvB9KY=;
        b=HjAts6KbK3my5ngWsm3Ng18CwnaRuAV2rVRSeLJo22rVbjayFlM6vIKrnIPbLprEa0
         AqhdMDag3hzM5bzBtBtIwAuBvSR5wN1sG7HCruIu8GGOxsFxuUFvNu5tNW/oGN/xu2RT
         zRfdWiQZH2XuUJcmDzIlV9O97YwddFPR8feMiRhvC04eY/JBLUP1esoLMxSGUBvhlMuR
         3pG4Pfx5b3snQ04C87UjKLtcQ2fbhghaoeErdGCm5YSjisrhysqQJ/+F7jJZwpQ4YwYt
         7BYGS21bI+gJxDG+K4mRNCOJRBHF2ku9SUB+SsiSVe6M2Cl3StbJF92+zAO5Q+zZpArm
         trpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAWiHcC9zP9I6CITvwomnDvExL16ts2usl9CWOfOmD8CtLqLsii6
	sDhMy7Vayp9nfP9Km2rLshwpZs4WckvQeyeX7e0Sx04oeeMXEEZL3pnOOgFbxKrHJuj4t4FbGZi
	XcGGDkcG3BvAT9NQb+n2xYDX2p9vAA0t1+mhL/knNZEWtz6w+tJTzVXwAEblC+YgzWg==
X-Received: by 2002:a05:6402:712:: with SMTP id w18mr69689990edx.201.1563978068233;
        Wed, 24 Jul 2019 07:21:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXykd+4eIDGw7ITnZ2RrrnY3h6IBXSpbvVgt3xb9jeHIPIrClPniCtgGMcDNanml46MtIK
X-Received: by 2002:a05:6402:712:: with SMTP id w18mr69689917edx.201.1563978067452;
        Wed, 24 Jul 2019 07:21:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563978067; cv=none;
        d=google.com; s=arc-20160816;
        b=h+NTb8EB6FOSjNBB05IK1jw0SJocCPHlmpVik/lO7zM4shxdT/mrFHKhJgZPdFGe9R
         lqFhQp+HHjevfCdhfgbgi+J5YmH8SQmuZnI3QI4UNmqDv2bcHs2BVaEy8eAH6UxEQO3G
         Efyh+/cMyUfhHwvnUPIyis8Qm7f/ZvVcT26yP46EYFcb0A7tSVj2tWWi7L0hDcBMDxjc
         TAlA7PqLpgzK0iP7fqEWAf3+LgsSw+AoFrf//Q8IWQe6i5Iy786W0WI9Saa0CqXDDUAD
         5Srw7DS8zX2J/xjtON/CJ5Fa8HYQWsL7RcHqEHh/furJn+Ru1FPfPBjEew/Uyzj4pSlT
         UDjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tfiZf3FnbtNZYPJuZcMNmX1qt34YRctiSE8E3pvB9KY=;
        b=Kc6+lXjwLd6UK/pvIpMEJectLNRlyb7yjnSsgNKOW/bpNHraZNJsBPkTzQ5vB4utWZ
         JC8fBHPCdgq7gdBIt8pcFNlAYYxSxNro6ovU/L8T0ggfko2vYxWeK8j8fS5ZZSULs1Oj
         eyXdiFHLoaE7dugfg5p6Kify2MsgnlpYamVV/7Z/3Roaa7h5JLUFq6OYYZISmCc9iovl
         VNrHJycJ1THuHH7A+E7BJBSxKUbFjnA63V1hY4KUIyLaHFHu0lBmybR8hzDE0XHJ2jH+
         Ep7AfQ+OuSehNCnWKlaibPb6aUmVM+mYzhoxar/Mpdr+Z0sHEcjMX1WpsZBq1W2GUsW+
         mJRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v26si7923084eju.206.2019.07.24.07.21.07
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 07:21:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4AFA328;
	Wed, 24 Jul 2019 07:21:06 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 761323F71A;
	Wed, 24 Jul 2019 07:21:01 -0700 (PDT)
Date: Wed, 24 Jul 2019 15:20:59 +0100
From: Will Deacon <will.deacon@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	dri-devel@lists.freedesktop.org, Kostya Serebryany <kcc@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
Message-ID: <20190724142059.GC21234@fuggles.cambridge.arm.com>
References: <cover.1563904656.git.andreyknvl@google.com>
 <CAAeHK+yc0D_nd7nTRsY4=qcSx+eQR0VLut3uXMf4NEiE-VpeCw@mail.gmail.com>
 <20190724140212.qzvbcx5j2gi5lcoj@willie-the-truck>
 <CAAeHK+xXzdQHpVXL7f1T2Ef2P7GwFmDMSaBH4VG8fT3=c_OnjQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xXzdQHpVXL7f1T2Ef2P7GwFmDMSaBH4VG8fT3=c_OnjQ@mail.gmail.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 04:16:49PM +0200, Andrey Konovalov wrote:
> On Wed, Jul 24, 2019 at 4:02 PM Will Deacon <will@kernel.org> wrote:
> > On Tue, Jul 23, 2019 at 08:03:29PM +0200, Andrey Konovalov wrote:
> > > On Tue, Jul 23, 2019 at 7:59 PM Andrey Konovalov <andreyknvl@google.com> wrote:
> > > >
> > > > === Overview
> > > >
> > > > arm64 has a feature called Top Byte Ignore, which allows to embed pointer
> > > > tags into the top byte of each pointer. Userspace programs (such as
> > > > HWASan, a memory debugging tool [1]) might use this feature and pass
> > > > tagged user pointers to the kernel through syscalls or other interfaces.
> > > >
> > > > Right now the kernel is already able to handle user faults with tagged
> > > > pointers, due to these patches:
> > > >
> > > > 1. 81cddd65 ("arm64: traps: fix userspace cache maintenance emulation on a
> > > >              tagged pointer")
> > > > 2. 7dcd9dd8 ("arm64: hw_breakpoint: fix watchpoint matching for tagged
> > > >               pointers")
> > > > 3. 276e9327 ("arm64: entry: improve data abort handling of tagged
> > > >               pointers")
> > > >
> > > > This patchset extends tagged pointer support to syscall arguments.
> >
> > [...]
> >
> > > Do you think this is ready to be merged?
> > >
> > > Should this go through the mm or the arm tree?
> >
> > I would certainly prefer to take at least the arm64 bits via the arm64 tree
> > (i.e. patches 1, 2 and 15). We also need a Documentation patch describing
> > the new ABI.
> 
> Sounds good! Should I post those patches together with the
> Documentation patches from Vincenzo as a separate patchset?

Yes, please (although as you say below, we need a new version of those
patches from Vincenzo to address the feedback on v5). The other thing I
should say is that I'd be happy to queue the other patches in the series
too, but some of them are missing acks from the relevant maintainers (e.g.
the mm/ and fs/ changes).

Will

