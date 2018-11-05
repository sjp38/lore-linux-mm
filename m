Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0286B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 00:44:32 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id l4-v6so2304500lji.5
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 21:44:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l16-v6sor17392126ljh.14.2018.11.04.21.44.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Nov 2018 21:44:30 -0800 (PST)
MIME-Version: 1.0
References: <20181103050504.GA3049@jordon-HP-15-Notebook-PC>
 <20181103120235.GA10491@bombadil.infradead.org> <20181104083611.GB7829@rapoport-lnx>
In-Reply-To: <20181104083611.GB7829@rapoport-lnx>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 5 Nov 2018 11:14:17 +0530
Message-ID: <CAFqt6zaVUT0RGpz+jE4c7rb5prOtDhnxOy-NAiFM9G6jMwofVg@mail.gmail.com>
Subject: Re: [PATCH] mm: Create the new vm_fault_t type
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.ibm.com
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, pasha.tatashin@oracle.com, vbabka@suse.cz, riel@redhat.com, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Hi Matthew,

On Sun, Nov 4, 2018 at 2:06 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Sat, Nov 03, 2018 at 05:02:36AM -0700, Matthew Wilcox wrote:
> > On Sat, Nov 03, 2018 at 10:35:04AM +0530, Souptick Joarder wrote:
> > > Page fault handlers are supposed to return VM_FAULT codes,
> > > but some drivers/file systems mistakenly return error
> > > numbers. Now that all drivers/file systems have been converted
> > > to use the vm_fault_t return type, change the type definition
> > > to no longer be compatible with 'int'. By making it an unsigned
> > > int, the function prototype becomes incompatible with a function
> > > which returns int. Sparse will detect any attempts to return a
> > > value which is not a VM_FAULT code.
> >
> >
> > > -/* Encode hstate index for a hwpoisoned large page */
> > > -#define VM_FAULT_SET_HINDEX(x) ((x) << 12)
> > > -#define VM_FAULT_GET_HINDEX(x) (((x) >> 12) & 0xf)
> > ...
> > > +/* Encode hstate index for a hwpoisoned large page */
> > > +#define VM_FAULT_SET_HINDEX(x) ((__force vm_fault_t)((x) << 16))
> > > +#define VM_FAULT_GET_HINDEX(x) (((x) >> 16) & 0xf)
> >
> > I think it's important to mention in the changelog that these values
> > have been changed to avoid conflicts with other VM_FAULT codes.
> >
> > > +/**
> > > + * typedef vm_fault_t -  __bitwise unsigned int
> > > + *
> > > + * vm_fault_t is the new unsigned int type to return VM_FAULT
> > > + * code by page fault handlers of drivers/file systems. Now if
> > > + * any page fault handlers returns non VM_FAULT code instead
> > > + * of VM_FAULT code, it will be a mismatch with function
> > > + * prototype and sparse will detect it.
> > > + */
> >
> > The first line should be what the typedef *means*, not repeat the
> > compiler's definition.  The rest of the description should be information
> > for someone coming to the type for the first time; what you've written
> > here is changelog material.
> >
> > /**
> >  * typedef vm_fault_t - Return type for page fault handlers.
> >  *
> >  * Page fault handlers return a bitmask of %VM_FAULT values.
> >  */
> >
> > > +typedef __bitwise unsigned int vm_fault_t;
> > > +
> > > +/**
> > > + * enum - VM_FAULT code
> >
> > Can you document an anonymous enum?  I've never tried.  Did you run this
> > through 'make htmldocs'?
>
> You cannot document an anonymous enum.


I assume, you are pointing to Document folder and I don't know if this
enum need to be documented or not.

I didn't run 'make htmldocs' as there is no document related changes.

>
> > > + * This enum is used to track the VM_FAULT code return by page
> > > + * fault handlers.
> >
> >  * Page fault handlers return a bitmask of these values to tell the
> >  * core VM what happened when handling the fault.
> >
>
> --
> Sincerely yours,
> Mike.
>
