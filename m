Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79E76C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 14:28:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15E0E21E70
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 14:28:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="1kfH0kuK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15E0E21E70
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 770FA6B0003; Wed,  7 Aug 2019 10:28:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 721A56B0006; Wed,  7 Aug 2019 10:28:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 610EF6B0007; Wed,  7 Aug 2019 10:28:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 143786B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 10:28:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so56214024ede.23
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 07:28:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=AK75Iich5LWx3hmzjSJRalUSa9mHCHUU+BYMHbZIZMc=;
        b=DlZWSdzIf+tGjDDEkM5EriXTYAU97gXX8eM6TFjvohwoXqlGN6Y3BnFNYNpB2+u8nz
         407WjBK6nfpfOuhZAoBEoFVc3/tTFiZ6PEkvmOXlnmCX1PSDgngVTqZJrr9wc/d28tHC
         zXm4wcMObRdVVDAcxVnFQ9RvwRZOQGQNbpS32vwmxZ/6//Hs7qBpbYI6w/68U6Jr++rN
         TEGflLO4A7X+Gfg1/uurgAMDLJY1/Kg1P3KpVgh+frNB3sYwSWaWdRiCNCVAcLCRSpEE
         q9hNdAwLYaVwWio1M4ycKUxIlapO3OBs7oHKJgpDwJ3qViEB3VstaetcRZ/qstJjyCi/
         UNvQ==
X-Gm-Message-State: APjAAAW0a8xA9DzZgY2iC0vs4PnrgRvWGM3yZuk+pRP/4M9QZXLPCVD4
	7rib3fTR/m7v5ee5B1374WT4/lXx1qZkHN5PXQ2SbCIV1cNq9zf+kPIsl4SUMVxP+NRy0MBS8eS
	jXck4o75fwb9QL09pFe0TsM4R1FoX1RnYFfOaO8erayZgBNHzyKfgLsRFgIe5oJVNVg==
X-Received: by 2002:a17:906:ad86:: with SMTP id la6mr8635094ejb.43.1565188132518;
        Wed, 07 Aug 2019 07:28:52 -0700 (PDT)
X-Received: by 2002:a17:906:ad86:: with SMTP id la6mr8635029ejb.43.1565188131577;
        Wed, 07 Aug 2019 07:28:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565188131; cv=none;
        d=google.com; s=arc-20160816;
        b=0JutrujMn9owNSBbAc07E0Qo68NjcdlTuBlaj0Fw1d4RWJeAtm4iEaTAzPjtwbBvR6
         nmJV1p9OBLvb2DGO0HY68Fz6gTLivCZhnN+Rcz/eZuYqWJ0U6H+zCkBQFZ9dVsM+NTmY
         zwuA8mJ6JJLPRYpeBNMnFlzhGIJLfnu0Zbv20+hTHRfqe0e4qQbUtXGVs38k5j83MoPd
         ZR9F1C6DM64OFBjXfqhAGNxQdSpHuDTM5mSOoKrW4yqTiLd09i+yFPLteG4fyZlxwy36
         eq91GqJ9CLt9JB9cibMCVrDdQsT3HK6UrIcLgB2bHLVARD/a9VkVl1Cu6yVihRmAx8K+
         mUTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=AK75Iich5LWx3hmzjSJRalUSa9mHCHUU+BYMHbZIZMc=;
        b=qNfglxrRr3f9LeP3eDgytxpTopmRG2cMQk+HNx35KlxO++QrchPwXQmuDGu9qrFPDd
         m7mmUUXH+j7KmdyIIc1M+vQHFFnFl3Ae4RfmSjV+QzrL72Uk6yKzh0cL/zNnXObSNj03
         8LwSYeebuHgvjch2Uw+T06JUfjQ7c8gotbJivNo5Khpett1t2E6LuUXomB7bzv3JDRcr
         Ne4ZF1ZtDkbzZHeuNlFmjx1CM6+sNajAIkgs6pQ/hdk4562Z6Mloqqs+oWZ1yDSRlkhP
         T5jR91mIF0LpcF2GbWElLSePjFm59e96Dc05j5ygd9G77aHOQihzs9nSvuswe0euortL
         GSaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=1kfH0kuK;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d11sor72598209edy.4.2019.08.07.07.28.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 07:28:51 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=1kfH0kuK;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=AK75Iich5LWx3hmzjSJRalUSa9mHCHUU+BYMHbZIZMc=;
        b=1kfH0kuKZirattxRfWIXAb8r/8XsqrwQ5+d4RJ0mmXY7DEH4SwvLktRN8ao5mQqeIV
         Y3ts078FX51cmkr90vSJtL/7kpBoPXXkQupeiLZiWKerWAGmgFJ5Zvn2S/5gBdKtsK7G
         gF0VS9r1jf+JhGubMnetDvc2e92Z6Z5+z4U8O8JMtfrTP/Llowbkfpl8b3oqAvhid7ve
         8wnfPsAKUAEzIX6F9HxCD3lF0DRbTNLYuN6fS7wGv7dIqOlhNFeAz1z8FZ5C16HANqQj
         /iY4mVqDeK/M8VJxQ2dSgEi0eZ/FsqFz9IbyUsa9c4zxZs+yPBtOzLgGcVj2gGvMJA17
         Vpqg==
