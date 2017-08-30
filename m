Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA352803A5
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:27:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v2so904487wmd.11
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 22:27:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p17si3538668wra.451.2017.08.29.22.26.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 22:27:00 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7U5O1ZK112226
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:26:59 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2cndnvvdut-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:26:58 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 30 Aug 2017 15:26:56 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v7U5Pdm240108270
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 15:25:39 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v7U5PTP2016996
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 15:25:29 +1000
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 30 Aug 2017 10:55:27 +0530
MIME-Version: 1.0
In-Reply-To: <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <f6927138-5863-82f8-8c85-2ff96d5e9434@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 08/27/2017 05:48 AM, Kirill A. Shutemov wrote:
>> +	/* Transparent huge pages are not supported. */
>> +	if (unlikely(pmd_trans_huge(*pmd)))
>> +		goto out_walk;
> That's looks like a blocker to me.
> 
> Is there any problem with making it supported (besides plain coding)?

IIUC we would have to reattempt once for each PMD level fault because
of the lack of a page table entry there. Besides do we want to support
huge pages in general as part of speculative page fault path ? The
number of faults will be very less (256 times lower on POWER and 512
times lower on X86). So is it worth it ? BTW calling hugetlb_fault()
after figuring out the VMA, works correctly inside handle_speculative
_fault() last time I checked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
