Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92045C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:57:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62F4421951
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:57:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62F4421951
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F155D6B0005; Fri, 26 Jul 2019 11:57:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC84F8E0003; Fri, 26 Jul 2019 11:57:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8F488E0002; Fri, 26 Jul 2019 11:57:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3516B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 11:57:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so34386834eda.2
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:57:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4633w728CXGgf0AmyOavmLCQnzkq443JLhtFjOezZEg=;
        b=CGlJ6SdIRSNEON4KqsmqRPYvxk0DJH/A4xmjv3Xd6mcZQbyNzHXklLUq5Ftl36XilX
         CfQ/+rwxstQfodbQLjgFsBqThc9SNcEjL9G2A/1LBTgkOVWuo1t+UQd+tq/uqwPs/kdE
         ow8V/QJKypDS7gNXtAIqZq+QDIcDZb72Vb6W4Z8PcyTNnKakbz63yaSMkn6kWhfFNNUi
         S7zqQwydd+5Nhy4gsq7NEvlcMik60ReaEA7DXXDCIKmcHWm+/fA6zPsijj1sdHn2SsL4
         HpBZI6u/GwNVl20uSm0rPoJQBYhHalhMd1IgDOAkwLJtzmKSB9ptfoH8Y9MB0mNm0PoG
         Eibw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXKi59s/B4uP8z8iyR3XDmbnp37iBZdKxuqYcriEB6VSp9wEBm9
	SZYOCV+XUzamcr/b2JTNDPpwbci8SHu3sAr9OXELxPj8lF1ltz1tycBOY/YDEP9wAr/JsUBt5Bi
	Xa4NtDuYc3EMvHSm2QuuAuvtyniLLzBVURfgLKSp/8tVPvBEGJC+XetDUBPyTRycScg==
X-Received: by 2002:a17:906:45d7:: with SMTP id z23mr48256673ejq.54.1564156659133;
        Fri, 26 Jul 2019 08:57:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhV5yiuSkBZnVSmK1s8xo6b79bIKmYtDfAfK6cLL0zWsnd33kTtuIsZKue9peFOIejs2rQ
X-Received: by 2002:a17:906:45d7:: with SMTP id z23mr48256622ejq.54.1564156658343;
        Fri, 26 Jul 2019 08:57:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564156658; cv=none;
        d=google.com; s=arc-20160816;
        b=GDA6S7sS0GqtZoci6oUhW2Qe7l09AUt256ifL8OVFTcThKSCbIxpJfiqW3kCxVMNUV
         8MAkKc5qrQ5CbDA3lWyeV+mlHl2QPWNz78+0bd6CgUBInMlFmUulHtZZdc5FprWSVFOR
         xQwf21s3ndR+Zuz+OqP4t6gJNZNSkVQPiNh6hEwdN4ndVzX3/S6aRdFnBS6vqXzTYbtK
         ovouTVsALQGVo7OVDz3pgnUgpe12mSCbpuNVRZKeRJug7mMSoaEsCvvJE5ESt7/7Ytgs
         iXRO0zZVjWQ+L45inkCNq0fJd+CfZRpotvhgS2YFaQkvYt2f/PTbnEwH7U/Cr+eaZxwj
         72OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4633w728CXGgf0AmyOavmLCQnzkq443JLhtFjOezZEg=;
        b=tuHSrdKJI5lZuVy0NNSyofBk/K0WUP+SO7mKOjgKYb1rUd7hGScmsXIKLt8WFlg8zP
         HokxKWVAMWJpva6/0YEskPLqDnnPucby9DraVJDUSrbGeTHP+hT/nxZv9BORJz5vnPSf
         GUW8rNS2g16Eu6jhQd+IBK2ILV7SwPpz5l8FpZbqD5mNvLNzHMvNOLe24Bco1wW49Hke
         KX/wbMkR5hCCM0zUvvX/1X0VEuxZzgOI/aQUCNpYhq+5R9efWQPyZrerOdUjNWxdLZ86
         9nlOyB32KtqKfYOJjrQcNrf0bF9oCwbs1ZSZ0jwXBIrMATyzbl8+/9O7U+btFqlCO2CP
         dFJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id k41si12576206edb.152.2019.07.26.08.57.38
        for <linux-mm@kvack.org>;
        Fri, 26 Jul 2019 08:57:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4C6C3152D;
	Fri, 26 Jul 2019 08:57:37 -0700 (PDT)
Received: from e109758.arm.com (unknown [10.1.39.157])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 50BC73F71F;
	Fri, 26 Jul 2019 08:57:35 -0700 (PDT)
Date: Fri, 26 Jul 2019 16:57:32 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+a871c1e6ea00685e73d7@syzkaller.appspotmail.com>,
	alexandre.belloni@free-electrons.com,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	nicolas.ferre@atmel.com, Rob Herring <robh@kernel.org>,
	sre@kernel.org, syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Subject: Re: memory leak in vq_meta_prefetch
Message-ID: <20190726155732.GA30211@e109758.arm.com>
References: <00000000000052ad6b058e722ba4@google.com>
 <20190726130013.GC2368@arrakis.emea.arm.com>
 <CACT4Y+b5H4jvY34iT2K0m6a2HCpzgKd3dtv+YFsApp=-18B+pw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+b5H4jvY34iT2K0m6a2HCpzgKd3dtv+YFsApp=-18B+pw@mail.gmail.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 05:20:55PM +0200, Dmitry Vyukov wrote:
> On Fri, Jul 26, 2019 at 3:00 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Wed, Jul 24, 2019 at 12:18:07PM -0700, syzbot wrote:
> > > syzbot found the following crash on:
> > >
> > > HEAD commit:    c6dd78fc Merge branch 'x86-urgent-for-linus' of git://git...
> > > git tree:       upstream
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=15fffef4600000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=8de7d700ea5ac607
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=a871c1e6ea00685e73d7
> > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=127b0334600000
> > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12609e94600000
> > >
> > > The bug was bisected to:
> > >
> > > commit 0e5f7d0b39e1f184dc25e3adb580c79e85332167
> > > Author: Nicolas Ferre <nicolas.ferre@atmel.com>
> > > Date:   Wed Mar 16 13:19:49 2016 +0000
> > >
> > >     ARM: dts: at91: shdwc binding: add new shutdown controller documentation
> >
> > That's another wrong commit identification (a documentation patch should
> > not cause a memory leak).
> >
> > I don't really think kmemleak, with its relatively high rate of false
> > positives, is suitable for automated testing like syzbot. You could
> 
> Do you mean automated testing in general, or bisection only?
> The wrong commit identification is related to bisection only, but you
> generalized it to automated testing in general. So which exactly you
> mean?

I probably meant both. In terms of automated testing and reporting, if
the false positives rate is high, people start ignoring the reports. So
it requires some human checking first (or make the tool more robust).

W.r.t. bisection, the false negatives (rather than positives) will cause
the tool to miss the problematic commit and misreport. I'm not sure you
can make the reporting deterministic on successive runs given that you
changed the kernel HEAD (for bisection). But it may get better if you
have a "stopscan" kmemleak option which freezes the machine during
scanning (it has been discussed in the past but I really struggle to
find time to work on it; any help appreciated ;)).

-- 
Catalin

