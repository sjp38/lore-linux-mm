Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E093C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 15:46:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52FC7222CE
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 15:46:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52FC7222CE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E25D26B0003; Fri, 19 Apr 2019 11:46:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD1616B0006; Fri, 19 Apr 2019 11:46:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C74926B0007; Fri, 19 Apr 2019 11:46:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7C36B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 11:46:24 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p88so3023298edd.17
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 08:46:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=ljfva5laX/uW2KOS0FIBuPL4Yg4p6stNoYJhsrY15i8=;
        b=prIxDba4UOqLtSoB5meBB8V3ZHpWsHfwp153J0kOtCfN5R9abmmbAoabv+wtjJ34w8
         ge06g8YOUJ5Sfbm5z0FK9wfAKwa9uKfvMolpG+Ng8e3s4CucN1hVKhFb6nQI+Ez/CGES
         NI2YFaPLHZjmdb1+G9TIBuY3pIhQc5x26S26ZDwTCDlocu3jg14opMFR6+3wppQdQQwP
         Itv265YxrNSyTX2VZdeznWWU5O2JelWOWnRm59rLPxc24ugBWDoQkmSVeRqOn5LwScmt
         0YHFqn6Eq7Vid4lGzbXc0wWyNKj66GGMz1vZUJ8pg2OJctXZa6ewq3iiQ/zc5tEQIWE+
         ImmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW3OaC62m9L5vec94DzMJ1pb0e18S5zSWg74UqyT81+tGtfW1uB
	YWC3BoQmIhNjIwQK9Go+v/T2OOGBcWDYchRrt/73kitW/XpJNN4mTCxbd5hkHSVl/UuHaOFBrEJ
	QSXYRGiZB0PBgVQb5TXuSO4PojCmWzER0GlFXA/Free7HLFd9fbmTaHtreKE1bYa6cQ==
X-Received: by 2002:a50:8786:: with SMTP id a6mr2962647eda.8.1555688783896;
        Fri, 19 Apr 2019 08:46:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAhge6GrU7uR63q2ernCihv5sC6Q9R2yme5yTpvujBnSP2C2+Ei8j3uBVyK1xXV5DFbhhl
X-Received: by 2002:a50:8786:: with SMTP id a6mr2962585eda.8.1555688782719;
        Fri, 19 Apr 2019 08:46:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555688782; cv=none;
        d=google.com; s=arc-20160816;
        b=XvP0cv3mfIgK6ok4JLiFftMY/ZCIqeNBLcvtCOXSq+5Ip4tcJHJX0OTQNGd+f7qWKN
         o8pOAjBTmay5Mr1/q2bFO1odXdIWTfa58aA5qu46wfwlZKxLyiIRa16NmwrWfHDEEo+e
         y8hv/hjrlJp+5PFWRvJXF48gnXY7GEUiacLrqhGCShUsdb8zb01iQs+U4VcV0GYEN7Fl
         aRnFDH578gUlUTYfotdC/XzBeG3PITM5Xw/GqyoQ1J3zTo9BwaF6sV/yumzaNTCyFQ7a
         AwPX/sMOepqDUJqlL+70OHbuzR3O3eixyvXnG+/bgH2U+K+yKV0z8q6TcyiKPosQPd1N
         8y4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=ljfva5laX/uW2KOS0FIBuPL4Yg4p6stNoYJhsrY15i8=;
        b=AaFX449WiItK1ntiixddl/kw7ekCqBUxZGHo89hyS/H674JeHSCbcczI0RdfyZyVHh
         kGnRZ/CC18y3B2oD12AVxZYxIyy8y02Ik6EA6sDHeDBBb47+u9blmeGY7GJg9loY5C56
         8y5RVV8rJEXuoHLY/Vw/1vdTCDRQsTjywpGY02fQT8CsR+ewPTlJvYUF+RL2KkQw+vWE
         FE9FMv5akw/a9Pwje2xlUf7cThXFguf+5+UNKv92qiIkG1axhTctaA/EMzCZwDskXUDk
         FAigDJUEVuz1Obmg4KB1maj+vlnO6cSoiNE3LnJ3bci7aJmRj+c+oE127BsJ4Le2t2HO
         orsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f23si2148742ejt.382.2019.04.19.08.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 08:46:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3JFkBWZ006477
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 11:46:20 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ryf8yctva-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 11:46:19 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Fri, 19 Apr 2019 16:46:14 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 19 Apr 2019 16:46:05 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3JFk3LC50266340
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 19 Apr 2019 15:46:03 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 83415A4051;
	Fri, 19 Apr 2019 15:46:03 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AC3F5A404D;
	Fri, 19 Apr 2019 15:45:57 +0000 (GMT)
