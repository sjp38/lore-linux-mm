Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61E12C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:57:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C76620693
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:57:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C76620693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91D176B0003; Mon, 22 Apr 2019 16:57:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A67E6B0006; Mon, 22 Apr 2019 16:57:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 746FB6B0007; Mon, 22 Apr 2019 16:57:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8226B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 16:57:30 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d8so11389917qkk.17
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 13:57:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=hf05psxxaozWzEt8WYwZbwgl1dkauY1r0784D+rYxgw=;
        b=Ibt2DeToi+sQeXrtWCd8mePJReMiZusIXEjHLDaAsmgkxg9QpVR5hpGipQiGFhjVx7
         ihr4YlmuWNsxf5jnIobA3pR+/Mq/YbiJS7amX444glykkhDkSbq2t4O19xOOk2bH0uD2
         It4YL0Dm89wQLRlce3erthWz9fuHPkhhTyPdhlX1ZCHdfi730HYpryvXbzKfUmLu68QO
         Nye5lYD5O6QCJqt9DRh9fH9shnK+XdxAIHLy7oEMwyMoMn6XyCxqKSmQfAMMV8Y3yoiH
         3NU0twOGbLV7HPCIsu/eozM0YHNv5qgScYh2DIQrnkXD9YiFdFP5zsfVcx8MLplHiNLw
         I78g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU2RnqJcgin/nWhT1qhIthcH/2oBv3tYthifDOLTlwAnn2d+hUn
	EM8PFgSEZYwjtX4YBPYS+qGl/hfJntwAf9hMbL9NXd8EeMW9hUN4g6y94/1LPKC7C/JRzCl/1xZ
	66f4bDotAZUF42awUX535zstSLw7cV4L35qZOBcVn09rO5LFvVjL+t8xTQ0FBYBWkig==
X-Received: by 2002:ac8:2cb0:: with SMTP id 45mr16943817qtw.92.1555966650055;
        Mon, 22 Apr 2019 13:57:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVtBc5RWj/8hNmleKIawnOQ9OGPO3/zo8Yarm+hOx7ll6JMDxA+ludJm1c5OakbIwWAUry
X-Received: by 2002:ac8:2cb0:: with SMTP id 45mr16943775qtw.92.1555966649064;
        Mon, 22 Apr 2019 13:57:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555966649; cv=none;
        d=google.com; s=arc-20160816;
        b=z4oHDW6qj8AKKg5xBZM6741hdnpdlagWGkfIyeOHixCVb1DxPOSUqZyLHvoC2d9Hls
         LmMo1k1s63zhnl1h/be1z195gGLGms6Z50Cj7DMlduTKi1pL4+A5QIXTQa1VL8RjIiVT
         O+kmin2D9AER/PwOlTzbtLu7jb2ff+tntPxFe1gpxKYI2+nVrZDMBsxj6h/9XDx3nEee
         14e677CIrgo8udQBOnQGiT39BqICwM/i4cuRyO8ZYWHVsTihQ0J1hzHY8UcF6QgXa1tx
         cihozr/4IVid1QB/nAQDPU0CqrECvk9vzTy17abRjUyykiOyUerGeZgoxHNUMw8XGWfo
         iLvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=hf05psxxaozWzEt8WYwZbwgl1dkauY1r0784D+rYxgw=;
        b=petzBiN55ztE8GcdCVunhtYgYyOFNV2lfvcZ9UbwOqJgOgK55YgdOBPJhhjj4kkDfP
         +0tl7MF03fkgfSbnxoqM5xuLTZwSOnX7Y07b8Ly6g1p7/My/J6YZO1KvLQHALgmSgQv4
         /0An8Qvyr9BZwQWt+BRnCvnkOECZqa0d7sa9gpY2NSQhBwILfRFRoIh974X90oCfrQfG
         Hool2pvDOq4BuSSubqu6tTD6OzT1cKS8/YGht07G5qCrbw3lst1XbfLZhzPKLtahNuCh
         QA7Gl3eo2Q81FzeW1PpUtrcPkgLiRWfOP3DlG83xQCOnVTevrLNaa/iXwNBMVdp2Nuac
         fbPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v24si10328577qvf.56.2019.04.22.13.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 13:57:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 57A783086214;
	Mon, 22 Apr 2019 20:57:27 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2E14117F20;
	Mon, 22 Apr 2019 20:57:23 +0000 (UTC)
