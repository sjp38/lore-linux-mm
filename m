Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5866C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 09:15:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6647C208CA
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 09:15:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="plUvNd2h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6647C208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3BC06B0007; Fri, 14 Jun 2019 05:15:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EECB16B0008; Fri, 14 Jun 2019 05:15:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8CE66B000A; Fri, 14 Jun 2019 05:15:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A49976B0007
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 05:15:23 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i26so1349042pfo.22
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:15:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bjuICrJxhqbVE3btlCQ3iZkvBOpZmXqWH1hsHhR0vEs=;
        b=sYoIJyQHfNO3aI30PSeYj01/bVF0vV3OnbjUzmUuwU/BWQuxZ6tCM8G8Ch3R2vWm43
         qnmyYJ/uFugkwsvIaIM+4oq0PM+qkwxmtp+2nuvjUSsFnhghBX8viyBHSETGXkHyuC8y
         JCd10Ci/LZQNRTSu+OtFjuZalOFhbWTU1NQ9bQQ28NgYvgI5LZcmKLo+xbfwUVZcS+cv
         w2AzL09XYZ8fAC3Et9eEOmfqll9k+DsMi2gt0Ngx8QP+/bXr5uvfZrxeTL5J2E9PzUT5
         I1wUBIR9/tylCfJJBpZk/gjLA8FJtoLx7SineMToZM491TjFu3iBvbvqh7nNxkaDp/9h
         QfZg==
X-Gm-Message-State: APjAAAUaGGxMPKSuCmovY2TNKddGz4IzMuVhYwfmO4Sc5M5+v2mJ4IM7
	ox8uyWs0BBwE6fIash5H03mAHea7hxzVWzrdWc/d0YtqVXBKDEgF09Wbk+hEzmK5yrsuv+Vrc98
	4Ukn1A6Ce2rcXzTRbJXCWTabKPRf2BbYEyAusFPJfqVEa94RWLkARaXyX8yXasxqJxA==
X-Received: by 2002:a63:5247:: with SMTP id s7mr16793449pgl.29.1560503722871;
        Fri, 14 Jun 2019 02:15:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwy/E7SaFob/o3SPnkgvaP3QApJUMJHUIg/EefHxlk1SzoFiyJl3ZgTDYSZdwAZkDMWCvSA
X-Received: by 2002:a63:5247:: with SMTP id s7mr16793390pgl.29.1560503722055;
        Fri, 14 Jun 2019 02:15:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560503722; cv=none;
        d=google.com; s=arc-20160816;
        b=bSaXMwaT92DtszZQaLzYsNt0zwU2s4Lpz61g7D1PoWPVc4YRizb6if0WxdSentmfPq
         r4MO7+fZgoqQVtYzhqoA6D85H2RcLVR4eh0/dp4y1k2U/9Cdu9BKdtdel553SbZ3QiJd
         m/QmHE6jFnV4PMiiuBn7djZoPU8OZvlJEH06mht3apqyeUPaNvoVc/+INvpiqCRN9vaG
         U7IEq2iD6jG4Xl9tv+eB1UBCnRpP3mDRds1t6alWY9kdW+xFDFHQxfxMNMbmjoipgbaF
         cA9gBaKgvHSjgWaOJ02d3YpbooztypeRR29kcHiGhU6/xWV6tyMqeDgr3zY+E0WL30/d
         c5ZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bjuICrJxhqbVE3btlCQ3iZkvBOpZmXqWH1hsHhR0vEs=;
        b=Ty7WxmxY55NtmosjnC4s6PRODshQpEMTbzWeQypyETSrgL3iGEqPwuNGcyc/15ik5X
         ZPzy36ez4xMDckw5Tk/wTaSkt6vhrdxdZvUuMqam9pVL6Xzk4jw4cFpoWhgeI2U0AUfG
         4O5YKZpKmsVsg//xpS29cUg3gaLVJAhoG9t6CO8/bdQGzkQ4TQL5riFOWhxBh2cMZHSq
         7PsaeG9tDq2A1bIWzZBummgZVQy02biAEm6iFvcbNDca7R/pyzh6KxlqhWcNMenWlFpz
         ajulKXrGtmTrRd6/i/X2qywxFDNnIgrC4ZWVh3euIU+YROBLvHDl4SmjnFOfvxpsCHid
         ECaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=plUvNd2h;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m1si2064128pgt.93.2019.06.14.02.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 02:15:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=plUvNd2h;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=bjuICrJxhqbVE3btlCQ3iZkvBOpZmXqWH1hsHhR0vEs=; b=plUvNd2hsauOJNdMcJW7PtfGU
	ToeAUBkrbzKvJm2BUG/yf8dWjbaAvX7Q4lidDs0ithX9OI2WVuXyjfjTLnReR0Y0BKcgCuAYiXgBC
	OYMfDsUCaba/eGhvG5pmOg+CVacs6ilSRsk2Vm9Q+cjRnTCoZahKJFZHX8emllCfCdfoOQyfYYpgd
	8P3NvVIEryL7h01oXhpMERwBy1+5j/J65bjKgYr8HqalG4n/8K5kG47A0w9CyIaEfbCm+XdyPqqR2
	+SODATdKf9VGfFZV7w3Vcr9SwOJUqEoqFkjC3/4Q1Bw12ultXg+EeVpqKI0Vp+ZCPmsLTqaO2Mazw
	5m/hAaOGg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbiIm-0004MH-MW; Fri, 14 Jun 2019 09:15:16 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 0E80820245BD7; Fri, 14 Jun 2019 11:15:14 +0200 (CEST)
Date: Fri, 14 Jun 2019 11:15:14 +0200
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
Subject: Re: [PATCH, RFC 09/62] x86/mm: Preserve KeyID on pte_modify() and
 pgprot_modify()
Message-ID: <20190614091513.GW3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-10-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-10-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:43:29PM +0300, Kirill A. Shutemov wrote:
> + * Cast PAGE_MASK to a signed type so that it is sign-extended if
> + * virtual addresses are 32-bits but physical addresses are larger
> + * (ie, 32-bit PAE).

On 32bit, 'long' is still 32bit, did you want to cast to 'long long'
instead? Ideally we'd use pteval_t here, but I see that is unsigned.

>   */
> -#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
> +#define PTE_PFN_MASK_MAX \
> +	(((signed long)PAGE_MASK) & ((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
> +#define _PAGE_CHG_MASK	(PTE_PFN_MASK_MAX | _PAGE_PCD | _PAGE_PWT |		\
>  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
>  			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
>  #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)

