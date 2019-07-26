Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65704C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 16:05:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 046A32189F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 16:05:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="K/SemTMC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 046A32189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65DAD8E0003; Fri, 26 Jul 2019 12:05:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60D558E0002; Fri, 26 Jul 2019 12:05:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FB878E0003; Fri, 26 Jul 2019 12:05:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 31E938E0002
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 12:05:47 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id h4so59315780iol.5
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:05:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AoOpJrER5lkg8Em3wVFNio3C8LuUFynD4kdmk02EVZ0=;
        b=BZW8QaWLcZWEBDXndH1uuMbY3w5KJ6545YhLHFvmeJiWXJILSwd5DZLOlAblyeu82M
         ImKGHRik5KQI1Xhgj+gf240scPrEUw4mbF65YgdhShPxbJkq6DeCXpSW2YBfKR24I+vH
         yXkIJxPCB1dvuqtFt2IzaJ0G0Y7lrZpEMxhq2si1hVr9PlzKPigSEtEu1rhTElzE+kOp
         ZJk1OYVUmE2K9FxKpAleMzFjHIQ+FXtSnGUDIlPUqgiz6QjJF0PjyX7d2xssgVcW/z+A
         2q36cC6PTq8GpfhNevViRkZBRxhBg6oMBjixpvvoXX8o9qxtLaUqsiVVd2GHRuqkCJZi
         BINA==
X-Gm-Message-State: APjAAAUaQiU5JsWHbz+lxvkC1yOxVhPS6pcvtl4LWLdhX9uQOSQ7AkuT
	eQgTBZxgzE7xevGQmnYSAdeY+P6l6Mb8KYIj+1nU095z8hJCUmZmFsZnnmYlHbnDaXa9s6bLrq0
	N1fCKNRbAYSBSlGwRcclBLlS0KOu1O++jk/ePJSnNgzmkQE+2zUVos+KYB4vjXH/J1g==
X-Received: by 2002:a05:6602:cc:: with SMTP id z12mr68843846ioe.86.1564157146894;
        Fri, 26 Jul 2019 09:05:46 -0700 (PDT)
X-Received: by 2002:a05:6602:cc:: with SMTP id z12mr68843773ioe.86.1564157146134;
        Fri, 26 Jul 2019 09:05:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564157146; cv=none;
        d=google.com; s=arc-20160816;
        b=cqZ1KEWpfVjQzvLPCjdgzD70SIc/sBsnC5id5AAlc0MyDmfGnaIDlbZqMnoBfrozMw
         bp0ybLz5nRMwl2+E38OeJey5IG9orsG0hVxPXta5mZfAx4ReR1znKK49PYdaJVtO/2Wo
         Qdv72mT8AYouIwywKRMn83ROYok8MD4s6VgLNpVZidjK06SJnW5GMeFd33OyB00jb2JU
         M5x1Rp9UIAA0qPpyRtm9N4iSyOL5YXp0CfncTyIBqN8UOeqlkNwjOr9NkbmROVw4MRb+
         9WfCfsunXKsoBtEPfDW1jWN29+h4PtEH8mj3m/yAHzgCvKMNTjrCaxkUM02vxNCW6T+B
         9n/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AoOpJrER5lkg8Em3wVFNio3C8LuUFynD4kdmk02EVZ0=;
        b=KSErOJGytZAsX8uz4md4Og86++uyuil7oSfolhGuSeSi5AzVZR8Qtka40GSYTotb5E
         Ka75bhVJPW536YX0UWJQkcecUcOZMTiYkQ/S1o35lP+lgyCWNhWrfUwQxYajnE9IFVFU
         j7xdbZMlFO5pfL+4dqZkiU2LIptYY9yCVEQ/yBnAxjlo45ywF+c9ygNmojDsEoUrkK5r
         PCVJgT0GI4a6AZxXp91E/zw8xuwZ3M4g4sSsqUNBoCLkmFQMCcBux2cr/pAVncc1+ruX
         ySE9eSCPwZfQXS0ThOSOhnuppt0ZUMQxk5qXi9ARfXtIsZ0C292z4gobq6Cagl2IbnGo
         xp5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="K/SemTMC";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a3sor36461187ioh.83.2019.07.26.09.05.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 09:05:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="K/SemTMC";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AoOpJrER5lkg8Em3wVFNio3C8LuUFynD4kdmk02EVZ0=;
        b=K/SemTMCiXyHQbxfV2/uM8winVoyG6FtMvMdX/B+Oqq2d1DvUDoowKjgxlbhSDPVEP
         6N2KrxCjCa3L6kPlOHoOmcyt4p29enh4lTg2fySZvfq2wqMET4gI9XXsxGYZQ30Zgxpx
         1Yd6fx1meAwrU3ECP7TW7HHVeOujY4aD4OjAWxDNBjmUMU8gThZsy3oReR5/++8YoNjg
         9YtuwFes1R2FIKfjGXpy8bFLIVBn75lR8c8VZYeGaDyXzPNEgxkWlL6wjU4v0Qch10d4
         xXy75iwQ/8GTCO7xHgzprutgoPpUT5Cs21giNQHKN69g1Xz2CFHIezxUic9NvJFMkz/a
         yw1Q==
