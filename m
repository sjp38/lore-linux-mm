Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 655C6C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:39:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2530821670
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:39:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QOy5xYDi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2530821670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD6A66B0269; Tue, 30 Apr 2019 05:39:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B87B96B026A; Tue, 30 Apr 2019 05:39:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A76CE6B026B; Tue, 30 Apr 2019 05:39:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 871036B0269
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 05:39:14 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id a64so1870832ith.0
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 02:39:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=R59xQNltNlo+UQspZjbwof7CktqW9+HwkEeV2CRgeuU=;
        b=VFIaJ48Uf+z8c6zpaPyqc/Iz8nt45+ejHvydSkNuZfMofxWoBT7j5cFXMT070FkNCY
         v1ZydZ4GwJOtpFPX7QGzGamrJKoREoGypwGlGdZr6emR7tlWTD2ORtfkX65TRNr9A+YN
         LufX7vQkuqbtAYKjjNqz2B2YRmMTKsbYhLhSvZLfWEjE/C2xYRnRTwjeXn+dbx6Siu9b
         bHxtRtIZIbcqbKF/AjaecKzcXJ6CrMQ3v7eEHN3e6x7M412UUk3pPHZORaIaJ3KchKSx
         tYJZ5rC4m0LwwNV6OMwfQ2glf3aiZ0+MUYNkWLitpU9vTKqHCypSuOWCsRwiEnxYgcUC
         gsLw==
X-Gm-Message-State: APjAAAUnWX0B4nK03dZ4wAcYz0SvHtKJIqqQQxAdB8R9HhmUkYzqwXl3
	fZHDsGQnFIzHnh6qF3hpu1iorBZZ7B3nC1GwqEW4YY21nbMTJBQB90UQ8kpkDDJ2HSCX5B1cMbu
	sNAjGheeuxzfcp0JpJZos+RWyrtW8ampo2aZh2i4Z4z7DOTPNrIeQzpJSJNbsUSwOJA==
X-Received: by 2002:a02:3ecb:: with SMTP id s194mr25094995jas.29.1556617154253;
        Tue, 30 Apr 2019 02:39:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEvothGmyX3Km/hq7F9ipGg+245gOnYx70H6LQuw3Z8T1xwgIub3xKM1JMg25cDIYYzg5F
X-Received: by 2002:a02:3ecb:: with SMTP id s194mr25094956jas.29.1556617153304;
        Tue, 30 Apr 2019 02:39:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556617153; cv=none;
        d=google.com; s=arc-20160816;
        b=ZMlpy8w9iOJUIlsU/meg2FSVEt1kHPuTWdgC8QdnObMpktOKheobr0J5bGaGEvF1R7
         gX78Wdzth19KbAyuEDYnVa6r/YCez/edT89zR8uzf50OQy6GhYUNz7p9QgVCH+LBvCVj
         0ckd0F4+GyLeXVlFLWh+CFzkFN4DwkQTg+ib+TIaU0gkaOJhXXeMxk7XnOwp+II4bHBb
         k37ccRtRNNE4ov8qPzH3edJVPfRjgZdHoCxHXWIxRORqXBoCQJwvIoq1kITyHcD2h5IA
         VCDBq9oi6F+iLsGltglwD1kgk2lRCC036iqZYixP1znS4P1BzsY4SUMs9yMjVtMBPHkK
         21OQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=R59xQNltNlo+UQspZjbwof7CktqW9+HwkEeV2CRgeuU=;
        b=F49ri12mjWsI7voNfspSsxBjQFVRGvvECwQ1lJ/WmkaFslpA1VQWj77USFmdenyqO9
         uNFmQIsc0hE69jhXROWldTZhc3rcjAwcwOXLMUvPUR7hpNAdDz2V/epHfy5A9lr23JK0
         RLX7iaVJCCUQg11R6GrJ91fq/y/P6Zb8bK2rj2oD7a61ukIgPbU23KKynxXEGcXOEBJg
         GB4vELXeCbX1D02AzvOyJFqAZEy3NMBNSwnvUHhPvXrrS742aMunmiwAd89QK2ZaiJKU
         wIjebOrWjSkvSBr14BgCBGoQAcfCg/ohhPab87lG8kyl3gOan+EYMVHdXtK91bFvqAfR
         9yOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=QOy5xYDi;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p20si26628804jam.1.2019.04.30.02.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Apr 2019 02:39:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=QOy5xYDi;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=R59xQNltNlo+UQspZjbwof7CktqW9+HwkEeV2CRgeuU=; b=QOy5xYDiWYSE3dg+lHcIEahnZ
	yso18XfZ2dJ+dYjUgeLSEj/9WsOa+WoKe+RQdMwsrNPXH3R6Xhq0TaOucgTPKijsid30226nZatGl
	pM3K0mFG5EGNvuvf/5r6+NLizmdw3kivj/5U+4ZRLWYOJgEP3ALrMYw5K99gEmJ7gNJo9VuqYPW7K
	+nik/sRvL/cofQIX6Qa6NnSG3Yk5PliBKEizrH5pibNe0KF0fxrUm9ipNL4VRP2k5HxSPYfaopNvG
	tZukHvNBTQgyf0/bTcSppTp6YdqDpsTc1X0cEt2RvMSGu1O4Q31Pj4PEoJRHsclvVgq/wI5oYG1A3
	N5wdO5xFw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLPE4-0007rz-Ir; Tue, 30 Apr 2019 09:39:01 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 7510F29ACFA27; Tue, 30 Apr 2019 11:38:57 +0200 (CEST)
Date: Tue, 30 Apr 2019 11:38:57 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexandre Chartre <alexandre.chartre@oracle.com>,
	Borislav Petkov <bp@alien8.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Jonathan Adams <jwadams@google.com>,
	Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	X86 ML <x86@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call
 isolation
Message-ID: <20190430093857.GO2623@hirez.programming.kicks-ass.net>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
 <20190426083144.GA126896@gmail.com>
 <20190426095802.GA35515@gmail.com>
 <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
 <20190427084752.GA99668@gmail.com>
 <20190427104615.GA55518@gmail.com>
 <CALCETrUn_86VAd8FGacJ169xcWE6XQngAMMhvgd1Aa6ZxhGhtA@mail.gmail.com>
 <20190430050336.GA92357@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190430050336.GA92357@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 07:03:37AM +0200, Ingo Molnar wrote:
> So the question IMHO isn't whether it's "valid C", because we already 
> have the Linux kernel's own C syntax variant and are enforcing it with 
> varying degrees of success.

I'm not getting into the whole 'safe' fight here; but you're under
selling things. We don't have a C syntax, we have a full blown C
lanugeage variant.

The 'Kernel C' that we write is very much not 'ANSI/ISO C' anymore in a
fair number of places. And if I can get my way, we'll only diverge
further from the standard.

And this is quite separate from us using every GCC extention under the
sun; which of course also doesn't help. It mostly has to do with us
treating C as a portable assembler and the C people not wanting to
commit to sensible things because they think C is a high-level language.