X-Google-Smtp-Source: APXvYqwSHTgb4vN8z+yJxmNxZpsglNgVTEuyS2yIdiGBZDefygaCQHxYo93g2XFzgfEA6Rl1wRLUyg==
X-Received: by 2002:a50:84a1:: with SMTP id 30mr10145054edq.44.1565188131065;
        Wed, 07 Aug 2019 07:28:51 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id oh24sm15018422ejb.35.2019.08.07.07.28.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 07:28:50 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 81A7010073F; Wed,  7 Aug 2019 17:28:50 +0300 (+03)
Date: Wed, 7 Aug 2019 17:28:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: "Lendacky, Thomas" <Thomas.Lendacky@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"x86@kernel.org" <x86@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"keyrings@vger.kernel.org" <keyrings@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 47/59] kvm, x86, mmu: setup MKTME keyID to spte for
 given PFN
Message-ID: <20190807142850.mjp4ctqc7wttpser@box>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
 <20190731150813.26289-48-kirill.shutemov@linux.intel.com>
 <a3aee9ea-a3ce-1219-b7ff-5a1b291bffdd@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a3aee9ea-a3ce-1219-b7ff-5a1b291bffdd@amd.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 08:26:52PM +0000, Lendacky, Thomas wrote:
> On 7/31/19 10:08 AM, Kirill A. Shutemov wrote:
> > From: Kai Huang <kai.huang@linux.intel.com>
> > 
> > Setup keyID to SPTE, which will be eventually programmed to shadow MMU
> > or EPT table, according to page's associated keyID, so that guest is
> > able to use correct keyID to access guest memory.
> > 
> > Note current shadow_me_mask doesn't suit MKTME's needs, since for MKTME
> > there's no fixed memory encryption mask, but can vary from keyID 1 to
> > maximum keyID, therefore shadow_me_mask remains 0 for MKTME.
> > 
> > Signed-off-by: Kai Huang <kai.huang@linux.intel.com>
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/kvm/mmu.c | 18 +++++++++++++++++-
> >  1 file changed, 17 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> > index 8f72526e2f68..b8742e6219f6 100644
> > --- a/arch/x86/kvm/mmu.c
> > +++ b/arch/x86/kvm/mmu.c
> > @@ -2936,6 +2936,22 @@ static bool kvm_is_mmio_pfn(kvm_pfn_t pfn)
> >  #define SET_SPTE_WRITE_PROTECTED_PT	BIT(0)
> >  #define SET_SPTE_NEED_REMOTE_TLB_FLUSH	BIT(1)
> >  
> > +static u64 get_phys_encryption_mask(kvm_pfn_t pfn)
> > +{
> > +#ifdef CONFIG_X86_INTEL_MKTME
> > +	struct page *page;
> > +
> > +	if (!pfn_valid(pfn))
> > +		return 0;
> > +
> > +	page = pfn_to_page(pfn);
> > +
> > +	return ((u64)page_keyid(page)) << mktme_keyid_shift();
> > +#else
> > +	return shadow_me_mask;
> > +#endif
> > +}
> 
> This patch breaks AMD virtualization (SVM) in general (non-SEV and SEV
> guests) when SME is active. Shouldn't this be a run time, vs build time,
> check for MKTME being active?

Thanks, I've missed this.

This fixup should help:

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 00d17bdfec0f..54931acf260e 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2947,18 +2947,17 @@ static bool kvm_is_mmio_pfn(kvm_pfn_t pfn)
 
 static u64 get_phys_encryption_mask(kvm_pfn_t pfn)
 {
-#ifdef CONFIG_X86_INTEL_MKTME
 	struct page *page;
 
+	if (!mktme_enabled())
+		return shadow_me_mask;
+
 	if (!pfn_valid(pfn))
 		return 0;
 
 	page = pfn_to_page(pfn);
 
 	return ((u64)page_keyid(page)) << mktme_keyid_shift();
-#else
-	return shadow_me_mask;
-#endif
 }
 
 static int set_spte(struct kvm_vcpu *vcpu, u64 *sptep,
-- 
 Kirill A. Shutemov

