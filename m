Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C09DD6B000C
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 05:47:51 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id az8-v6so6624plb.15
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 02:47:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73-v6sor2041795pgc.52.2018.07.23.02.47.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 02:47:50 -0700 (PDT)
Date: Mon, 23 Jul 2018 12:47:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 11/19] x86/mm: Implement vma_keyid()
Message-ID: <20180723094746.447v2jnegqlosi2f@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-12-kirill.shutemov@linux.intel.com>
 <a204a032-5e2b-63f6-31d3-c17014f94c8b@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a204a032-5e2b-63f6-31d3-c17014f94c8b@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 18, 2018 at 04:40:14PM -0700, Dave Hansen wrote:
> > --- a/arch/x86/mm/mktme.c
> > +++ b/arch/x86/mm/mktme.c
> > @@ -1,3 +1,4 @@
> > +#include <linux/mm.h>
> >  #include <asm/mktme.h>
> >  
> >  phys_addr_t mktme_keyid_mask;
> > @@ -37,3 +38,14 @@ struct page_ext_operations page_mktme_ops = {
> >  	.need = need_page_mktme,
> >  	.init = init_page_mktme,
> >  };
> > +
> > +int vma_keyid(struct vm_area_struct *vma)
> > +{
> > +	pgprotval_t prot;
> > +
> > +	if (!mktme_enabled())
> > +		return 0;
> > +
> > +	prot = pgprot_val(vma->vm_page_prot);
> > +	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
> > +}
> 
> I'm a bit surprised this isn't inlined.  Not that function calls are
> expensive, but we *could* entirely avoid them using the normal pattern of:
> 
> // In the header:
> static inline vma_keyid(...)
> {
> 	if (!mktme_enabled())
> 		return 0;
> 
> 	return __vma_keyid(...); // <- the .c file version
> }

Okay. I'll do this. But it would be a macros. <asm/mktme.h> gets included
very early. We cannot really use jump label code there directly.

-- 
 Kirill A. Shutemov
