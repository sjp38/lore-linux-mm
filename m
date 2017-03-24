Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 111C56B0343
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 04:51:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c23so15881156pfj.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 01:51:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y21si1867988pgi.329.2017.03.24.01.51.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 01:51:16 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2O8imPL006276
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 04:51:16 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29cyr5heru-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 04:51:15 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Fri, 24 Mar 2017 02:51:15 -0600
Subject: Re: [v1 0/5] parallelized "struct page" zeroing
References: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Fri, 24 Mar 2017 09:51:09 +0100
MIME-Version: 1.0
In-Reply-To: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <341568c3-0473-860f-aa20-63723aa40b87@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390 <linux-s390@vger.kernel.org>

On 03/24/2017 12:01 AM, Pavel Tatashin wrote:
> When deferred struct page initialization feature is enabled, we get a
> performance gain of initializing vmemmap in parallel after other CPUs are
> started. However, we still zero the memory for vmemmap using one boot CPU.
> This patch-set fixes the memset-zeroing limitation by deferring it as well.
> 
> Here is example performance gain on SPARC with 32T:
> base
> https://hastebin.com/ozanelatat.go
> 
> fix
> https://hastebin.com/utonawukof.go
> 
> As you can see without the fix it takes: 97.89s to boot
> With the fix it takes: 46.91 to boot.
> 
> On x86 time saving is going to be even greater (proportionally to memory size)
> because there are twice as many "struct page"es for the same amount of memory,
> as base pages are twice smaller.

Fixing the linux-s390 mailing list email.
This might be useful for s390 as well.

> 
> 
> Pavel Tatashin (5):
>   sparc64: simplify vmemmap_populate
>   mm: defining memblock_virt_alloc_try_nid_raw
>   mm: add "zero" argument to vmemmap allocators
>   mm: zero struct pages during initialization
>   mm: teach platforms not to zero struct pages memory
> 
>  arch/powerpc/mm/init_64.c |    4 +-
>  arch/s390/mm/vmem.c       |    5 ++-
>  arch/sparc/mm/init_64.c   |   26 +++++++----------------
>  arch/x86/mm/init_64.c     |    3 +-
>  include/linux/bootmem.h   |    3 ++
>  include/linux/mm.h        |   15 +++++++++++--
>  mm/memblock.c             |   46 ++++++++++++++++++++++++++++++++++++------
>  mm/page_alloc.c           |    3 ++
>  mm/sparse-vmemmap.c       |   48 +++++++++++++++++++++++++++++---------------
>  9 files changed, 103 insertions(+), 50 deletions(-)
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
