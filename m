Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFDD6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 21:36:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g7so626277pgr.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:36:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u18si1212536plj.51.2017.06.14.18.36.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 18:36:37 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5F1YGSx085317
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 21:36:36 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b3ek3c6us-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 21:36:36 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 Jun 2017 19:36:35 -0600
Subject: Re: [HELP-NEEDED, PATCH 0/3] Do not loose dirty bit on THP pages
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
 <eed279c6-bf61-f2f3-c9f2-d9a94568e2e3@linux.vnet.ibm.com>
 <20170614165513.GD17632@arm.com>
 <d589ad0a-d5d4-927a-597c-4b094285d4b1@suse.cz>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Thu, 15 Jun 2017 07:06:16 +0530
MIME-Version: 1.0
In-Reply-To: <d589ad0a-d5d4-927a-597c-4b094285d4b1@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <694d801a-cc15-d871-7951-97a7d33dc285@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will.deacon@arm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com



On Wednesday 14 June 2017 10:30 PM, Vlastimil Babka wrote:
> On 06/14/2017 06:55 PM, Will Deacon wrote:
>>>
>>> May be we should relook at pmd PTE udpate interface. We really need an
>>> interface that can update pmd entries such that we don't clear it in
>>> between. IMHO, we can avoid the pmdp_invalidate() completely, if we can
>>> switch from a pmd PTE entry to a pointer to PTE page (pgtable_t). We also
>>> need this interface to avoid the madvise race fixed by
>>
>> There's a good chance I'm not following your suggestion here, but it's
>> probably worth me pointing out that swizzling a page table entry from a
>> block mapping (e.g. a huge page mapped at the PMD level) to a table entry
>> (e.g. a pointer to a page of PTEs) can lead to all sorts of horrible
>> problems on ARM, including amalgamation of TLB entries and fatal aborts.
> 
> AFAIK some AMD x86_64 CPU's had the same problem and generated MCE's,
> and on Intel there are some restrictions when you can do that. See the
> large comment in __split_huge_pmd_locked().
> 

I was wondering whether we can do pmdp_establish(pgtable); and document 
all quirks needed for that in the per arch implementation of 
pmdp_establish(). We could also then switch all the 
pmdp_clear/set_pmd_at() usage to pmdp_establish().

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
