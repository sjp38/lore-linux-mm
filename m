Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20D6DC31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 11:25:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEFEE208E4
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 11:25:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="uV36HBJj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEFEE208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53F248E0003; Mon, 17 Jun 2019 07:25:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EF708E0001; Mon, 17 Jun 2019 07:25:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DD8F8E0003; Mon, 17 Jun 2019 07:25:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E29868E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:25:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so16001658edr.13
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:25:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9AwinP98tyRtHdg0mJkLa6bfVqgtL4TsktjuNz76Who=;
        b=N1njcErEqA1vSXIgNO7zgfywm7pnFHuNxhVD0vzG4bwMby9B/6Ofb3X1jsItxAZSKC
         iNetpsBBeJ07z+EEK1afio2jB2j9YiAfGidzu97kWSMRGbHFk27r/6AppTfkEWi00PFk
         Jh5LmDt+M7wn+rUWJKpy6IIiokZeufZj7cPBpmoNs1ixTVJUrpOPBHWtiX+iR7IjMrH1
         ruC7H4ir6aVQjeteznhe1Pmjj5327zTDESvxYIbugUk+AALseccGFzjfWntVD0grtPEy
         /rLpJ+kTx6U9d9WVkWKttqfF9pnzTZrT6AIupMfasY8ZXawTb/qLgZ3LvvbMyDZZWsGH
         OkrQ==
X-Gm-Message-State: APjAAAX3MCaJNtgQsXIxMfaAAtTCD0itMPaFt5JDa/6R9wIFJRViYsCU
	WY5nn4sx+l/oBoWvPDIrgCZcsBilA/zv8Owdy1zrpL64huTkJLjBVJBkP9gYztG0PpGcTmBjlo8
	TqA62bOKE2XByDPkMkDOLz2I5Izw565jTPlqpdpWZ74IFkQSJDcaQnWfENh1jv2xJXg==
X-Received: by 2002:a17:906:e204:: with SMTP id gf4mr53018330ejb.302.1560770703483;
        Mon, 17 Jun 2019 04:25:03 -0700 (PDT)
X-Received: by 2002:a17:906:e204:: with SMTP id gf4mr53018272ejb.302.1560770702580;
        Mon, 17 Jun 2019 04:25:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560770702; cv=none;
        d=google.com; s=arc-20160816;
        b=KQkSq1zo5IXXibr+2rS+K7FY2ltGmAmzTltlTCreFM7K0Oz48NGJmOLNJKWVpl1Pab
         U2SgStScPRDqBWTmkCCTHQWdC0RUCmST+G2eTaoruhN79edfRzds1Tcdo4XCgf5eBG1A
         Q609xd6OMl7f/27zErD2+Bk8KWPueXgyXzEyVTfYAKJi0OgFNTqIfBgJ/HfwMFhggOdQ
         tGB1P+Z4bzVKFXQsiOHQxoU5Pq1DRE9wYrsVJyzqXw+RGH0BtjHc01Xxe2F8oBwbrZU4
         mG9dG9T049l1rGKWA9t7//c0JOsVkVEAa7+ySoc395dw5MI0DddpOjS79FJW3wNKqoLm
         H4Xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9AwinP98tyRtHdg0mJkLa6bfVqgtL4TsktjuNz76Who=;
        b=JnDTARili5SnGAq5m25/smFn8L/jEINE2KoBpRbEX3a8zS8qM8T5kcHXVkavG+VzLF
         nci53JBD5wz/GdjZv5AgdeiH9Su5CDe9h//6Sor2/b6W560dSvEqko4qvMpwWgGFpn7T
         Khl7CkuGfPOgdqmoxkCNFnRwIdenbhAIhKx4Ko/dnwNcqY3tM7a4LmnyJv89X/KYdM+t
         teBg0HOFEJ4FxUEwa2Ujkv5AvjRlHCOgTPBU2XW6BxmQ//F0DczEch9HhYO3rVZC/yBD
         1Us6TFFQiobUWiuUkAdxUZDJEjsys8Bh1R39EegCKX5FzsOW6k93AIJCFDyJu927qwMM
         69Hw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=uV36HBJj;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r20sor2048998edp.8.2019.06.17.04.25.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 04:25:02 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=uV36HBJj;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9AwinP98tyRtHdg0mJkLa6bfVqgtL4TsktjuNz76Who=;
        b=uV36HBJjLuM8IaSJ5lnIjDPz/NT6Ima0VTqA5XgxtXzYGLtD5Zk1oOFcZIOs5eNXNV
         pH0NKGr3K5PIEFLdfJ4QY5MASu8ZolMiISb4+T5+hLkqTyBzPrnUDdx/hU3vjrgigEg5
         XFnoHWLNGGyz/u66QlR4uui8QiQ+svYc42qDT7NRAQYv6KgqnNwvy4xSWlxjmoYgo9KT
         ekxQsjh1gx+i56hFixjDbLIdHmzETZGZXB2016IB59YaBabg47ntq/77FeVXdTQW9Mw5
         aQMao99SPvxYN97xvhncTxzUgIhypTKI32Gazqeb0JGoQgELhGOXdv5DquuY1RhnraGV
         TZKQ==
