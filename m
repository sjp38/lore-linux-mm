Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96E9AC31E54
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:39:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D7A32080A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:39:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D7A32080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B60AA8E0003; Mon, 17 Jun 2019 04:39:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B109C8E0001; Mon, 17 Jun 2019 04:39:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D8638E0003; Mon, 17 Jun 2019 04:39:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 67A4F8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:39:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z10so7293928pgf.15
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 01:39:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=09I/l5lGJSa8tFtbjVCJVSuLA6OoWE0rPIDLnXVXKpQ=;
        b=C/XtrNv39aLCJWxpNiCe+9paZwrG6ZMv0G7B4yamk4gSvyARXlJsSUFdNEN22N/QKs
         XB37H8qisJpgkLvd/2Ao6X68dh39wuMnx1ksatDhhU9207g5EbNZNs4X14zPY9YVAYsh
         AFv7fxGLJ0KGOdMy4Wy4ijBdUuKWn1w/qarFY1kd5HjxF0/qZXhmEYPdKwhSnk9qxlIH
         NwnHeuG9mP0bPQNMORJmoq3XKwQhMhTSaMgAVBjJn4JjGq/WB16FEHb6psF43Mz9cnxd
         +5m0kuvY6hdKArGbwDpnC0oipCH0BPmOVHOn4F8vbjTyqzVs+D4OzdpqZw62nkJz7aTH
         pdgg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX0BeSagyZT1ktTNPkjnkMJXKitJT1tAdWjgevAYj2ekiN+9pCg
	J8VyiDwWU31OKve6P7x5RjEaq9FaA7DxxTjeVTNcjbh9qDwWoO2glLgRbvvZMSgVBOBxu2r4aI7
	NqI5jJk/G5DLDcGTjDiz3nceEp9BozbUTcL7f4U5ydPmR584m4xAfw8QDV/SSCrUa5g==
X-Received: by 2002:a17:902:2a28:: with SMTP id i37mr104096812plb.52.1560760790021;
        Mon, 17 Jun 2019 01:39:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzTKjeZnnXJrElHRQXYiBEnXPAUDAy0MCHnOpdI0DF0dCG1b0Eh3f/PLPueGFBqvUyUtIj
X-Received: by 2002:a17:902:2a28:: with SMTP id i37mr104096735plb.52.1560760788420;
        Mon, 17 Jun 2019 01:39:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560760788; cv=none;
        d=google.com; s=arc-20160816;
        b=Yc1ZM+dwg2CxpDaCKNDX2dGg2rbwHFVD6DIw8tsLfH327D2kvoCkbV5MWMxl6RNfxS
         IQgEDlskhBK66YT6WbLP5v3DAJFDO3tLa2WySKB8cJ/SA3q2BYrpcyNEBjSfq5dFwPHm
         fghuGEBwZkHY/IcRPpqQ5rTG6yZUNutCXDRwQcRAc3XM+70On0s/YdpWSI9xCtEQhsLl
         spJjDyKb4VF4Gb0jtNx+Z2A1Op5WyPUGMAjLF3Pk5HtsQJ2qGCj71Vub74baiO37NbnM
         ILnJi6J0xEFP2Qj1PnrF6k7w/onLCsYIBk9HY3chVCMpxgYUrvfcI4rWYKiTcvXP9vVG
         2sYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=09I/l5lGJSa8tFtbjVCJVSuLA6OoWE0rPIDLnXVXKpQ=;
        b=gENbOfreN8wAwNIApHMfALpFXdZ8Vps7aIWhIyOlrWyeWvxMCWDNc3jPU9BihyCi6q
         coOIbd90ZPLp/kXAaH8nn50/xEqa0dX8Z0QpoLaemH1oF3RoU1jSNGP9eIY5LWY8eKlS
         TG50cKISl7zVsNkD6ZLWhaw+r6VqZhwQAZ7I90vdZIj3LcWVyXqGTd6u9Ey04gCml39n
         l4L7ArKUoRaaRc0o6hbUcsaMB93xdd+aALpKAVV6OikLopmhiGQyuxYchV00YUfr+ptY
         hwpmrkhA3KWtP6+e08fLazCvGtF2YwM4dLGeRMKe7j0wZEu0+uGx9zntdi0+DlPsmPrK
         0VaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v16si93880pfe.39.2019.06.17.01.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 01:39:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 01:39:47 -0700
