Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5F12C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 12:04:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A28472133D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 12:04:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jQiHhG3v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A28472133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E6456B0269; Fri, 14 Jun 2019 08:04:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36F9F6B026A; Fri, 14 Jun 2019 08:04:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 238636B026B; Fri, 14 Jun 2019 08:04:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E32D16B0269
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:04:29 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c17so1632156pfb.21
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 05:04:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=alVHZlU/yeIna7DaDwxabV9QPdfrwUg7lNOiHL0K7hc=;
        b=XmXds8rOtzQTlt/G7/AtkamOtuWg2hFToKtv0DbaL7wtFuUCjulDvZjEdp0u6QxEBN
         XOeo63n2aSC4+137pWrrM7nncQzAgKgTDs5ig7wlYFJCZ0X7TfDvJNoo2n4yJ6EUAoCA
         3iotK44c+TQA+7EcCoHxfGyDTY45jmgQRPdspcTsULTov5DKsgbdbGLRAw6tXN0Q7W98
         /OMa1tOiRWn/SpcRd/eeQ+Y6mVmL+H64o/nhuZXag2MI5HNV4q+kaIQ6M+QKa343LKIo
         M/9Lwy0pzK6JZ+hxZtfDw6hWH5kF9klOQq2CxmnOUtY2DG0pWSSe6PQsm6TBp6+cGusa
         RjUA==
X-Gm-Message-State: APjAAAVFvqQU1yxA5gyrwUE69IZy8W9wdRPwwvMIVINEdw6GvIxscfTM
	c5VIemJrAdjwrARMz4iv+XTvMBSfKtZMxDSqHynuppVP7ViE83DV/9twCK5mr+wt5SSupS5mUjV
	isQ2u+KKCZwWQ4Rbj4FP+O6zUGaFycVJzsPfFtplaudQG5AxgmDFiN5Xs22QeXrxtuw==
X-Received: by 2002:a65:534b:: with SMTP id w11mr36152166pgr.210.1560513869524;
        Fri, 14 Jun 2019 05:04:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqythAOy/bPGYMS0B74Qp57AQJgiBF6TS2k2YTV+iOULFDyd1H1rlRSl+RiJiZVCytWjoTan
X-Received: by 2002:a65:534b:: with SMTP id w11mr36152106pgr.210.1560513868644;
        Fri, 14 Jun 2019 05:04:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560513868; cv=none;
        d=google.com; s=arc-20160816;
        b=0Q+5vwOf7qBd8SFhnxPqGOV40tYrW4OfesRHtuydaaEidRdZaRlJ8GRx+ZK9QZXIbp
         DDBp69foPChby1Ogpybe45fOycjQSjyrPjQGDP4vKyWu9TY3bFJyPYMGm/34MTCgxfnz
         BJMZCP/WT8l8MvV+OCK6hUcyU/IG2XsPdCxY2q+ZHD5Z6JonIRksKYmM8lOo5LUy45ld
         EINm1AvFrrQE8MxRaFC33DlPNSHG4zNnivejVc7hEVI/eE66fGmb4+JSkNp6WLNJfgEV
         tR5YzkLWrgaOp38X+7fPfZW0gmEsc5Ln5EQX+4JMD9Y9PAAGAJRWEbuZAZB6QzBZejVN
         6udg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=alVHZlU/yeIna7DaDwxabV9QPdfrwUg7lNOiHL0K7hc=;
        b=B+5K9HuL3rgoQuLVl4IdIBtuM5ZBLsLYRaHmKeG8f15aT8xI+RW3KjTbgYCiU8l8VN
         qkxE65S9mQZ408Lvx9oxiElCsefnAyKcGbXLDikHrv5mevflHUyxNYZoUkXkSnepmqXx
         bjherPLAPzGC/MdFU09a3wREjUNA/RGbOt3C9A9SSj48UHL1HtZztO17y4w4A8K5KUc4
         57nLFGnjDsQuD9dr6jiRKSc0w1BvoqGAFIhqLqp5KWpb3MS3mClRMG01oOgdaRLxEJH/
         s6zpX1bP7EKJKU9PvXCPXysHbKxGqJNRV11YgpEmbbfzIgZq89pF3expzgVqUte2aP3W
         qg8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jQiHhG3v;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a3si2210780plc.132.2019.06.14.05.04.28
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 05:04:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jQiHhG3v;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=alVHZlU/yeIna7DaDwxabV9QPdfrwUg7lNOiHL0K7hc=; b=jQiHhG3v7EnRCAKQJ2BUOiOxw
	BldbzF3Z7igBVgDE13rSdJP5Xm+EPAMWgYZ7B948eJIxJR26at4A0gEjvCsyqG4jhIoSTRQTHy66F
	q1Lp5wYqW5JnFDHmW9wfQvUH2yXpgHlV+3pK6H5xe+rfQxW6fSzVKBMZLKc2ykaJlJ5m30So5TAVR
	s78XezV2gDn8USUKISzydWIp5yu23olD9M4tPQF/yw8sqkbQFdQ1mcpjttqeXZMNdqQDDP0SMA6ko
	ZLAb6gdVgKb/pkijrewfJeEBT6079GT5Q4uuE2BiL2XhqJMetnqruL8j2dVPJTtj2Pm4gScClcHcm
	iDydIt+cQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbkwT-0006qX-QL; Fri, 14 Jun 2019 12:04:25 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 4BD1920A29B58; Fri, 14 Jun 2019 14:04:24 +0200 (CEST)
Date: Fri, 14 Jun 2019 14:04:24 +0200
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
Subject: Re: [PATCH, RFC 51/62] iommu/vt-d: Support MKTME in DMA remapping
Message-ID: <20190614120424.GJ3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-52-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-52-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:44:11PM +0300, Kirill A. Shutemov wrote:
> @@ -603,7 +605,12 @@ static inline void dma_clear_pte(struct dma_pte *pte)
>  static inline u64 dma_pte_addr(struct dma_pte *pte)
>  {
>  #ifdef CONFIG_64BIT
> -	return pte->val & VTD_PAGE_MASK;

I don't know this code, but going by the below cmpxchg64, this wants to
be READ_ONCE().

> +	u64 addr = pte->val;
> +	addr &= VTD_PAGE_MASK;
> +#ifdef CONFIG_X86_INTEL_MKTME
> +	addr &= ~mktme_keyid_mask;
> +#endif
> +	return addr;
>  #else
>  	/* Must have a full atomic 64-bit read */
>  	return  __cmpxchg64(&pte->val, 0ULL, 0ULL) & VTD_PAGE_MASK;
> -- 
> 2.20.1
> 

