Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED5E8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 22:21:14 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t2so14713654edb.22
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 19:21:14 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x12si2264620edh.28.2018.12.18.19.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 19:21:13 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBJ3J6AF189176
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 22:21:12 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pfbj4ncd6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 22:21:11 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 19 Dec 2018 03:21:10 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V4 5/5] arch/powerpc/mm/hugetlb: NestMMU workaround for hugetlb mprotect RW upgrade
In-Reply-To: <20181218172236.GC22729@infradead.org>
References: <20181218094137.13732-1-aneesh.kumar@linux.ibm.com> <20181218094137.13732-6-aneesh.kumar@linux.ibm.com> <20181218172236.GC22729@infradead.org>
Date: Wed, 19 Dec 2018 08:50:57 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87r2eefbhi.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Christoph Hellwig <hch@infradead.org> writes:

> On Tue, Dec 18, 2018 at 03:11:37PM +0530, Aneesh Kumar K.V wrote:
>> +EXPORT_SYMBOL(huge_ptep_modify_prot_start);
>
> The only user of this function is the one you added in the last patch
> in mm/hugetlb.c, so there is no need to export this function.
>
>> +
>> +void huge_ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
>> +				  pte_t *ptep, pte_t old_pte, pte_t pte)
>> +{
>> +
>> +	if (radix_enabled())
>> +		return radix__huge_ptep_modify_prot_commit(vma, addr, ptep,
>> +							   old_pte, pte);
>> +	set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
>> +}
>> +EXPORT_SYMBOL(huge_ptep_modify_prot_commit);
>
> Same here.

That was done considering that ptep_modify_prot_start/commit was defined
in asm-generic/pgtable.h. I was trying to make sure I didn't break
anything with the patch. Also s390 do have that EXPORT_SYMBOL() for the
same. hugetlb just inherited that.

If you feel strongly about it, I can drop the EXPORT_SYMBOL().

-aneesh
