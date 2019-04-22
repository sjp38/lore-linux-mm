Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D7ECC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:19:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FAA020811
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:19:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FAA020811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4B666B0003; Mon, 22 Apr 2019 16:19:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FB726B0006; Mon, 22 Apr 2019 16:19:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C4826B0007; Mon, 22 Apr 2019 16:19:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4D56B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 16:19:05 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id o34so12788862qte.5
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 13:19:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=SDK/enqLyrKpuOp0PMo1eZ2TiWUqDDo7E4INs3FtGZ8=;
        b=UUxabP32kLDwZg8hEC8+cGI0vCHYGNOuCYzl/rEltzBnhBOQF9JQAIDL/fWn7fqKB0
         TNkFHVl3PPw8nBuW7TJ6SlaPV7JI8gs+vftxwL5WF6lgwTdaeNWgt86nXht5YiDfPYzh
         Q7pGbL+rVz+EdVMvySocE796sCa5IeBOii/gVoRUjKv84LRMdauYpYnJHZGf/WgTdpiU
         +nSQLHTJdT8hgL8wcCVnW0JaIdZUwXPweyWxFtNdCUeTjS/bpGZnS3YwxT2qJnVxp0Ea
         Ab8f18wBmIBygzV4Vw6mFy22y6Z4EPSOoTYoj3Qd91zVTuMMYYYVfZgNfwT6QEwyp+pT
         onDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXB+//L1TpDXi6lCo4+p+xQKYoqZekdeqd7AiHWoX/+KLnZVhcJ
	39lNOi44MkyRk3N8ObJUJMdDTMDdlri6GoFUxQxDypF3EP2TraRXufIA1fiOiP6FwktCvi99oqd
	bNUQak/w8nHmndCrjrHFLx8EIPFfipbM0jLcNEVKJl4XWy+fQbPXLmFgKBuMXJsm0oQ==
X-Received: by 2002:ac8:8d4:: with SMTP id y20mr17880896qth.13.1555964345171;
        Mon, 22 Apr 2019 13:19:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrl+/d/PzFunRBdcfOhTgvRIVE4KzTLnyIav4y0iLFD5/LKEJJLaO58EsFW/jHJ0XyQhUw
X-Received: by 2002:ac8:8d4:: with SMTP id y20mr17880841qth.13.1555964344404;
        Mon, 22 Apr 2019 13:19:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555964344; cv=none;
        d=google.com; s=arc-20160816;
        b=Setat2LIiX5aRorrrTYFnpR/cWRcXwux+niqjErd4RgEKRvQdtwsj1wu0XNYdd09CY
         K9MUzmO7O/XGziMuikX6QZeUnXBgLBdh5UIeZgBYvLtWBPJmjFGTohKB6E3ZOjAmbRsD
         QJk84oRrEljCzOR7nmzCIaYOU5HFsDPMQ4NQTK8np33yfeF+90ayDeMFoOE8gnSD/DBZ
         9cTGsA+ehq3lhxhVtEDQpXEWmkQBC3uD5YxcwxfgVI5CLpfruQYaXGiI1KSWrkgzi0bj
         NXafSbxdzveZS/MY7S2H/N2y40SjhNHkqScxZBGBhekt8pDiXA0JepkvAU5YBCgRxhlT
         dZ8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=SDK/enqLyrKpuOp0PMo1eZ2TiWUqDDo7E4INs3FtGZ8=;
        b=jnbHrgQN6GYlhMKUeO0lAsHEuHhbCiPTwmgdGts33EXduuOkJVxuK1/aPoyicbgnGm
         OyKpLqUB51pgrU6EzG83F358qtWGmHkE0GnJI4Y9Ro+agWYPp55GWEHAC0dDHBaqnzBv
         kgkP7D3vFn+Jz958SbCF8pCqmZpZaTV3fxbGqErJusF36sEKMx4q5kKFs95ucPWZjFcP
         RnJ9ak+1BYBU2tzTJPuzwA/331+ghEbVIbiK0aWrmvEtl+wNqrulu81sQ91mr+seNPaK
         cGxWMrDn4F3yM9kGKc3YymueW7+r3Qr36aiYJIgKaSjWZSaygcNY+kkEkW1zNqFSzJnT
         L2nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o15si1169729qtq.388.2019.04.22.13.19.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 13:19:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EFE9E83F3D;
	Mon, 22 Apr 2019 20:19:02 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4B40F6013B;
	Mon, 22 Apr 2019 20:18:59 +0000 (UTC)
