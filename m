Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55167C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:11:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DD412075A
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:11:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DD412075A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DCF16B0003; Mon, 22 Apr 2019 16:11:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B4706B0006; Mon, 22 Apr 2019 16:11:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CB346B0007; Mon, 22 Apr 2019 16:11:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5B76B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 16:11:34 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id t67so6004887qkd.15
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 13:11:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=7Izj+DWXH3+Wsi34otsLo96Ls123Pc9kPSHyJW0hfAY=;
        b=ry2om7G6o9dtT2kbvZkJMvPHhiWn5edMxuQ1laX5Qfid1xhwl945pKSekNHwSoenR7
         WIsi8t5gLu17M1m2lAvUlNYDeK2nNO2jp8pbIcs3uQCQ6jNY6Xc8MCNabSA0q/D98T1X
         3rhfNKpYQIMgvWcc1FBCOJ8bqPO4DlKT1zapYBAwpjxcA7/UkciShKEaHIQFrP43kogm
         JaLaGhOOSe5QXJkt7Cvo3pNGN/REpyDVg5CS4zFPDg3AtRwsK5TQaUSOiwNPXBQ2VA+X
         gFRol+mkp8q2c/zE2ZjYpPJK6Zm9bznNf8qnhF/NOE+PPdrC5LLFRJ1zjIhfGy2++Ljz
         FFEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXECs3QyS1CznSNJYOcsdpBUdgN4usZUSVe5ZDD2+l9VN0+Cy6V
	LfnX1JZOCGxMkJlTMD+Waur82dxzHXgFtelwXLDICZCVR+VByszoTIIifzVihoV6ozqCfiI1JMv
	8iW08sI9z+/7Qcdkbbf5pyajY1p4SrnQvSA46ZatAV5X9gfwDTPXX+X07RaV8+zJppw==
X-Received: by 2002:aed:35db:: with SMTP id d27mr4608137qte.251.1555963894211;
        Mon, 22 Apr 2019 13:11:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMrgQzlUrj6LiBrMKgHyMJ0hWyaD4SsAaRGsXYBNuGGTJDTnujYjrtjILQkZmHNyqblceo
X-Received: by 2002:aed:35db:: with SMTP id d27mr4608053qte.251.1555963893431;
        Mon, 22 Apr 2019 13:11:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555963893; cv=none;
        d=google.com; s=arc-20160816;
        b=nwg7dTj8v9L72i48t+ove09cPX+lBxJ3hb4ZLwhSjk75xx43Q/oNsQ9cPlSNmObBSs
         uktwWJ5t5eLrUi4KGExlL+Km3WrjqWUF+AxD8tk10sN6ZXF9CZJMkJRHFddPSkElgNBm
         eNn9qlk5n1LsnxFpEbJmwuoSBYUXqV+RJzBi+D5WUR1lk9tLnyS3k5MQd8npnCxgNI3p
         YiHqaS3okansDxufJWqkUxYtyIBvwBqUKNZMZLC4TVuVsD+zx46P1xdiYtIV9NgoKR+B
         SloVi0sbes0VE0D3fEiz+tNZYDpGnEMqOiVDTb+DvOfjnWuX/xvSDCwkSmVgNmmFKWbN
         lvXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=7Izj+DWXH3+Wsi34otsLo96Ls123Pc9kPSHyJW0hfAY=;
        b=FqrYjxJJq7nm0lrrwkB1on6H6em/oJNw2sNYbk8LnV+weD2oMiH7roAMWj8o921Guf
         20DDvxHeXix0yT7itm0c0Sxj0ENIN3qZ2qbOP+6ZmwDWiOTOBa23B45kEhsXKRIL/lmY
         +6kmAU01WE9qcsCw2RsOE5HuPi6rCMtV6APQ5taDowqaBGHRUqTRowvBRfjVfU3nDsti
         H9/nT+OoMlvhNjpkOgeQ5odesxZWGfwkrpGuy6yOW5HcP4i6V/xnf9bqZLQzGu0uQ9Sj
         ALn6QTGB5zwblGSTJDs1giDZvLFdgW53xBG/XyREnMplkNdBpTj/lRDiwHBBjjkZ9sl7
         2YUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v25si8318975qtc.297.2019.04.22.13.11.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 13:11:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3F1AFC13070F;
	Mon, 22 Apr 2019 20:11:32 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 9B7F05D9D4;
	Mon, 22 Apr 2019 20:11:28 +0000 (UTC)
