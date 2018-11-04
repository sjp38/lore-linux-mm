Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E282A6B0003
	for <linux-mm@kvack.org>; Sun,  4 Nov 2018 03:36:23 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i19-v6so3879408pfi.21
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 01:36:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b34-v6si34762pld.276.2018.11.04.01.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 01:36:22 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA48TPIh104631
	for <linux-mm@kvack.org>; Sun, 4 Nov 2018 03:36:22 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nhs4cq0f8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 04 Nov 2018 03:36:21 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 4 Nov 2018 08:36:19 -0000
Date: Sun, 4 Nov 2018 10:36:11 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH] mm: Create the new vm_fault_t type
References: <20181103050504.GA3049@jordon-HP-15-Notebook-PC>
 <20181103120235.GA10491@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181103120235.GA10491@bombadil.infradead.org>
Message-Id: <20181104083611.GB7829@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, pasha.tatashin@oracle.com, vbabka@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Nov 03, 2018 at 05:02:36AM -0700, Matthew Wilcox wrote:
> On Sat, Nov 03, 2018 at 10:35:04AM +0530, Souptick Joarder wrote:
> > Page fault handlers are supposed to return VM_FAULT codes,
> > but some drivers/file systems mistakenly return error
> > numbers. Now that all drivers/file systems have been converted
> > to use the vm_fault_t return type, change the type definition
> > to no longer be compatible with 'int'. By making it an unsigned
> > int, the function prototype becomes incompatible with a function
> > which returns int. Sparse will detect any attempts to return a
> > value which is not a VM_FAULT code.
> 
> 
> > -/* Encode hstate index for a hwpoisoned large page */
> > -#define VM_FAULT_SET_HINDEX(x) ((x) << 12)
> > -#define VM_FAULT_GET_HINDEX(x) (((x) >> 12) & 0xf)
> ...
> > +/* Encode hstate index for a hwpoisoned large page */
> > +#define VM_FAULT_SET_HINDEX(x) ((__force vm_fault_t)((x) << 16))
> > +#define VM_FAULT_GET_HINDEX(x) (((x) >> 16) & 0xf)
> 
> I think it's important to mention in the changelog that these values
> have been changed to avoid conflicts with other VM_FAULT codes.
> 
> > +/**
> > + * typedef vm_fault_t -  __bitwise unsigned int
> > + *
> > + * vm_fault_t is the new unsigned int type to return VM_FAULT
> > + * code by page fault handlers of drivers/file systems. Now if
> > + * any page fault handlers returns non VM_FAULT code instead
> > + * of VM_FAULT code, it will be a mismatch with function
> > + * prototype and sparse will detect it.
> > + */
> 
> The first line should be what the typedef *means*, not repeat the
> compiler's definition.  The rest of the description should be information
> for someone coming to the type for the first time; what you've written
> here is changelog material.
> 
> /**
>  * typedef vm_fault_t - Return type for page fault handlers.
>  *
>  * Page fault handlers return a bitmask of %VM_FAULT values.
>  */
> 
> > +typedef __bitwise unsigned int vm_fault_t;
> > +
> > +/**
> > + * enum - VM_FAULT code
> 
> Can you document an anonymous enum?  I've never tried.  Did you run this
> through 'make htmldocs'?

You cannot document an anonymous enum.
 
> > + * This enum is used to track the VM_FAULT code return by page
> > + * fault handlers.
> 
>  * Page fault handlers return a bitmask of these values to tell the
>  * core VM what happened when handling the fault.
> 

-- 
Sincerely yours,
Mike.