X-Google-Smtp-Source: APXvYqx1DMdxq/O+3koIzpoMVm15SRd82G8zIAIH2kBNUwLkI3sjNquWgQypNmv9GFwq6RmdFU5SwnkJU44a6givHcA=
X-Received: by 2002:a6b:4101:: with SMTP id n1mr61984828ioa.138.1564157145336;
 Fri, 26 Jul 2019 09:05:45 -0700 (PDT)
MIME-Version: 1.0
References: <00000000000052ad6b058e722ba4@google.com> <20190726130013.GC2368@arrakis.emea.arm.com>
 <CACT4Y+b5H4jvY34iT2K0m6a2HCpzgKd3dtv+YFsApp=-18B+pw@mail.gmail.com> <20190726155732.GA30211@e109758.arm.com>
In-Reply-To: <20190726155732.GA30211@e109758.arm.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 26 Jul 2019 18:05:32 +0200
Message-ID: <CACT4Y+Zf-p7CTRZd8x+2ymAXho2tM_5hLCn3ODJXPVuocMxwbw@mail.gmail.com>
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

On Fri, Jul 26, 2019 at 5:57 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Fri, Jul 26, 2019 at 05:20:55PM +0200, Dmitry Vyukov wrote:
> > On Fri, Jul 26, 2019 at 3:00 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > On Wed, Jul 24, 2019 at 12:18:07PM -0700, syzbot wrote:
> > > > syzbot found the following crash on:
> > > >
> > > > HEAD commit:    c6dd78fc Merge branch 'x86-urgent-for-linus' of git://git...
> > > > git tree:       upstream
> > > > console output: https://syzkaller.appspot.com/x/log.txt?x=15fffef4600000
> > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=8de7d700ea5ac607
> > > > dashboard link: https://syzkaller.appspot.com/bug?extid=a871c1e6ea00685e73d7
> > > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=127b0334600000
> > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12609e94600000
> > > >
> > > > The bug was bisected to:
> > > >
> > > > commit 0e5f7d0b39e1f184dc25e3adb580c79e85332167
> > > > Author: Nicolas Ferre <nicolas.ferre@atmel.com>
> > > > Date:   Wed Mar 16 13:19:49 2016 +0000
> > > >
> > > >     ARM: dts: at91: shdwc binding: add new shutdown controller documentation
> > >
> > > That's another wrong commit identification (a documentation patch should
> > > not cause a memory leak).
> > >
> > > I don't really think kmemleak, with its relatively high rate of false
> > > positives, is suitable for automated testing like syzbot. You could
> >
> > Do you mean automated testing in general, or bisection only?
> > The wrong commit identification is related to bisection only, but you
> > generalized it to automated testing in general. So which exactly you
> > mean?
>
> I probably meant both. In terms of automated testing and reporting, if
> the false positives rate is high, people start ignoring the reports. So
> it requires some human checking first (or make the tool more robust).
>
> W.r.t. bisection, the false negatives (rather than positives) will cause
> the tool to miss the problematic commit and misreport. I'm not sure you
> can make the reporting deterministic on successive runs given that you
> changed the kernel HEAD (for bisection). But it may get better if you
> have a "stopscan" kmemleak option which freezes the machine during
> scanning (it has been discussed in the past but I really struggle to
> find time to work on it; any help appreciated ;)).


Do you have any data points wrt automated testing in general? This
disagrees with what I see.

For bisection, I agree. Need to look at the data we got over the past
days when it become enabled. But I suspect that, yes, false positives,
flakes, and other true leaks can make it infeasible.

