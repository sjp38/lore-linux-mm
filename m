Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 654AD6B66D5
	for <linux-mm@kvack.org>; Sun,  2 Dec 2018 22:01:07 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id g22so12025157qke.15
        for <linux-mm@kvack.org>; Sun, 02 Dec 2018 19:01:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p3si3160632qtp.114.2018.12.02.19.01.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Dec 2018 19:01:06 -0800 (PST)
Date: Mon, 3 Dec 2018 11:01:00 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCHv3 1/3] x86/mm: Move LDT remap out of KASLR region on
 5-level paging
Message-ID: <20181203030100.GA22521@MiWiFi-R3L-srv>
References: <20181026122856.66224-1-kirill.shutemov@linux.intel.com>
 <20181026122856.66224-2-kirill.shutemov@linux.intel.com>
 <20181110122905.GA2653@MiWiFi-R3L-srv>
 <20181123155831.ewkrq4r27rne75mz@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123155831.ewkrq4r27rne75mz@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, jgross@suse.com, willy@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Kirill,

On 11/23/18 at 06:58pm, Kirill A. Shutemov wrote:
> > Thanks for this fix. One small concern is whether we can put LDT
> > remap in other place, e.g shrink KASAN area and save one pgd size for
> > it, Just from Redhat's enterprise relase point of view, we don't
> > enable CONFIG_KASAN, and LDT is rarely used for server, now cutting one
> > block from the direct mapping area and moving it up one pgd slot seems a
> > little too abrupt. Does KASAN really cost 16 TB in 4-level and 8 PB in
> > 5-level? After all the direct mapping is the core mapping and has been
> > there always, LDT remap is kind of not so core and important mapping.
> > Just a very perceptual feeling.
> 
> KASAN requires one byte of shadow memory per 8 bytes of target memory, so,
> yeah, we need 16 TiB of virtual address space with 4-level paging.
> 
> With 5-level, we might save some address space as the limit for physical
> address space if 52-bit, not 55. I dedicated 55-bit address space because
> it was easier: just scale 4-level layout by factor of 9 and you'll get all
> nicely aligned without much thought (PGD translates to PGD, etc).
> 
> There is also complication with KASAN layout. We have to have the same
> KASAN_SHADOW_OFFSET between 4- and 5-level paging to make boot time
> switching between paging modes work. The offset cannot be changed at
> runtime: it used as parameter to compiler. That's the reason KASAN area
> alignment looks strange.

Thanks for explanation. KASAN area can't be touched as you said.

> 
> A possibly better solution would be to actually include LDT in KASLR:
> randomize the area along with direct mapping, vmalloc and vmemmap.
> But it's more complexity than I found reasonable for a fix.
> 
> Do you want to try this? :)

                                                           |
Seems the unused hole between vmemmap and KASAN can be used. e.g put LDT
remap in -20.5 TB place like below. And meanwhile 
____________________________________________________________|___________________________________________________________
                  |            |                  |         |
 ffff800000000000 | -128    TB | ffff87ffffffffff |    8 TB | ... guard hole, also reserved for hypervisor
 ffff888000000000 | -120    TB | ffffc87fffffffff |   64 TB | direct mapping of all physical memory (page_offset_base)
 ffffc88000000000 |  -56    TB | ffffc8ffffffffff |    1 TB | ... unused hole
 ffffc90000000000 |  -55    TB | ffffe8ffffffffff |   32 TB | vmalloc/ioremap space (vmalloc_base)
 ffffe90000000000 |  -23    TB | ffffe9ffffffffff |    1 TB | ... unused hole
 ffffea0000000000 |  -22    TB | ffffeaffffffffff |    1 TB | virtual memory map (vmemmap_base)
 ffffeb0000000000 |  -21    TB | ffffebffffffffff |  0.5 TB | ... unused hole
 ffffeb0000000000 |  -20.5  TB | ffffebffffffffff |  0.5 TB | LDT remap for PTI 
 ffffec0000000000 |  -20    TB | fffffbffffffffff |   16 TB | KASAN shadow memory
__________________|____________|__________________|_________|____________________________________________________________

In non-KASLR case, only 0.5 TB left as hole between vmemmap and LDT.
Meanwhile since LDT remap only costs 128 KB at most at the beginning,
the left area can be seen as guard hole between it and KASAN.

And yes, in KASLR case, we have to take it with the old three regions
together to randomize.

It looks do-able, not sure if the test case is complicated or not, if
not hard, I can have a try. And I have some internal bugs, can focus on
this later. I saw you posted another patchset to fix xen issue, it may
not be needed any more if we take this way?

And not sure if other people have different idea.

Thanks
Baoquan
