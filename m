Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7BBFB6B0036
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 13:40:44 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id j15so1238383qaq.11
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 10:40:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u10si8193628qge.63.2014.08.14.10.40.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Aug 2014 10:40:40 -0700 (PDT)
Date: Thu, 14 Aug 2014 19:40:23 +0200
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: Re: [PATCH 1/1] x86: add phys addr validity check for /dev/mem mmap
Message-ID: <20140814174023.GA7575@localhost.localdomain>
Reply-To: Frantisek Hrbata <fhrbata@redhat.com>
References: <1408025927-16826-1-git-send-email-fhrbata@redhat.com>
 <1408025927-16826-2-git-send-email-fhrbata@redhat.com>
 <53ECE573.1030405@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53ECE573.1030405@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com

On Thu, Aug 14, 2014 at 09:36:03AM -0700, Dave Hansen wrote:
> Thanks for dredging this back up!
> 
> On 08/14/2014 07:18 AM, Frantisek Hrbata wrote:
> > +int valid_phys_addr_range(phys_addr_t addr, size_t count)
> > +{
> > +	return addr + count <= __pa(high_memory);
> > +}
> 
> Is this correct on 32-bit?  It would limit /dev/mem to memory below 896MB.

Unfortunatelly this is how it works right now. Please note that at this moment
x86 is using the default checks from drivers/char/mem.c. The
valid_phys_addr_range is used just for read/write. Meaning yes, you cannot access
/dev/mem above high_memory via read/write, which is 896MB on x86_32.

I simply copied this generic check. There is no change compared to the current
behaviour.

BTW I think this can be simply fixed by moving the high_memory check directly to
the xlate_dev_mem_ptr function.

Something like the following. Please note this is not even compile tested.

diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index baff1da..7ebc241 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -321,7 +321,7 @@ void *xlate_dev_mem_ptr(unsigned long phys)
 	unsigned long start = phys & PAGE_MASK;
 
 	/* If page is RAM, we can use __va. Otherwise ioremap and unmap. */
-	if (page_is_ram(start >> PAGE_SHIFT))
+	if (page_is_ram(start >> PAGE_SHIFT) && phys <= __pa(high_memory))
 		return __va(phys);
 
 	addr = (void __force *)ioremap_cache(start, PAGE_SIZE);
@@ -333,7 +333,7 @@ void *xlate_dev_mem_ptr(unsigned long phys)
 
 void unxlate_dev_mem_ptr(unsigned long phys, void *addr)
 {
-	if (page_is_ram(phys >> PAGE_SHIFT))
+	if (page_is_ram(phys >> PAGE_SHIFT) && phys <= __pa(high_memory))
 		return;
 
 	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));


IIUIC the whole high_memory check is here only because of the kernel identity
mapping and as a generic check because of the generic xlate_dev_mem_ptr.

include/asm-generic/io.h: #define xlate_dev_mem_ptr(p)    __va(p)

> 
> > +int valid_mmap_phys_addr_range(unsigned long pfn, size_t count)
> > +{
> 
> Nit: please add units to things like "count".  len_bytes would be nice
> for this kind of thing, especially since it's passed *with* a pfn it
> would be easy to think it is a count in pages.

Sure I have no problem with this. But please note that I just took the already
used/presented interface from drivers/char/mem.c.

> 
> > +	/* pgoff + count overflow is checked in do_mmap_pgoff */
> > +	pfn += count >> PAGE_SHIFT;
> > +
> > +	if (pfn >> BITS_PER_LONG - PAGE_SHIFT)
> > +		return -EOVERFLOW;
> 
> Is this -EOVERFLOW correct?  It is called like this:
> 
> > static int mmap_mem(struct file *file, struct vm_area_struct *vma)
> > {
> >         if (!valid_mmap_phys_addr_range(vma->vm_pgoff, size))
> >                 return -EINVAL;
> 
> So I think we need to return true/false:0/1.  -EOVERFLOW would be true,
> and that if() would pass.

Facepalm, sure this is completely wrong. We of course need to return zero. I
thought it would be more descriptive to use -EOVERFLOW, even though we get
-EINVAL in the end. I will fix this. Many thanks for pointing this out.

> 
> > +	return phys_addr_valid(pfn << PAGE_SHIFT);
> > +}
> 
> Maybe I'm dumb, but it took me a minute to figure out what you were
> trying to do with the: "(pfn >> BITS_PER_LONG - PAGE_SHIFT)".  In any
> case, I think it is wrong on 32-bit.
> 
> On 32-bit, BITS_PER_LONG=32, and PAGE_SIZE=12, and a paddr=0x100000000
> or pfn=0x100000 (4GB) is perfectly valid with PAE enabled.  But, this
> code pfn>>(32-12) would result in 0x1 and return -EOVERFLOW.

Right, I did not realized this.

> 
> I think something like this would be easier to read and actually work on
> 32-bit:
> 
> static inline int arch_pfn_possible(unsigned long pfn)
> {
>  	unsigned long max_arch_pfn = 1UL << (boot_cpu_data.x86_phys_bits -
> PAGE_SHIFT);
> 	return pfn < max_arch_pfn;
> }

Actually I wanted to use exactly this instead of calling phys_addr_valid, because
we can avoid the whole overflow check, but it seemed natural to use what is
already available. But you are right for sure. This needs to be fixed also.

Dave, many thanks for your feedback, it's really appreciated!

-- 
Frantisek Hrbata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
