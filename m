Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74DA7C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:56:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3760D204EC
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:56:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3760D204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB89E6B0272; Mon, 22 Apr 2019 15:56:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D68B56B0273; Mon, 22 Apr 2019 15:56:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C300D6B0274; Mon, 22 Apr 2019 15:56:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 70B216B0272
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:56:12 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id u18so885705wrq.2
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:56:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UQRJVezOw5NyrjRq0B+wygXZgAlIYifoXcYtYJvWroY=;
        b=sXgar7ZqapSD/ia+50riI/vfoxHgq8H6VFsWRWW1IktSHNqERRgog4RK88pJuQhREV
         Gs/0YREo6YbcoU34tss8WpWmUoRGNpDDalQa70ytxhf36gSM4nVDG6IYbkygl1kBom4u
         5hc7OtCMGjByWVtiSceiSjcmrAlIhjt6xgVp5hlwFr4OhVk2I6e292rMXQK5cy7+OJDY
         Omj7k3ye+gHOSAzySQLAfi3mA2tFGNnAyXMqSjGxqZrl9zvzf3bqhzYhqancp/ufAU4N
         8NV7UiEEfq5TDFR0urQvKk/8xFvXf4l77lx6p2WLDYwOAXJWAmeFXkIXg6+/n+6RLSk/
         CCzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUTQA+4ULVmJlznMd/9FFm6sLLMHZFkfrTp4GWa8BxY/wyvTHZv
	tjK7ibwfiGAeqvFRwirWlU554azl4bJsXTvx2xc9R00ZUsEPEGYWZYWAaDuqnSUb9pBRNM+yNnN
	iOMqaERASeuSxZKvczy63CAum4R9D+CcnFuRnjncLD+HztE9dUasK25rBNakcrc32Jw==
X-Received: by 2002:adf:eac4:: with SMTP id o4mr13732067wrn.312.1555962972030;
        Mon, 22 Apr 2019 12:56:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyC75MgDPaybldpAHbGcfhLFV7IfBQBpkEhJAfXooyJAO1nLIgHVaVswQwIjd413Awx7/e1
X-Received: by 2002:adf:eac4:: with SMTP id o4mr13732036wrn.312.1555962971399;
        Mon, 22 Apr 2019 12:56:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555962971; cv=none;
        d=google.com; s=arc-20160816;
        b=VqPvLbN558VM2QOA9UVrM7HlhXeiJCLxCFYQxmHQ62Us48Mn0rcDzAA/DyYqvP7p0E
         ORG+8h2j377BhKTRX84C4uq5JFKQDtUJagz/yCnFYxRCoUJmwNtlICeR1If4sC++5zh4
         CFGV6pgE5TqDy00ruGZzRSRjFRLmmbZ+19NWJD3gyHEiFv+ao5f9I0KKSK4ezwOFrFrB
         2g+b6C7orYfbd+jS26Kbw+qZ4YowQa+/XpXLudprvvhzbdFSDHLbDOTzDjaSwqK1mdHQ
         QcFv7hNuZlr5fPuxixCjlLBv7653yOdkfn/yOrnsBHyVkXciwHbkr6wK6SO30VMGAzJF
         LlwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UQRJVezOw5NyrjRq0B+wygXZgAlIYifoXcYtYJvWroY=;
        b=TqYqrm9jRfBHdBOUm8Yzz4B/CBgIQL8OMPXlXQoNwBgzvOLJd7jM7IaGLhi/ffwmCO
         v6Xy200s0xPFWcDQOTCxCjmXggTGikeX0+KI02tFJM6xg2nEoIv8gK33u7VaGqmF2Ps/
         eZYYH8P7yCV5T2gDWMSjkAXyxdSPqSoMaWeF70Lgutm8QDOmRmNHD4vW8SN515+K6VQs
         ywoB8/HOLo1aS5wPwcpUJ/DCzNoshhntnKzm0C8Jnp6Z3IlHRZA9orxwqmcL2K2q5Jhw
         EaBFdaahaHVYdPQi1qkcQcBBUeX2xpLD9Ainh4FNJ0N1t3n2VqCMOi6tweJGM4uoH0aO
         u0FQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v16si9589527wri.436.2019.04.22.12.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 12:56:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 7ABF068AFE; Mon, 22 Apr 2019 21:55:57 +0200 (CEST)
Date: Mon, 22 Apr 2019 21:55:56 +0200
From: Christoph Hellwig <hch@lst.de>
To: Kees Cook <keescook@chromium.org>
Cc: Alex Ghiti <alex@ghiti.fr>, Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>,
	Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 04/11] arm64, mm: Move generic mmap layout functions
 to mm
Message-ID: <20190422195556.GD2224@lst.de>
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-5-alex@ghiti.fr> <CAGXu5j+NV7nfQ044kvsqqSrWpuXH5J6aZEbvg7YpxyBFjdAHyw@mail.gmail.com> <fd2b02b3-5872-ccf6-9f52-53f692fba02d@ghiti.fr> <CAGXu5j+NkQ+nwRShuKeHMwuy6++3x0QMS9djE=wUzUUtAkVf3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+NkQ+nwRShuKeHMwuy6++3x0QMS9djE=wUzUUtAkVf3g@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 09:19:18AM -0500, Kees Cook wrote:
> On Thu, Apr 18, 2019 at 12:55 AM Alex Ghiti <alex@ghiti.fr> wrote:
> > Regarding the help text, I agree that it does not seem to be frequent to
> > place
> > comment above config like that, I'll let Christoph and you decide what's
> > best. And I'll
> > add the possibility for the arch to define its own STACK_RND_MASK.
> 
> Yeah, I think it's very helpful to spell out the requirements for new
> architectures with these kinds of features in the help text (see
> SECCOMP_FILTER for example).

Spelling out the requirements sounds useful.  Abusing the help text
for an option for which no help text can be displayed it pointless.
Just make it a comment as Alex did in this patch, which makes whole
lot more sense.

> > Actually, I had to add those ifdefs for mmap_rnd_compat_bits, not
> > is_compat_task.
> 
> Oh! In that case, use CONFIG_HAVE_ARCH_MMAP_RND_BITS. :) Actually,
> what would be maybe cleaner would be to add mmap_rnd_bits_min/max
> consts set to 0 for the non-CONFIG_HAVE_ARCH_MMAP_RND_BITS case at the
> top of mm/mmap.c.

Lets do that in a second step.  The current series is already big
enough and a major improvement, even if there is much more to clean
up in this area still left.