Date: Mon, 22 Apr 2019 16:18:57 -0400
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
Subject: Re: [PATCH v12 17/31] mm: introduce __page_add_new_anon_rmap()
Message-ID: <20190422201857.GH14666@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-18-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-18-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 22 Apr 2019 20:19:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:45:08PM +0200, Laurent Dufour wrote:
> When dealing with speculative page fault handler, we may race with VMA
> being split or merged. In this case the vma->vm_start and vm->vm_end
> fields may not match the address the page fault is occurring.
> 
> This can only happens when the VMA is split but in that case, the
> anon_vma pointer of the new VMA will be the same as the original one,
> because in __split_vma the new->anon_vma is set to src->anon_vma when
> *new = *vma.
> 
> So even if the VMA boundaries are not correct, the anon_vma pointer is
> still valid.
> 
> If the VMA has been merged, then the VMA in which it has been merged
> must have the same anon_vma pointer otherwise the merge can't be done.
> 
> So in all the case we know that the anon_vma is valid, since we have
> checked before starting the speculative page fault that the anon_vma
> pointer is valid for this VMA and since there is an anon_vma this
> means that at one time a page has been backed and that before the VMA
> is cleaned, the page table lock would have to be grab to clean the
> PTE, and the anon_vma field is checked once the PTE is locked.
> 
> This patch introduce a new __page_add_new_anon_rmap() service which
> doesn't check for the VMA boundaries, and create a new inline one
> which do the check.
> 
> When called from a page fault handler, if this is not a speculative one,
> there is a guarantee that vm_start and vm_end match the faulting address,
> so this check is useless. In the context of the speculative page fault
> handler, this check may be wrong but anon_vma is still valid as explained
> above.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/linux/rmap.h | 12 ++++++++++--
>  mm/memory.c          |  8 ++++----
>  mm/rmap.c            |  5 ++---
>  3 files changed, 16 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index 988d176472df..a5d282573093 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -174,8 +174,16 @@ void page_add_anon_rmap(struct page *, struct vm_area_struct *,
>  		unsigned long, bool);
>  void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
>  			   unsigned long, int);
> -void page_add_new_anon_rmap(struct page *, struct vm_area_struct *,
> -		unsigned long, bool);
> +void __page_add_new_anon_rmap(struct page *, struct vm_area_struct *,
> +			      unsigned long, bool);
> +static inline void page_add_new_anon_rmap(struct page *page,
> +					  struct vm_area_struct *vma,
> +					  unsigned long address, bool compound)
> +{
> +	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
> +	__page_add_new_anon_rmap(page, vma, address, compound);
> +}
> +
>  void page_add_file_rmap(struct page *, bool);
>  void page_remove_rmap(struct page *, bool);
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index be93f2c8ebe0..46f877b6abea 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2347,7 +2347,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
>  		 * thread doing COW.
>  		 */
>  		ptep_clear_flush_notify(vma, vmf->address, vmf->pte);
> -		page_add_new_anon_rmap(new_page, vma, vmf->address, false);
> +		__page_add_new_anon_rmap(new_page, vma, vmf->address, false);
>  		mem_cgroup_commit_charge(new_page, memcg, false, false);
>  		__lru_cache_add_active_or_unevictable(new_page, vmf->vma_flags);
>  		/*
> @@ -2897,7 +2897,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  
>  	/* ksm created a completely new copy */
>  	if (unlikely(page != swapcache && swapcache)) {
> -		page_add_new_anon_rmap(page, vma, vmf->address, false);
> +		__page_add_new_anon_rmap(page, vma, vmf->address, false);
>  		mem_cgroup_commit_charge(page, memcg, false, false);
>  		__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
>  	} else {
> @@ -3049,7 +3049,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
>  	}
>  
>  	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
> -	page_add_new_anon_rmap(page, vma, vmf->address, false);
> +	__page_add_new_anon_rmap(page, vma, vmf->address, false);
>  	mem_cgroup_commit_charge(page, memcg, false, false);
>  	__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
>  setpte:
> @@ -3328,7 +3328,7 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
>  	/* copy-on-write page */
>  	if (write && !(vmf->vma_flags & VM_SHARED)) {
>  		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
> -		page_add_new_anon_rmap(page, vma, vmf->address, false);
> +		__page_add_new_anon_rmap(page, vma, vmf->address, false);
>  		mem_cgroup_commit_charge(page, memcg, false, false);
>  		__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
>  	} else {
> diff --git a/mm/rmap.c b/mm/rmap.c
> index e5dfe2ae6b0d..2148e8ce6e34 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1140,7 +1140,7 @@ void do_page_add_anon_rmap(struct page *page,
>  }
>  
>  /**
> - * page_add_new_anon_rmap - add pte mapping to a new anonymous page
> + * __page_add_new_anon_rmap - add pte mapping to a new anonymous page
>   * @page:	the page to add the mapping to
>   * @vma:	the vm area in which the mapping is added
>   * @address:	the user virtual address mapped
> @@ -1150,12 +1150,11 @@ void do_page_add_anon_rmap(struct page *page,
>   * This means the inc-and-test can be bypassed.
>   * Page does not have to be locked.
>   */
> -void page_add_new_anon_rmap(struct page *page,
> +void __page_add_new_anon_rmap(struct page *page,
>  	struct vm_area_struct *vma, unsigned long address, bool compound)
>  {
>  	int nr = compound ? hpage_nr_pages(page) : 1;
>  
> -	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
>  	__SetPageSwapBacked(page);
>  	if (compound) {
>  		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> -- 
> 2.21.0
> 