Received: from [9.145.44.158] (unknown [9.145.44.158])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 19 Apr 2019 15:45:57 +0000 (GMT)
Subject: Re: [PATCH v12 09/31] mm: VMA sequence count
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
        kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
        jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
        aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
        mpe@ellerman.id.au, paulus@samba.org,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        hpa@zytor.com, Will Deacon <will.deacon@arm.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        sergey.senozhatsky.work@gmail.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        David Rientjes <rientjes@google.com>,
        Ganesh Mahendran <opensource.ganesh@gmail.com>,
        Minchan Kim <minchan@kernel.org>,
        Punit Agrawal <punitagrawal@gmail.com>,
        vinayak menon <vinayakm.list@gmail.com>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        zhong jiang <zhongjiang@huawei.com>,
        Haiyan Song <haiyanx.song@intel.com>,
        Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
        Michel Lespinasse <walken@google.com>,
        Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
        paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
        linuxppc-dev@lists.ozlabs.org, x86@kernel.org
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-10-ldufour@linux.ibm.com>
 <20190418224857.GI11645@redhat.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Fri, 19 Apr 2019 17:45:57 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418224857.GI11645@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041915-0028-0000-0000-00000362ABA3
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041915-0029-0000-0000-00002421EFDD
Message-Id: <d217e71c-7d55-ce1a-6461-ce1de732fb57@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-19_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904190115
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jerome,

Thanks a lot for reviewing this series.

Le 19/04/2019 à 00:48, Jerome Glisse a écrit :
> On Tue, Apr 16, 2019 at 03:45:00PM +0200, Laurent Dufour wrote:
>> From: Peter Zijlstra <peterz@infradead.org>
>>
>> Wrap the VMA modifications (vma_adjust/unmap_page_range) with sequence
>> counts such that we can easily test if a VMA is changed.
>>
>> The calls to vm_write_begin/end() in unmap_page_range() are
>> used to detect when a VMA is being unmap and thus that new page fault
>> should not be satisfied for this VMA. If the seqcount hasn't changed when
>> the page table are locked, this means we are safe to satisfy the page
>> fault.
>>
>> The flip side is that we cannot distinguish between a vma_adjust() and
>> the unmap_page_range() -- where with the former we could have
>> re-checked the vma bounds against the address.
>>
>> The VMA's sequence counter is also used to detect change to various VMA's
>> fields used during the page fault handling, such as:
>>   - vm_start, vm_end
>>   - vm_pgoff
>>   - vm_flags, vm_page_prot
>>   - vm_policy
> 
> ^ All above are under mmap write lock ?

Yes, changes are still made under the protection of the mmap_sem.

> 
>>   - anon_vma
> 
> ^ This is either under mmap write lock or under page table lock
> 
> So my question is do we need the complexity of seqcount_t for this ?

The sequence counter is used to detect write operation done while 
readers (SPF handler) is running.

The implementation is quite simple (here without the lockdep checks):

static inline void raw_write_seqcount_begin(seqcount_t *s)
{
	s->sequence++;
	smp_wmb();
}

I can't see why this is too complex here, would you elaborate on this ?

> 
> It seems that using regular int as counter and also relying on vm_flags
> when vma is unmap should do the trick.

vm_flags is not enough I guess an some operation are not impacting the 
vm_flags at all (resizing for instance).
Am I missing something ?

> 
> vma_delete(struct vm_area_struct *vma)
> {
>      ...
>      /*
>       * Make sure the vma is mark as invalid ie neither read nor write
>       * so that speculative fault back off. A racing speculative fault
>       * will either see the flags as 0 or the new seqcount.
>       */
>      vma->vm_flags = 0;
>      smp_wmb();
>      vma->seqcount++;
>      ...
> }

