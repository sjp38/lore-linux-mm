Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B8E1C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:03:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51F4E21473
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:03:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="vR79kuHp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51F4E21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7D876B0003; Fri, 14 Jun 2019 09:03:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2EB46B000A; Fri, 14 Jun 2019 09:03:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1CE36B000D; Fri, 14 Jun 2019 09:03:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 740046B0003
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:03:25 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id s18so1022568wru.16
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:03:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1va0Zhc3Ckkn/M19SdwI/BpgUN6PKWmJzS8DDu3XqvU=;
        b=Y8tPnjpyCYTtZhmSbYB/AbcBhWxmsHtRuP/VRQVSeizhy2Sas6EWJoMdMsRacfBnB3
         1nJ6+8IrCBWG+BJCQ/09J+AC6UdW6H65f8NP7uKl+wSXMlyQtaxhgxxbgywK1pxGrnn4
         CtHRxHcy54W6uHFBC05nBaB3p9Jp4CRlBwaI8mkJxvH/mRmPQpKd7W3kWkM3HvYvn1zl
         oDRsDOjmZV4ciGNl/8vNeiK8vl7oqNTK3uTkvmMRgbWeeJKIcJ4/zbSrNO6lUMBESwsU
         wifhNtiFzw6pPh0ZrxZmI2lyYjk4hQVVehjB+tpzvK0eR0O+j0jslh81vmFq4fKuXu9B
         a++w==
X-Gm-Message-State: APjAAAX1daTTLhzXnd8D6GYh/k1CEoWlZHhd/0pkZ/8wSlXBjcJgOlAm
	ZmRBx/LLy8Q01BzwTNgZHbPAQnXFi00zGdBa7fEOjSXQOdaJy3DiPLMa5JX3qrPL0jQG3dxJFTZ
	uRUNYUEY9+1KaUEI0fiFO6r5O+52rXj6n4N9d7IM8IF497c39XotQ1ia0u1XNKnSykQ==
X-Received: by 2002:a1c:9813:: with SMTP id a19mr7707696wme.11.1560517405023;
        Fri, 14 Jun 2019 06:03:25 -0700 (PDT)
X-Received: by 2002:a1c:9813:: with SMTP id a19mr7707574wme.11.1560517403780;
        Fri, 14 Jun 2019 06:03:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560517403; cv=none;
        d=google.com; s=arc-20160816;
        b=PwuyqE9P4TW56dV7Y1Hux6sfpRTR65w7W3p9ppk0TaZs0EeUMNzA34ylFNblQueYAz
         jIViYI4Vpl6vDcVb7Me8BieHWPw9/ijY8pPFyP+2tCk+Lfv+YC4TDUSM24YsY7k3juU+
         Gr1uMPiIxLdq3yEclouf2SdmoPPTFXVQbliO89FfozK6QO0cDzQTadSHRSr7TCX2TQUr
         d++Jprsgm2Z7d2asmk9ThdfvduCyqfQtHPTKvZ5iALkhQO5braX59IFl2jVAmjd4R3HF
         7oN/CAl3RrnGWPR9A5A/f1+bNZTflmEGQrOYkvWuEbzmJFx/gG0j4tfq2A+TaMYXgF1M
         gnHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1va0Zhc3Ckkn/M19SdwI/BpgUN6PKWmJzS8DDu3XqvU=;
        b=VI2fjluHICG72ZQMjthfNzWS9JmRzLXzyKKH4Hhr56+m1nSjntGk9czkmzFLaozZ6U
         BQ64S7N7vh9LmBmcKSprN1l3cxQ9b/wogL5omGD7H6Z1PKmP6WRyxMWq9a8EfidftO2N
         M9myZOu4zAszx6CV/dgFkgOEyNiPZZBuKiUEDm0nyzzBYLlo9yet/zl8xtf9IziFm45G
         +ibr7+yYpg5tNBImUdOOev/RMgem9LC1F+B2BWmj0sYcWFKglCVaORYkZIF2mX+Dh/ye
         e8eqCkbqaNlaU38iUDe+xBDqS+/5Vt42Z8IyF6ZWXdW2iy5rj921TjvkrPclrLgMXVwF
         07PA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=vR79kuHp;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l20sor897872ejr.35.2019.06.14.06.03.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 06:03:23 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=vR79kuHp;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1va0Zhc3Ckkn/M19SdwI/BpgUN6PKWmJzS8DDu3XqvU=;
        b=vR79kuHpQYXyxhZu8YR3M90jIJfwFWRVTm/9V5oFLGKzLRardmvObkXq9H4m0Vi6eI
         hdVp7daDWmX4NjKKjpNMRAp78CxDsbQD0dTSkz6kE0JwSfjW+s9yUAyzRWPwZQif4fVH
         nuk2WQZjcSHf09oQmJX2MDlSzVGVSjO4GeyaiD6SyDJEiS8htGGxd7iLNeMT/kxvSm1K
         zL82qR4pLp7Cx5FFMhZ4N0XEq17N7fCBv9xkqog0PGDidrguk0g8sXWzpGmFNuTSt3L+
         RETLZdk/pnPMk4IGiN0Z8/lU/1Wsdyh4AEckoXvUwGz6WE5+ieVSd3lN4xWfjy49IirL
         Tbow==
