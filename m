Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 365866B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 09:14:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a13-v6so4654399pfo.22
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 06:14:22 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v8-v6si8005225plo.322.2018.06.15.06.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 06:14:19 -0700 (PDT)
Date: Fri, 15 Jun 2018 16:14:17 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 08/17] x86/mm: Implement vma_is_encrypted() and
 vma_keyid()
Message-ID: <20180615131416.sl7ib6kt2mg5ufya@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-9-kirill.shutemov@linux.intel.com>
 <cc63f92a-4020-79b5-9b49-4cdd5cb800d2@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cc63f92a-4020-79b5-9b49-4cdd5cb800d2@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 06:18:05PM +0000, Dave Hansen wrote:
> On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> > +bool vma_is_encrypted(struct vm_area_struct *vma)
> > +{
> > +	return pgprot_val(vma->vm_page_prot) & mktme_keyid_mask;
> > +}
> > +
> > +int vma_keyid(struct vm_area_struct *vma)
> > +{
> > +	pgprotval_t prot;
> > +
> > +	if (!vma_is_anonymous(vma))
> > +		return 0;
> > +
> > +	prot = pgprot_val(vma->vm_page_prot);
> > +	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
> > +}
> 
> Why do we have a vma_is_anonymous() in one of these but not the other?

It shouldn't be there. It's from earlier approach to the function.
I'll fix this.

And I'll drop vma_is_encrypted(). It is not very useful.

> While this reuse of ->vm_page_prot is cute, is there any downside?  It's
> the first place I know of that we can't derive ->vm_page_prot from
> ->vm_flags on non-VM_IO/PFNMAP VMAs.  Is that a problem?

I don't think so.

It need to be covered in pte_modify() and such, but it's about it.

That's relatively isolated change and we can move KeyID into a standalone
field, if this approach proves to be problematic.

-- 
 Kirill A. Shutemov
