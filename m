Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA7C6C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:10:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9786E20693
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:10:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9786E20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4469A6B0005; Thu, 18 Apr 2019 18:10:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F2F96B0006; Thu, 18 Apr 2019 18:10:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27AA96B0007; Thu, 18 Apr 2019 18:10:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00BBB6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 18:10:13 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d49so3289277qtk.8
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:10:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=DBNfdHjVlyltMJlh/rgdrOde7mCb3PJbhT2ulMO54l8=;
        b=U7DGKAXY1m4BH/ZumP//FChEGX8AkSjbh5GoYUmwKbpStmH5ai426JzHBAnSQZ+ljo
         E5yCESvLeUJ5jMudD1iC7e68VL09PK7rUfl2O2/FFmIfkE94OFXIZ7iYw6NTr7HNAuhK
         4wNwMbJQaFbKqFpILycLCiyFJPdO32xayuO+2pyw7nc6sHdJvZcvplzkstVnLH11l/0z
         PqQkARWLVchlNU9qbTzaZfCOQ8BpFCnBas4ODpuDy98e97k0qHKFx23TS8dqyONCwPPb
         YHXNMrZk0kQHrVHJdVnh1Guzj+EJCSMFVvQnawym0NuFUcwjGiif5/GLvUpJR2fK5kWQ
         /bmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVRX8rM8JsUEs8m2RdGJnZjdGKlMdxwvR9ip8vNRUGLR9H3wEoN
	R4dN/oD+2VYbzTzaBHQb9n8KvBq0AsQlt/tAU1bzdKUaFa1uvMQkRq6B/hh/n1irFVpUmzRFMOm
	BqyXANeKlW/nGm0LqFCvShMKJF8noJ7JqTDLb1iBMS+dfALONYjvnppLS+OTOaJ9XAQ==
X-Received: by 2002:ac8:3113:: with SMTP id g19mr450413qtb.356.1555625412762;
        Thu, 18 Apr 2019 15:10:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytwIKEa5iUb07FrJqQPpyZYg1osKgxcy2NYSU4W6kfcb3HdcKqoeeV1ySW5+eF8I3B8su7
X-Received: by 2002:ac8:3113:: with SMTP id g19mr450348qtb.356.1555625411994;
        Thu, 18 Apr 2019 15:10:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555625411; cv=none;
        d=google.com; s=arc-20160816;
        b=pGaI+EOVHMNANJkgW5wGpyZjxDi6qgL3DBSvRYuuNxM0uXhi7CCz0/qVdD54eW4J3r
         XriYOB0V8MZJAiDh4XAmLHhH9RzJ3obcr1XlDOvs4mp9eUeWYC5Dc7kLTEa3ALNXeq1z
         22xLy86E5RlrG+xi+LAPbYkpZAOkatwEwZRHW0Nq9bnUZuH4xONgNfWiXJ6MRMiWqb9h
         szZl7/e9BlfJHnrqIXEQVryQooVKZnCp7uiQ98hCvSjg+vSlcNy+iaIqY8TN3R5/Eve7
         Ew+2eGyb1iAk7IVgLrxBqOFSKEGK9oeKeHCmJWUhCmdxTV3e8gpBXXFax/kcSnwdrLho
         4OWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=DBNfdHjVlyltMJlh/rgdrOde7mCb3PJbhT2ulMO54l8=;
        b=XhKJFsbBhODkwWIQ0j9BZ7kl8M0w6CageKY8gXoQf6IKjfSm4N8S0TmG08KYvXnTTQ
         0ft3ED2EFEq2zo5yJ9DiCBf6mOL+UXEtfiZg4s1XuGPg9QdeLgoG4NX+BpwY2zsyPpfX
         b3zSWW6KELYHhgmclHYhJuZTBpvnIp5xrchVc6hOjKaMX2RfNXjVLHGSDf3AWdLXktW4
         v3wDqaz7LpRck5uljtng35nAKhRSbeVVIOiAblok0enBaf1eE94N4X/bfBxuk8DRWsJ9
         VCC2AdmbJQGWx5L57Jeafer9hwrFlaXEf8qE+RYvbLTZGCqBC5YK0KQdmegZ8RO76P9J
         knRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 33si527560qvm.72.2019.04.18.15.10.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 15:10:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7F87370D6B;
	Thu, 18 Apr 2019 22:10:10 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A571C5D70A;
	Thu, 18 Apr 2019 22:10:06 +0000 (UTC)
