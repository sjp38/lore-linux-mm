Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 426076B0505
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 04:53:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z193so7676846pgd.12
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 01:53:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v189si4231778pgb.579.2017.08.25.01.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 01:52:59 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7P8nD8f013654
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 04:52:58 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cjeexfad1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 04:52:58 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 25 Aug 2017 09:52:56 +0100
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170820121155.GA624@tigerII.localdomain>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Fri, 25 Aug 2017 10:52:45 +0200
MIME-Version: 1.0
In-Reply-To: <20170820121155.GA624@tigerII.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: fr
Content-Transfer-Encoding: 7bit
Message-Id: <e91cd0ad-0b59-0d93-e8c8-8a82a26015ec@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 20/08/2017 14:11, Sergey Senozhatsky wrote:
> On (08/18/17 00:05), Laurent Dufour wrote:
> [..]
>> +	/*
>> +	 * MPOL_INTERLEAVE implies additional check in mpol_misplaced() which
>> +	 * are not compatible with the speculative page fault processing.
>> +	 */
>> +	pol = __get_vma_policy(vma, address);
>> +	if (!pol)
>> +		pol = get_task_policy(current);
>> +	if (pol && pol->mode == MPOL_INTERLEAVE)
>> +		goto unlock;
> 
> include/linux/mempolicy.h defines
> 
> struct mempolicy *get_task_policy(struct task_struct *p);
> struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
> 		unsigned long addr);
> 
> only for CONFIG_NUMA configs.

Thanks Sergey, I'll add #ifdef around this block.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