Date: Mon, 22 Apr 2019 16:57:21 -0400
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
Subject: Re: [PATCH v12 21/31] mm: Introduce find_vma_rcu()
Message-ID: <20190422205721.GL14666@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-22-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-22-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Mon, 22 Apr 2019 20:57:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:45:12PM +0200, Laurent Dufour wrote:
> This allows to search for a VMA structure without holding the mmap_sem.
> 
> The search is repeated while the mm seqlock is changing and until we found
> a valid VMA.
> 
> While under the RCU protection, a reference is taken on the VMA, so the
> caller must call put_vma() once it not more need the VMA structure.
> 
> At the time a VMA is inserted in the MM RB tree, in vma_rb_insert(), a
> reference is taken to the VMA by calling get_vma().
> 
> When removing a VMA from the MM RB tree, the VMA is not release immediately
> but at the end of the RCU grace period through vm_rcu_put(). This ensures
> that the VMA remains allocated until the end the RCU grace period.
> 
> Since the vm_file pointer, if valid, is released in put_vma(), there is no
> guarantee that the file pointer will be valid on the returned VMA.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Minor comments about comment (i love recursion :)) see below.

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/linux/mm_types.h |  1 +
>  mm/internal.h            |  5 ++-
>  mm/mmap.c                | 76 ++++++++++++++++++++++++++++++++++++++--
>  3 files changed, 78 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 6a6159e11a3f..9af6694cb95d 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -287,6 +287,7 @@ struct vm_area_struct {
>  
>  #ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>  	atomic_t vm_ref_count;
> +	struct rcu_head vm_rcu;
>  #endif
>  	struct rb_node vm_rb;
>  
> diff --git a/mm/internal.h b/mm/internal.h
> index 302382bed406..1e368e4afe3c 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -55,7 +55,10 @@ static inline void put_vma(struct vm_area_struct *vma)
>  		__free_vma(vma);
>  }
>  
> -#else
> +extern struct vm_area_struct *find_vma_rcu(struct mm_struct *mm,
> +					   unsigned long addr);
> +
> +#else /* CONFIG_SPECULATIVE_PAGE_FAULT */
>  
>  static inline void get_vma(struct vm_area_struct *vma)
>  {
> diff --git a/mm/mmap.c b/mm/mmap.c
> index c106440dcae7..34bf261dc2c8 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -179,6 +179,18 @@ static inline void mm_write_sequnlock(struct mm_struct *mm)
>  {
>  	write_sequnlock(&mm->mm_seq);
>  }
> +
> +static void __vm_rcu_put(struct rcu_head *head)
> +{
> +	struct vm_area_struct *vma = container_of(head, struct vm_area_struct,
> +						  vm_rcu);
> +	put_vma(vma);
> +}
> +static void vm_rcu_put(struct vm_area_struct *vma)
> +{
> +	VM_BUG_ON_VMA(!RB_EMPTY_NODE(&vma->vm_rb), vma);
> +	call_rcu(&vma->vm_rcu, __vm_rcu_put);
> +}
>  #else
>  static inline void mm_write_seqlock(struct mm_struct *mm)
>  {
> @@ -190,6 +202,8 @@ static inline void mm_write_sequnlock(struct mm_struct *mm)
>  
>  void __free_vma(struct vm_area_struct *vma)
>  {
> +	if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT))
> +		VM_BUG_ON_VMA(!RB_EMPTY_NODE(&vma->vm_rb), vma);
>  	mpol_put(vma_policy(vma));
>  	vm_area_free(vma);
>  }
> @@ -197,11 +211,24 @@ void __free_vma(struct vm_area_struct *vma)
>  /*
>   * Close a vm structure and free it, returning the next.
>   */
> -static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
> +static struct vm_area_struct *__remove_vma(struct vm_area_struct *vma)
>  {
>  	struct vm_area_struct *next = vma->vm_next;
>  
>  	might_sleep();
> +	if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT) &&
> +	    !RB_EMPTY_NODE(&vma->vm_rb)) {
> +		/*
> +		 * If the VMA is still linked in the RB tree, we must release
> +		 * that reference by calling put_vma().
> +		 * This should only happen when called from exit_mmap().
> +		 * We forcely clear the node to satisfy the chec in
                                                        ^
Typo: chec -> check

> +		 * __free_vma(). This is safe since the RB tree is not walked
> +		 * anymore.
> +		 */
> +		RB_CLEAR_NODE(&vma->vm_rb);
> +		put_vma(vma);
> +	}
>  	if (vma->vm_ops && vma->vm_ops->close)
>  		vma->vm_ops->close(vma);
>  	if (vma->vm_file)
> @@ -211,6 +238,13 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
>  	return next;
>  }
>  
> +static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
> +{
> +	if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT))
> +		VM_BUG_ON_VMA(!RB_EMPTY_NODE(&vma->vm_rb), vma);

