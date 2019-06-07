Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5318C468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:12:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60345208E3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:12:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="G2TH77zw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60345208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 069766B026B; Fri,  7 Jun 2019 16:12:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01BA36B026E; Fri,  7 Jun 2019 16:12:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4BD36B026F; Fri,  7 Jun 2019 16:12:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AECA66B026B
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:12:08 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g65so2045287plb.9
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:12:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=V+gSVnIv9QBKq1mZboB8NpBLa64Y8lrKysJJF3r5Di4=;
        b=auWLudN0Wfm891qbV1vIAyFCrUYk47AdQdef1tSlopneAJ+kyTCGNLpREucXhYrL5o
         cwmIe55K73VDxtKRLFX3Mf9IUjQUHVmxzMv2pR/yuoGp6JfV/SoQBImIW8soAwmzogcS
         5CKDaH63vbpy+BVGz6PB1WGiAHhHtTLsWELZ3xDOOzzkYXdXC4K/5lZ7Opw9/gFffRse
         aBejeo6XKk1ohfw5U9gQ2QAUdHplAsz6APo4uU/SaD2WKjFQwfJFEyFNwbn4RbKK+YIo
         0u3Wygm2XlVJzlGbhaojx4T7goVkug3sLUlWylCiXdfjBCtft3ROVOSG4cTEgouAsslx
         OQuQ==
X-Gm-Message-State: APjAAAUlvlw2eFWTHM9bLRIuN0eHxzYSRkh1pR9Ni1LsnQDsQGBIIhZy
	wDrXa4Q67Xx+vhnPxSWJz0t2iEffuECCOuURZOtKhXa5O/rOixC/nLej94LbKOTJhDZ0ZUy8KyC
	MNbu40hS0XSQ6MPzQaRUOWs95XGMQKDjUjC1htMert3gTMSy7UIg0mUVStfhkO1NP+w==
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr57178461plb.334.1559938328363;
        Fri, 07 Jun 2019 13:12:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXPXLwLNixZaBIP+38I7H9euJsCfhuFL5/84aNEMv4qjyVqAt0BuBHmxehnexcFcnARzqd
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr57178420plb.334.1559938327663;
        Fri, 07 Jun 2019 13:12:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559938327; cv=none;
        d=google.com; s=arc-20160816;
        b=aksTLnEecv1c6emOeRQACCYihX3/GN7HBq6j4f26l3mV/8S4qUVO2RJba5qE9fnDBd
         X0fkG8mz5j0q37Kc2TRVQtIp2xWxOJc6uBSi8SXZXRrmqAvaSExC1HIir1GDK7+4dTcS
         xMEH2n5Z1olo4GAovf7gcOYS/9eri9kGZ3dRVrnLR1tei7KnSx/6AYP9JL1v8R/MWIo9
         GqzazC6bT6UuZ+g8qUcxWULMFqV61uu+aQD4ZD+m8vazug8e22Ife19knyFZynv0bf74
         KV7fBF/nNsQ4RDWgdxYz7oHyESthHOYnXnC6OyXb696ozC+OZPF+pNVsFm/ddjdfW4by
         fVEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=V+gSVnIv9QBKq1mZboB8NpBLa64Y8lrKysJJF3r5Di4=;
        b=gnwEa3xPQdek3ZcE20YpP+C1uD+I8wC8IyNhona6Gfxngy7CwPDwp7IK4fw7G7Rgpb
         6PY/lLiee6fl5GvTFMOonBXBEm0xEmxhF/vtRpPSAOXs4eMdSund/f1J4TM07MyTFwUQ
         Ul49yZV6gsIEbZuc+xfwN3+nBdf1x/vWE/gMRXIYgp0kfWUPYp20gudytqcfQYWUOCwN
         jPC37FU1djgcABhNTl5toXxbcAhtdPo5srSKAhOE8Dey6tr092brR7kmyaEmwQWxNM0r
         09b5B90fA55gGD9dlAxG7A8Yi6VXhbYrz/epldM9SzUieR+EqRH9ZTNxPe8cayCLR1et
         alNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=G2TH77zw;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u21si2953965pgm.431.2019.06.07.13.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 07 Jun 2019 13:12:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=G2TH77zw;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=V+gSVnIv9QBKq1mZboB8NpBLa64Y8lrKysJJF3r5Di4=; b=G2TH77zwcRW+ghgSutS9pXWwx
	q06PFG90kLdW9nSZ8eT0zhsmJkCONTk9ihOiwCD/vOWRCH7+RiVotuRpO+PXMPtB8viY749wFWiHD
	e35WP8ojqL7BLHfJjBicKoWZKTv7dWog/hIuqMTYYTk2e38Bi6ed1zJgJ9LV8EZFY6S7kzQtNbxWR
	dq2EVJjEtvyg+7uncwjU/GfOave+g4SmAyk4QaIqVw/cBAp5JROl4fss5kOmhhd48m/zKN/BT2Kne
	4r7aT25INlQYUt07MKB6e3JiljH56Bv5dF61FNPZ9GAePTzIrq6vFfaE5EIdtGfqYacXVUhZ0+nnV
	aWTdDN8VA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hZLDX-0002mb-5b; Fri, 07 Jun 2019 20:12:03 +0000