Date: Thu, 18 Apr 2019 18:10:04 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
	kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
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
Subject: Re: [PATCH v12 07/31] mm: make pte_unmap_same compatible with SPF
Message-ID: <20190418221004.GG11645@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-8-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-8-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 18 Apr 2019 22:10:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:44:58PM +0200, Laurent Dufour wrote:
> pte_unmap_same() is making the assumption that the page table are still
> around because the mmap_sem is held.
> This is no more the case when running a speculative page fault and
> additional check must be made to ensure that the final page table are still
> there.
> 
> This is now done by calling pte_spinlock() to check for the VMA's
> consistency while locking for the page tables.
> 
> This is requiring passing a vm_fault structure to pte_unmap_same() which is
> containing all the needed parameters.
> 
> As pte_spinlock() may fail in the case of a speculative page fault, if the
> VMA has been touched in our back, pte_unmap_same() should now return 3
> cases :
> 	1. pte are the same (0)
> 	2. pte are different (VM_FAULT_PTNOTSAME)
> 	3. a VMA's changes has been detected (VM_FAULT_RETRY)
> 
> The case 2 is handled by the introduction of a new VM_FAULT flag named
> VM_FAULT_PTNOTSAME which is then trapped in cow_user_page().
> If VM_FAULT_RETRY is returned, it is passed up to the callers to retry the
> page fault while holding the mmap_sem.
> 
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>


> ---
>  include/linux/mm_types.h |  6 +++++-
>  mm/memory.c              | 37 +++++++++++++++++++++++++++----------
>  2 files changed, 32 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 8ec38b11b361..fd7d38ee2e33 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -652,6 +652,8 @@ typedef __bitwise unsigned int vm_fault_t;
>   * @VM_FAULT_NEEDDSYNC:		->fault did not modify page tables and needs
>   *				fsync() to complete (for synchronous page faults
>   *				in DAX)
> + * @VM_FAULT_PTNOTSAME		Page table entries have changed during a
> + *				speculative page fault handling.
>   * @VM_FAULT_HINDEX_MASK:	mask HINDEX value
>   *
>   */
> @@ -669,6 +671,7 @@ enum vm_fault_reason {
>  	VM_FAULT_FALLBACK       = (__force vm_fault_t)0x000800,
>  	VM_FAULT_DONE_COW       = (__force vm_fault_t)0x001000,
>  	VM_FAULT_NEEDDSYNC      = (__force vm_fault_t)0x002000,
> +	VM_FAULT_PTNOTSAME	= (__force vm_fault_t)0x004000,
>  	VM_FAULT_HINDEX_MASK    = (__force vm_fault_t)0x0f0000,
>  };
>  
> @@ -693,7 +696,8 @@ enum vm_fault_reason {
>  	{ VM_FAULT_RETRY,               "RETRY" },	\
>  	{ VM_FAULT_FALLBACK,            "FALLBACK" },	\
>  	{ VM_FAULT_DONE_COW,            "DONE_COW" },	\
> -	{ VM_FAULT_NEEDDSYNC,           "NEEDDSYNC" }
> +	{ VM_FAULT_NEEDDSYNC,           "NEEDDSYNC" },	\
> +	{ VM_FAULT_PTNOTSAME,		"PTNOTSAME" }
>  
>  struct vm_special_mapping {
>  	const char *name;	/* The name, e.g. "[vdso]". */
> diff --git a/mm/memory.c b/mm/memory.c
> index 221ccdf34991..d5bebca47d98 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2094,21 +2094,29 @@ static inline bool pte_map_lock(struct vm_fault *vmf)
>   * parts, do_swap_page must check under lock before unmapping the pte and
>   * proceeding (but do_wp_page is only called after already making such a check;
>   * and do_anonymous_page can safely check later on).
> + *
> + * pte_unmap_same() returns:
> + *	0			if the PTE are the same
> + *	VM_FAULT_PTNOTSAME	if the PTE are different
> + *	VM_FAULT_RETRY		if the VMA has changed in our back during
> + *				a speculative page fault handling.
>   */
> -static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
> -				pte_t *page_table, pte_t orig_pte)
> +static inline vm_fault_t pte_unmap_same(struct vm_fault *vmf)
>  {
> -	int same = 1;
> +	int ret = 0;
> +
>  #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
>  	if (sizeof(pte_t) > sizeof(unsigned long)) {
> -		spinlock_t *ptl = pte_lockptr(mm, pmd);
> -		spin_lock(ptl);
> -		same = pte_same(*page_table, orig_pte);
> -		spin_unlock(ptl);
> +		if (pte_spinlock(vmf)) {
> +			if (!pte_same(*vmf->pte, vmf->orig_pte))
> +				ret = VM_FAULT_PTNOTSAME;
> +			spin_unlock(vmf->ptl);
> +		} else
> +			ret = VM_FAULT_RETRY;
>  	}
>  #endif
> -	pte_unmap(page_table);
> -	return same;
> +	pte_unmap(vmf->pte);
> +	return ret;
>  }
>  
>  static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
> @@ -2714,8 +2722,17 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  	int exclusive = 0;
>  	vm_fault_t ret = 0;
>  
> -	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
> +	ret = pte_unmap_same(vmf);
> +	if (ret) {
> +		/*
> +		 * If pte != orig_pte, this means another thread did the
> +		 * swap operation in our back.
> +		 * So nothing else to do.
> +		 */
> +		if (ret == VM_FAULT_PTNOTSAME)
> +			ret = 0;
>  		goto out;
> +	}
>  
>  	entry = pte_to_swp_entry(vmf->orig_pte);
>  	if (unlikely(non_swap_entry(entry))) {
> -- 
> 2.21.0
> 

