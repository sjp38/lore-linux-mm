Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB2BBC31E54
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 03:14:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A9A6216FD
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 03:14:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A9A6216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB7218E0003; Sun, 16 Jun 2019 23:14:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B672E8E0001; Sun, 16 Jun 2019 23:14:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A570A8E0003; Sun, 16 Jun 2019 23:14:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CDD98E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 23:14:35 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 59so5171046plb.14
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 20:14:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Mz784ipIwNxejQsE2+n+M8MeNShXZD+sx5XSxzLueo8=;
        b=lKkP+U8T1+S99MAQ5HMp28GSdjrNpbvr9sEDcTsI0OchglEZOC+BthO6CCf+0TdDu4
         JKJUI9F6D8USyAXRAEqq6paV8bp1B54zOjfLWd7Hymdus++Nq+PASFcCaK4h5VVYekF6
         4ZspYIo5DgSeJRELF12XemXu5Cgk4RxAh5xwnxvjRhczbPYNQ9G10MFFnAGEv3OobpWa
         zSLS9IueuQX0wkA2B1m7sOnO2ANwImeUfYMVjVbqrTFRNYbI70sSONPYoZ3Hey0LryDG
         efoHksmR6AaUshi76+/Eni2XaWUV7bxcf0XdGaMLyethw+LhwwtebdAZkIVGWzeb13LZ
         dXHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUev33LpJxfJ3N8iBAxjxE9GqfoWvb8OD6NG7z0PzGz/3yaN2Qk
	9zbgOrzyLPRw2ZuhLEyNLorHgXFIgK2pDr16zQtiaQx8qwwDhb/pPoqSt0TMRUmthwjB3f50BLC
	qJihydfZ+gvvDdsmoHoPibDTNnOXdc5KmLblLiXpOJVAG+Km6xLFg6d60I7Ig+cuakA==
X-Received: by 2002:a17:902:7c03:: with SMTP id x3mr81189897pll.242.1560741274950;
        Sun, 16 Jun 2019 20:14:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+DPfi12uv0yK6D2imtaXKboklGiMDesSpJf6ML3Dw4dgBt1emnmZxJmpMerJPHxK1lbYs
X-Received: by 2002:a17:902:7c03:: with SMTP id x3mr81189847pll.242.1560741274239;
        Sun, 16 Jun 2019 20:14:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560741274; cv=none;
        d=google.com; s=arc-20160816;
        b=0r9Wuzv8HwFLVp0HOTti0tSzCmxq1YuMNNAfaEe+4wPaACzhf7Hgfu449NevUo8Sqb
         C2QFK/2NoUsOrlLiIv978PiQxshZj43WumtnjZmopOqD7wEmjZzPGzlVz3eGQa4s0wF1
         8udCS284sZq0BALx+XhFnNEHXuOtmrUAaVN1b81Ds6DhvdZ9y/fTeiLkXWwGpzYuQLLU
         eOLTKDCIFugprgv6BzZqZXKfaJrTorrb33fSMc/yW46aBSJ1yHoxaewtcBEaJX+nHrm/
         VNGihe6yy+PZV/V5d5l3LLV0BzlsHEz6aRGmD7+WAV3NTOQO0ISNvVCkrZbDxC1Q2l8j
         UqlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=Mz784ipIwNxejQsE2+n+M8MeNShXZD+sx5XSxzLueo8=;
        b=YcrnGnNW37x8lQWwcT9UUMjTKhrfsXQniww15+hSYr20mbT3VQBdSdaHWDSj4M1sF8
         GaduYvqAqU6Pov4WzzrN9BUegmUiIBAqrCzsVGYcZgGQCk7vlgBDhalWgXPa5A0l6h05
         vrFev+bppfXLwx1XDjUxnPvBrvmvVi3tIiP0B6V/WdaZ2sIPB5FOzWIvCTw8eCRKbmsL
         wFig8doP7aVwZOwJr/Q/asdb7BuHTacT/RRDzTo9FCecRVgJIGNVaNV3zW2W1pDAhQgr
         vGfgowQvjJ1JBu0ZkdGQFCrQPrgBdBbJ1zllLVlvdsgRtaUfsw4HwRJdKs2V7gqlCRsC
         1yHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b6si9189523pfa.36.2019.06.16.20.14.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 20:14:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Jun 2019 20:14:33 -0700
X-ExtLoop1: 1
Received: from khuang2-desk.gar.corp.intel.com ([10.255.91.82])
  by fmsmga004.fm.intel.com with ESMTP; 16 Jun 2019 20:14:30 -0700
Message-ID: <1560741269.5187.7.camel@linux.intel.com>
Subject: Re: [PATCH, RFC 49/62] mm, x86: export several MKTME variables
From: Kai Huang <kai.huang@linux.intel.com>
To: Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov"
	 <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas
 Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski
 <luto@amacapital.net>, David Howells <dhowells@redhat.com>, Kees Cook
 <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, Jacob Pan
 <jacob.jun.pan@linux.intel.com>, Alison Schofield
 <alison.schofield@intel.com>,  linux-mm@kvack.org, kvm@vger.kernel.org,
 keyrings@vger.kernel.org,  linux-kernel@vger.kernel.org
Date: Mon, 17 Jun 2019 15:14:29 +1200
In-Reply-To: <20190614115647.GI3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
	 <20190508144422.13171-50-kirill.shutemov@linux.intel.com>
	 <20190614115647.GI3436@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.24.6 (3.24.6-1.fc26) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-14 at 13:56 +0200, Peter Zijlstra wrote:
> On Wed, May 08, 2019 at 05:44:09PM +0300, Kirill A. Shutemov wrote:
> > From: Kai Huang <kai.huang@linux.intel.com>
> > 
> > KVM needs those variables to get/set memory encryption mask.
> > 
> > Signed-off-by: Kai Huang <kai.huang@linux.intel.com>
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/mm/mktme.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
> > index df70651816a1..12f4266cf7ea 100644
> > --- a/arch/x86/mm/mktme.c
> > +++ b/arch/x86/mm/mktme.c
> > @@ -7,13 +7,16 @@
> >  
> >  /* Mask to extract KeyID from physical address. */
> >  phys_addr_t mktme_keyid_mask;
> > +EXPORT_SYMBOL_GPL(mktme_keyid_mask);
> >  /*
> >   * Number of KeyIDs available for MKTME.
> >   * Excludes KeyID-0 which used by TME. MKTME KeyIDs start from 1.
> >   */
> >  int mktme_nr_keyids;
> > +EXPORT_SYMBOL_GPL(mktme_nr_keyids);
> >  /* Shift of KeyID within physical address. */
> >  int mktme_keyid_shift;
> > +EXPORT_SYMBOL_GPL(mktme_keyid_shift);
> >  
> >  DEFINE_STATIC_KEY_FALSE(mktme_enabled_key);
> >  EXPORT_SYMBOL_GPL(mktme_enabled_key);
> 
> NAK, don't export variables. Who owns the values, who enforces this?
> 

Both KVM and IOMMU driver need page_keyid() and mktme_keyid_shift to set page's keyID to the right
place in the PTE (of KVM EPT and VT-d DMA page table).

MKTME key type code need to know mktme_nr_keyids in order to alloc/free keyID.

Maybe better to introduce functions instead of exposing variables directly?

Or instead of introducing page_keyid(), we use page_encrypt_mask(), which essentially holds
"page_keyid() << mktme_keyid_shift"?

Thanks,
-Kai