Adding a comment here explaining the BUG_ON so people can understand
what is wrong if that happens. For instance:

/*
 * remove_vma() should be call only once a vma have been remove from the rbtree
 * at which point the vma->vm_rb is an empty node. The exception is when vmas
 * are destroy through exit_mmap() in which case we do not bother updating the
 * rbtree (see comment in __remove_vma()).
 */

> +	return __remove_vma(vma);
> +}
> +
>  static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long flags,
>  		struct list_head *uf);
>  SYSCALL_DEFINE1(brk, unsigned long, brk)
> @@ -475,7 +509,7 @@ static inline void vma_rb_insert(struct vm_area_struct *vma,
>  
>  	/* All rb_subtree_gap values must be consistent prior to insertion */
>  	validate_mm_rb(root, NULL);
> -
> +	get_vma(vma);
>  	rb_insert_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
>  }
>  
> @@ -491,6 +525,14 @@ static void __vma_rb_erase(struct vm_area_struct *vma, struct mm_struct *mm)
>  	mm_write_seqlock(mm);
>  	rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
>  	mm_write_sequnlock(mm);	/* wmb */
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	/*
> +	 * Ensure the removal is complete before clearing the node.
> +	 * Matched by vma_has_changed()/handle_speculative_fault().
> +	 */
> +	RB_CLEAR_NODE(&vma->vm_rb);
> +	vm_rcu_put(vma);
> +#endif
>  }
>  
>  static __always_inline void vma_rb_erase_ignore(struct vm_area_struct *vma,
> @@ -2331,6 +2373,34 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
>  
>  EXPORT_SYMBOL(find_vma);
>  
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +/*
> + * Like find_vma() but under the protection of RCU and the mm sequence counter.
> + * The vma returned has to be relaesed by the caller through the call to
> + * put_vma()
> + */
> +struct vm_area_struct *find_vma_rcu(struct mm_struct *mm, unsigned long addr)
> +{
> +	struct vm_area_struct *vma = NULL;
> +	unsigned int seq;
> +
> +	do {
> +		if (vma)
> +			put_vma(vma);
> +
> +		seq = read_seqbegin(&mm->mm_seq);
> +
> +		rcu_read_lock();
> +		vma = find_vma(mm, addr);
> +		if (vma)
> +			get_vma(vma);
> +		rcu_read_unlock();
> +	} while (read_seqretry(&mm->mm_seq, seq));
> +
> +	return vma;
> +}
> +#endif
> +
>  /*
>   * Same as find_vma, but also return a pointer to the previous VMA in *pprev.
>   */
> @@ -3231,7 +3301,7 @@ void exit_mmap(struct mm_struct *mm)
>  	while (vma) {
>  		if (vma->vm_flags & VM_ACCOUNT)
>  			nr_accounted += vma_pages(vma);
> -		vma = remove_vma(vma);
> +		vma = __remove_vma(vma);
>  	}
>  	vm_unacct_memory(nr_accounted);
>  }
> -- 
> 2.21.0
> 

