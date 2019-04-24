Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 870FDC282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:56:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D7AA2084F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:56:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D7AA2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF3FA6B026B; Wed, 24 Apr 2019 10:56:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA29B6B026C; Wed, 24 Apr 2019 10:56:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A45336B026F; Wed, 24 Apr 2019 10:56:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 785B36B026B
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:56:43 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id j14so8811916ywb.2
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:56:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=vrPd8CzBpGjHBdr4YIkSBuda2KUNX9GTDh2gLLhBTGs=;
        b=XdJKh2UmqGj4RdSaYF6FnPdimgQ9DVyTT+VfFSqqVPSRytAyaRinAkeKeH86fsSxlt
         0643z2Wp08J2Gmiy4biKDFdBXzkzQbsmSFzKtcLyZmCjgG5NeMZKJlWN7Wr2WJJWX23h
         pH9FVD9cGAjT8KmhESwnKWi3r0UloGyn4zjTLst1nOqi1umeX5543DTTPY8cqF7HSSCB
         TsuYfBhaA97vCaG0d6O/vkpXR75dcZb140XJPvRPuQw7g/8GWcsj5k5UAXzTV01WP9KZ
         vcAu9/vfWrlICkx/bITu9RCHcHhr6/E2ZMaCXSHjtc9fos+OdlH6XODtLVMXaFIrNb93
         9ufQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVa3L+lqYmnPgUTTEjrEo6apJ90DPU1ZfVK8E9+iW6fIgcidgZ7
	RkpGVXkPjXiMdAf8rpmv/Djf5QC2ToAeS/KSsGSB+HcCW+hg+vKHSmTmjFDU7pCLxlAsINndiWi
	ocnkOhZPInSRscEDWp7hKZg9VcB9AMoeOYggomGVceIs7n3l3v1MUodbfJwIs95QDgg==
X-Received: by 2002:a25:391:: with SMTP id 139mr26520988ybd.297.1556117803064;
        Wed, 24 Apr 2019 07:56:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7IrmbNhAA9cHMwdebLStfh5d/2T/hTivn2gua4NyineIDpgu9PM1GthvVn+ajNmR37HLv
X-Received: by 2002:a25:391:: with SMTP id 139mr26520874ybd.297.1556117801245;
        Wed, 24 Apr 2019 07:56:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556117801; cv=none;
        d=google.com; s=arc-20160816;
        b=t95boNK9LS9/GWipRhXtS6pOY9RcLasnTzvMdTNn0MGjiUvHgyDchvcdObaKvtFDBs
         lI9i9P5F1jAxKmRTC8kWAM01nmI7vP6M4KD4VfMtAhuSWS1FQPu3dCSCMYkZxWfLpZOV
         9G+eQRtomB4rZvRJ0Ne9aA7wHz1XuIRotEkqiJKSuc6Juj9eei7RqtbIqYvakS6nZIfn
         FkWL8YDGLdHRhLN3r9aazZq+/0zk3nri2PGAJj5/aqo3K+5i9tsgBlEuFR70KrkWU4CE
         q6Kb1qG231ac9LhDcXsRoikkXBo/h5oiTqHCDPRgUuDJRyluMXTmXaaKjW8ROLWQ5azH
         9dIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=vrPd8CzBpGjHBdr4YIkSBuda2KUNX9GTDh2gLLhBTGs=;
        b=lyOM+ON4d3EekNSJ0cHZbHO/teIZE0SdLc6xE+7y+bqsDWl+EgkAUzbVGiefC9tMYX
         YhIWfYDK5pX5HUnjkvDtIwFt/L2euIWks55tdwXLudNsU4DItSq+Zp+Kvl9sbTi5sXqg
         IDOPKFWJ4NFJ63RliCvNnGYAwo73MyBm56sOyRDxei6sIsAclrRVzmfV9sNBBvpdKmyn
         epST2ArSSY/W88M0vAz2Q9sV3D+WM3fYWH0VteqFNe9NB5NhV0V1h6Q+hthU7kYXKGfl
         PW5nCJJylm4j9499oQ0bZJ46HfAf1caKJ5uBIeO3SyX4/fvIpVhSRrlN0NZ0OUPsljbg
         yREw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p9si13105332ybl.177.2019.04.24.07.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:56:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OEtH42068182
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:56:41 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s2qfu8k8j-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:56:36 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Wed, 24 Apr 2019 15:56:28 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 15:56:20 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3OEuIX361669436
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 14:56:18 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1EF4BAE04D;
	Wed, 24 Apr 2019 14:56:18 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6F808AE056;
	Wed, 24 Apr 2019 14:56:15 +0000 (GMT)
