Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61B0BC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 16:26:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14BDF206E0
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 16:26:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oSxV5e5b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14BDF206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CFED8E0003; Fri, 26 Jul 2019 12:26:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 959568E0002; Fri, 26 Jul 2019 12:26:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8204F8E0003; Fri, 26 Jul 2019 12:26:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6130A8E0002
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 12:26:21 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id p12so59220472iog.19
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:26:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=49yfm4zari4iNgyc4c8iUnGnNiF8H5iDhklR2GX7QUY=;
        b=eaTKsFiH0xE97DQEWas0HqLARwySZuaGsijNLxlq+00txV/vyEEKAWo9lkCPKEvm3g
         MEcQD/VrHKA6jPhbfEa5NctBVZ7tvyY0cz1fKzq0wjX6D5KUqHym63B5G9USGxInoo4A
         Z0H32eGFM88xfvaX/tpQ+2iVjmqE+RNDOqAOtZ0vT/KFq26mx45968wHqUqMzGNEQ3Of
         i3ZrYG+ayPyNgumAvV4JQW8wix7g5x1CbMVMzMlgJZ37qXbTkQZzQfsNN4wS3QOnbacf
         heQluM4uwHwkFOVShSpHyEg/dRqCRylMS2wDYXHZ7JLVEfvPAxMOXiTHXOhJhur/+9KO
         cNGQ==
X-Gm-Message-State: APjAAAUgr53q25jq4s8OngO8bZ2CuNYmyagJPRslHoUBoHLDmT6srE5R
	8z/cuqpjaZ+gSoi7EGnOxvVsAVbJGFk4yUNiRxaBh0UpkscY45irNFYc/XXQXadNKrKa9wWm5dz
	FQPty/5xIecCv7C555anT5ftXFsFpcd+TOxg0UG4lXSeTVVp5M1VepW/BkP42JCF75A==
X-Received: by 2002:a02:ac09:: with SMTP id a9mr12982877jao.48.1564158381146;
        Fri, 26 Jul 2019 09:26:21 -0700 (PDT)
X-Received: by 2002:a02:ac09:: with SMTP id a9mr12982828jao.48.1564158380410;
        Fri, 26 Jul 2019 09:26:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564158380; cv=none;
        d=google.com; s=arc-20160816;
        b=mbHtF/80MeHYdOHp8WtD9bDHtR+8YWkL1Pkrvh0j+CZEQvdt6ELGtgbry7e1vr++Bx
         S+jM3nXlVpVKF9Smk34fwFsypAHO8KkjKI/CJLdUCG9dnaIqui88jLwc/pXPsnQPY7Yz
         JgJkbKkgu7GBXVJSXcs8TP05XdqEoCttNQT4RSur4mFP3Ry1vXnQHzjxawp3UBYJrN90
         HVuNP8m4IStngLL7tob6PY8ANwLZeLM+bqeTsTPtxsVQ/nMuFMF0sDE2FYX6463NX5/d
         MZTWTLLbevARnAPlHRYx+kHsvLfB8LhTEVQkgU+XdQDfih/ZNYLWCpjdZKpix2v2E+x8
         H8vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=49yfm4zari4iNgyc4c8iUnGnNiF8H5iDhklR2GX7QUY=;
        b=ynq+KaBDOpP/a7cvKClAUQYQHWSOr5tcUEPHwP5ao5U2bKoSHIbEsxLipdmPQsWH07
         lc2q8uB1CH8bKmsrm2/bfEeB+fJcrqjQ0TNb+Ja40NwrEMpFUFDQZNPbrxYvXbJkWAW8
         VKhihiSa8jhcWckO4BYP0ZySFdls18XmgXr4vv+TxsCyoAtKGcWvN3504/eP33JBXDz+
         rbJxyc42keRnDifttVDL6aDGhwN3wdx/An5kv+DY9cOV9WhwR31PKTTeBQcdMp73dMob
         YP2r1lwmH3dAl4yCHUsun93uz6y8kZflb2zhrXCM+betFM6mgYGbkRaJ1+byaO3HYsMc
         k5FA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oSxV5e5b;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d21sor37397978ioc.57.2019.07.26.09.26.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 09:26:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oSxV5e5b;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=49yfm4zari4iNgyc4c8iUnGnNiF8H5iDhklR2GX7QUY=;
        b=oSxV5e5bNKAEOl0HwhKJhFqS6oocpVP8oUntBD5al/WdfjqqJtsIfjWUwUDx29tEVj
         Ocox6SNSxTgTxci3S8uus+9f4v048jOPUOqwuyvdGpFBolmfQvjuixpWQTQ5t5g8nuwr
         Sy9w9ffMso7C/QX4f1ZEvHSPRs5SJNYv6cimfjMXpAyHuG6KjU7Rsm1uupYDv1xHZZxm
         U9VXVqwxnRXp45lR+vyNSgiPcH8dTiR7z+dw7MCbH2Yt6OKPOLKCfrRN86ogxLxP1o2E
         CbNgCMUgLLBu374M3UiEjVmgk6BDWDqRqVAPodQaRsA6oqmCQhhul6kJGPCrPdH4BVfB
         3cNg==
