Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96E72C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:10:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CF9E21537
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:10:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JeHvFDZ1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CF9E21537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0B796B000A; Fri, 14 Jun 2019 07:10:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBDE86B000D; Fri, 14 Jun 2019 07:10:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAAC46B000E; Fri, 14 Jun 2019 07:10:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC0A06B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:10:21 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id b197so2311459iof.12
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:10:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=k3YqewRln6/e39DRE9WtzDLs69QdBQzUJmMwD/K+784=;
        b=fyFFVVhV1px/IWnaDDu8oZS/9jbae3AdlwW3Q4DEujYm1PaDVf5znEO4OVfrgeS2p+
         G6JhQ0/YogTOuygxUSzK4RqL+30ElxfPpoqVizuDt0d8f9Z8h3c+6+4TpUqEJfvulGvU
         S/ZEKJdlfXl64MN+GDlvKivaCc0TebAOM4crGSVxmgcWzWZqMrIDBdniLUX5fYPdrkb2
         Mqhl/Rje7EhZgZTlLvAfk3aeo6K5e4PGAYp/yDRRLvxVjRHc+AKfM3VOZ/yvOkXs/vVg
         EHXcqyOsqoGbhriLbRpDZLeOw2Oh5PRH5/X9myfWU2ZR7KTJdupGpK4hJMumrcXsz1cD
         rOTQ==
X-Gm-Message-State: APjAAAWLh/3nXZFTM+Xt1ZZLgmRqZkqbtkmjubGHJAzLB3L2XvBINfG6
	For/5/gOc+A3OQIBwWUbHPx9VRJF1CXSVtBMT7mbYnQtumEgTLqHiSz7H2S+SfqZBpCIg1kuEgS
	SqzEw7Sb+jF928kmJMLXDOW6JVQLZ8Zmxi9fG2D5N30nmfQH2RGeyt1vJ8658lkEOZA==
X-Received: by 2002:a5d:9dc7:: with SMTP id 7mr13052093ioo.237.1560510621359;
        Fri, 14 Jun 2019 04:10:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvOpwAKp65XNCCOPN0orwQs04UVohZ5ikF0Cc7Lxvmq1TUxXh/shdgpaTdpKV30R2Os0gL
X-Received: by 2002:a5d:9dc7:: with SMTP id 7mr13052031ioo.237.1560510620554;
        Fri, 14 Jun 2019 04:10:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560510620; cv=none;
        d=google.com; s=arc-20160816;
        b=vRB4/RV7zUchZBBjVA3UnWMVUc1mzdpSCw/2xIqxFtgg+tT4eVIPtppL9d4eMPLH+b
         jKzfMK/W+31jwE9moF+bm5SV47p8w4jVJN5gBmgOtLodOcp/42m9FtbxGtVnlIBkOjhK
         4o9G9jRQxwNknVSSKBGg/1aVf4DFeI+Pww7/0s5P4T7qyWoRIwP36tS/C67l+l/9BzJD
         lO0oOA2dzxp5JGnoVHqKpQXB3utciOlrotrPdYsSHWrICTouVyzt3Ynynd6v81SbrYe1
         3XV4BCrdkIUpICRRI5XdtR/rsubYrZmbHnLnuZwDmpYUMZSxVeRT4AXZJ1c1K02HXnir
         ghlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=k3YqewRln6/e39DRE9WtzDLs69QdBQzUJmMwD/K+784=;
        b=pFWX56LULL54d8B54bRNNJnLrK3P3EU7zZtFwl/0ZDLQXjVDynX+rgtTfutmQpBWEn
         Qcv7VvVtF0mHhXanog97LVATgz8WuIe16kLbC4zGRZ7OV8vXPbkteas+EtCZdBvZsALe
         3RLaD+vBOsDMxDcCt3zoNUhFNvGxuDCuoq9f7lY3V76WUQyZLNaU/+6qwKhaykPlOyGi
         gA6m0n7bJOOjI0I0ZgeyzwbokYZtMC9BAk/PsZzACExUk/UZrj9CzM2MAuf7ZV3uqQOJ
         wnb1iyMdQYvqsAqj0ClRAPK9cIlxlJG/EeZ+gDv5Xm/WfeAHq2NneEEo05r4ENwAD2PZ
         lyUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=JeHvFDZ1;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j21si2700568ioj.71.2019.06.14.04.10.20
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 04:10:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=JeHvFDZ1;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=k3YqewRln6/e39DRE9WtzDLs69QdBQzUJmMwD/K+784=; b=JeHvFDZ1XZKf46UtJbklNv329
	zxPeWCBBT5gHiRXg0qHfYMSShJ50q81UGDkAeJE9FcWdO/SCjEYz3JU8UXpLuU6uc6PFP2XpRNvK+
	nNlwp9bUo/kdsuC6AFfbgd7HXZDFHpn1xHrafeJJR6SixQoH6Nv/Wtx4oVvAw3fTufghLgtkrBv9j
	an8WKxT5Gswm8hfhSGYfbnRS0eDamGKTp/8YlAej/fobLDGjuVhLGjjzF9kfoI0Mgn60AM8/k+9Lk
	sCp4omDUt0XNmJ7wkPr4sjPSGb6D1rRg8Rh2ep/EJpIlClSa65BB1JGUsIn20Gch0banuMTPifR/I
	sDKPR1LCQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbk62-00073a-5e; Fri, 14 Jun 2019 11:10:14 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E916520A28B1F; Fri, 14 Jun 2019 13:10:12 +0200 (CEST)
Date: Fri, 14 Jun 2019 13:10:12 +0200
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
Subject: Re: [PATCH, RFC 19/62] x86/mm: Handle encrypted memory in
 page_to_virt() and __pa()
Message-ID: <20190614111012.GZ3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-20-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-20-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:43:39PM +0300, Kirill A. Shutemov wrote:
> Per-KeyID direct mappings require changes into how we find the right
> virtual address for a page and virt-to-phys address translations.
> 
> page_to_virt() definition overwrites default macros provided by
> <linux/mm.h>.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/include/asm/page.h    | 3 +++
>  arch/x86/include/asm/page_64.h | 2 +-
>  2 files changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
> index 39af59487d5f..aff30554f38e 100644
> --- a/arch/x86/include/asm/page.h
> +++ b/arch/x86/include/asm/page.h
> @@ -72,6 +72,9 @@ static inline void copy_user_page(void *to, void *from, unsigned long vaddr,
>  extern bool __virt_addr_valid(unsigned long kaddr);
>  #define virt_addr_valid(kaddr)	__virt_addr_valid((unsigned long) (kaddr))
>  
> +#define page_to_virt(x) \
> +	(__va(PFN_PHYS(page_to_pfn(x))) + page_keyid(x) * direct_mapping_size)
> +
>  #endif	/* __ASSEMBLY__ */

So this is the bit that makes patch 13 make sense. It would've been nice
to have that called out in the Changelog or something.

