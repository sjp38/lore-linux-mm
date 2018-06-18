Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 999376B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 09:34:58 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id c6-v6so10167563pll.4
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 06:34:58 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 13-v6si15803416ple.274.2018.06.18.06.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 06:34:57 -0700 (PDT)
Date: Mon, 18 Jun 2018 16:34:55 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 16/17] x86/mm: Handle encrypted memory in
 page_to_virt() and __pa()
Message-ID: <20180618133455.aumn4wihygvds543@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-17-kirill.shutemov@linux.intel.com>
 <f8b9da42-1f7b-529c-bfdd-e82f669f6fe8@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f8b9da42-1f7b-529c-bfdd-e82f669f6fe8@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 06:43:08PM +0000, Dave Hansen wrote:
> > diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
> > index efc0d4bb3b35..d6edcabacfc7 100644
> > --- a/arch/x86/include/asm/mktme.h
> > +++ b/arch/x86/include/asm/mktme.h
> > @@ -43,6 +43,9 @@ void mktme_disable(void);
> >  void setup_direct_mapping_size(void);
> >  int sync_direct_mapping(void);
> >  
> > +#define page_to_virt(x) \
> > +	(__va(PFN_PHYS(page_to_pfn(x))) + page_keyid(x) * direct_mapping_size)
> 
> This looks like a super important memory management function being
> defined in some obscure Intel-specific feature header.  How does that work?

No magic. It overwrites define in <linux/mm.h>.

> >  #else
> >  #define mktme_keyid_mask	((phys_addr_t)0)
> >  #define mktme_nr_keyids		0
> > diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
> > index 53c32af895ab..ffad496aadad 100644
> > --- a/arch/x86/include/asm/page_64.h
> > +++ b/arch/x86/include/asm/page_64.h
> > @@ -23,7 +23,7 @@ static inline unsigned long __phys_addr_nodebug(unsigned long x)
> >  	/* use the carry flag to determine if x was < __START_KERNEL_map */
> >  	x = y + ((x > y) ? phys_base : (__START_KERNEL_map - PAGE_OFFSET));
> >  
> > -	return x;
> > +	return x % direct_mapping_size;
> >  }
> 
> What are the performance implications of this patch?

Let me collect the numbers.

-- 
 Kirill A. Shutemov
