Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id E6AF56B0072
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 16:52:47 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so1598386pbc.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 13:52:47 -0800 (PST)
Date: Thu, 15 Nov 2012 13:52:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 08/11] thp: setup huge zero page on non-write page
 fault
In-Reply-To: <20121115093209.GF9676@otc-wbsnb-06>
Message-ID: <alpine.DEB.2.00.1211151348080.27188@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-9-git-send-email-kirill.shutemov@linux.intel.com> <alpine.DEB.2.00.1211141531110.22537@chino.kir.corp.google.com> <20121115093209.GF9676@otc-wbsnb-06>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu, 15 Nov 2012, Kirill A. Shutemov wrote:

> > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > index f36bc7d..41f05f1 100644
> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -726,6 +726,16 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > >  			return VM_FAULT_OOM;
> > >  		if (unlikely(khugepaged_enter(vma)))
> > >  			return VM_FAULT_OOM;
> > > +		if (!(flags & FAULT_FLAG_WRITE)) {
> > > +			pgtable_t pgtable;
> > > +			pgtable = pte_alloc_one(mm, haddr);
> > > +			if (unlikely(!pgtable))
> > > +				goto out;
> > 
> > No use in retrying, just return VM_FAULT_OOM.
> 
> Hm. It's consistent with non-hzp path: if pte_alloc_one() in
> __do_huge_pmd_anonymous_page() fails __do_huge_pmd_anonymous_page()
> returns VM_FAULT_OOM which leads to "goto out".
> 

If the pte_alloc_one(), which wraps __pte_alloc(), you're adding fails, 
it's pointless to "goto out" to try __pte_alloc() which we know won't 
succeed.

> Should it be fixed too?
> 

It's done for maintainablility because although 
__do_huge_pmd_anonymous_page() will only return VM_FAULT_OOM today when 
pte_alloc_one() fails, if it were to ever fail in a different way then the 
caller is already has a graceful failure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
