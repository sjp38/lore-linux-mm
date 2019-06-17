Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BA7DC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:46:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FCD321995
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:46:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rCvYNa7/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FCD321995
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DA628E0003; Mon, 17 Jun 2019 03:46:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98AE48E0001; Mon, 17 Jun 2019 03:46:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8796F8E0003; Mon, 17 Jun 2019 03:46:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7568E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 03:46:57 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id e6so4313021wrv.20
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:46:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YkzG8FgrjsJE2ZjG5g7hfYDZEeo6+OA/Btz/mk5jlNA=;
        b=OeHVqzeN0tfpU11oZaKBOAYeYDMol/iEHpkPEFOGCZcvSMRDWH4KUGVuVZKveeg+7K
         bLQiYjo7GzKwsJAn6K58Kg7AXnHpYzd0fLZrQbrEAHcSnRSmlmcajDQ3vFhadBOmkzH8
         3bMNLErD0mvhNp6Mk7hwluaU4ef69lJjoNzTs468G5zv9fdM0FASJxr8tcOfvZRkhv/l
         MDeE1OBtXs4rG7JdUxJqeleMGrdINreaNKV/WhbPfMrsbpS4B3Vp5GGYq++cA9JKB8JQ
         S88LtFj7xAE6WbQ3DLTEIOhwUFuzAgksvJNP7M6einIM9U24445/bkPln5N63ws+JTej
         HKTA==
X-Gm-Message-State: APjAAAVSNkL9Ad939Qa9mGE9ZGKzDtyRHaVPcBA9eEpnv88Urw1bE4S/
	vcJlPmB8HFuYaiGobpXykkwP326KLWIu9tL0qlvqrl4/Q6UBXLFR7l20aei0zf+qguSis8IL2SU
	rYbQqzUYYGbNE7iOS2XBq1xqLjJHNiraDW29DS8fIqMMOLQpQ+7Z5uwTE7gCaD1e6rw==
X-Received: by 2002:a1c:4956:: with SMTP id w83mr16970661wma.67.1560757616621;
        Mon, 17 Jun 2019 00:46:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdOlw+JGSf7gSQQ5vSCDTWK8h0IJeTFEtrm25mksfpiELCAr2ga46tAa8+EWnjfN+2N0T1
X-Received: by 2002:a1c:4956:: with SMTP id w83mr16970611wma.67.1560757615815;
        Mon, 17 Jun 2019 00:46:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560757615; cv=none;
        d=google.com; s=arc-20160816;
        b=J8r8x/AMDnyq09IF3GyNzYk7STdKmom5MR/1HsKa6IfcruRUKMhw+JlIstClAB1gWs
         F2JklFTH/y9122wsP021rR3R4+xjhcD4wZGHTfJxqyxiYycct84X0Bm/0pEJ2LwGdhJ7
         64ctXkg6ZdZl/4sC0IOgbzHujVGfLenWpgykPhGED1rpF1taTyv3nZnMNP3RMIA+hvu8
         Cziy5vfKDL2d520SStvskRCbmV/cowawfL/RdgDMOxnjb1qVYQWPbC6Culu9nGQuoLrl
         kAHTmoSLH4tr5nDgus4HUrWRvvlsZSzViW2cecskHXd41zfR5R28DZPhEoUywzg30FZ4
         2GnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YkzG8FgrjsJE2ZjG5g7hfYDZEeo6+OA/Btz/mk5jlNA=;
        b=d22cu1jn6DJsKyVSYGJI88BTwW70kIQfpZ9wSnNGhuQRvLV+QMcJCJp6FfAVnN50R2
         RBPfL5hsyVzWF4bVtIMM1Ls8XS06+fzx/z42pNgmKgWbEswihxig5yJK2ZdMUw6lo11A
         XUtnfkOg2nDUG5dNYxNVb4iWn3RqBjaONu7BecCzmcLCp5x13oCIRe3I2HJdFIMt+vdF
         GkHHMB0+bbXC6SJGB/XjfZ7syfNog12y1fjBDxu++hezJUJUGxQOm0F1LSS0rflY1yqz
         n7kh0PzUspv9+7uYQsGNsxtaFoWCsWyNgIlLuWeAjLbzXGzXaZvA4wGixES4qO2+CGLM
         +BBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="rCvYNa7/";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id d17si7519678wrp.60.2019.06.17.00.46.55
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 00:46:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="rCvYNa7/";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=YkzG8FgrjsJE2ZjG5g7hfYDZEeo6+OA/Btz/mk5jlNA=; b=rCvYNa7/NvaIcpx/eS9RsD3zq
	AfDoAj5ne5PjHAPsNNRhWmX6hypo262EDdiDCPlHuxGce32uhXRLpzjvBzbikSRZJcmLtrNTtSVgW
	rzcyk4RJqcl8vpfFlcjxtUDMDrotaRgaducgqtG9EcCMf9RifWeZ1/mUP1sMgYNYS63w2MB3TKhdV
	WTha/hzgsuI74FPHTYlGXhMyYe7cAuTCkFuHtLtoZd2os6d3RGl5hn6JWfW+XwzYRRaOiCB6h5xJ3
	17Zg4IQ1oDzAYtM1bSfmTqu6hvkkpvEX7pt8C43DWflPBRQghgLdhMs8wX6E+Du/mc5qmpWo/q3n6
	YdnKS7szw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcmLk-0005Pt-OF; Mon, 17 Jun 2019 07:46:44 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 3D54C20961A06; Mon, 17 Jun 2019 09:46:43 +0200 (CEST)
