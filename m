Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70DD26B026D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:03:30 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id s15-v6so1111010wrn.16
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:03:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y17-v6si1175654wrh.45.2018.07.03.08.03.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 08:03:27 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w63EwoBb055858
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 11:03:26 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k0b52gyrs-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 03 Jul 2018 11:03:25 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 3 Jul 2018 16:03:23 +0100
Date: Tue, 3 Jul 2018 18:03:16 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] m68k/page_no.h: force __va argument to be unsigned
 long
References: <1530613795-6956-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530613795-6956-3-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703142054.GL16767@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703142054.GL16767@dhcp22.suse.cz>
Message-Id: <20180703150315.GC4809@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 03, 2018 at 04:20:54PM +0200, Michal Hocko wrote:
> On Tue 03-07-18 13:29:54, Mike Rapoport wrote:
> > Add explicit casting to unsigned long to the __va() parameter
> 
> Why is this needed?

To make it consitent with other architecures and asm-generic :)

But more importantly, __memblock_free_late() passes u64 to page_to_pfn().
On m68k-nommu this results in:

  CC      mm/nobootmem.o
In file included from
arch/m68k/include/asm/page.h:49,
                 from
arch/m68k/include/asm/thread_info.h:6,
                 from
include/linux/thread_info.h:38,
                 from
include/asm-generic/preempt.h:5,
                 from ./arch/m68k/include/generated/asm/preempt.h:1,
                 from include/linux/preempt.h:81,
                 from include/linux/spinlock.h:51,
                 from include/linux/mmzone.h:8,
                 from include/linux/gfp.h:6,
                 from include/linux/slab.h:15,
                 from mm/memblock.c:14:
mm/memblock.c: In function '__memblock_free_late':
arch/m68k/include/asm/page_no.h:21:23: warning:
cast to pointer from integer of different size [-Wint-to-pointer-cast]
 #define __va(paddr)  ((void *)(paddr))
                       ^
arch/m68k/include/asm/page_no.h:26:57: note: in
definition of macro 'virt_to_page'
 #define virt_to_page(addr) (mem_map + (((unsigned long)(addr)-PAGE_OFFSET)
>> PAGE_SHIFT))
                                                         ^~~~
arch/m68k/include/asm/page_no.h:24:26: note: in
expansion of macro '__va'
 #define pfn_to_virt(pfn) __va((pfn) << PAGE_SHIFT)
                          ^~~~
arch/m68k/include/asm/page_no.h:29:39: note: in
expansion of macro 'pfn_to_virt'
 #define pfn_to_page(pfn) virt_to_page(pfn_to_virt(pfn))
                                       ^~~~~~~~~~~
mm/memblock.c:1473:24: note: in expansion of macro
'pfn_to_page'
   __free_pages_bootmem(pfn_to_page(cursor), cursor, 0);
                        ^~~~~~~~~~~

 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> >  arch/m68k/include/asm/page_no.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/arch/m68k/include/asm/page_no.h b/arch/m68k/include/asm/page_no.h
> > index e644c4d..6bbe520 100644
> > --- a/arch/m68k/include/asm/page_no.h
> > +++ b/arch/m68k/include/asm/page_no.h
> > @@ -18,7 +18,7 @@ extern unsigned long memory_end;
> >  #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
> >  
> >  #define __pa(vaddr)		((unsigned long)(vaddr))
> > -#define __va(paddr)		((void *)(paddr))
> > +#define __va(paddr)		((void *)((unsigned long)(paddr)))
> >  
> >  #define virt_to_pfn(kaddr)	(__pa(kaddr) >> PAGE_SHIFT)
> >  #define pfn_to_virt(pfn)	__va((pfn) << PAGE_SHIFT)
> > -- 
> > 2.7.4
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
