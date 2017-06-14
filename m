Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1836B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 11:25:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c75so3072998pfk.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 08:25:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 89si231493pld.33.2017.06.14.08.25.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 08:25:48 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5EFOCtX131099
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 11:25:47 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b36mrkx0d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 11:25:46 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 Jun 2017 09:25:45 -0600
Subject: Re: [HELP-NEEDED, PATCH 0/3] Do not loose dirty bit on THP pages
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Wed, 14 Jun 2017 20:55:26 +0530
MIME-Version: 1.0
In-Reply-To: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <eed279c6-bf61-f2f3-c9f2-d9a94568e2e3@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Wednesday 14 June 2017 07:21 PM, Kirill A. Shutemov wrote:
> Hi,
> 
> Vlastimil noted that pmdp_invalidate() is not atomic and we can loose
> dirty and access bits if CPU sets them after pmdp dereference, but
> before set_pmd_at().
> 
> The bug doesn't lead to user-visible misbehaviour in current kernel, but
> fixing this would be critical for future work on THP: both huge-ext4 and THP
> swap out rely on proper dirty tracking.
> 
> Unfortunately, there's no way to address the issue in a generic way. We need to
> fix all architectures that support THP one-by-one.
> 
> All architectures that have THP supported have to provide atomic
> pmdp_invalidate(). If generic implementation of pmdp_invalidate() is used,
> architecture needs to provide atomic pmdp_mknonpresent().
> 
> I've fixed the issue for x86, but I need help with the rest.
> 
> So far THP is supported on 8 architectures. Power and S390 already provides
> atomic pmdp_invalidate(). x86 is fixed by this patches, so 5 architectures
> left:
> 
>   - arc;
>   - arm;
>   - arm64;
>   - mips;
>   - sparc -- it has custom pmdp_invalidate(), but it's racy too;
> 
> Please, help me with them.
> 
> Kirill A. Shutemov (3):
>    x86/mm: Provide pmdp_mknotpresent() helper
>    mm: Do not loose dirty and access bits in pmdp_invalidate()
>    mm, thp: Do not loose dirty bit in __split_huge_pmd_locked()
> 


But in __split_huge_pmd_locked() we collected the dirty bit early. So 
even if we made pmdp_invalidate() atomic, if we had marked the pmd pte 
entry dirty after we collected the dirty bit, we still loose it right ?


May be we should relook at pmd PTE udpate interface. We really need an 
interface that can update pmd entries such that we don't clear it in 
between. IMHO, we can avoid the pmdp_invalidate() completely, if we can 
switch from a pmd PTE entry to a pointer to PTE page (pgtable_t). We 
also need this interface to avoid the madvise race fixed by

https://lkml.kernel.org/r/20170302151034.27829-1-kirill.shutemov@linux.intel.com

The usage of pmdp_invalidate while splitting the pmd also need updated 
documentation. In the earlier version of thp, we were required to keep 
the pmd present and marked splitting, so that code paths can wait till 
the splitting is done.

With the current design, we can ideally mark the pmdp not present early 
on right ? As long as we hold the pmd lock a parallel fault will try to 
mark the pmd accessed and wait on the pmd lock. On taking the lock it 
will find the pmd modified and we should retry access again ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
