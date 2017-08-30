Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B55226B04A6
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 23:50:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 63so10257598pgc.0
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 20:50:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 6si3625643plc.700.2017.08.29.20.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 20:50:30 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7U3o27E113395
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 23:50:29 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cnd16gk1t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 23:50:29 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 30 Aug 2017 13:50:27 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v7U3nAgQ41943170
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 13:49:10 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v7U3n0Nc013949
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 13:49:01 +1000
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
 <507e79d5-59df-c5b5-106d-970c9353d9bc@linux.vnet.ibm.com>
 <20170829120426.4ar56rbmiupbqmio@hirez.programming.kicks-ass.net>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 30 Aug 2017 09:18:59 +0530
MIME-Version: 1.0
In-Reply-To: <20170829120426.4ar56rbmiupbqmio@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <3da42409-6313-d710-5293-47426fac4808@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 08/29/2017 05:34 PM, Peter Zijlstra wrote:
> On Tue, Aug 29, 2017 at 09:59:30AM +0200, Laurent Dufour wrote:
>> On 27/08/2017 02:18, Kirill A. Shutemov wrote:
>>>> +
>>>> +	if (unlikely(!vma->anon_vma))
>>>> +		goto unlock;
>>> It deserves a comment.
>> You're right I'll add it in the next version.
>> For the record, the root cause is that __anon_vma_prepare() requires the
>> mmap_sem to be held because vm_next and vm_prev must be safe.
> But should that test not be:
> 
> 	if (unlikely(vma_is_anonymous(vma) && !vma->anon_vma))
> 		goto unlock;

This makes more sense. We are backing off from speculative path
because struct anon_vma has not been created for this anonymous
vma and we cannot do that without holding mmap_sem. This should
have nothing to do with vma->vm_ops availability.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