Date: Fri, 7 Jun 2019 13:12:03 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Mark Rutland <mark.rutland@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Andrey Konovalov <andreyknvl@google.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>,
	Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
Message-ID: <20190607201202.GA32656@bombadil.infradead.org>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Before:

> @@ -46,23 +46,6 @@ kmmio_fault(struct pt_regs *regs, unsigned long addr)
>  	return 0;
>  }
>  
> -static nokprobe_inline int kprobes_fault(struct pt_regs *regs)
> -{
> -	if (!kprobes_built_in())
> -		return 0;
> -	if (user_mode(regs))
> -		return 0;
> -	/*
> -	 * To be potentially processing a kprobe fault and to be allowed to call
> -	 * kprobe_running(), we have to be non-preemptible.
> -	 */
> -	if (preemptible())
> -		return 0;
> -	if (!kprobe_running())
> -		return 0;
> -	return kprobe_fault_handler(regs, X86_TRAP_PF);
> -}

After:

> +++ b/include/linux/kprobes.h
> @@ -458,4 +458,20 @@ static inline bool is_kprobe_optinsn_slot(unsigned long addr)
>  }
>  #endif
>  
> +static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
> +					      unsigned int trap)
> +{
> +	int ret = 0;
> +
> +	/*
> +	 * To be potentially processing a kprobe fault and to be allowed
> +	 * to call kprobe_running(), we have to be non-preemptible.
> +	 */
> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
> +			ret = 1;
> +	}
> +	return ret;
> +}

Do you really think this is easier to read?

Why not just move the x86 version to include/linux/kprobes.h, and replace
the int with bool?

On Fri, Jun 07, 2019 at 04:04:15PM +0530, Anshuman Khandual wrote:
> Very similar definitions for notify_page_fault() are being used by multiple
> architectures duplicating much of the same code. This attempts to unify all
> of them into a generic implementation, rename it as kprobe_page_fault() and
> then move it to a common header.

I think this description suffers from having been written for v1 of
this patch.  It describes what you _did_, but it's not what this patch
currently _is_.

Why not something like:

Architectures which support kprobes have very similar boilerplate around
calling kprobe_fault_handler().  Use a helper function in kprobes.h to
unify them, based on the x86 code.

This changes the behaviour for other architectures when preemption
is enabled.  Previously, they would have disabled preemption while
calling the kprobe handler.  However, preemption would be disabled
if this fault was due to a kprobe, so we know the fault was not due
to a kprobe handler and can simply return failure.  This behaviour was
introduced in commit a980c0ef9f6d ("x86/kprobes: Refactor kprobes_fault()
like kprobe_exceptions_notify()")

>  arch/arm/mm/fault.c      | 24 +-----------------------
>  arch/arm64/mm/fault.c    | 24 +-----------------------
>  arch/ia64/mm/fault.c     | 24 +-----------------------
>  arch/powerpc/mm/fault.c  | 23 ++---------------------
>  arch/s390/mm/fault.c     | 16 +---------------
>  arch/sh/mm/fault.c       | 18 ++----------------
>  arch/sparc/mm/fault_64.c | 16 +---------------
>  arch/x86/mm/fault.c      | 21 ++-------------------
>  include/linux/kprobes.h  | 16 ++++++++++++++++

What about arc and mips?

