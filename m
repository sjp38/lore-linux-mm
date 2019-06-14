Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA99DC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:56:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B14C92133D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:56:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cSm5PBNC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B14C92133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D6AE6B0269; Fri, 14 Jun 2019 07:56:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 486C96B026A; Fri, 14 Jun 2019 07:56:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 375A46B026B; Fri, 14 Jun 2019 07:56:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 000246B0269
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:56:52 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u7so1624849pfh.17
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:56:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sguVOcCD8xzkuKBxAXbNwLoTIO2Bzo3Eiksza5G7pQs=;
        b=LlH1dxaKgxJOF9UJHCKFK4HON2PeQ5zAqWde5ID9BoP7OJMudBib9FgHTErfNjoO2q
         yj+5JPN0eVDsKQFvmfRbVNRx8N4ZbKVFI3XWNU3bStRxkcI6HpWHhEcVejNsgv8psYAl
         tSEXDNAL/Btojbn3lPRfkk3WsXB3i+SM3zdsBApkdqAUb3vwnnXtjuUc8BzH+EH1lnKF
         qWxaOKhygFMiecf9hUNVOkFt45F0lI104EikYQ9QaQGd0p962GWKc+BrJ3bOD8JZBJ0p
         27v1CnqfYBNxsBbTFJXuSxiXVi+7UYd0MmP7ywkpGSIgw98OBYpF0SB9zRyRLudL6rKg
         Sv1g==
X-Gm-Message-State: APjAAAWtQjHy8YVk3TAZwaCy0LU42ttSlCh0c87au30kW1SdvGrQ+uG1
	k99338QV8O4eNsI21M2sbBic3MWPbCTWbsq6Lhcr10TcX+jwq5dWiA9b4jkqL3lmI17oC7bdcks
	3RzsmM4JJc2G0oPmkePN1K43Mw53/XGswaS0uMeQL1Quq/OSO5odULRuJHQiuEtj0cg==
X-Received: by 2002:a17:902:b611:: with SMTP id b17mr40364597pls.261.1560513412662;
        Fri, 14 Jun 2019 04:56:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwd5lLv2GjuQrDIEm2SfgaSoNeKpTErvSLE2NzJQ75jBf090M6rAhrvyRqWoC/GFt6QHela
X-Received: by 2002:a17:902:b611:: with SMTP id b17mr40364557pls.261.1560513412024;
        Fri, 14 Jun 2019 04:56:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560513412; cv=none;
        d=google.com; s=arc-20160816;
        b=k5VikiTXqO8xVOJsgb+oCsL6PkrRwwd+jmPf9d9niEY+KCqhnerVwi+8xqmmMyJlDK
         FPxtprKlzlpdt5ciBPRulmTQ5Veq/VMBOdtHcdSMb7GN0lRP78ixpYV+GhiDp9SbJDT5
         yGRVU9tuyWulaROUEcltTsbMxLpmiLsWH4leGFBcEHkbloqZTJU5kT3evzMwIgervvJ8
         YrJIq5/D+0U8p6TOa1JJucSSuLaQSsN+BRDKKSegh691NzqbVwt9uqy/gacYOJENEAL1
         FDXZVMDWHWVQ+zQq5qvsooTMYT1WXWwJmsfGyB7MjgBqKpv4k7A+3J+hmceimRtevzS8
         O8tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sguVOcCD8xzkuKBxAXbNwLoTIO2Bzo3Eiksza5G7pQs=;
        b=CP9UmWFZywYJZpsDP5TZxV6RlH9XfeNwQt0clN+3aFm2b/mCojtn9SC564jZMWaMud
         yPUTD5xxRd+O/g0c1icuQk03ZJymAPfEXqW/bupw/CsSgNzcA+0xrb+idQwT0m5LVApG
         K7my4+kEFdisIQ+s5hIbtxM2B0nxOVcO4SnPcb0SXuv2dNYjzBRJoA8CDxhGbrAQIhf5
         RoVcZH/qHhK/0aMZ3n8NQ36Q+GPsPv0beNOST+5Zw4ICtqpnr09bZO+ycSRrHDDutoNn
         JkBNUI4sBgSFnIvxvfD4vcoEETv1PfyyS3BVz/MG8tIZbLtc1pzXTVGbDhCkVBbYdVis
         b66w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cSm5PBNC;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id gn2si2063366plb.273.2019.06.14.04.56.51
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 04:56:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cSm5PBNC;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=sguVOcCD8xzkuKBxAXbNwLoTIO2Bzo3Eiksza5G7pQs=; b=cSm5PBNCt4M8uJZY1qjBxCUXr
	H5O87c2TUu73yBZbv+rbeId9QKYO7rcOoardZx9weKhgS+3hIMIFgLL4gq0VjjQ41UCQ0DZTJEvBE
	v9L26qxOd+/i6m3ddYrH901cECMuXIRsttSXQbJ/ac3UCFB6SWlLjHy/J0weQblA0TThiRJPQeWkB
	rU+VGSfcBuXDneU9uteMmYGcC+aTCn5DvWUt2neAkStNKIfgqTFlWpBFp4a4oUAtJ7MonQrarCOB8
	l1CAdU/xZhFdBlq06gHnV/SuU6BN5256YqvNgiiialsn3ZXhyRUV73I2u1viT0U+EGpE+8IZxyp4+
	NfcckPLsg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbkp7-0003dw-4X; Fri, 14 Jun 2019 11:56:49 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id A68CE20A29B4F; Fri, 14 Jun 2019 13:56:47 +0200 (CEST)
Date: Fri, 14 Jun 2019 13:56:47 +0200
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
Subject: Re: [PATCH, RFC 49/62] mm, x86: export several MKTME variables
Message-ID: <20190614115647.GI3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-50-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-50-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:44:09PM +0300, Kirill A. Shutemov wrote:
> From: Kai Huang <kai.huang@linux.intel.com>
> 
> KVM needs those variables to get/set memory encryption mask.
> 
> Signed-off-by: Kai Huang <kai.huang@linux.intel.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/mm/mktme.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
> index df70651816a1..12f4266cf7ea 100644
> --- a/arch/x86/mm/mktme.c
> +++ b/arch/x86/mm/mktme.c
> @@ -7,13 +7,16 @@
>  
>  /* Mask to extract KeyID from physical address. */
>  phys_addr_t mktme_keyid_mask;
> +EXPORT_SYMBOL_GPL(mktme_keyid_mask);
>  /*
>   * Number of KeyIDs available for MKTME.
>   * Excludes KeyID-0 which used by TME. MKTME KeyIDs start from 1.
>   */
>  int mktme_nr_keyids;
> +EXPORT_SYMBOL_GPL(mktme_nr_keyids);
>  /* Shift of KeyID within physical address. */
>  int mktme_keyid_shift;
> +EXPORT_SYMBOL_GPL(mktme_keyid_shift);
>  
>  DEFINE_STATIC_KEY_FALSE(mktme_enabled_key);
>  EXPORT_SYMBOL_GPL(mktme_enabled_key);

NAK, don't export variables. Who owns the values, who enforces this?

