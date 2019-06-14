Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 200DCC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:51:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA07820850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:51:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jmYBMKhA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA07820850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 662566B000A; Fri, 14 Jun 2019 07:51:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 612FB6B000D; Fri, 14 Jun 2019 07:51:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DA536B000E; Fri, 14 Jun 2019 07:51:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17DB16B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:51:42 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d3so1728062pgc.9
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:51:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6uPpBmRMCo+tgIg2r1zxKrPWw32mDCaK9zcJcUBOcWo=;
        b=SFyNQJOAi+agA2pn77AfJCBzA69cmR/8eQoRC2znJDC7gfhx4TzGu8NHEpl7O522yf
         3uUbddmsXd/3V69vbuvlpBf/1IeW03GgKv67L0v8pT9oD0FVsuyf44CN/0zs9ZV7Xsow
         In2HyDE9asnIrPqFBSU6lu49RUXhm7JjTCgKn57Z55l/4EcLLISr3ZbLEcWfnqi9mr5w
         hS5xnRwJgZGUGh8sDN/7ISAj12jUISkmQ+woacJ0jN4U6Da/rKsXRK2ImqQymiQ+reor
         oqYvVZVFkWwvBug/maKGelHmqwNX4tWZPuSr/adxGl9WphT7Ae/d5CmtucE30qZcpTau
         +zKg==
X-Gm-Message-State: APjAAAUYA/O0yFMooVYe6INaV6toboyv7XGBwKhkLvCe7cHCCMjbehXK
	rErwVn5/A1iHp9fod1DHmqtJ/s1/evKFdSS9dg5Kp1AtjjjEJsUJ5jyk4jEHJm6PZ3G1I4/Nmr5
	cImoK7p2Gy0D8VH649MvGUE6uvI0E/GqBv9JBP0WxcNGzXklWvuKGKaQZYW2JA5UIUQ==
X-Received: by 2002:a17:90a:35e5:: with SMTP id r92mr8713983pjb.34.1560513101633;
        Fri, 14 Jun 2019 04:51:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUMGe2FJoGKJrAQtTpAPwLUtJgqVvcqTiTQ+pZSDqJMSE07FIGc6KwkwYTj8I1t6sB3A3b
X-Received: by 2002:a17:90a:35e5:: with SMTP id r92mr8713938pjb.34.1560513100964;
        Fri, 14 Jun 2019 04:51:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560513100; cv=none;
        d=google.com; s=arc-20160816;
        b=tgsLLK41oBMWXP6DdwMwYKs1F2pEfzcf5xAL1XPQjvvrw5+MAL4M1E4StL/f9B6x2O
         6IbQBa9j7p9vpchgA8tP0xSYHGtzFELRiGS9MK2BCJ43peSz6/mG0Cz4pFN1fSmId93T
         9JBWOXVMjioFqtZ6tCrd0cseqdNSq6lxW3fIeD5pxQW/P6rKsrdZAWnJuoyMpgtCs5IW
         49CEvjAIaqHwpAtXlwml8yIPekblAVcGmTzGju8QdfwL7iUige6WTdNzf00jta5renPB
         0IMXfvZz69YngsR00cqqnfUzdy9M3QimC/ZFuECdJ3x4Hy1QVGSAmDG7k3FleGtW9C/+
         OqJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6uPpBmRMCo+tgIg2r1zxKrPWw32mDCaK9zcJcUBOcWo=;
        b=TwAFkfHLzLEadpTuAAqLJfH4G4m0/HjRtf2y3r8WYPnpK52FarRyubSehtAS14VmZF
         99ubYkqYSqRKTgtZCH89msF9iml7lTTOqUOv7GnAroSPM28PfnbBVEFkoq7gt379qHp3
         1cM6rNDEVE5ZnbqrVNwZD97frWssS18DlltGFPtEH2IxNPK+X/ms6p9PxMI2ryezU9ZS
         XI3MP+cZr4Lpz02WYvnKEc3wk0oqxBiJuB2hWR0de8jtCZeJ1MWuPcX+fQ2d2OXnsWiW
         nunTa/E71mS1eS66AEyR6Vy/eltdoRQzoHKu1dBubv0vVqTg9ne4yy5gYG102RKkPT2V
         UyUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jmYBMKhA;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g12si2216607pla.322.2019.06.14.04.51.40
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 04:51:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jmYBMKhA;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=6uPpBmRMCo+tgIg2r1zxKrPWw32mDCaK9zcJcUBOcWo=; b=jmYBMKhAa1UffRPdkK9RLJLOS
	QdmfuTjDZ8NB4GXF/zHW3rz6cJWu+XpCEA1hAu19diiDUBsEXDoK+kKbI8a9yiKOyZQ3CF3PInIUQ
	bKOZuduix2OL2GFE+f3y35ts/hSbBLpgUqg8O3tCDH3RTiaBrjM4qXKlUTnCQJVFClCitsescAugU
	AbgEZ8MbL93i/TM4f15wK06QGyzT+L4W7JN9QCBJV7RMSy3QGXdpqnFVW5nBAktHuID4zk4rprhMt
	eEEuT0d5NdtDREXGLMrP4AslnTeHOVmVmg5XQAU13Avb22U+SuiQ3YAgNOOKPZXwGMgaFoYBwddgg
	aXV0xJdHA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbkk6-0001vf-Lz; Fri, 14 Jun 2019 11:51:38 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 2E5292013F74A; Fri, 14 Jun 2019 13:51:37 +0200 (CEST)
