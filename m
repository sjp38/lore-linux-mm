Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D17B96B02BE
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 01:21:46 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c2-v6so7069147edi.6
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 22:21:46 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x55-v6si4127984eda.272.2018.11.05.22.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 22:21:45 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA66Jgx1135030
	for <linux-mm@kvack.org>; Tue, 6 Nov 2018 01:21:43 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nk0kk1s74-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Nov 2018 01:21:43 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 6 Nov 2018 06:21:41 -0000
Date: Tue, 6 Nov 2018 08:21:34 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH] mm: Create the new vm_fault_t type
References: <20181103050504.GA3049@jordon-HP-15-Notebook-PC>
 <20181103120235.GA10491@bombadil.infradead.org>
 <20181104083611.GB7829@rapoport-lnx>
 <CAFqt6zaVUT0RGpz+jE4c7rb5prOtDhnxOy-NAiFM9G6jMwofVg@mail.gmail.com>
 <20181105091302.GA3713@rapoport-lnx>
 <CAFqt6zYbb9xpnOhhoESq3BbF4aD0_UKzh=MrwJ-i+NiUqNh7+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zYbb9xpnOhhoESq3BbF4aD0_UKzh=MrwJ-i+NiUqNh7+Q@mail.gmail.com>
Message-Id: <20181106062133.GB4499@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, riel@redhat.com, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Mon, Nov 05, 2018 at 07:23:55PM +0530, Souptick Joarder wrote:
> On Mon, Nov 5, 2018 at 2:43 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> >
> > On Mon, Nov 05, 2018 at 11:14:17AM +0530, Souptick Joarder wrote:
> > > Hi Matthew,
> > >
> > > On Sun, Nov 4, 2018 at 2:06 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > > >
> > > > On Sat, Nov 03, 2018 at 05:02:36AM -0700, Matthew Wilcox wrote:
> > > > > On Sat, Nov 03, 2018 at 10:35:04AM +0530, Souptick Joarder wrote:

> > > > > > +typedef __bitwise unsigned int vm_fault_t;
> > > > > > +
> > > > > > +/**
> > > > > > + * enum - VM_FAULT code
> > > > >
> > > > > Can you document an anonymous enum?  I've never tried.  Did you run this
> > > > > through 'make htmldocs'?
> > > >
> > > > You cannot document an anonymous enum.
> > >
> > > I assume, you are pointing to Document folder and I don't know if this
> > > enum need to be documented or not.
> >
> > The enum should be documented, even if it's documentation is (yet) not
> > linked anywhere in the Documentation/
> >
> > > I didn't run 'make htmldocs' as there is no document related changes.
> >
> > You can verify that kernel-doc can parse your documentation by running
> >
> > scripts/kernel-doc -none -v <filename>
> 
> I run "scripts/kernel-doc -none -v include/linux/mm_types.h" and it is showing
> below error and warning which is linked to enum in discussion.
> 
> include/linux/mm_types.h:612: info: Scanning doc for typedef vm_fault_t
> include/linux/mm_types.h:623: info: Scanning doc for enum
> include/linux/mm_types.h:628: warning: contents before sections
> include/linux/mm_types.h:660: error: Cannot parse enum!
> 1 errors
> 1 warnings
> 
> Shall I keep the documentation for enum or remove it from this patch ?

The documentation should be there, you just need to add a name for the
enum. Then kernel-doc will be able to parse it.
 
> > > >
> > > > > > + * This enum is used to track the VM_FAULT code return by page
> > > > > > + * fault handlers.
> > > > >

I think that the enum description should also include the text from the
comment that described VM_FAULT_* defines:

/*
 * Different kinds of faults, as returned by handle_mm_fault().
 * Used to decide whether a process gets delivered SIGBUS or
 * just gets major/minor fault counters bumped up.
 */



-- 
Sincerely yours,
Mike.
