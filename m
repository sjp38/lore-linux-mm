Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A7D1C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 18:27:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 267E520673
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 18:27:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 267E520673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=namei.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B26C46B0003; Mon, 29 Apr 2019 14:27:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB7346B0005; Mon, 29 Apr 2019 14:27:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94E856B0007; Mon, 29 Apr 2019 14:27:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2296B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:27:40 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id o13so6273078otk.12
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 11:27:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=4evQIkgyRVWLDxBf09ZSuhvlGBNXaZkOeslBcvLLfho=;
        b=I0LtjNX9LUqkWGRHIYYfNE2133r5KOW/TLxGL/rpvx1wxKZ0UAcwvXY7ksEn0TGJo2
         DWfVHnBVqDB1s9pd8NuI7i+VbzV2qUFhr5lho/izm70GD0yBaD/DwpCCwArj8qSJpwFq
         vmLUSYvl9atFcDAdEKwsa8+CDpk8tIO99pv3OQfaLqJQHAM7xvX4kzrEUT+PxygT4wJd
         dM0ejtmyM/D32mAVMnUukZcZqh3gUJpC1BoA0rgT0x7J6Txgo05Yj+9/Nc9j7MM8jKSk
         aeyjJ5RFoiCWKTmtlsKjF3ueHuAnRiHdMr0Hp/oxGfi8R+GIa9o+XFcCr1YqYCxg+T2s
         5ToA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
X-Gm-Message-State: APjAAAX0v9avLJQ2DWtsp3P2Dq4lyauxw/UyH2172L7qMGmXcIWJNJpx
	BD0Y825DLIEb7hS9y9AyeweHFnVE1/4bhoLsQm2iCCNPsp2Rj6Vr0PVqlc4/9GJq55ofG7c+r1H
	YcKkBm402hNMoDCp8mDW7l4rss6C2/5CHdUepdCUAF0076gCAf6EP4HghM1x2RiJx+w==
X-Received: by 2002:aca:efc1:: with SMTP id n184mr303332oih.121.1556562460046;
        Mon, 29 Apr 2019 11:27:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxVTUXVaJ4+5PrVHB0+k27W7WlJjt/Ll29o3ydZqqIvwf4xbhMW/7a+xT41rxuHjJjcnmq
X-Received: by 2002:aca:efc1:: with SMTP id n184mr303283oih.121.1556562459230;
        Mon, 29 Apr 2019 11:27:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556562459; cv=none;
        d=google.com; s=arc-20160816;
        b=kB0k/JRErgwwqIiuhMUN5qyZrtINE326TInAiw/XELs128QEIrGWY8wLvFBWCUctfN
         Nb+eZZoJZYXqIftByfIGRUKMbf7a8oqsFJaaQuH6C3+7AoaH0cBvyfATeDPHaLsTaot3
         O97XOrjS5GPs2cQhyc5Gv58RORIiz8/f2ptL2atV7irhP8cVB+99MykNjQG3oLP6XUh/
         /llQFR0iVMmd1S1DdITjOzboW4Abj69nDbgA2aR/l5Xx3JnBYDd6ZgFLKllG7UTSLxE6
         Uj5YZTVrl28ESzVNr7jA2wQjoxw+PkfKrvlMSdGQAmqc0Lm4R4XqfCiQ01Nn2aVcpDsh
         0g9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=4evQIkgyRVWLDxBf09ZSuhvlGBNXaZkOeslBcvLLfho=;
        b=AtiISzasyYojmSWgAkx3X6E8fFvZ4Q3fgX0Yrq7k5+OC8sTZSbgNZ9fBvuuVJT3PJl
         ereZA8CrOioWJz1+DNxbF5XG0mcYkf+17psgS8Na9AjAxwJsBvAyeamr0jscEh91KbgL
         EuhECYnvbhXvcTa6up1UVFUNSFBetiarwXXGRTEesfIgKFC7QjrqI/weeVXTR4c7pbv6
         Q3w57QFo9rdguhPmg0YjtJVjtXk53kuXZjApGLwPC8LfoHVqgjgMcRMnZR7Xz50CFbSx
         QsPIEHm34OKuJKDr16089MS5mySqBQmIN9z3SPEyznO7Foy8HNLBYQqUHQt9/mBqUBKs
         vw1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
Received: from namei.org (namei.org. [65.99.196.166])
        by mx.google.com with ESMTPS id b83si17597516oia.79.2019.04.29.11.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 11:27:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) client-ip=65.99.196.166;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of jmorris@namei.org designates 65.99.196.166 as permitted sender) smtp.mailfrom=jmorris@namei.org
Received: from localhost (localhost [127.0.0.1])
	by namei.org (8.14.4/8.14.4) with ESMTP id x3TIQxlq021250;
	Mon, 29 Apr 2019 18:26:59 GMT
Date: Tue, 30 Apr 2019 04:26:59 +1000 (AEST)
From: James Morris <jmorris@namei.org>
To: Ingo Molnar <mingo@kernel.org>
cc: Andy Lutomirski <luto@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexandre Chartre <alexandre.chartre@oracle.com>,
        Borislav Petkov <bp@alien8.de>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>,
        Paul Turner <pjt@google.com>, Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        X86 ML <x86@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call
 isolation
In-Reply-To: <20190427104615.GA55518@gmail.com>
Message-ID: <alpine.LRH.2.21.1904300425200.20645@namei.org>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com> <1556228754-12996-3-git-send-email-rppt@linux.ibm.com> <20190426083144.GA126896@gmail.com> <20190426095802.GA35515@gmail.com> <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
 <20190427084752.GA99668@gmail.com> <20190427104615.GA55518@gmail.com>
User-Agent: Alpine 2.21 (LRH 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 27 Apr 2019, Ingo Molnar wrote:

>  - A C language runtime that is a subset of current C syntax and 
>    semantics used in the kernel, and which doesn't allow access outside 
>    of existing objects and thus creates a strictly enforced separation 
>    between memory used for data, and memory used for code and control 
>    flow.

Might be better to start with Rust.


-- 
James Morris
<jmorris@namei.org>