Date: Fri, 14 Jun 2019 13:51:37 +0200
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
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
Message-ID: <20190614115137.GF3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:44:05PM +0300, Kirill A. Shutemov wrote:

> @@ -347,7 +348,8 @@ static int prot_none_walk(struct vm_area_struct *vma, unsigned long start,
>  
>  int
>  mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
> -	unsigned long start, unsigned long end, unsigned long newflags)
> +	       unsigned long start, unsigned long end, unsigned long newflags,
> +	       int newkeyid)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	unsigned long oldflags = vma->vm_flags;
> @@ -357,7 +359,14 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
>  	int error;
>  	int dirty_accountable = 0;
>  
> -	if (newflags == oldflags) {
> +	/*
> +	 * Flags match and Keyids match or we have NO_KEY.
> +	 * This _fixup is usually called from do_mprotect_ext() except
> +	 * for one special case: caller fs/exec.c/setup_arg_pages()
> +	 * In that case, newkeyid is passed as -1 (NO_KEY).
> +	 */
> +	if (newflags == oldflags &&
> +	    (newkeyid == vma_keyid(vma) || newkeyid == NO_KEY)) {
>  		*pprev = vma;
>  		return 0;
>  	}
> @@ -423,6 +432,8 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
>  	}
>  
>  success:
> +	if (newkeyid != NO_KEY)
> +		mprotect_set_encrypt(vma, newkeyid, start, end);
>  	/*
>  	 * vm_flags and vm_page_prot are protected by the mmap_sem
>  	 * held in write mode.
> @@ -454,10 +465,15 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
>  }
>  
>  /*
> - * When pkey==NO_KEY we get legacy mprotect behavior here.
> + * do_mprotect_ext() supports the legacy mprotect behavior plus extensions
> + * for Protection Keys and Memory Encryption Keys. These extensions are
> + * mutually exclusive and the behavior is:
> + *	(pkey==NO_KEY && keyid==NO_KEY) ==> legacy mprotect
> + *	(pkey is valid)  ==> legacy mprotect plus Protection Key extensions
> + *	(keyid is valid) ==> legacy mprotect plus Encryption Key extensions
>   */
>  static int do_mprotect_ext(unsigned long start, size_t len,
> -		unsigned long prot, int pkey)
> +			   unsigned long prot, int pkey, int keyid)
>  {
>  	unsigned long nstart, end, tmp, reqprot;
>  	struct vm_area_struct *vma, *prev;
> @@ -555,7 +571,8 @@ static int do_mprotect_ext(unsigned long start, size_t len,
>  		tmp = vma->vm_end;
>  		if (tmp > end)
>  			tmp = end;
> -		error = mprotect_fixup(vma, &prev, nstart, tmp, newflags);
> +		error = mprotect_fixup(vma, &prev, nstart, tmp, newflags,
> +				       keyid);
>  		if (error)
>  			goto out;
>  		nstart = tmp;

I've missed the part where pkey && keyid results in a WARN or error or
whatever.

