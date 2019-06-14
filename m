Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCF92C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:54:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96A452133D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:54:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="M7O9zXWb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96A452133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 379836B000E; Fri, 14 Jun 2019 07:54:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DAA26B0266; Fri, 14 Jun 2019 07:54:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17C0D6B0269; Fri, 14 Jun 2019 07:54:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEBD46B000E
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:54:29 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 59so1475826plb.14
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:54:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=V9MxUDuNmfO4r0z06SPalcFOxnjAwgY7mVSx/TAv4CA=;
        b=i6kBDE5sJ2gf2mxo9cXBGIqzTIzRQb33n2S6SC17HBJwooe/Z0bMcDKIQeB54ATStV
         nUU+AcXpMU/sYtEsqMndH9glxwd3ucXLfM65QuieNw7BSiGi568dkRR1s9WRvdnGHaYC
         gNWIzZG6ZJAopRqwtEw5tswlFs43sQRRfw8tztFDPcI9f/vz9fTLlKr7rzvN35a+xqTD
         H66SYd7AS2WvgKNEgew20jyZI3mI2dK0jFouUqIkgQqOwpJcYWfHbzAXTKR5UjTC/1hN
         cVbAQE0N7lQchIXKXhw2ocWTe2YvdBPid2ZiWgRu6kbRMRmM1+cojdOoYPeRKTuoUFS7
         dyjA==
X-Gm-Message-State: APjAAAXzZMPdkaCbS7dHCj3suIWAjHWthbYno/dGP9JQBubDVYrlxmxQ
	pIsX3TLKhqq74PW+gpzrRZU9j/f7WuoYJxBAouv/nwDJGNwuvtm2w6OxsRfZ0CITm/3jaFglEuB
	tvqmAVHNRw0FzoreYWpbEDBRnGiyezg7FyVohxmFTVWNrbjMwShhxfZu/Cf0MnaFylg==
X-Received: by 2002:a63:4d05:: with SMTP id a5mr33114398pgb.19.1560513269325;
        Fri, 14 Jun 2019 04:54:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCRtnlkz1CaHgq5UdXsps+wItq1BAiO3olZo1M7uYuwT9HkKnOVCFJO62NmTLC2jM2F+9c
X-Received: by 2002:a63:4d05:: with SMTP id a5mr33114352pgb.19.1560513268495;
        Fri, 14 Jun 2019 04:54:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560513268; cv=none;
        d=google.com; s=arc-20160816;
        b=r/s0C/wgvrLfIIxiyJGQxiPw0lkBFi1W43bw9tWZ1+6RyMuSVN5ANLx1htGaerBIQB
         AR6GautKR7mK+vZOEuIsQs96Mgju+BLNC0PdQaXxLKoNS9tfqmLARj0jVzHal3UYIuBq
         tmLRmxs7H6jIERcrtHLOZ3sL+Z6sKUfsMD6hPx6HEdNrof5IoTPLf1zvv9IIscHiwWdE
         luzBF9nFZz4lWWdgP9x32pEgag6FzJIkCCN+h2HdAkYEw/UR4LWTLtzmLkqxf8t4/saQ
         Ln2ryTFQlAeIHcf3F2c0jsJiT9BEI2DbY7i66nEPf2uGCKfYu2OtuNk70IebNh218y7X
         vghA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=V9MxUDuNmfO4r0z06SPalcFOxnjAwgY7mVSx/TAv4CA=;
        b=Ob9c/nQDS08xCKLx5RY3P7+M30zCtP+QorHO9n5i4JJUj2ds9myVMh+1RZbC3d7SXq
         rdTMdZ3OWsuD/ALSNapNofalNpeTpLhltZatVDLTUore1bEFhDw69UAWQIA2uUjW7SUG
         /9K7GwcrGgDbF9ktfr1vprtzA4ZfFHp1jX4p6fzDkZl6qvyXSDBfq6/nEy9jfmQgee1z
         bWIOYD7gUI5BO9HaquZpzMlo5qvq5phJlUUaPuMKnC3MEtgbs28Bhb1Mm2cnwAtusT0j
         XfRdzGS71aoWQvRp8tCIjdxALrVD/vy5008B6ldE8Df5EyxzWeV2oaUeafeFjsGXo0DE
         KVjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=M7O9zXWb;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l7si2365006pgl.562.2019.06.14.04.54.28
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 04:54:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=M7O9zXWb;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=V9MxUDuNmfO4r0z06SPalcFOxnjAwgY7mVSx/TAv4CA=; b=M7O9zXWbjnUSmnDAOEmTK7Md1
	Z232umC/Ih4w0N8OJkMIQxcnrGvrzB8H/aYEJh2NILrV6grz+ZS4iMVMPIljrdAZzeSQl32EoqVmc
	j9dPtuTqOLDXMls53IKjGHjUpO6mg61K24O95pcgqQDd1mWbASyhdbtqNRtmFf4tWCGOhyPlyJCiY
	ZDgjGaiymge3jtRgtsGSf4cgMUsVeTBqlSeI08iRRUyXxzHYKrr1kkOTU+kESF5T+cSeUNPSLeSBF
	cFezL2X72sFAc99UeeE4ZVIdO12z7QcyfpUqx61BiAewhS9S5JkG8drNIEvQRD6wZWwOGyebGriLr
	T3LxQ3aCw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbkmn-0002Jj-Qb; Fri, 14 Jun 2019 11:54:25 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 4E56A20A26CE7; Fri, 14 Jun 2019 13:54:24 +0200 (CEST)
