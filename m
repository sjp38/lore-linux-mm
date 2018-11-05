Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 59C956B000D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 04:13:16 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id n32-v6so4975124edc.17
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 01:13:16 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c13-v6si1499377ejj.300.2018.11.05.01.13.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 01:13:15 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA59AElM093141
	for <linux-mm@kvack.org>; Mon, 5 Nov 2018 04:13:13 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2njjx40bwm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 05 Nov 2018 04:13:13 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 5 Nov 2018 09:13:10 -0000
Date: Mon, 5 Nov 2018 11:13:03 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH] mm: Create the new vm_fault_t type
References: <20181103050504.GA3049@jordon-HP-15-Notebook-PC>
 <20181103120235.GA10491@bombadil.infradead.org>
 <20181104083611.GB7829@rapoport-lnx>
 <CAFqt6zaVUT0RGpz+jE4c7rb5prOtDhnxOy-NAiFM9G6jMwofVg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zaVUT0RGpz+jE4c7rb5prOtDhnxOy-NAiFM9G6jMwofVg@mail.gmail.com>
Message-Id: <20181105091302.GA3713@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, pasha.tatashin@oracle.com, vbabka@suse.cz, riel@redhat.com, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Mon, Nov 05, 2018 at 11:14:17AM +0530, Souptick Joarder wrote:
> Hi Matthew,
> 
> On Sun, Nov 4, 2018 at 2:06 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> >
> > On Sat, Nov 03, 2018 at 05:02:36AM -0700, Matthew Wilcox wrote:
> > > On Sat, Nov 03, 2018 at 10:35:04AM +0530, Souptick Joarder wrote:
> > > > Page fault handlers are supposed to return VM_FAULT codes,
> > > > but some drivers/file systems mistakenly return error
> > > > numbers. Now that all drivers/file systems have been converted
> > > > to use the vm_fault_t return type, change the type definition
> > > > to no longer be compatible with 'int'. By making it an unsigned
> > > > int, the function prototype becomes incompatible with a function
> > > > which returns int. Sparse will detect any attempts to return a
> > > > value which is not a VM_FAULT code.
> > >
> > >
> > > > -/* Encode hstate index for a hwpoisoned large page */
> > > > -#define VM_FAULT_SET_HINDEX(x) ((x) << 12)
> > > > -#define VM_FAULT_GET_HINDEX(x) (((x) >> 12) & 0xf)
> > > ...
> > > > +/* Encode hstate index for a hwpoisoned large page */
> > > > +#define VM_FAULT_SET_HINDEX(x) ((__force vm_fault_t)((x) << 16))
> > > > +#define VM_FAULT_GET_HINDEX(x) (((x) >> 16) & 0xf)
> > >
> > > I think it's important to mention in the changelog that these values
> > > have been changed to avoid conflicts with other VM_FAULT codes.
> > >
> > > > +/**
> > > > + * typedef vm_fault_t -  __bitwise unsigned int
> > > > + *
> > > > + * vm_fault_t is the new unsigned int type to return VM_FAULT
> > > > + * code by page fault handlers of drivers/file systems. Now if
> > > > + * any page fault handlers returns non VM_FAULT code instead
> > > > + * of VM_FAULT code, it will be a mismatch with function
> > > > + * prototype and sparse will detect it.
> > > > + */
> > >
> > > The first line should be what the typedef *means*, not repeat the
> > > compiler's definition.  The rest of the description should be information
> > > for someone coming to the type for the first time; what you've written
> > > here is changelog material.
> > >
> > > /**
> > >  * typedef vm_fault_t - Return type for page fault handlers.
> > >  *
> > >  * Page fault handlers return a bitmask of %VM_FAULT values.
> > >  */
> > >
> > > > +typedef __bitwise unsigned int vm_fault_t;
> > > > +
> > > > +/**
> > > > + * enum - VM_FAULT code
> > >
> > > Can you document an anonymous enum?  I've never tried.  Did you run this
> > > through 'make htmldocs'?
> >
> > You cannot document an anonymous enum.
> 
> 
> I assume, you are pointing to Document folder and I don't know if this
> enum need to be documented or not.

The enum should be documented, even if it's documentation is (yet) not
linked anywhere in the Documentation/
 
> I didn't run 'make htmldocs' as there is no document related changes.

You can verify that kernel-doc can parse your documentation by running

scripts/kernel-doc -none -v <filename>

> >
> > > > + * This enum is used to track the VM_FAULT code return by page
> > > > + * fault handlers.
> > >
> > >  * Page fault handlers return a bitmask of these values to tell the
> > >  * core VM what happened when handling the fault.
> > >
> >
> > --
> > Sincerely yours,
> > Mike.
> >
> 

-- 
Sincerely yours,
Mike.