X-Google-Smtp-Source: APXvYqyjf4GbmLPhL55X+s5p3TCQUBLJfRXVKJ2wZzfFHaTvxUziKKWb5psRA8Z3KyOrSCo3gRDt5OcQAS+5PqQqTdQ=
X-Received: by 2002:a5d:80d6:: with SMTP id h22mr65658210ior.231.1564158379700;
 Fri, 26 Jul 2019 09:26:19 -0700 (PDT)
MIME-Version: 1.0
References: <00000000000052ad6b058e722ba4@google.com> <20190726130013.GC2368@arrakis.emea.arm.com>
 <CACT4Y+b5H4jvY34iT2K0m6a2HCpzgKd3dtv+YFsApp=-18B+pw@mail.gmail.com>
 <20190726155732.GA30211@e109758.arm.com> <CACT4Y+Zf-p7CTRZd8x+2ymAXho2tM_5hLCn3ODJXPVuocMxwbw@mail.gmail.com>
 <20190726161530.GE2368@arrakis.emea.arm.com>
In-Reply-To: <20190726161530.GE2368@arrakis.emea.arm.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 26 Jul 2019 18:26:08 +0200
Message-ID: <CACT4Y+bDSnocDe_VB4VhXaJv+q83YMnvpn+KCuW3hENiBfCNTw@mail.gmail.com>
Subject: Re: memory leak in vq_meta_prefetch
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: syzbot <syzbot+a871c1e6ea00685e73d7@syzkaller.appspotmail.com>, 
	alexandre.belloni@free-electrons.com, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, nicolas.ferre@atmel.com, Rob Herring <robh@kernel.org>, 
	sre@kernel.org, syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 6:15 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > > > On Wed, Jul 24, 2019 at 12:18:07PM -0700, syzbot wrote:
> > > > > > syzbot found the following crash on:
> > > > > >
> > > > > > HEAD commit:    c6dd78fc Merge branch 'x86-urgent-for-linus' of git://git...
> > > > > > git tree:       upstream
> > > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=15fffef4600000
> > > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=8de7d700ea5ac607
> > > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=a871c1e6ea00685e73d7
> > > > > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=127b0334600000
> > > > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12609e94600000
> > > > > >
> > > > > > The bug was bisected to:
> > > > > >
> > > > > > commit 0e5f7d0b39e1f184dc25e3adb580c79e85332167
> > > > > > Author: Nicolas Ferre <nicolas.ferre@atmel.com>
> > > > > > Date:   Wed Mar 16 13:19:49 2016 +0000
> > > > > >
> > > > > >     ARM: dts: at91: shdwc binding: add new shutdown controller documentation
> > > > >
> > > > > That's another wrong commit identification (a documentation patch should
> > > > > not cause a memory leak).
> > > > >
> > > > > I don't really think kmemleak, with its relatively high rate of false
> > > > > positives, is suitable for automated testing like syzbot. You could
> > > >
> > > > Do you mean automated testing in general, or bisection only?
> > > > The wrong commit identification is related to bisection only, but you
> > > > generalized it to automated testing in general. So which exactly you
> > > > mean?
> > >
> > > I probably meant both. In terms of automated testing and reporting, if
> > > the false positives rate is high, people start ignoring the reports. So
> > > it requires some human checking first (or make the tool more robust).
> [...]
> > Do you have any data points wrt automated testing in general? This
> > disagrees with what I see.
>
> I'm fine with automated testing in general. Just that automated
> reporting for kmemleak could be improved a bit to reduce the false
> positives (e.g. run it a few times to confirm that it is a real leak).


I did a bunch of various external measures in syzkaller to improve
kmemleak quality. As far as I see the current rate is close to 100%
true positives. We already have 40 leaks (>50%) fixed.

Though, kmemleak can be improved too (stop-the-world, etc what we
discussed). That would make kmemleak directly usable e.g. during
unit-testing, something that's badly needed for kernel.


> Just to be clear, I'm not talking about syzbot in general, it's a great
> tool, only about improving kmemleak reporting and bisecting.

