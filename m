Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27D6AC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:31:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B55312173C
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:31:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dJE0dmec"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B55312173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 286698E0003; Mon, 18 Feb 2019 06:31:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 238398E0002; Mon, 18 Feb 2019 06:31:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14DF68E0003; Mon, 18 Feb 2019 06:31:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAF458E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:31:44 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so13529821pfq.8
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:31:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oKffzBACjkSj6o9w5aZt7Px1P4l0HPVu2+Xyfumag+E=;
        b=bxmeZNQwK+vFqskeXk8dqUejqYodUo0yKcw3s0j9wHvG+CgKWnYKcZxIUuvjJRkxBk
         KKIJg3SpgIuOKguuXgufVciNtCTq63dBYM53bcvegDICCLunpSGcxBjWHgfAvty0SZE7
         f9OppU4c1ZOalYkiJxqVwgm8lm9DYtun9I7SY4YYhv67xA0LPDO0Q5FLCpUCrvz5Od3P
         uPTRIgW9MUM+OVewcG/eSI8xyqRhZIrWJ7x8jiJtbrKmwsF4c8qoL3JLi5Jzp156pHRS
         cMIQtSO9dv8PEcfw8jI3kQfJT0mqsj0AVLlj+0QyToauZE+L3JtOMEWcz1ZE+ssM4qVw
         3XCA==
X-Gm-Message-State: AHQUAubc75lE2se7JHbtLylvUNhMc2PtSb52EgxvnpsP9PrFq3UosA1K
	2O7zqPOQani6rXweceTi0KWd8ruG/R4g+HtFcFf5FbpMOMc8+jHmF+Nw0r7383f0Ed91F6QUDZS
	ZNrG1OHjWCZ8D+/GKgSNuB2Q7L43t29BHtWjXRR7Vl4feKEB12fqOQ97QelWnQeGPKg==
X-Received: by 2002:a62:5789:: with SMTP id i9mr23269616pfj.75.1550489504453;
        Mon, 18 Feb 2019 03:31:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ3ihHaX/chwL640GQUsXYGnsm2Pul93FnANO2P4uJ02bmeeOjTl6I/pmf28nBUalXDeY4E
X-Received: by 2002:a62:5789:: with SMTP id i9mr23269575pfj.75.1550489503896;
        Mon, 18 Feb 2019 03:31:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550489503; cv=none;
        d=google.com; s=arc-20160816;
        b=U/aDRemp2imTUz9CgkwzDAHIJmtRxSsY5WziiLXVDAWjRRHTWmEFu57Z8FTXmy9pq1
         vX9H8zgcSYgA0HvFN/jQPUKSTSQnfzBNygUJjSIObTQKSJCeH64hLNVere0rREKO4jOj
         FJhvEa9LczfYDXYNctlg2eFyQ0cl4i3x37WqaIs2xb58RawG6DPeXSsZoKFJ9c5iHwKa
         exeKfiFCi7pB7mRCl1rbdHrKXJRs31DBWViNLWa6hEoY0Jizq/6lvbctO80fdGk7DFAl
         OdWwuJRj6UBzNQnd2RNiyDdKYLNnMXHkW5BIx8vfYuaz2MGNYXjt3zkv0xMlF9r2vIqM
         HqzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=oKffzBACjkSj6o9w5aZt7Px1P4l0HPVu2+Xyfumag+E=;
        b=um8mbUtkbfVMANS6dChrKUSz1n30UygibU1JqMgmvckOXbMWYpDcUVP6LSkNnIWhWC
         EUYS//xf1UsAiXA0Kgz9ep5m8aiRu4NGBJa/RA741fOXpSm8JSgEPkXYYTHHUKSw+M4O
         AFtQY8652RA2u3c1k5S5jR5f+67YFZYkrAinzxUxK+dRIeaXhz6NWMOeFu/RxSDrurjv
         ckN3lWDdOLuuA0qY+iJpuTsGQVAbf1T2+EoHLssT8/gi/t3jPTORfxkg2iDprlKSLRNy
         G4bsxaIB+yr5JdIRzcvAQhbyBq7XfbC2Oy+A7E5y53VYxlQvf1O/bxThXUaU6lq8RdEO
         mI3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dJE0dmec;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a12si12596190pgk.291.2019.02.18.03.31.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 03:31:43 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dJE0dmec;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=oKffzBACjkSj6o9w5aZt7Px1P4l0HPVu2+Xyfumag+E=; b=dJE0dmec0vzaWeeAGiwYX0sX5
	nTF4DE3finLImKyx8Rlxnu7yd/tEDz+Wv8tZxIxlixjmWGgRCzpOMEQJB5Xw/W055+MGcXyPmyfSG
	IhVmVYTUO9XF1yKO/npu5E2EJDOuJawlJLGG3lmEh74A//1DSdhV9zkLXXKHoDwN3E9jF9hzqU8kt
	N6jeDN4rIhzAsPwEX0kBhUdPR4Itcl5eZZpn88O7HU94itGvbIi1SXdA9D1XBzxxKPQwQBIxhNb/v
	JMK9clZRMvsyKeXWSpPqBf0BZ14S2k6Svs2UBj8gMFXeugRLTMPseVXLBH1BjxnZBrx9RBLZChFzu
	Wjs0KXdWA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gvh96-0001st-Ep; Mon, 18 Feb 2019 11:31:38 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E8BBF23EAF75C; Mon, 18 Feb 2019 12:31:34 +0100 (CET)
Date: Mon, 18 Feb 2019 12:31:34 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	kan.liang@linux.intel.com, kirill@shutemov.name
Subject: Re: [PATCH 03/13] mm: Add generic p?d_large() macros
Message-ID: <20190218113134.GU32477@hirez.programming.kicks-ass.net>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-4-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190215170235.23360-4-steven.price@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 05:02:24PM +0000, Steven Price wrote:
> From: James Morse <james.morse@arm.com>
> 
> Exposing the pud/pgd levels of the page tables to walk_page_range() means
> we may come across the exotic large mappings that come with large areas
> of contiguous memory (such as the kernel's linear map).
> 
> For architectures that don't provide p?d_large() macros, provided a
> does nothing default.

Kan was going to fix that for all archs I think..

See:

  http://lkml.kernel.org/r/20190204105409.GA17550@hirez.programming.kicks-ass.net

> Signed-off-by: James Morse <james.morse@arm.com>
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  include/asm-generic/pgtable.h | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 05e61e6c843f..7630d663cd51 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -1186,4 +1186,14 @@ static inline bool arch_has_pfn_modify_check(void)
>  #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
>  #endif
>  
> +#ifndef pgd_large
> +#define pgd_large(x)	0
> +#endif
> +#ifndef pud_large
> +#define pud_large(x)	0
> +#endif
> +#ifndef pmd_large
> +#define pmd_large(x)	0
> +#endif
> +
>  #endif /* _ASM_GENERIC_PGTABLE_H */
> -- 
> 2.20.1
> 