Well I don't think we can safely clear the vm_flags this way when the 
VMA is unmap, I think it is used later when cleaning is doen.

Later in this series, the VMA deletion is managed when the VMA is 
unlinked from the RB Tree. That is checked using the vm_rb field's 
value, and managed using RCU.

> Then:
> speculative_fault_begin(struct vm_area_struct *vma,
>                          struct spec_vmf *spvmf)
> {
>      ...
>      spvmf->seqcount = vma->seqcount;
>      smp_rmb();
>      spvmf->vm_flags = vma->vm_flags;
>      if (!spvmf->vm_flags) {
>          // Back off the vma is dying ...
>          ...
>      }
> }
> 
> bool speculative_fault_commit(struct vm_area_struct *vma,
>                                struct spec_vmf *spvmf)
> {
>      ...
>      seqcount = vma->seqcount;
>      smp_rmb();
>      vm_flags = vma->vm_flags;
> 
>      if (spvmf->vm_flags != vm_flags || seqcount != spvmf->seqcount) {
>          // Something did change for the vma
>          return false;
>      }
>      return true;
> }
> 
> This would also avoid the lockdep issue described below. But maybe what
> i propose is stupid and i will see it after further reviewing thing.

That's true that the lockdep is quite annoying here. But it is still 
interesting to keep in the loop to avoid 2 subsequent 
write_seqcount_begin() call being made in the same context (which would 
lead to an even sequence counter value while write operation is in 
progress). So I think this is still a good thing to have lockdep 
available here.



