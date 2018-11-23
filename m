Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 346436B31A4
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 10:58:38 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o17so4333254pgi.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:58:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b11-v6sor54467121pla.12.2018.11.23.07.58.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 07:58:36 -0800 (PST)
Date: Fri, 23 Nov 2018 18:58:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 1/3] x86/mm: Move LDT remap out of KASLR region on
 5-level paging
Message-ID: <20181123155831.ewkrq4r27rne75mz@kshutemo-mobl1>
References: <20181026122856.66224-1-kirill.shutemov@linux.intel.com>
 <20181026122856.66224-2-kirill.shutemov@linux.intel.com>
 <20181110122905.GA2653@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181110122905.GA2653@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, jgross@suse.com, willy@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Nov 10, 2018 at 08:29:05PM +0800, Baoquan He wrote:
> > diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
> > index 702898633b00..75bff98928a8 100644
> > --- a/Documentation/x86/x86_64/mm.txt
> > +++ b/Documentation/x86/x86_64/mm.txt
> > @@ -34,23 +34,24 @@ __________________|____________|__________________|_________|___________________
> >  ____________________________________________________________|___________________________________________________________
> >                    |            |                  |         |
> >   ffff800000000000 | -128    TB | ffff87ffffffffff |    8 TB | ... guard hole, also reserved for hypervisor
> > - ffff880000000000 | -120    TB | ffffc7ffffffffff |   64 TB | direct mapping of all physical memory (page_offset_base)
> > - ffffc80000000000 |  -56    TB | ffffc8ffffffffff |    1 TB | ... unused hole
> > + ffff880000000000 | -120    TB | ffff887fffffffff |  0.5 TB | LDT remap for PTI
> > + ffff888000000000 | -119.5  TB | ffffc87fffffffff |   64 TB | direct mapping of all physical memory (page_offset_base)
> > + ffffc88000000000 |  -55.5  TB | ffffc8ffffffffff |  0.5 TB | ... unused hole
> 
> Hi Kirill,
> 
> Thanks for this fix. One small concern is whether we can put LDT
> remap in other place, e.g shrink KASAN area and save one pgd size for
> it, Just from Redhat's enterprise relase point of view, we don't
> enable CONFIG_KASAN, and LDT is rarely used for server, now cutting one
> block from the direct mapping area and moving it up one pgd slot seems a
> little too abrupt. Does KASAN really cost 16 TB in 4-level and 8 PB in
> 5-level? After all the direct mapping is the core mapping and has been
> there always, LDT remap is kind of not so core and important mapping.
> Just a very perceptual feeling.

Sorry for late reply.

KASAN requires one byte of shadow memory per 8 bytes of target memory, so,
yeah, we need 16 TiB of virtual address space with 4-level paging.

With 5-level, we might save some address space as the limit for physical
address space if 52-bit, not 55. I dedicated 55-bit address space because
it was easier: just scale 4-level layout by factor of 9 and you'll get all
nicely aligned without much thought (PGD translates to PGD, etc).

There is also complication with KASAN layout. We have to have the same
KASAN_SHADOW_OFFSET between 4- and 5-level paging to make boot time
switching between paging modes work. The offset cannot be changed at
runtime: it used as parameter to compiler. That's the reason KASAN area
alignment looks strange.

A possibly better solution would be to actually include LDT in KASLR:
randomize the area along with direct mapping, vmalloc and vmemmap.
But it's more complexity than I found reasonable for a fix.

Do you want to try this? :)

-- 
 Kirill A. Shutemov
