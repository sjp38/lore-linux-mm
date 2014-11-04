Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 408F26B0095
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 12:15:37 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id r10so14052825pdi.30
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 09:15:36 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id ui1si866627pbc.4.2014.11.04.09.15.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 04 Nov 2014 09:15:35 -0800 (PST)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NEI007LSYLX2FA0@mailout4.samsung.com> for linux-mm@kvack.org;
 Wed, 05 Nov 2014 02:15:33 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com>
 <1413986796-19732-1-git-send-email-pintu.k@samsung.com>
 <alpine.DEB.2.10.1411031556140.9845@chino.kir.corp.google.com>
In-reply-to: <alpine.DEB.2.10.1411031556140.9845@chino.kir.corp.google.com>
Subject: RE: [PATCH v2 1/2] mm: cma: split cma-reserved in dmesg log
Date: Tue, 04 Nov 2014 22:45:46 +0530
Message-id: <001a01cff853$04c90290$0e5b07b0$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'David Rientjes' <rientjes@google.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, aquini@redhat.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lcapitulino@redhat.com, kirill.shutemov@linux.intel.com, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, mina86@mina86.com, lauraa@codeaurora.org, gioh.kim@lge.com, mgorman@suse.de, hannes@cmpxchg.org, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pintu_agarwal@yahoo.com, cpgs@samsung.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com



> -----Original Message-----
> From: David Rientjes [mailto:rientjes@google.com]
> Sent: Tuesday, November 04, 2014 5:27 AM
> To: Pintu Kumar
> Cc: akpm@linux-foundation.org; riel@redhat.com; aquini@redhat.com;
> paul.gortmaker@windriver.com; jmarchan@redhat.com;
> lcapitulino@redhat.com; kirill.shutemov@linux.intel.com;
> m.szyprowski@samsung.com; aneesh.kumar@linux.vnet.ibm.com;
> iamjoonsoo.kim@lge.com; mina86@mina86.com; lauraa@codeaurora.org;
> gioh.kim@lge.com; mgorman@suse.de; hannes@cmpxchg.org; vbabka@suse.cz;
> sasha.levin@oracle.com; linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> pintu_agarwal@yahoo.com; cpgs@samsung.com; vishnu.ps@samsung.com;
> rohit.kr@samsung.com; ed.savinay@samsung.com
> Subject: Re: [PATCH v2 1/2] mm: cma: split cma-reserved in dmesg log
> 
> On Wed, 22 Oct 2014, Pintu Kumar wrote:
> 
> > diff --git a/include/linux/cma.h b/include/linux/cma.h index
> > 0430ed0..0b75896 100644
> > --- a/include/linux/cma.h
> > +++ b/include/linux/cma.h
> > @@ -15,6 +15,7 @@
> >
> >  struct cma;
> >
> > +extern unsigned long totalcma_pages;
> >  extern phys_addr_t cma_get_base(struct cma *cma);  extern unsigned
> > long cma_get_size(struct cma *cma);
> >
> > diff --git a/mm/cma.c b/mm/cma.c
> > index 963bc4a..8435762 100644
> > --- a/mm/cma.c
> > +++ b/mm/cma.c
> > @@ -288,6 +288,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
> >  	if (ret)
> >  		goto err;
> >
> > +	totalcma_pages += (size / PAGE_SIZE);
> >  	pr_info("Reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
> >  		(unsigned long)base);
> >  	return 0;
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c index dd73f9a..ababbd8
> > 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -110,6 +110,7 @@ static DEFINE_SPINLOCK(managed_page_count_lock);
> >
> >  unsigned long totalram_pages __read_mostly;  unsigned long
> > totalreserve_pages __read_mostly;
> > +unsigned long totalcma_pages __read_mostly;
> 
> Shouldn't this be __initdata instead?
> 

No, we wanted to retain this variable for later use. 
We wanted to use this to print CMA info in /proc/meminfo.
Please see the next patch for this set.
[PATCH v2 2/2] fs: proc: Include cma info in proc/meminfo


> >  /*
> >   * When calculating the number of globally allowed dirty pages, there
> >   * is a certain number of per-zone reserves that should not be @@
> > -5520,7 +5521,7 @@ void __init mem_init_print_info(const char *str)
> >
> >  	pr_info("Memory: %luK/%luK available "
> >  	       "(%luK kernel code, %luK rwdata, %luK rodata, "
> > -	       "%luK init, %luK bss, %luK reserved"
> > +	       "%luK init, %luK bss, %luK reserved, %luK cma-reserved"
> >  #ifdef	CONFIG_HIGHMEM
> >  	       ", %luK highmem"
> >  #endif
> > @@ -5528,7 +5529,8 @@ void __init mem_init_print_info(const char *str)
> >  	       nr_free_pages() << (PAGE_SHIFT-10), physpages << (PAGE_SHIFT-10),
> >  	       codesize >> 10, datasize >> 10, rosize >> 10,
> >  	       (init_data_size + init_code_size) >> 10, bss_size >> 10,
> > -	       (physpages - totalram_pages) << (PAGE_SHIFT-10),
> > +	       (physpages - totalram_pages - totalcma_pages) << (PAGE_SHIFT-10),
> > +	       totalcma_pages << (PAGE_SHIFT-10),
> >  #ifdef	CONFIG_HIGHMEM
> >  	       totalhigh_pages << (PAGE_SHIFT-10),  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