X-ExtLoop1: 1
Received: from khuang2-desk.gar.corp.intel.com ([10.255.91.82])
  by fmsmga005.fm.intel.com with ESMTP; 17 Jun 2019 01:39:44 -0700
Message-ID: <1560760783.5187.10.camel@linux.intel.com>
Subject: Re: [PATCH, RFC 49/62] mm, x86: export several MKTME variables
From: Kai Huang <kai.huang@linux.intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton
 <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner
 <tglx@linutronix.de>,  Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin"
 <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski
 <luto@amacapital.net>, David Howells <dhowells@redhat.com>, Kees Cook
 <keescook@chromium.org>,  Dave Hansen <dave.hansen@intel.com>, Jacob Pan
 <jacob.jun.pan@linux.intel.com>, Alison Schofield
 <alison.schofield@intel.com>, linux-mm@kvack.org, kvm@vger.kernel.org, 
 keyrings@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 17 Jun 2019 20:39:43 +1200
In-Reply-To: <20190617074643.GW3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
	 <20190508144422.13171-50-kirill.shutemov@linux.intel.com>
	 <20190614115647.GI3436@hirez.programming.kicks-ass.net>
	 <1560741269.5187.7.camel@linux.intel.com>
	 <20190617074643.GW3436@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.24.6 (3.24.6-1.fc26) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-17 at 09:46 +0200, Peter Zijlstra wrote:
> On Mon, Jun 17, 2019 at 03:14:29PM +1200, Kai Huang wrote:
> > On Fri, 2019-06-14 at 13:56 +0200, Peter Zijlstra wrote:
> > > On Wed, May 08, 2019 at 05:44:09PM +0300, Kirill A. Shutemov wrote:
> > > > From: Kai Huang <kai.huang@linux.intel.com>
> > > > 
> > > > KVM needs those variables to get/set memory encryption mask.
> > > > 
> > > > Signed-off-by: Kai Huang <kai.huang@linux.intel.com>
> > > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > ---
> > > >  arch/x86/mm/mktme.c | 3 +++
> > > >  1 file changed, 3 insertions(+)
> > > > 
> > > > diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
> > > > index df70651816a1..12f4266cf7ea 100644
> > > > --- a/arch/x86/mm/mktme.c
> > > > +++ b/arch/x86/mm/mktme.c
> > > > @@ -7,13 +7,16 @@
> > > >  
> > > >  /* Mask to extract KeyID from physical address. */
> > > >  phys_addr_t mktme_keyid_mask;
> > > > +EXPORT_SYMBOL_GPL(mktme_keyid_mask);
> > > >  /*
> > > >   * Number of KeyIDs available for MKTME.
> > > >   * Excludes KeyID-0 which used by TME. MKTME KeyIDs start from 1.
> > > >   */
> > > >  int mktme_nr_keyids;
> > > > +EXPORT_SYMBOL_GPL(mktme_nr_keyids);
> > > >  /* Shift of KeyID within physical address. */
> > > >  int mktme_keyid_shift;
> > > > +EXPORT_SYMBOL_GPL(mktme_keyid_shift);
> > > >  
> > > >  DEFINE_STATIC_KEY_FALSE(mktme_enabled_key);
> > > >  EXPORT_SYMBOL_GPL(mktme_enabled_key);
> > > 
> > > NAK, don't export variables. Who owns the values, who enforces this?
> > > 
> > 
> > Both KVM and IOMMU driver need page_keyid() and mktme_keyid_shift to set page's keyID to the
> > right
> > place in the PTE (of KVM EPT and VT-d DMA page table).
> > 
> > MKTME key type code need to know mktme_nr_keyids in order to alloc/free keyID.
> > 
> > Maybe better to introduce functions instead of exposing variables directly?
> > 
> > Or instead of introducing page_keyid(), we use page_encrypt_mask(), which essentially holds
> > "page_keyid() << mktme_keyid_shift"?
> 
> Yes, that's much better, because that strictly limits the access to R/O.
> 

Thanks. I think Kirill will be the one to handle your suggestion. :)

Kirill?

Thanks,
-Kai