> 
> Cheers,
> Jérôme
> 
> 
>>
>> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>>
>> [Port to 4.12 kernel]
>> [Build depends on CONFIG_SPECULATIVE_PAGE_FAULT]
>> [Introduce vm_write_* inline function depending on
>>   CONFIG_SPECULATIVE_PAGE_FAULT]
>> [Fix lock dependency between mapping->i_mmap_rwsem and vma->vm_sequence by
>>   using vm_raw_write* functions]
>> [Fix a lock dependency warning in mmap_region() when entering the error
>>   path]
>> [move sequence initialisation INIT_VMA()]
>> [Review the patch description about unmap_page_range()]
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
>> ---
>>   include/linux/mm.h       | 44 ++++++++++++++++++++++++++++++++++++++++
>>   include/linux/mm_types.h |  3 +++
>>   mm/memory.c              |  2 ++
>>   mm/mmap.c                | 30 +++++++++++++++++++++++++++
>>   4 files changed, 79 insertions(+)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 2ceb1d2869a6..906b9e06f18e 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1410,6 +1410,9 @@ struct zap_details {
>>   static inline void INIT_VMA(struct vm_area_struct *vma)
>>   {
>>   	INIT_LIST_HEAD(&vma->anon_vma_chain);
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +	seqcount_init(&vma->vm_sequence);
>> +#endif
>>   }
>>   
>>   struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>> @@ -1534,6 +1537,47 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
>>   	unmap_mapping_range(mapping, holebegin, holelen, 0);
>>   }
>>   
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +static inline void vm_write_begin(struct vm_area_struct *vma)
>> +{
>> +	write_seqcount_begin(&vma->vm_sequence);
>> +}
>> +static inline void vm_write_begin_nested(struct vm_area_struct *vma,
>> +					 int subclass)
>> +{
>> +	write_seqcount_begin_nested(&vma->vm_sequence, subclass);
>> +}
>> +static inline void vm_write_end(struct vm_area_struct *vma)
>> +{
>> +	write_seqcount_end(&vma->vm_sequence);
>> +}
>> +static inline void vm_raw_write_begin(struct vm_area_struct *vma)
>> +{
>> +	raw_write_seqcount_begin(&vma->vm_sequence);
>> +}
>> +static inline void vm_raw_write_end(struct vm_area_struct *vma)
>> +{
>> +	raw_write_seqcount_end(&vma->vm_sequence);
>> +}
>> +#else
>> +static inline void vm_write_begin(struct vm_area_struct *vma)
>> +{
>> +}
>> +static inline void vm_write_begin_nested(struct vm_area_struct *vma,
>> +					 int subclass)
>> +{
>> +}
>> +static inline void vm_write_end(struct vm_area_struct *vma)
>> +{
>> +}
>> +static inline void vm_raw_write_begin(struct vm_area_struct *vma)
>> +{
>> +}
>> +static inline void vm_raw_write_end(struct vm_area_struct *vma)
>> +{
>> +}
>> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
>> +
>>   extern int access_process_vm(struct task_struct *tsk, unsigned long addr,
>>   		void *buf, int len, unsigned int gup_flags);
>>   extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index fd7d38ee2e33..e78f72eb2576 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -337,6 +337,9 @@ struct vm_area_struct {
>>   	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>>   #endif
>>   	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +	seqcount_t vm_sequence;
>> +#endif
>>   } __randomize_layout;
>>   
>>   struct core_thread {
>> diff --git a/mm/memory.c b/mm/memory.c
>> index d5bebca47d98..423fa8ea0569 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1256,6 +1256,7 @@ void unmap_page_range(struct mmu_gather *tlb,
>>   	unsigned long next;
>>   
>>   	BUG_ON(addr >= end);
>> +	vm_write_begin(vma);
>>   	tlb_start_vma(tlb, vma);
>>   	pgd = pgd_offset(vma->vm_mm, addr);
>>   	do {
>> @@ -1265,6 +1266,7 @@ void unmap_page_range(struct mmu_gather *tlb,
>>   		next = zap_p4d_range(tlb, vma, pgd, addr, next, details);
>>   	} while (pgd++, addr = next, addr != end);
>>   	tlb_end_vma(tlb, vma);
>> +	vm_write_end(vma);
>>   }
>>   
>>   
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 5ad3a3228d76..a4e4d52a5148 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -726,6 +726,30 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>   	long adjust_next = 0;
>>   	int remove_next = 0;
>>   
>> +	/*
>> +	 * Why using vm_raw_write*() functions here to avoid lockdep's warning ?
>> +	 *
>> +	 * Locked is complaining about a theoretical lock dependency, involving
>> +	 * 3 locks:
>> +	 *   mapping->i_mmap_rwsem --> vma->vm_sequence --> fs_reclaim
>> +	 *
>> +	 * Here are the major path leading to this dependency :
>> +	 *  1. __vma_adjust() mmap_sem  -> vm_sequence -> i_mmap_rwsem
>> +	 *  2. move_vmap() mmap_sem -> vm_sequence -> fs_reclaim
>> +	 *  3. __alloc_pages_nodemask() fs_reclaim -> i_mmap_rwsem
>> +	 *  4. unmap_mapping_range() i_mmap_rwsem -> vm_sequence
>> +	 *
>> +	 * So there is no way to solve this easily, especially because in
>> +	 * unmap_mapping_range() the i_mmap_rwsem is grab while the impacted
>> +	 * VMAs are not yet known.
>> +	 * However, the way the vm_seq is used is guarantying that we will
>> +	 * never block on it since we just check for its value and never wait
>> +	 * for it to move, see vma_has_changed() and handle_speculative_fault().
>> +	 */
>> +	vm_raw_write_begin(vma);
>> +	if (next)
>> +		vm_raw_write_begin(next);
>> +
>>   	if (next && !insert) {
>>   		struct vm_area_struct *exporter = NULL, *importer = NULL;
>>   
>> @@ -950,6 +974,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>   			 * "vma->vm_next" gap must be updated.
>>   			 */
>>   			next = vma->vm_next;
>> +			if (next)
>> +				vm_raw_write_begin(next);
>>   		} else {
>>   			/*
>>   			 * For the scope of the comment "next" and
>> @@ -996,6 +1022,10 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>   	if (insert && file)
>>   		uprobe_mmap(insert);
>>   
>> +	if (next && next != vma)
>> +		vm_raw_write_end(next);
>> +	vm_raw_write_end(vma);
>> +
>>   	validate_mm(mm);
>>   
>>   	return 0;
>> -- 
>> 2.21.0
>>
> 

