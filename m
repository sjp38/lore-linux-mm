Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A84F98E0006
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 19:30:45 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id z6so27346155qtj.21
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 16:30:45 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id t22si2754412qtq.46.2018.12.19.16.30.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Dec 2018 16:30:44 -0800 (PST)
Message-ID: <493d07674c58d9ab32b8ba60c7153c323dfe9ab7.camel@kernel.crashing.org>
Subject: Re: [PATCH V4 5/5] arch/powerpc/mm/hugetlb: NestMMU workaround for
 hugetlb mprotect RW upgrade
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 20 Dec 2018 11:30:12 +1100
In-Reply-To: <87r2eefbhi.fsf@linux.ibm.com>
References: <20181218094137.13732-1-aneesh.kumar@linux.ibm.com>
	 <20181218094137.13732-6-aneesh.kumar@linux.ibm.com>
	 <20181218172236.GC22729@infradead.org> <87r2eefbhi.fsf@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Christoph Hellwig <hch@infradead.org>
Cc: npiggin@gmail.com, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Wed, 2018-12-19 at 08:50 +0530, Aneesh Kumar K.V wrote:
> Christoph Hellwig <hch@infradead.org> writes:
> 
> > On Tue, Dec 18, 2018 at 03:11:37PM +0530, Aneesh Kumar K.V wrote:
> > > +EXPORT_SYMBOL(huge_ptep_modify_prot_start);
> > 
> > The only user of this function is the one you added in the last patch
> > in mm/hugetlb.c, so there is no need to export this function.
> > 
> > > +
> > > +void huge_ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
> > > +				  pte_t *ptep, pte_t old_pte, pte_t pte)
> > > +{
> > > +
> > > +	if (radix_enabled())
> > > +		return radix__huge_ptep_modify_prot_commit(vma, addr, ptep,
> > > +							   old_pte, pte);
> > > +	set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
> > > +}
> > > +EXPORT_SYMBOL(huge_ptep_modify_prot_commit);
> > 
> > Same here.
> 
> That was done considering that ptep_modify_prot_start/commit was defined
> in asm-generic/pgtable.h. I was trying to make sure I didn't break
> anything with the patch. Also s390 do have that EXPORT_SYMBOL() for the
> same. hugetlb just inherited that.
> 
> If you feel strongly about it, I can drop the EXPORT_SYMBOL().

At the very least it should be _GPL

Cheers,
Ben.
