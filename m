Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58989C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 21:21:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E16320989
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 21:21:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E16320989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A32976B0003; Wed,  8 May 2019 17:21:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BC836B0005; Wed,  8 May 2019 17:21:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E8686B0007; Wed,  8 May 2019 17:21:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 440136B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 17:21:08 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so145813plt.11
        for <linux-mm@kvack.org>; Wed, 08 May 2019 14:21:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JtUtoSpMtQDZXsMEcrWrAt4CklNL2KvK7KYNltsrk6k=;
        b=IkzDcncjCdqGFbdQMy0Gm/dRp8QUrkn2Eg1KkQJGOLdWEHtenGyh+wsBd6/Q3cAfEf
         DwkF2T1hRu2xh9X3acYFwef0dRLw/2lmnnwAgj6eDedvO968l/qm8ue40iPDvCN7dWLy
         I2HLXO+nl55BO2TxyiUNLSTBX/arPTAl/uzZmMXcujghJ4DGDxmQi/8a2YYPjzus2zBe
         +dbii/ud4R0WXL74VXkXoMGaXy4r4X3WagAcbVfsN31xsmzFZM0Ua4sVQGUAU6L6VGuR
         0AeMEZue3vW1aZLtNc2UDNwc/NlJ6L3Zp/PUNhlgt3tqGJFLvQNxpD7LyPA6B3QSATd0
         4Edg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUUAm3AUrRnm3qOiw8LKHEGKpApdU4I8qu81krwTURRF0f0Sn0a
	JimqRQrAy/q3ZsaZFNCcpteF+37MfskwXYDNM3Tqc+5RDbytw/GPhd+IMQFSBGwPBYXTuXkkUvL
	uq2366Hcza4GOwzp67HvQ9piFynZ2zJka8/lasfz+uvfo7P5+d1S9paxZkAWHHbGADA==
X-Received: by 2002:a17:902:f208:: with SMTP id gn8mr65148plb.312.1557350467954;
        Wed, 08 May 2019 14:21:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynqW0iNVFA53S5sN5B2jjsIxfXKP4yAWVmynPkQV3JTNCzX7WJ/ZUJekqxtWsQ9EMFaBuw
X-Received: by 2002:a17:902:f208:: with SMTP id gn8mr65039plb.312.1557350466948;
        Wed, 08 May 2019 14:21:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557350466; cv=none;
        d=google.com; s=arc-20160816;
        b=fJwr4QaCNnvhgEI2V9dTZJBhin8sVyzqSn2ai8KJeg8SXEy1SzWRKlLjrSTIwITyxU
         HpUrlwlwsoOLFQMPEaZY8lx2EQRFm7gUNV8Ogb/oCVq9jiFmOrnqXXUrvE003YvB2btH
         ef+xHm+hMZNFrNi+8NCcX5tSEaebL8kZCEYnrCBF4TtsNj7PJQ8xeBJaZcPx2I6BKHT4
         JxsC6xELDNgBt79mGbP9gE+AQyOoR6p34Q/14DQLk9aBHQ0F8UDvDK5pF3/bAxM0lv6K
         UyHBtJgZY/upY6kmrngY7DXxkRZt2+Z5FNqeP2/8VtWSx0Zoty0VB7Y6mrl2pCatT61P
         Bzwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JtUtoSpMtQDZXsMEcrWrAt4CklNL2KvK7KYNltsrk6k=;
        b=JKSq3YB6EriYv8Xnyl6zFgvYy/wX6uB+RbGJzO2byJYpPh8+FptCAABjMLl/5XfN6x
         d3KySQJvg+0j1jH1MmqCcOjeovgGE3KnrXq+JyeQNxRH6RRgpawHGHXEHK2R+MbEsTrT
         NGY633i8OmyVXq5+OKnsJ6o5L2s7W5RXe9fr9kBO7Cvn5Q7EmvXjND17bAnDyuC1Pg1i
         kDeDCk79WPUS8z9tUc06PgCndG8yqUiW9n5MDbeB40iJGr2RWPtCCeamE5+da79G8XMq
         FzZQXWY+sYgYcmzFSMEkEPsa+M6GMncoDEjhnVNr5wYAnMuVnOqPE9W8XLOT8ItIgy/z
         7HpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id y9si183503pgq.233.2019.05.08.14.21.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 14:21:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 14:21:06 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga007.fm.intel.com with ESMTP; 08 May 2019 14:21:01 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 98A30EC; Thu,  9 May 2019 00:21:00 +0300 (EEST)
Date: Thu, 9 May 2019 00:21:00 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Jacob Pan <jacob.jun.pan@linux.intel.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 52/62] x86/mm: introduce common code for mem
 encryption
Message-ID: <20190508212100.bnkgcy45xqd2o2d7@black.fi.intel.com>
References:<20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-53-kirill.shutemov@linux.intel.com>
 <20190508165830.GA11815@infradead.org>
 <20190508135225.3cb0e638@jacob-builder>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To:<20190508135225.3cb0e638@jacob-builder>
User-Agent: NeoMutt/20170714-126-deb55f (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 08:52:25PM +0000, Jacob Pan wrote:
> On Wed, 8 May 2019 09:58:30 -0700
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Wed, May 08, 2019 at 05:44:12PM +0300, Kirill A. Shutemov wrote:
> > > +EXPORT_SYMBOL_GPL(__mem_encrypt_dma_set);
> > > +
> > > +phys_addr_t __mem_encrypt_dma_clear(phys_addr_t paddr)
> > > +{
> > > +	if (sme_active())
> > > +		return __sme_clr(paddr);
> > > +
> > > +	return paddr & ~mktme_keyid_mask;
> > > +}
> > > +EXPORT_SYMBOL_GPL(__mem_encrypt_dma_clear);  
> > 
> > In general nothing related to low-level dma address should ever
> > be exposed to modules.  What is your intended user for these two?
> 
> Right no need to export. It will be used by IOMMU drivers.

I will drop these EXPORT_SYMBOL_GPL().

-- 
 Kirill A. Shutemov