X-Google-Smtp-Source: APXvYqwcK64TzeBKKN7Kf5JNSHie2auwQpGxruSpvU1WBTnyHll+7eGrNwcSGlsUpIC9SxKCjImLYg==
X-Received: by 2002:a50:a48a:: with SMTP id w10mr11385422edb.1.1560770702235;
        Mon, 17 Jun 2019 04:25:02 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id w35sm1152436edd.32.2019.06.17.04.25.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 04:25:01 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 122F1100F6D; Mon, 17 Jun 2019 14:25:00 +0300 (+03)
Date: Mon, 17 Jun 2019 14:25:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Kai Huang <kai.huang@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
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
Message-ID: <20190617112500.vmuu4kcjoep34hwe@box>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-50-kirill.shutemov@linux.intel.com>
 <20190614115647.GI3436@hirez.programming.kicks-ass.net>
 <1560741269.5187.7.camel@linux.intel.com>
 <20190617074643.GW3436@hirez.programming.kicks-ass.net>
 <1560760783.5187.10.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560760783.5187.10.camel@linux.intel.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 08:39:43PM +1200, Kai Huang wrote:
> On Mon, 2019-06-17 at 09:46 +0200, Peter Zijlstra wrote:
> > On Mon, Jun 17, 2019 at 03:14:29PM +1200, Kai Huang wrote:
> > > On Fri, 2019-06-14 at 13:56 +0200, Peter Zijlstra wrote:
> > > > On Wed, May 08, 2019 at 05:44:09PM +0300, Kirill A. Shutemov wrote:
> > > > > From: Kai Huang <kai.huang@linux.intel.com>
> > > > > 
> > > > > KVM needs those variables to get/set memory encryption mask.
> > > > > 
> > > > > Signed-off-by: Kai Huang <kai.huang@linux.intel.com>
> > > > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > > ---
> > > > >  arch/x86/mm/mktme.c | 3 +++
> > > > >  1 file changed, 3 insertions(+)
> > > > > 
> > > > > diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
> > > > > index df70651816a1..12f4266cf7ea 100644
> > > > > --- a/arch/x86/mm/mktme.c
> > > > > +++ b/arch/x86/mm/mktme.c
> > > > > @@ -7,13 +7,16 @@
> > > > >  
> > > > >  /* Mask to extract KeyID from physical address. */
> > > > >  phys_addr_t mktme_keyid_mask;
> > > > > +EXPORT_SYMBOL_GPL(mktme_keyid_mask);
> > > > >  /*
> > > > >   * Number of KeyIDs available for MKTME.
> > > > >   * Excludes KeyID-0 which used by TME. MKTME KeyIDs start from 1.
> > > > >   */
> > > > >  int mktme_nr_keyids;
> > > > > +EXPORT_SYMBOL_GPL(mktme_nr_keyids);
> > > > >  /* Shift of KeyID within physical address. */
> > > > >  int mktme_keyid_shift;
> > > > > +EXPORT_SYMBOL_GPL(mktme_keyid_shift);
> > > > >  
> > > > >  DEFINE_STATIC_KEY_FALSE(mktme_enabled_key);
> > > > >  EXPORT_SYMBOL_GPL(mktme_enabled_key);
> > > > 
> > > > NAK, don't export variables. Who owns the values, who enforces this?
> > > > 
> > > 
> > > Both KVM and IOMMU driver need page_keyid() and mktme_keyid_shift to set page's keyID to the
> > > right
> > > place in the PTE (of KVM EPT and VT-d DMA page table).
> > > 
> > > MKTME key type code need to know mktme_nr_keyids in order to alloc/free keyID.
> > > 
> > > Maybe better to introduce functions instead of exposing variables directly?
> > > 
> > > Or instead of introducing page_keyid(), we use page_encrypt_mask(), which essentially holds
> > > "page_keyid() << mktme_keyid_shift"?
> > 
> > Yes, that's much better, because that strictly limits the access to R/O.
> > 
> 
> Thanks. I think Kirill will be the one to handle your suggestion. :)
> 
> Kirill?

Will do.

-- 
 Kirill A. Shutemov