Date: Fri, 14 Jun 2019 13:54:24 +0200
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
Subject: Re: [PATCH, RFC 46/62] x86/mm: Keep reference counts on encrypted
 VMAs for MKTME
Message-ID: <20190614115424.GG3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-47-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-47-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:44:06PM +0300, Kirill A. Shutemov wrote:
> From: Alison Schofield <alison.schofield@intel.com>
> 
> The MKTME (Multi-Key Total Memory Encryption) Key Service needs
> a reference count on encrypted VMAs. This reference count is used
> to determine when a hardware encryption KeyID is no longer in use
> and can be freed and reassigned to another Userspace Key.
> 
> The MKTME Key service does the percpu_ref_init and _kill, so
> these gets/puts on encrypted VMA's can be considered the
> intermediaries in the lifetime of the key.
> 
> Increment/decrement the reference count during encrypt_mprotect()
> system call for initial or updated encryption on a VMA.
> 
> Piggy back on the vm_area_dup/free() helpers. If the VMAs being
> duplicated, or freed are encrypted, adjust the reference count.

That all talks about VMAs, but...

> @@ -102,6 +115,22 @@ void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
>  
>  		page++;
>  	}
> +
> +	/*
> +	 * Make sure the KeyID cannot be freed until the last page that
> +	 * uses the KeyID is gone.
> +	 *
> +	 * This is required because the page may live longer than VMA it
> +	 * is mapped into (i.e. in get_user_pages() case) and having
> +	 * refcounting per-VMA is not enough.
> +	 *
> +	 * Taking a reference per-4K helps in case if the page will be
> +	 * split after the allocation. free_encrypted_page() will balance
> +	 * out the refcount even if the page was split and freed as bunch
> +	 * of 4K pages.
> +	 */
> +
> +	percpu_ref_get_many(&encrypt_count[keyid], 1 << order);
>  }
>  
>  /*
> @@ -110,7 +139,9 @@ void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
>   */
>  void free_encrypted_page(struct page *page, int order)
>  {
> -	int i;
> +	int i, keyid;
> +
> +	keyid = page_keyid(page);
>  
>  	/*
>  	 * The hardware/CPU does not enforce coherency between mappings
> @@ -125,6 +156,8 @@ void free_encrypted_page(struct page *page, int order)
>  		lookup_page_ext(page)->keyid = 0;
>  		page++;
>  	}
> +
> +	percpu_ref_put_many(&encrypt_count[keyid], 1 << order);
>  }

counts pages, what gives?

