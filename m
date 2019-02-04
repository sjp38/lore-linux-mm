Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C9E3C282CC
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 19:40:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD1DF2087C
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 19:40:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD1DF2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CDD98E0059; Mon,  4 Feb 2019 14:40:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07EDA8E001C; Mon,  4 Feb 2019 14:40:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E897D8E0059; Mon,  4 Feb 2019 14:40:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A90838E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 14:40:34 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id b7so543423pge.17
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 11:40:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=T+XnHt9phSVYV4D22R7vO+07OjDgFPVFIRINvGMhBOc=;
        b=r8KyDFoIDgf8mLTiGY7IYJXiZjo/minbTOGm7yubzXAXgE5pCKzWRQGRmHP/Fl35Jw
         hNSQ7GXlvwjvgOJ5Teax1xMGLcua++XPMrks+0kqKyA+FDNMtO5cz42dJqraS3q1HLOG
         xng5WjbxqI8oi9JB4EbO0z9JByZXPojdz+L+rS90eB3HArjkSNM0s4czKGMETNpJbzi4
         fJxNanx2A++qOwOoNdpNC2ZVsGSjUywRnfKua5Zktc7fGZSC4Vj/ZcrC6Fg4mdJY4GKO
         D7/OMvDhbWHs4inPctJpJHW8ZzFaR4d5wrCqp0w/jRivBtbU6Q+XqL2ODhIJ1M2G6dYw
         bO4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaUOtiY7gk6PgKTnlWlsR0PYJdLg3YTRQYco/R7Cke9qUE/vPGy
	61+cAglP6zrT3C4UV3HySOXaA9RLLrNEWb5Yxbo28XcXRUSnIqkdknJSOyuLwfeUG63FsERecUI
	QaN7mlJQalDPe8WwP7G+lzw4pMcMD/7x0n1JDZnOmufAm9RlxKYfQ5Fc5dS25t8sOCg==
X-Received: by 2002:a63:a452:: with SMTP id c18mr974018pgp.204.1549309234288;
        Mon, 04 Feb 2019 11:40:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaVUvFba569myfPh82lK1ZSo1ls16yeZHd9NJxCnjr6b7Z/nJwwCpNl8qIOA7N7BFuZTPCC
X-Received: by 2002:a63:a452:: with SMTP id c18mr973978pgp.204.1549309233416;
        Mon, 04 Feb 2019 11:40:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549309233; cv=none;
        d=google.com; s=arc-20160816;
        b=B4kVR2+2IQyoSxcZrotuqjc0W6Z46Y+89MsBJobAvdho9Dkp3GaOY98WnpAQPZFule
         8QkH0nNksr7m9Iry2QKxnEkItKasGLA1b+eldQB2JKCEiEx+5eSZyPESEkZuoBoqlrBu
         8vMrjnat4/oW6aS6r0C+9yxVXekwUPZ7S3fDkrT27bdSOFWccJsAta6EvTLDM5DQgd5x
         E/9vR8sNhGDlbzyiLwd3BbJBKQJVjfNYoe8bARdohku7/ABZkFiYS/w3zhakN+ZGZocL
         Csx0GmvDWPiCTrOi87abVzcNmclHDHOt91rpbUk2v0ABL34iLPeKV/UrfXHfDWqOTt1N
         SdHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=T+XnHt9phSVYV4D22R7vO+07OjDgFPVFIRINvGMhBOc=;
        b=LO4j+TzRkTPgBV7vCm17rFw0rj+3JafP6O3kWfAK/uG01OpxFRxP/5alju4DwcI8r0
         6ebQ49TbDVwQyShSjS7c/CsoQUolqjgz7EnnFcUody7Qb5dCZVeMeoORhB5jvLP5jXNX
         DHBp1rs5x5/67fCU0ANb+ueIroAFjyBPOfK1yOiZ7jdyBbWu1xRencVA0hctuA3a6Ka6
         +D94boruLBjOialUBN5P/rbozDvnvqE2q21ePipTJY1N4Z2TItnxP+hA7LAzgGj/9pIj
         H53ftE78I6OUrGTKt2oZgPu2GzEJ1OGgiFWgQLGv+j6Rp8LKBvY3nEUtPyQtQrKb+ZqK
         Qd+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d8si814143pgl.386.2019.02.04.11.40.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 11:40:33 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Feb 2019 11:40:32 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,560,1539673200"; 
   d="scan'208";a="131487035"
Received: from ray.jf.intel.com (HELO [10.7.201.17]) ([10.7.201.17])
  by orsmga002.jf.intel.com with ESMTP; 04 Feb 2019 11:40:32 -0800
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
To: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181558.12095.83484.stgit@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <33d14370-b47d-5ceb-09c4-41f0d6b33af8@intel.com>
Date: Mon, 4 Feb 2019 11:40:32 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190204181558.12095.83484.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> +void __arch_merge_page(struct zone *zone, struct page *page,
> +		       unsigned int order)
> +{
> +	/*
> +	 * The merging logic has merged a set of buddies up to the
> +	 * KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER. Since that is the case, take
> +	 * advantage of this moment to notify the hypervisor of the free
> +	 * memory.
> +	 */
> +	if (order != KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
> +		return;
> +
> +	/*
> +	 * Drop zone lock while processing the hypercall. This
> +	 * should be safe as the page has not yet been added
> +	 * to the buddy list as of yet and all the pages that
> +	 * were merged have had their buddy/guard flags cleared
> +	 * and their order reset to 0.
> +	 */
> +	spin_unlock(&zone->lock);
> +
> +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
> +		       PAGE_SIZE << order);
> +
> +	/* reacquire lock and resume freeing memory */
> +	spin_lock(&zone->lock);
> +}

Why do the lock-dropping on merge but not free?  What's the difference?

This makes me really nervous.  You at *least* want to document this at
the arch_merge_page() call-site, and perhaps even the __free_one_page()
call-sites because they're near where the zone lock is taken.

The place you are calling arch_merge_page() looks OK to me, today.  But,
it can't get moved around without careful consideration.  That also
needs to be documented to warn off folks who might move code around.

The interaction between the free and merge hooks is also really
implementation-specific.  If an architecture is getting order-0
arch_free_page() notifications, it's probably worth at least documenting
that they'll *also* get arch_merge_page() notifications.

The reason x86 doesn't double-hypercall on those is not broached in the
descriptions.  That seems to be problematic.

