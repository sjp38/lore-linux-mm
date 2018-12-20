Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE638E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 02:11:46 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id b24so676127pls.11
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 23:11:46 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w12si16747290pgl.122.2018.12.19.23.11.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Dec 2018 23:11:45 -0800 (PST)
Date: Wed, 19 Dec 2018 23:11:19 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V4 5/5] arch/powerpc/mm/hugetlb: NestMMU workaround for
 hugetlb mprotect RW upgrade
Message-ID: <20181220071119.GA16944@infradead.org>
References: <20181218094137.13732-1-aneesh.kumar@linux.ibm.com>
 <20181218094137.13732-6-aneesh.kumar@linux.ibm.com>
 <20181218172236.GC22729@infradead.org>
 <87r2eefbhi.fsf@linux.ibm.com>
 <493d07674c58d9ab32b8ba60c7153c323dfe9ab7.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <493d07674c58d9ab32b8ba60c7153c323dfe9ab7.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Christoph Hellwig <hch@infradead.org>, npiggin@gmail.com, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, Dec 20, 2018 at 11:30:12AM +1100, Benjamin Herrenschmidt wrote:
> On Wed, 2018-12-19 at 08:50 +0530, Aneesh Kumar K.V wrote:
> > Christoph Hellwig <hch@infradead.org> writes:
> > 
> > > On Tue, Dec 18, 2018 at 03:11:37PM +0530, Aneesh Kumar K.V wrote:
> > > > +EXPORT_SYMBOL(huge_ptep_modify_prot_start);
> > > 
> > > The only user of this function is the one you added in the last patch
> > > in mm/hugetlb.c, so there is no need to export this function.
> > > 
> > > > +
> > > > +void huge_ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
> > > > +				  pte_t *ptep, pte_t old_pte, pte_t pte)
> > > > +{
> > > > +
> > > > +	if (radix_enabled())
> > > > +		return radix__huge_ptep_modify_prot_commit(vma, addr, ptep,
> > > > +							   old_pte, pte);
> > > > +	set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
> > > > +}
> > > > +EXPORT_SYMBOL(huge_ptep_modify_prot_commit);
> > > 
> > > Same here.
> > 
> > That was done considering that ptep_modify_prot_start/commit was defined
> > in asm-generic/pgtable.h. I was trying to make sure I didn't break
> > anything with the patch. Also s390 do have that EXPORT_SYMBOL() for the
> > same. hugetlb just inherited that.
> > 
> > If you feel strongly about it, I can drop the EXPORT_SYMBOL().
> 
> At the very least it should be _GPL

In general yes, but in this case it just needs to go.  The s390
maintainers already removed a patch to remove their
ptep_modify_prot_start / ptep_modify_prot_commit exports.
