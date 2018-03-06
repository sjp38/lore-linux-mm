Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF8B56B000A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 03:30:24 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u83so5767396wmb.3
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 00:30:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b3sor8399630edb.47.2018.03.06.00.30.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 00:30:23 -0800 (PST)
Date: Tue, 6 Mar 2018 11:30:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 16/22] x86/mm: Preserve KeyID on pte_modify() and
 pgprot_modify()
Message-ID: <20180306083008.6dklty5oq3pbzxuo@node.shutemov.name>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-17-kirill.shutemov@linux.intel.com>
 <774c1251-46d9-534e-24c2-ca04f1e0a8bb@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <774c1251-46d9-534e-24c2-ca04f1e0a8bb@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 05, 2018 at 11:09:23AM -0800, Dave Hansen wrote:
> On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> > + * It includes full range of PFN bits regardless if they were claimed for KeyID
> > + * or not: we want to preserve KeyID on pte_modify() and pgprot_modify().
> >   */
> > -#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
> > +#define PTE_PFN_MASK_MAX \
> > +	(((signed long)PAGE_MASK) & ((1UL << __PHYSICAL_MASK_SHIFT) - 1))
> > +#define _PAGE_CHG_MASK	(PTE_PFN_MASK_MAX | _PAGE_PCD | _PAGE_PWT |		\
> >  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
> >  			 _PAGE_SOFT_DIRTY)
> 
> Is there a way to make this:
> 
> #define _PAGE_CHG_MASK	(PTE_PFN_MASK | PTE_KEY_MASK...? | _PAGE_PCD |
> 
> That would be a lot more understandable.

Yes, it would.

But it means we will have *two* variables referenced from _PAGE_CHG_MASK:
one for PTE_PFN_MASK and one for PTE_KEY_MASK as both of them are dynamic.

With this patch we would get rid of both of them.

I'll update the description.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