Date: Mon, 17 Jun 2019 09:46:43 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Kai Huang <kai.huang@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 49/62] mm, x86: export several MKTME variables
Message-ID: <20190617074643.GW3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-50-kirill.shutemov@linux.intel.com>
 <20190614115647.GI3436@hirez.programming.kicks-ass.net>
 <1560741269.5187.7.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560741269.5187.7.camel@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 03:14:29PM +1200, Kai Huang wrote:
> On Fri, 2019-06-14 at 13:56 +0200, Peter Zijlstra wrote:
> > On Wed, May 08, 2019 at 05:44:09PM +0300, Kirill A. Shutemov wrote:
> > > From: Kai Huang <kai.huang@linux.intel.com>
> > > 
> > > KVM needs those variables to get/set memory encryption mask.
> > > 
> > > Signed-off-by: Kai Huang <kai.huang@linux.intel.com>
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > ---
> > >  arch/x86/mm/mktme.c | 3 +++
> > >  1 file changed, 3 insertions(+)
> > > 
> > > diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
> > > index df70651816a1..12f4266cf7ea 100644
> > > --- a/arch/x86/mm/mktme.c
> > > +++ b/arch/x86/mm/mktme.c
> > > @@ -7,13 +7,16 @@
> > >  
> > >  /* Mask to extract KeyID from physical address. */
> > >  phys_addr_t mktme_keyid_mask;
> > > +EXPORT_SYMBOL_GPL(mktme_keyid_mask);
> > >  /*
> > >   * Number of KeyIDs available for MKTME.
> > >   * Excludes KeyID-0 which used by TME. MKTME KeyIDs start from 1.
> > >   */
> > >  int mktme_nr_keyids;
> > > +EXPORT_SYMBOL_GPL(mktme_nr_keyids);
> > >  /* Shift of KeyID within physical address. */
> > >  int mktme_keyid_shift;
> > > +EXPORT_SYMBOL_GPL(mktme_keyid_shift);
> > >  
> > >  DEFINE_STATIC_KEY_FALSE(mktme_enabled_key);
> > >  EXPORT_SYMBOL_GPL(mktme_enabled_key);
> > 
> > NAK, don't export variables. Who owns the values, who enforces this?
> > 
> 
> Both KVM and IOMMU driver need page_keyid() and mktme_keyid_shift to set page's keyID to the right
> place in the PTE (of KVM EPT and VT-d DMA page table).
> 
> MKTME key type code need to know mktme_nr_keyids in order to alloc/free keyID.
> 
> Maybe better to introduce functions instead of exposing variables directly?
> 
> Or instead of introducing page_keyid(), we use page_encrypt_mask(), which essentially holds
> "page_keyid() << mktme_keyid_shift"?

Yes, that's much better, because that strictly limits the access to R/O.