Date: Mon, 22 Apr 2019 16:11:26 -0400
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
Subject: Re: [PATCH v12 15/31] mm: introduce
 __lru_cache_add_active_or_unevictable
Message-ID: <20190422201126.GF14666@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-16-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-16-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 22 Apr 2019 20:11:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:45:06PM +0200, Laurent Dufour wrote:
> The speculative page fault handler which is run without holding the
> mmap_sem is calling lru_cache_add_active_or_unevictable() but the vm_flags
> is not guaranteed to remain constant.
> Introducing __lru_cache_add_active_or_unevictable() which has the vma flags
> value parameter instead of the vma pointer.
> 
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/linux/swap.h | 10 ++++++++--
>  mm/memory.c          |  8 ++++----
>  mm/swap.c            |  6 +++---
>  3 files changed, 15 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 4bfb5c4ac108..d33b94eb3c69 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -343,8 +343,14 @@ extern void deactivate_file_page(struct page *page);
>  extern void mark_page_lazyfree(struct page *page);
>  extern void swap_setup(void);
>  
> -extern void lru_cache_add_active_or_unevictable(struct page *page,
> -						struct vm_area_struct *vma);
> +extern void __lru_cache_add_active_or_unevictable(struct page *page,
> +						unsigned long vma_flags);
> +
> +static inline void lru_cache_add_active_or_unevictable(struct page *page,
> +						struct vm_area_struct *vma)
> +{
> +	return __lru_cache_add_active_or_unevictable(page, vma->vm_flags);
> +}
>  
>  /* linux/mm/vmscan.c */
>  extern unsigned long zone_reclaimable_pages(struct zone *zone);
> diff --git a/mm/memory.c b/mm/memory.c
> index 56802850e72c..85ec5ce5c0a8 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2347,7 +2347,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
>  		ptep_clear_flush_notify(vma, vmf->address, vmf->pte);
>  		page_add_new_anon_rmap(new_page, vma, vmf->address, false);
>  		mem_cgroup_commit_charge(new_page, memcg, false, false);
> -		lru_cache_add_active_or_unevictable(new_page, vma);
> +		__lru_cache_add_active_or_unevictable(new_page, vmf->vma_flags);
>  		/*
>  		 * We call the notify macro here because, when using secondary
>  		 * mmu page tables (such as kvm shadow page tables), we want the
> @@ -2896,7 +2896,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  	if (unlikely(page != swapcache && swapcache)) {
>  		page_add_new_anon_rmap(page, vma, vmf->address, false);
>  		mem_cgroup_commit_charge(page, memcg, false, false);
> -		lru_cache_add_active_or_unevictable(page, vma);
> +		__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
>  	} else {
>  		do_page_add_anon_rmap(page, vma, vmf->address, exclusive);
>  		mem_cgroup_commit_charge(page, memcg, true, false);
> @@ -3048,7 +3048,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
>  	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
>  	page_add_new_anon_rmap(page, vma, vmf->address, false);
>  	mem_cgroup_commit_charge(page, memcg, false, false);
> -	lru_cache_add_active_or_unevictable(page, vma);
> +	__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
>  setpte:
>  	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, entry);
>  
> @@ -3327,7 +3327,7 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
>  		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
>  		page_add_new_anon_rmap(page, vma, vmf->address, false);
>  		mem_cgroup_commit_charge(page, memcg, false, false);
> -		lru_cache_add_active_or_unevictable(page, vma);
> +		__lru_cache_add_active_or_unevictable(page, vmf->vma_flags);
>  	} else {
>  		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
>  		page_add_file_rmap(page, false);
> diff --git a/mm/swap.c b/mm/swap.c
> index 3a75722e68a9..a55f0505b563 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -450,12 +450,12 @@ void lru_cache_add(struct page *page)
>   * directly back onto it's zone's unevictable list, it does NOT use a
>   * per cpu pagevec.
>   */
> -void lru_cache_add_active_or_unevictable(struct page *page,
> -					 struct vm_area_struct *vma)
> +void __lru_cache_add_active_or_unevictable(struct page *page,
> +					   unsigned long vma_flags)
>  {
>  	VM_BUG_ON_PAGE(PageLRU(page), page);
>  
> -	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
> +	if (likely((vma_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
>  		SetPageActive(page);
>  	else if (!TestSetPageMlocked(page)) {
>  		/*
> -- 
> 2.21.0
> 

