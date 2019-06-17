Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36A56C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF7EE2084A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:52:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HhwqhNrM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF7EE2084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 827E88E0002; Mon, 17 Jun 2019 10:52:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D8428E0001; Mon, 17 Jun 2019 10:52:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EE548E0002; Mon, 17 Jun 2019 10:52:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 362A58E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:52:07 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id w14so6121752plp.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:52:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CC6TusG/xvd2NrKEqztW6Q0eLvQHpCSqZ9asqvSUbGQ=;
        b=Pw3QSNQwJzkDOgv9bj5qCPBfGhUBN74jS0XdBU3Xj1eFMcxKczOhhmlyt+ZOWRUeou
         enfYim3JnqLGEV2fsKnP9Nkt7eMeHaachhbSuxHXGUtnpYaRbq5vRklwVeNv5PJfr4zF
         2808suE6Sk5JqflI2Dv2ZnCdQ6+Pz+t3tExnOpazfZidDme0Ymb7iAKL9LLcUwk1XyIE
         +dannAKEk6I1bKAJHEuYNlYczE6VCRhLSnztjPKcJGMxaQUCNGiuJ0SvQHUCKaw9JQy2
         AqKKmp3kvcDn8rjOc0CdU3ivnE2qXARudXu4BWTnoDoIXoVkTB7QCPSpHtXFlxpZl4sd
         bl1A==
X-Gm-Message-State: APjAAAX0dwdHMJHESJ9Ou89voF5SMPQJ2boySfclTsn4ahqtSjgt600E
	UJNPDy92ea2mXrGn7gDm8cC4UiO6XJsn+3tI0Y5YT20rk5aRn2YLl9/43Sb/u5KyVlF7/n4OPpd
	l09m+DDCXDXUDyNfnnDlrr4vadYRYUQOu09cUxY7JaRO/8VCwcvyh7zzf3hQj6oFaIQ==
X-Received: by 2002:a62:2ec4:: with SMTP id u187mr112428578pfu.84.1560783126784;
        Mon, 17 Jun 2019 07:52:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrSixbG+C8hkiS4kt1wHHbrvGo1otC9DmfiEvg80modWIcyhnD/IETUWeHYamfvL+go62N
X-Received: by 2002:a62:2ec4:: with SMTP id u187mr112428533pfu.84.1560783126177;
        Mon, 17 Jun 2019 07:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560783126; cv=none;
        d=google.com; s=arc-20160816;
        b=R0q61xGWYAey2zaJOHA//ESO/o+/tkz5Hp3lsXZmYMvxQXC0zG+Jf3cf9kOU88OkN3
         vyh+GFhB3izZzULminT6PlXaNVjXcaoz9joMebnqRILPHR0IPC5nqraFIDgbi1vWSITv
         ufSkXZxGfRleAb4SotZEm6/TKRM8eCptfRoQN4zgCvL0YGchlfkucwbsMn2welJ9hTeK
         Rlk/kgWtWU+/tWu8rVbTzKvrt8WdIDZrm4LT4C+RWiTBz8WP1F1rpsXDXf35OjNtEnu3
         kgrVaJiCAks/xPsBDjx07KNkR3DdaJ0l/B0snq+5fp2Cne++dKw8XYSjReciGe0h1GKM
         oAsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CC6TusG/xvd2NrKEqztW6Q0eLvQHpCSqZ9asqvSUbGQ=;
        b=IoUP81TvilcvTH2QKdvTo90YM5e0wb7cfWWEMNGVHHIBNgd5VdWj6rCrd8POYY6dgR
         d5RUECS+ZV6OqftwPdiYO/xzJ31Mw7i+qXHTBY4pAnPcOhT/w48sTkPBdO/GKF0rN5SK
         6p/s82IuLeRv/K1eYaOKuuICxen5gbd62mopUHPhXSwFCYIdBl+zqUUnGcwkPfZS8V8f
         mFgDiTEjlXC0BQXTky2hoxUde7m8NaJ2zT5D1uHMHx9CnkpcdemMZDZHL2kmiGRchhiq
         /CCkm5oPip2so/Bagp5bHt7YCfvyvPvb5OkCDYMh2SqT3SS5BsmzqfB9dDFQfnmuU5wT
         FrcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HhwqhNrM;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l24si10966373pgm.248.2019.06.17.07.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 07:52:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HhwqhNrM;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=CC6TusG/xvd2NrKEqztW6Q0eLvQHpCSqZ9asqvSUbGQ=; b=HhwqhNrM9xrAQOq0eNTILgTfj
	R+0T3K6DbjbIQyqcNTefACa3jRYLYfmFr4O2DTtDoavuT0bYMdlrxcS92IvJtv2UUGOO3dBzTihLB
	UNtKyWn6YD230yNinCi6buZ5Y1cFQrcsU3Yf0AKOWWsUOio12DIiRYw0JHoJhAFyg7pDgL7qkcSr0
	9B1owcTUHT3GZq77EKPQ2Be6tSOdWLwu/5DQDTsaA+kc+xdgkxwwbDZqVqeemMIuiKx2sI21XYSkj
	VNQrWUbfXOqlIDfhkhAkwTWqWnsFdYX9pzSdlvpXOVDMOmtOUK0OoVu6wc12rWnWOkLladzvUZa8S
	/gsHPagpw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcszI-0004sz-1Q; Mon, 17 Jun 2019 14:52:00 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 68240201F4619; Mon, 17 Jun 2019 16:51:58 +0200 (CEST)
