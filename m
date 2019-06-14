Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABEC0C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 12:15:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EFE7208CA
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 12:15:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="znSzzWUD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EFE7208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1FDD6B000A; Fri, 14 Jun 2019 08:15:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D0846B000D; Fri, 14 Jun 2019 08:15:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BE396B000E; Fri, 14 Jun 2019 08:15:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68F046B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:15:29 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id c5so2480319iom.18
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 05:15:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=4508jy29+aun7N2LGIzBHEHdPpOHU7DfASwN5eoEnJ0=;
        b=Gy9QqcA2BNrYNEnfNRXHQ4oVmmmyEouCLyQvpiCxv9eEAQ6mdFGRPuPdl/xOEO469f
         A5O5z2o/6bocpZJgLppwwLjsL+tcPEFkiwIBDnS5bUKGtCYi/wOoe+1otro2vADqbU3M
         4S+F9Eu7Y2BPD/g7w7qnUbOm5OJ5/T5CRfOI/+dvpy3jGkSIJUpxqa+MppO/NC3FXbOl
         QRTqUDhGKzGue+w/pkaIT1gvC9Yg33vPwwkq8SS7ZuxPueBrUOuUQdCeeZbRowE6+KPC
         i+NoWrFqJ8jB1LZR2S3m//XSUuqgMd2t62YmKvfcZ4BZ3aPk3LR8fJJAB1WBUo9vYxiE
         sOKg==
X-Gm-Message-State: APjAAAUmZGScSoxBtabhNIfySPedhVTEPHIaDhmHy4movug2X2uijySm
	Lc8GpqgyL70vT6AKtyPXklCAnbyaK+GJISxce6pECXe0wHkQ7S2Ukw0mYsmuYQNgqSr0k/D2oes
	/0w4yGmsv5dz6JMEQZ1SnJ9ZNNMcB4N3t8zZuEY8WtVwzg5U8FpSk2BQ819L7H6kMSw==
X-Received: by 2002:a6b:dc17:: with SMTP id s23mr5181978ioc.56.1560514529191;
        Fri, 14 Jun 2019 05:15:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFsYSxEowYLYBu+Zir8SvCnaktRbbOfShbS99mGA/d4dxuDZDH8mGN0ux5ljn3T8HrkneE
X-Received: by 2002:a6b:dc17:: with SMTP id s23mr5181887ioc.56.1560514528169;
        Fri, 14 Jun 2019 05:15:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560514528; cv=none;
        d=google.com; s=arc-20160816;
        b=OwEBEE1vj50TJXzL9KCdd4+FrpqHnHkM/ZXnKtda7wKtc/vJrqDXfBoKUW1Nze2nM0
         45LpFqnvAaxHi6mUFWOsc+PbipgDyISqV4fF/Zy4Y7+MzokomQHRhaKnGqgRekpC9jov
         zKGQUPfve3rBx/hjQIuqtvQkvOuICCkBHyG4SOV2XkdaoEDt1Dk0fdDG3XqPxTRK7USi
         EC1xjsjQeB6dIdFq7naxmwvpPRcIDIvvTpJ5+j6PCKd+9HFx9LegBWHqztR/M/OXC6e3
         5EE/UKbjJzB4Beo5xB3hZrmBxNqU/Nv0EL33f2O4B+rXkOFZRIEB0+LzZn/hrF1ApA5M
         yfMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=4508jy29+aun7N2LGIzBHEHdPpOHU7DfASwN5eoEnJ0=;
        b=x1ptq7crHnKPPvs0+iqPKqv2rBUZMFtkaNE5mjMwto2AUEQBcTrWNYkJ+2YqnXVhJB
         mXelxH38zkQNOAfDVmNigVtL8zKLDKwyNJ7dMvy6DwHi5zMI6g5CqYTv8q79MlhRZBa3
         xpsgc7gOV8u7AgxPctFFTuxKEyvzr8NCH3pBug6O8xM+nO4WqCdF1JsFIdBAJs3MI8nz
         SAFZuFxMlBtkwaekZhWWLZT0YNCRjL9T4FVnLVQFw0jy71iX0nyCYYpf9oLqUrJYt/Jf
         985q4MzpalkKDdseesBPHk0fefTC63Eq0DJIkvX6HavJDghY3PFwYE4YseBKdkutzg+Z
         bkGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=znSzzWUD;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a20si2851927ios.80.2019.06.14.05.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 05:15:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=znSzzWUD;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=4508jy29+aun7N2LGIzBHEHdPpOHU7DfASwN5eoEnJ0=; b=znSzzWUDWHtxTeSgjW/Fm4G9b
	I0fEYjCe6xbhDAdqQtncGNa7JPgPEedhGzQZEmkIJUL0jsptzXyvy/BM7k+T2GipSP5waiKTIz4cp
	FdK4P3MeaT9AODHnmT90Abzm+kAOhgPUSMxh5fFPrRDGUtSAlguTcAc6N/onnUBjsQCcgNm27oU7M
	oJC+jqsSKBHSg4/lQ5lvGNvKBDQa+ZYvQ2XYniMOnwc9/JiksBCPrd1dx0Z+MLEIcRMVIuGtFOSRI
	rSu0GIJ8PDZaiYJzZD9mXB6ZSPNeTG+fp/ksjm6PY/z69c2wRCwth07eu0Ff4g0l/rE9yCGsMPSuE
	GcTXZV0aQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbl6z-0007bG-Ai; Fri, 14 Jun 2019 12:15:17 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 0A24120A29B57; Fri, 14 Jun 2019 14:15:15 +0200 (CEST)
Date: Fri, 14 Jun 2019 14:15:14 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 00/62] Intel MKTME enabling
Message-ID: <20190614121514.GK3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:43:20PM +0300, Kirill A. Shutemov wrote:
> = Intro =
> 
> The patchset brings enabling of Intel Multi-Key Total Memory Encryption.
> It consists of changes into multiple subsystems:
> 
>  * Core MM: infrastructure for allocation pages, dealing with encrypted VMAs
>    and providing API setup encrypted mappings.

That wasn't eye-bleeding bad. With exception of the refcounting; that
looks like something that can easily go funny without people noticing.

>  * arch/x86: feature enumeration, program keys into hardware, setup
>    page table entries for encrypted pages and more.

That seemed incomplete (pageattr seems to be a giant hole).

>  * Key management service: setup and management of encryption keys.
>  * DMA/IOMMU: dealing with encrypted memory on IO side.

Just minor nits, someone else would have to look at this.

>  * KVM: interaction with virtualization side.

You really want to limit the damage random modules can do. They have no
business writing to the mktme variables.

>  * Documentation: description of APIs and usage examples.

Didn't bother with those; if the Changelogs are inadequate to make sense
of the patches documentation isn't the right place to fix things.

> The patchset is huge. This submission aims to give view to the full picture and
> get feedback on the overall design. The patchset will be split into more
> digestible pieces later.
> 
> Please review. Any feedback is welcome.

I still can't tell if this is worth the complexity :-/

Yes, there's a lot of words, but it doesn't mean anything to me, that
is, nothing here makes me want to build my kernel with this 'feature'
enabled.