Received: from [9.145.176.48] (unknown [9.145.176.48])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 24 Apr 2019 14:56:15 +0000 (GMT)
Subject: Re: [PATCH v12 22/31] mm: provide speculative fault infrastructure
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
 <20190416134522.17540-23-ldufour@linux.ibm.com>
 <20190422212623.GM14666@redhat.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Wed, 24 Apr 2019 16:56:14 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190422212623.GM14666@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042414-0016-0000-0000-000002732704
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042414-0017-0000-0000-000032CF99B5
Message-Id: <a1e27d15-2890-28fc-d350-ca62fb77f508@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240116
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 22/04/2019 à 23:26, Jerome Glisse a écrit :
> On Tue, Apr 16, 2019 at 03:45:13PM +0200, Laurent Dufour wrote:
>> From: Peter Zijlstra <peterz@infradead.org>
>>
>> Provide infrastructure to do a speculative fault (not holding
>> mmap_sem).
>>
>> The not holding of mmap_sem means we can race against VMA
>> change/removal and page-table destruction. We use the SRCU VMA freeing
>> to keep the VMA around. We use the VMA seqcount to detect change
>> (including umapping / page-table deletion) and we use gup_fast() style
>> page-table walking to deal with page-table races.
>>
>> Once we've obtained the page and are ready to update the PTE, we
>> validate if the state we started the fault with is still valid, if
>> not, we'll fail the fault with VM_FAULT_RETRY, otherwise we update the
>> PTE and we're done.
>>
>> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>>
>> [Manage the newly introduced pte_spinlock() for speculative page
>>   fault to fail if the VMA is touched in our back]
>> [Rename vma_is_dead() to vma_has_changed() and declare it here]
>> [Fetch p4d and pud]
>> [Set vmd.sequence in __handle_mm_fault()]
>> [Abort speculative path when handle_userfault() has to be called]
>> [Add additional VMA's flags checks in handle_speculative_fault()]
>> [Clear FAULT_FLAG_ALLOW_RETRY in handle_speculative_fault()]
>> [Don't set vmf->pte and vmf->ptl if pte_map_lock() failed]
>> [Remove warning comment about waiting for !seq&1 since we don't want
>>   to wait]
>> [Remove warning about no huge page support, mention it explictly]
>> [Don't call do_fault() in the speculative path as __do_fault() calls
>>   vma->vm_ops->fault() which may want to release mmap_sem]
>> [Only vm_fault pointer argument for vma_has_changed()]
>> [Fix check against huge page, calling pmd_trans_huge()]
>> [Use READ_ONCE() when reading VMA's fields in the speculative path]
>> [Explicitly check for __HAVE_ARCH_PTE_SPECIAL as we can't support for
>>   processing done in vm_normal_page()]
>> [Check that vma->anon_vma is already set when starting the speculative
>>   path]
>> [Check for memory policy as we can't support MPOL_INTERLEAVE case due to
>>   the processing done in mpol_misplaced()]
>> [Don't support VMA growing up or down]
>> [Move check on vm_sequence just before calling handle_pte_fault()]
>> [Don't build SPF services if !CONFIG_SPECULATIVE_PAGE_FAULT]
>> [Add mem cgroup oom check]
>> [Use READ_ONCE to access p*d entries]
>> [Replace deprecated ACCESS_ONCE() by READ_ONCE() in vma_has_changed()]
>> [Don't fetch pte again in handle_pte_fault() when running the speculative
>>   path]
>> [Check PMD against concurrent collapsing operation]
>> [Try spin lock the pte during the speculative path to avoid deadlock with
>>   other CPU's invalidating the TLB and requiring this CPU to catch the
>>   inter processor's interrupt]
>> [Move define of FAULT_FLAG_SPECULATIVE here]
>> [Introduce __handle_speculative_fault() and add a check against
>>   mm->mm_users in handle_speculative_fault() defined in mm.h]
>> [Abort if vm_ops->fault is set instead of checking only vm_ops]
>> [Use find_vma_rcu() and call put_vma() when we are done with the VMA]
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> 
> 
> Few comments and questions for this one see below.
> 
> 
>> ---
>>   include/linux/hugetlb_inline.h |   2 +-
>>   include/linux/mm.h             |  30 +++
>>   include/linux/pagemap.h        |   4 +-
>>   mm/internal.h                  |  15 ++
>>   mm/memory.c                    | 344 ++++++++++++++++++++++++++++++++-
>>   5 files changed, 389 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.h
>> index 0660a03d37d9..9e25283d6fc9 100644
>> --- a/include/linux/hugetlb_inline.h
>> +++ b/include/linux/hugetlb_inline.h
>> @@ -8,7 +8,7 @@
>>   
>>   static inline bool is_vm_hugetlb_page(struct vm_area_struct *vma)
>>   {
>> -	return !!(vma->vm_flags & VM_HUGETLB);
>> +	return !!(READ_ONCE(vma->vm_flags) & VM_HUGETLB);
>>   }
>>   
>>   #else
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index f761a9c65c74..ec609cbad25a 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -381,6 +381,7 @@ extern pgprot_t protection_map[16];
>>   #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
>>   #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
>>   #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
>> +#define FAULT_FLAG_SPECULATIVE	0x200	/* Speculative fault, not holding mmap_sem */
>>   
>>   #define FAULT_FLAG_TRACE \
>>   	{ FAULT_FLAG_WRITE,		"WRITE" }, \
>> @@ -409,6 +410,10 @@ struct vm_fault {
>>   	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
>>   	pgoff_t pgoff;			/* Logical page offset based on vma */
>>   	unsigned long address;		/* Faulting virtual address */
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +	unsigned int sequence;
>> +	pmd_t orig_pmd;			/* value of PMD at the time of fault */
>> +#endif
>>   	pmd_t *pmd;			/* Pointer to pmd entry matching
>>   					 * the 'address' */
>>   	pud_t *pud;			/* Pointer to pud entry matching
>> @@ -1524,6 +1529,31 @@ int invalidate_inode_page(struct page *page);
>>   #ifdef CONFIG_MMU
>>   extern vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
>>   			unsigned long address, unsigned int flags);
>> +
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +extern vm_fault_t __handle_speculative_fault(struct mm_struct *mm,
>> +					     unsigned long address,
>> +					     unsigned int flags);
>> +static inline vm_fault_t handle_speculative_fault(struct mm_struct *mm,
>> +						  unsigned long address,
>> +						  unsigned int flags)
>> +{
>> +	/*
>> +	 * Try speculative page fault for multithreaded user space task only.
>> +	 */
>> +	if (!(flags & FAULT_FLAG_USER) || atomic_read(&mm->mm_users) == 1)
>> +		return VM_FAULT_RETRY;
>> +	return __handle_speculative_fault(mm, address, flags);
>> +}
>> +#else
>> +static inline vm_fault_t handle_speculative_fault(struct mm_struct *mm,
>> +						  unsigned long address,
>> +						  unsigned int flags)
>> +{
>> +	return VM_FAULT_RETRY;
>> +}
>> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
>> +
>>   extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
>>   			    unsigned long address, unsigned int fault_flags,
>>   			    bool *unlocked);
>> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
>> index 2e8438a1216a..2fcfaa910007 100644
>> --- a/include/linux/pagemap.h
>> +++ b/include/linux/pagemap.h
>> @@ -457,8 +457,8 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
>>   	pgoff_t pgoff;
>>   	if (unlikely(is_vm_hugetlb_page(vma)))
>>   		return linear_hugepage_index(vma, address);
>> -	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
>> -	pgoff += vma->vm_pgoff;
>> +	pgoff = (address - READ_ONCE(vma->vm_start)) >> PAGE_SHIFT;
>> +	pgoff += READ_ONCE(vma->vm_pgoff);
>>   	return pgoff;
>>   }
>>   
>> diff --git a/mm/internal.h b/mm/internal.h
>> index 1e368e4afe3c..ed91b199cb8c 100644
>> --- a/mm/internal.h
>> +++ b/mm/internal.h
>> @@ -58,6 +58,21 @@ static inline void put_vma(struct vm_area_struct *vma)
>>   extern struct vm_area_struct *find_vma_rcu(struct mm_struct *mm,
>>   					   unsigned long addr);
>>   
>> +
>> +static inline bool vma_has_changed(struct vm_fault *vmf)
>> +{
>> +	int ret = RB_EMPTY_NODE(&vmf->vma->vm_rb);
>> +	unsigned int seq = READ_ONCE(vmf->vma->vm_sequence.sequence);
>> +
>> +	/*
>> +	 * Matches both the wmb in write_seqlock_{begin,end}() and
>> +	 * the wmb in vma_rb_erase().
>> +	 */
>> +	smp_rmb();
>> +
>> +	return ret || seq != vmf->sequence;
>> +}
>> +
>>   #else /* CONFIG_SPECULATIVE_PAGE_FAULT */
>>   
>>   static inline void get_vma(struct vm_area_struct *vma)
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 46f877b6abea..6e6bf61c0e5c 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -522,7 +522,8 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
>>   	if (page)
>>   		dump_page(page, "bad pte");
>>   	pr_alert("addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
>> -		 (void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
>> +		 (void *)addr, READ_ONCE(vma->vm_flags), vma->anon_vma,
>> +		 mapping, index);
>>   	pr_alert("file:%pD fault:%pf mmap:%pf readpage:%pf\n",
>>   		 vma->vm_file,
>>   		 vma->vm_ops ? vma->vm_ops->fault : NULL,
>> @@ -2082,6 +2083,118 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>>   }
>>   EXPORT_SYMBOL_GPL(apply_to_page_range);
>>   
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +static bool pte_spinlock(struct vm_fault *vmf)
>> +{
>> +	bool ret = false;
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +	pmd_t pmdval;
>> +#endif
>> +
>> +	/* Check if vma is still valid */
>> +	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
>> +		vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
>> +		spin_lock(vmf->ptl);
>> +		return true;
>> +	}
>> +
>> +again:
>> +	local_irq_disable();
>> +	if (vma_has_changed(vmf))
>> +		goto out;
>> +
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +	/*
>> +	 * We check if the pmd value is still the same to ensure that there
>> +	 * is not a huge collapse operation in progress in our back.
>> +	 */
>> +	pmdval = READ_ONCE(*vmf->pmd);
>> +	if (!pmd_same(pmdval, vmf->orig_pmd))
>> +		goto out;
>> +#endif
>> +
>> +	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
>> +	if (unlikely(!spin_trylock(vmf->ptl))) {
>> +		local_irq_enable();
>> +		goto again;
>> +	}
> 
> Do we want to constantly retry taking the spinlock ? Shouldn't it
> be limited ? If we fail few times it is probably better to give
> up on that speculative page fault.
> 
> So maybe putting everything within a for(i; i < MAX_TRY; ++i) loop
> would be cleaner.

I did tried that by the past when I added this loop but I never reach 
the limit I set. By the way what should be the MAX_TRY value? ;)

The loop was introduced to fix a race between CPU, this is explained in 
the patch description, but a comment is clearly missing here:

/*
  * A spin_trylock() of the ptl is done to avoid a deadlock with other
  * CPU invalidating the TLB and requiring this CPU to catch the IPI.
  * As the interrupt are disabled during this operation we need to relax
  * them and try again locking the PTL.
  */

I don't think that retrying the page fault would help, since the regular 
page fault handler will also spin here if there is a massive contention 
on the PTL.

> 
> 
>> +
>> +	if (vma_has_changed(vmf)) {
>> +		spin_unlock(vmf->ptl);
>> +		goto out;
>> +	}
>> +
>> +	ret = true;
>> +out:
>> +	local_irq_enable();
>> +	return ret;
>> +}
>> +
>> +static bool pte_map_lock(struct vm_fault *vmf)
>> +{
>> +	bool ret = false;
>> +	pte_t *pte;
>> +	spinlock_t *ptl;
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +	pmd_t pmdval;
>> +#endif
>> +
>> +	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
>> +		vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
>> +					       vmf->address, &vmf->ptl);
>> +		return true;
>> +	}
>> +
>> +	/*
>> +	 * The first vma_has_changed() guarantees the page-tables are still
>> +	 * valid, having IRQs disabled ensures they stay around, hence the
>> +	 * second vma_has_changed() to make sure they are still valid once
>> +	 * we've got the lock. After that a concurrent zap_pte_range() will
>> +	 * block on the PTL and thus we're safe.
>> +	 */
>> +again:
>> +	local_irq_disable();
>> +	if (vma_has_changed(vmf))
>> +		goto out;
>> +
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +	/*
>> +	 * We check if the pmd value is still the same to ensure that there
>> +	 * is not a huge collapse operation in progress in our back.
>> +	 */
>> +	pmdval = READ_ONCE(*vmf->pmd);
>> +	if (!pmd_same(pmdval, vmf->orig_pmd))
>> +		goto out;
>> +#endif
>> +
>> +	/*
>> +	 * Same as pte_offset_map_lock() except that we call
>> +	 * spin_trylock() in place of spin_lock() to avoid race with
>> +	 * unmap path which may have the lock and wait for this CPU
>> +	 * to invalidate TLB but this CPU has irq disabled.
>> +	 * Since we are in a speculative patch, accept it could fail
>> +	 */
>> +	ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
>> +	pte = pte_offset_map(vmf->pmd, vmf->address);
>> +	if (unlikely(!spin_trylock(ptl))) {
>> +		pte_unmap(pte);
>> +		local_irq_enable();
>> +		goto again;
>> +	}
> 
> Same comment as above shouldn't be limited to a maximum number of retry ?

Same answer ;)

> 
>> +
>> +	if (vma_has_changed(vmf)) {
>> +		pte_unmap_unlock(pte, ptl);
>> +		goto out;
>> +	}
>> +
>> +	vmf->pte = pte;
>> +	vmf->ptl = ptl;
>> +	ret = true;
>> +out:
>> +	local_irq_enable();
>> +	return ret;
>> +}
>> +#else
>>   static inline bool pte_spinlock(struct vm_fault *vmf)
>>   {
>>   	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
>> @@ -2095,6 +2208,7 @@ static inline bool pte_map_lock(struct vm_fault *vmf)
>>   				       vmf->address, &vmf->ptl);
>>   	return true;
>>   }
>> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
>>   
>>   /*
>>    * handle_pte_fault chooses page fault handler according to an entry which was
>> @@ -2999,6 +3113,14 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
>>   		ret = check_stable_address_space(vma->vm_mm);
>>   		if (ret)
>>   			goto unlock;
>> +		/*
>> +		 * Don't call the userfaultfd during the speculative path.
>> +		 * We already checked for the VMA to not be managed through
>> +		 * userfaultfd, but it may be set in our back once we have lock
>> +		 * the pte. In such a case we can ignore it this time.
>> +		 */
>> +		if (vmf->flags & FAULT_FLAG_SPECULATIVE)
>> +			goto setpte;
> 
> Bit confuse by the comment above, if userfaultfd is set in the back
> then shouldn't the speculative fault abort ? So wouldn't the following
> be correct:
> 
> 		if (userfaultfd_missing(vma)) {
> 			pte_unmap_unlock(vmf->pte, vmf->ptl);
> 			if (vmf->flags & FAULT_FLAG_SPECULATIVE)
> 				return VM_FAULT_RETRY;
> 			...

Well here we are racing with the user space action setting the 
userfaultfd, we may have go through this page fault seeing the 
userfaultfd or not. But I can't imagine that the user process will rely 
on that to happen. If there is such a race, it would be up to the user 
space process to ensure that no page fault are triggered while it is 
setting up the userfaultfd.
Since a check on the userfaultfd is done at the beginning of the SPF 
handler, I made the choice to ignore this later and not trigger the 
userfault this time.

Obviously we may abort the SPF handling but what is the benefit ?

> 
>>   		/* Deliver the page fault to userland, check inside PT lock */
>>   		if (userfaultfd_missing(vma)) {
>>   			pte_unmap_unlock(vmf->pte, vmf->ptl);
>> @@ -3041,7 +3163,8 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
>>   		goto unlock_and_release;
>>   
>>   	/* Deliver the page fault to userland, check inside PT lock */
>> -	if (userfaultfd_missing(vma)) {
>> +	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE) &&
>> +	    userfaultfd_missing(vma)) {
> 
> Same comment as above but this also seems more wrong then above. What
> i propose above would look more correct in both cases ie we still want
> to check for userfaultfd but if we are in speculative fault then we
> just want to abort the speculative fault.

Why is more wrong here ? Indeed this is consistent with the previous 
action, ignore the userfault event if it has been set while the SPF 
handler is in progress. IMHO this is up to the user space to serialize 
the userfaultfd setting against the ongoing page fault in that case.

> 
>>   		pte_unmap_unlock(vmf->pte, vmf->ptl);
>>   		mem_cgroup_cancel_charge(page, memcg, false);
>>   		put_page(page);
>> @@ -3836,6 +3959,15 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
>>   	pte_t entry;
>>   
>>   	if (unlikely(pmd_none(*vmf->pmd))) {
>> +		/*
>> +		 * In the case of the speculative page fault handler we abort
>> +		 * the speculative path immediately as the pmd is probably
>> +		 * in the way to be converted in a huge one. We will try
>> +		 * again holding the mmap_sem (which implies that the collapse
>> +		 * operation is done).
>> +		 */
>> +		if (vmf->flags & FAULT_FLAG_SPECULATIVE)
>> +			return VM_FAULT_RETRY;
>>   		/*
>>   		 * Leave __pte_alloc() until later: because vm_ops->fault may
>>   		 * want to allocate huge page, and if we expose page table
>> @@ -3843,7 +3975,7 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
>>   		 * concurrent faults and from rmap lookups.
>>   		 */
>>   		vmf->pte = NULL;
>> -	} else {
>> +	} else if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
>>   		/* See comment in pte_alloc_one_map() */
>>   		if (pmd_devmap_trans_unstable(vmf->pmd))
>>   			return 0;
>> @@ -3852,6 +3984,9 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
>>   		 * pmd from under us anymore at this point because we hold the
>>   		 * mmap_sem read mode and khugepaged takes it in write mode.
>>   		 * So now it's safe to run pte_offset_map().
>> +		 * This is not applicable to the speculative page fault handler
>> +		 * but in that case, the pte is fetched earlier in
>> +		 * handle_speculative_fault().
>>   		 */
>>   		vmf->pte = pte_offset_map(vmf->pmd, vmf->address);
>>   		vmf->orig_pte = *vmf->pte;
>> @@ -3874,6 +4009,8 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
>>   	if (!vmf->pte) {
>>   		if (vma_is_anonymous(vmf->vma))
>>   			return do_anonymous_page(vmf);
>> +		else if (vmf->flags & FAULT_FLAG_SPECULATIVE)
>> +			return VM_FAULT_RETRY;
> 
> Maybe a small comment about speculative page fault not applying to
> file back vma.

Sure.

> 
>>   		else
>>   			return do_fault(vmf);
>>   	}
>> @@ -3971,6 +4108,9 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
>>   	vmf.pmd = pmd_alloc(mm, vmf.pud, address);
>>   	if (!vmf.pmd)
>>   		return VM_FAULT_OOM;
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +	vmf.sequence = raw_read_seqcount(&vma->vm_sequence);
>> +#endif
>>   	if (pmd_none(*vmf.pmd) && __transparent_hugepage_enabled(vma)) {
>>   		ret = create_huge_pmd(&vmf);
>>   		if (!(ret & VM_FAULT_FALLBACK))
>> @@ -4004,6 +4144,204 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
>>   	return handle_pte_fault(&vmf);
>>   }
>>   
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +/*
>> + * Tries to handle the page fault in a speculative way, without grabbing the
>> + * mmap_sem.
>> + */
>> +vm_fault_t __handle_speculative_fault(struct mm_struct *mm,
>> +				      unsigned long address,
>> +				      unsigned int flags)
>> +{
>> +	struct vm_fault vmf = {
>> +		.address = address,
>> +	};
>> +	pgd_t *pgd, pgdval;
>> +	p4d_t *p4d, p4dval;
>> +	pud_t pudval;
>> +	int seq;
>> +	vm_fault_t ret = VM_FAULT_RETRY;
>> +	struct vm_area_struct *vma;
>> +#ifdef CONFIG_NUMA
>> +	struct mempolicy *pol;
>> +#endif
>> +
>> +	/* Clear flags that may lead to release the mmap_sem to retry */
>> +	flags &= ~(FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_KILLABLE);
>> +	flags |= FAULT_FLAG_SPECULATIVE;
>> +
>> +	vma = find_vma_rcu(mm, address);
>> +	if (!vma)
>> +		return ret;
>> +
>> +	/* rmb <-> seqlock,vma_rb_erase() */
>> +	seq = raw_read_seqcount(&vma->vm_sequence);
>> +	if (seq & 1)
>> +		goto out_put;
> 
> A comment explaining that odd sequence number means that we are racing
> with a write_begin and write_end would be welcome above.

Yes that would be welcome.

>> +
>> +	/*
>> +	 * Can't call vm_ops service has we don't know what they would do
>> +	 * with the VMA.
>> +	 * This include huge page from hugetlbfs.
>> +	 */
>> +	if (vma->vm_ops && vma->vm_ops->fault)
>> +		goto out_put;
>> +
>> +	/*
>> +	 * __anon_vma_prepare() requires the mmap_sem to be held
>> +	 * because vm_next and vm_prev must be safe. This can't be guaranteed
>> +	 * in the speculative path.
>> +	 */
>> +	if (unlikely(!vma->anon_vma))
>> +		goto out_put;
> 
> Maybe also remind people that once the vma->anon_vma is set then its
> value will not change and thus we do not need to protect against such
> thing (unlike vm_flags or other vma field below and above).

Will do, thanks.


>> +
>> +	vmf.vma_flags = READ_ONCE(vma->vm_flags);
>> +	vmf.vma_page_prot = READ_ONCE(vma->vm_page_prot);
>> +
>> +	/* Can't call userland page fault handler in the speculative path */
>> +	if (unlikely(vmf.vma_flags & VM_UFFD_MISSING))
>> +		goto out_put;
>> +
>> +	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP)
>> +		/*
>> +		 * This could be detected by the check address against VMA's
>> +		 * boundaries but we want to trace it as not supported instead
>> +		 * of changed.
>> +		 */
>> +		goto out_put;
>> +
>> +	if (address < READ_ONCE(vma->vm_start)
>> +	    || READ_ONCE(vma->vm_end) <= address)
>> +		goto out_put;
>> +
>> +	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
>> +				       flags & FAULT_FLAG_INSTRUCTION,
>> +				       flags & FAULT_FLAG_REMOTE)) {
>> +		ret = VM_FAULT_SIGSEGV;
>> +		goto out_put;
>> +	}
>> +
>> +	/* This is one is required to check that the VMA has write access set */
>> +	if (flags & FAULT_FLAG_WRITE) {
>> +		if (unlikely(!(vmf.vma_flags & VM_WRITE))) {
>> +			ret = VM_FAULT_SIGSEGV;
>> +			goto out_put;
>> +		}
>> +	} else if (unlikely(!(vmf.vma_flags & (VM_READ|VM_EXEC|VM_WRITE)))) {
>> +		ret = VM_FAULT_SIGSEGV;
>> +		goto out_put;
>> +	}
>> +
>> +#ifdef CONFIG_NUMA
>> +	/*
>> +	 * MPOL_INTERLEAVE implies additional checks in
>> +	 * mpol_misplaced() which are not compatible with the
>> +	 *speculative page fault processing.
>> +	 */
>> +	pol = __get_vma_policy(vma, address);
>> +	if (!pol)
>> +		pol = get_task_policy(current);
>> +	if (pol && pol->mode == MPOL_INTERLEAVE)
>> +		goto out_put;
>> +#endif
>> +
>> +	/*
>> +	 * Do a speculative lookup of the PTE entry.
>> +	 */
>> +	local_irq_disable();
>> +	pgd = pgd_offset(mm, address);
>> +	pgdval = READ_ONCE(*pgd);
>> +	if (pgd_none(pgdval) || unlikely(pgd_bad(pgdval)))
>> +		goto out_walk;
>> +
>> +	p4d = p4d_offset(pgd, address);
>> +	p4dval = READ_ONCE(*p4d);
>> +	if (p4d_none(p4dval) || unlikely(p4d_bad(p4dval)))
>> +		goto out_walk;
>> +
>> +	vmf.pud = pud_offset(p4d, address);
>> +	pudval = READ_ONCE(*vmf.pud);
>> +	if (pud_none(pudval) || unlikely(pud_bad(pudval)))
>> +		goto out_walk;
>> +
>> +	/* Huge pages at PUD level are not supported. */
>> +	if (unlikely(pud_trans_huge(pudval)))
>> +		goto out_walk;
>> +
>> +	vmf.pmd = pmd_offset(vmf.pud, address);
>> +	vmf.orig_pmd = READ_ONCE(*vmf.pmd);
>> +	/*
>> +	 * pmd_none could mean that a hugepage collapse is in progress
>> +	 * in our back as collapse_huge_page() mark it before
>> +	 * invalidating the pte (which is done once the IPI is catched
>> +	 * by all CPU and we have interrupt disabled).
>> +	 * For this reason we cannot handle THP in a speculative way since we
>> +	 * can't safely identify an in progress collapse operation done in our
>> +	 * back on that PMD.
>> +	 * Regarding the order of the following checks, see comment in
>> +	 * pmd_devmap_trans_unstable()
>> +	 */
>> +	if (unlikely(pmd_devmap(vmf.orig_pmd) ||
>> +		     pmd_none(vmf.orig_pmd) || pmd_trans_huge(vmf.orig_pmd) ||
>> +		     is_swap_pmd(vmf.orig_pmd)))
>> +		goto out_walk;
>> +
>> +	/*
>> +	 * The above does not allocate/instantiate page-tables because doing so
>> +	 * would lead to the possibility of instantiating page-tables after
>> +	 * free_pgtables() -- and consequently leaking them.
>> +	 *
>> +	 * The result is that we take at least one !speculative fault per PMD
>> +	 * in order to instantiate it.
>> +	 */
>> +
>> +	vmf.pte = pte_offset_map(vmf.pmd, address);
>> +	vmf.orig_pte = READ_ONCE(*vmf.pte);
>> +	barrier(); /* See comment in handle_pte_fault() */
>> +	if (pte_none(vmf.orig_pte)) {
>> +		pte_unmap(vmf.pte);
>> +		vmf.pte = NULL;
>> +	}
>> +
>> +	vmf.vma = vma;
>> +	vmf.pgoff = linear_page_index(vma, address);
>> +	vmf.gfp_mask = __get_fault_gfp_mask(vma);
>> +	vmf.sequence = seq;
>> +	vmf.flags = flags;
>> +
>> +	local_irq_enable();
>> +
>> +	/*
>> +	 * We need to re-validate the VMA after checking the bounds, otherwise
>> +	 * we might have a false positive on the bounds.
>> +	 */
>> +	if (read_seqcount_retry(&vma->vm_sequence, seq))
>> +		goto out_put;
>> +
>> +	mem_cgroup_enter_user_fault();
>> +	ret = handle_pte_fault(&vmf);
>> +	mem_cgroup_exit_user_fault();
>> +
>> +	put_vma(vma);
>> +
>> +	/*
>> +	 * The task may have entered a memcg OOM situation but
>> +	 * if the allocation error was handled gracefully (no
>> +	 * VM_FAULT_OOM), there is no need to kill anything.
>> +	 * Just clean up the OOM state peacefully.
>> +	 */
>> +	if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
>> +		mem_cgroup_oom_synchronize(false);
>> +	return ret;
>> +
>> +out_walk:
>> +	local_irq_enable();
>> +out_put:
>> +	put_vma(vma);
>> +	return ret;
>> +}
>> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
>> +
>>   /*
>>    * By the time we get here, we already hold the mm semaphore
>>    *
>> -- 
>> 2.21.0
>>
> 