Date: Mon, 17 Jun 2019 16:51:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
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
Subject: Re: [PATCH, RFC 18/62] x86/mm: Implement syncing per-KeyID direct
 mappings
Message-ID: <20190617145158.GF3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-19-kirill.shutemov@linux.intel.com>
 <20190614095131.GY3436@hirez.programming.kicks-ass.net>
 <20190614224309.t4ce7lpx577qh2gu@box>
 <20190617092755.GA3419@hirez.programming.kicks-ass.net>
 <20190617144328.oqwx5rb5yfm2ziws@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617144328.oqwx5rb5yfm2ziws@box>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 05:43:28PM +0300, Kirill A. Shutemov wrote:
> On Mon, Jun 17, 2019 at 11:27:55AM +0200, Peter Zijlstra wrote:

> > > > And yet I don't see anything in pageattr.c.
> > > 
> > > You're right. I've hooked up the sync in the wrong place.

> I think something like this should do (I'll fold it in after testing):

> @@ -643,7 +641,7 @@ static int sync_direct_mapping_keyid(unsigned long keyid)
>   *
>   * The function is nop until MKTME is enabled.
>   */
> -int sync_direct_mapping(void)
> +int sync_direct_mapping(unsigned long start, unsigned long end)
>  {
>  	int i, ret = 0;
>  
> @@ -651,7 +649,7 @@ int sync_direct_mapping(void)
>  		return 0;
>  
>  	for (i = 1; !ret && i <= mktme_nr_keyids; i++)
> -		ret = sync_direct_mapping_keyid(i);
> +		ret = sync_direct_mapping_keyid(i, start, end);
>  
>  	flush_tlb_all();
>  
> diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
> index 6a9a77a403c9..eafbe0d8c44f 100644
> --- a/arch/x86/mm/pageattr.c
> +++ b/arch/x86/mm/pageattr.c
> @@ -347,6 +347,28 @@ static void cpa_flush(struct cpa_data *data, int cache)
>  
>  	BUG_ON(irqs_disabled() && !early_boot_irqs_disabled);
>  
> +	if (mktme_enabled()) {
> +		unsigned long start, end;
> +
> +		start = *cpa->vaddr;
> +		end = *cpa->vaddr + cpa->numpages * PAGE_SIZE;
> +
> +		/* Sync all direct mapping for an array */
> +		if (cpa->flags & CPA_ARRAY) {
> +			start = PAGE_OFFSET;
> +			end = PAGE_OFFSET + direct_mapping_size;
> +		}

Understandable but sad, IIRC that's the most used interface (at least,
its the one the graphics people use).

> +
> +		/*
> +		 * Sync per-KeyID direct mappings with the canonical one
> +		 * (KeyID-0).
> +		 *
> +		 * sync_direct_mapping() does full TLB flush.
> +		 */
> +		sync_direct_mapping(start, end);
> +		return;

But it doesn't flush cache. So you can't return here.

> +	}
> +
>  	if (cache && !static_cpu_has(X86_FEATURE_CLFLUSH)) {
>  		cpa_flush_all(cache);
>  		return;
> -- 
>  Kirill A. Shutemov