X-Google-Smtp-Source: APXvYqyF3tprtqswZ7hH6Vh6WtHyJArFxj3qOaU8YYRPmR2cn7Rbt/kKd3pYO/xaBN40TDf0h7NHSw==
X-Received: by 2002:a17:906:65d7:: with SMTP id z23mr13450758ejn.18.1560517403352;
        Fri, 14 Jun 2019 06:03:23 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id m6sm849255ede.2.2019.06.14.06.03.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 06:03:22 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id CF04110086F; Fri, 14 Jun 2019 16:03:22 +0300 (+03)
Date: Fri, 14 Jun 2019 16:03:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
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
Message-ID: <20190614130322.zbpubyxcncysgyi3@box>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-10-kirill.shutemov@linux.intel.com>
 <20190614091513.GW3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614091513.GW3436@hirez.programming.kicks-ass.net>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 11:15:14AM +0200, Peter Zijlstra wrote:
> On Wed, May 08, 2019 at 05:43:29PM +0300, Kirill A. Shutemov wrote:
> > + * Cast PAGE_MASK to a signed type so that it is sign-extended if
> > + * virtual addresses are 32-bits but physical addresses are larger
> > + * (ie, 32-bit PAE).
> 
> On 32bit, 'long' is still 32bit, did you want to cast to 'long long'
> instead? Ideally we'd use pteval_t here, but I see that is unsigned.

It will be cased implecitly to unsigned long long by '& ((1ULL <<
__PHYSICAL_MASK_SHIFT) - 1)' and due to sign-extension it will get it
right for PAE.

Just to be on safe side, I've re-checked that nothing changed for PAE by
the patch using the test below. PTE_PFN_MASK and PTE_PFN_MASK_MAX are
identical when compiled with -m32.

> >   */
> > -#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
> > +#define PTE_PFN_MASK_MAX \
> > +	(((signed long)PAGE_MASK) & ((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
> > +#define _PAGE_CHG_MASK	(PTE_PFN_MASK_MAX | _PAGE_PCD | _PAGE_PWT |		\
> >  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
> >  			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
> >  #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
> 

#include <stdio.h>

typedef unsigned long long u64;
typedef u64 pteval_t;
typedef u64 phys_addr_t;

#define PAGE_SHIFT		12
#define PAGE_SIZE		(1UL << PAGE_SHIFT)
#define PAGE_MASK		(~(PAGE_SIZE-1))
#define __PHYSICAL_MASK_SHIFT	52
#define __PHYSICAL_MASK		((phys_addr_t)((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
#define PHYSICAL_PAGE_MASK	(((signed long)PAGE_MASK) & __PHYSICAL_MASK)
#define PTE_PFN_MASK		((pteval_t)PHYSICAL_PAGE_MASK)
#define PTE_PFN_MASK_MAX	(((signed long)PAGE_MASK) & ((1ULL << __PHYSICAL_MASK_SHIFT) - 1))

int main(void)
{
	printf("PTE_PFN_MASK: %#llx\n", PTE_PFN_MASK);
	printf("PTE_PFN_MASK_MAX: %#llx\n", PTE_PFN_MASK_MAX);

	return 0;
}
-- 
 Kirill A. Shutemov

