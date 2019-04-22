Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22F77C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:34:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5DC820859
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:33:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5DC820859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 562BD6B0006; Mon, 22 Apr 2019 16:33:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50ED16B0007; Mon, 22 Apr 2019 16:33:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AFE06B0008; Mon, 22 Apr 2019 16:33:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14C4E6B0006
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 16:33:59 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id j9so6489016qtp.17
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 13:33:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=387eashXwjQh5KAXgGCHdyJxaR2TrgnUAVU+gbo6h2Y=;
        b=MNm/sEfpO5PZsl1lE8cvbrVgvk9FpPL5kFaqNRR/8pFNnqUDUQZrEMluqp2ux64p/J
         pl6qIoptsGyNiK94/rIhAYGZs2WlUDXLB+99Jz8XQ9HioCPWIrfm1C2n0roRcndnT1A6
         of5X5h/7WmTHmn6kEtGa/nSAQJ21H06N5X+f0rcIXHM9aSZ+OPQxXju1byjpBbYdVs20
         LYPEOAyQ3ylle0ReiP73gyQQRBHGratdj1nYuSRptVDWHfjS79bj33F5/le6EEGkwplG
         oyBxLtZM0Q2wqx7FtO6wNqMJQSwlkkrJSa6Iaz8zk8IYG/bPh5yq2lTs+RZ8K9R4VKHF
         YU4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXl4xZY6MWbvwsp/hdOroa8Ft5S6HmpmrqV8G8Kg0CiGYR8Fydn
	cNE8aekSgpE3zyxIUQO0xiM9WuQVFWgXtz8mGFdfs5IzqQiqCuiusCWTAyX0gEHehKN/ygFNLkI
	6ZCsOqJhMbL/5XRP71WsqIUrEteUGgtx6c3SarqNZ1/d4uRj1EWjO0Adla8PeNV2q6g==
X-Received: by 2002:a05:620a:130f:: with SMTP id o15mr16308672qkj.252.1555965238821;
        Mon, 22 Apr 2019 13:33:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3Bt8gPtBpIyvia6XQac6q/8bGQjoa6Z4FwFYtBCmHaecC3fZVK5oXuSepzLMFaK2AeDUb
X-Received: by 2002:a05:620a:130f:: with SMTP id o15mr16308604qkj.252.1555965237838;
        Mon, 22 Apr 2019 13:33:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555965237; cv=none;
        d=google.com; s=arc-20160816;
        b=xUEHJyuHS8t/IgHdmYDoCa2DQ//rsCMedjdidc22sg9DcJFXIXESai8/t4TU1/I/Hr
         6QisvjCmrfe2H+qucMZHY2WlQcBoQntOESYkbK+K8PVtkopdek3mtmoVO8QEhtNCwHGI
         JLcHH9Y+pSFaoemqsNGZx1okjOrh0d5c/ob+Gn2zy1NnHU5baaC8FWJrWFsox4ypjago
         f5qpc1u4HVk2+Rz61y3ogvQVNb6xxMNP8xsT6cjp+1s/6Nhrn/NV7mii58t3lNq47hgq
         LpcXUts22smvMxNjHaFHAHy0lwEMtKT9WeThpibDqWkW7FOCc8UNe1qwAmaQ23M4sgg5
         JoGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=387eashXwjQh5KAXgGCHdyJxaR2TrgnUAVU+gbo6h2Y=;
        b=A0eM7PLwoYKGkL/rAVn104C62ALGiaKlq1dSGwdoXeDoO1UJ8GbnJAeCBv0XZQxUbA
         3Nw8y5TAfhqf7CwG5bgvzOoZ5oz4oJPZd0pkaMOqHmILrByw2vVVSVrk9PLnEk8tCcCL
         /h1cT+GWGj1JbBL0LirbS/mnaq9isf6d3gvQ0rd2/AzkUwBYDAJzj8hHeUSZTgHJcjpx
         7G+T1JiigL1zAs9JDlG/w3m5gq8XTcC2cimDKoD1dYwfp/Wsc0VpiFCj9WyHEN4DEq6K
         8iBjPlCvVAJzoZV0V+ujNy1k1sXR0hEIdeHwu/KH/PHAr884DiZKzhQyOdfSlc4DwvPo
         gW8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g34si3731076qve.192.2019.04.22.13.33.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 13:33:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7D15F30832EF;
	Mon, 22 Apr 2019 20:33:56 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E22545D9D4;
	Mon, 22 Apr 2019 20:33:52 +0000 (UTC)
Date: Mon, 22 Apr 2019 16:33:51 -0400
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
Subject: Re: [PATCH v12 19/31] mm: protect the RB tree with a sequence lock
Message-ID: <20190422203350.GJ14666@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-20-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-20-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 22 Apr 2019 20:33:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:45:10PM +0200, Laurent Dufour wrote:
> Introducing a per mm_struct seqlock, mm_seq field, to protect the changes
> made in the MM RB tree. This allows to walk the RB tree without grabbing
> the mmap_sem, and on the walk is done to double check that sequence counter
> was stable during the walk.
> 
> The mm seqlock is held while inserting and removing entries into the MM RB
> tree.  Later in this series, it will be check when looking for a VMA
> without holding the mmap_sem.
> 
> This is based on the initial work from Peter Zijlstra:
> https://lore.kernel.org/linux-mm/20100104182813.479668508@chello.nl/
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/linux/mm_types.h |  3 +++
>  kernel/fork.c            |  3 +++
>  mm/init-mm.c             |  3 +++
>  mm/mmap.c                | 48 +++++++++++++++++++++++++++++++---------
>  4 files changed, 46 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index e78f72eb2576..24b3f8ce9e42 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -358,6 +358,9 @@ struct mm_struct {
>  	struct {
>  		struct vm_area_struct *mmap;		/* list of VMAs */
>  		struct rb_root mm_rb;
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +		seqlock_t mm_seq;
> +#endif
>  		u64 vmacache_seqnum;                   /* per-thread vmacache */
>  #ifdef CONFIG_MMU
>  		unsigned long (*get_unmapped_area) (struct file *filp,
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 2992d2c95256..3a1739197ebc 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1008,6 +1008,9 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
>  	mm->mmap = NULL;
>  	mm->mm_rb = RB_ROOT;
>  	mm->vmacache_seqnum = 0;
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	seqlock_init(&mm->mm_seq);
> +#endif
>  	atomic_set(&mm->mm_users, 1);
>  	atomic_set(&mm->mm_count, 1);
>  	init_rwsem(&mm->mmap_sem);
> diff --git a/mm/init-mm.c b/mm/init-mm.c
> index a787a319211e..69346b883a4e 100644
> --- a/mm/init-mm.c
> +++ b/mm/init-mm.c
> @@ -27,6 +27,9 @@
>   */
>  struct mm_struct init_mm = {
>  	.mm_rb		= RB_ROOT,
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	.mm_seq		= __SEQLOCK_UNLOCKED(init_mm.mm_seq),
> +#endif
>  	.pgd		= swapper_pg_dir,
>  	.mm_users	= ATOMIC_INIT(2),
>  	.mm_count	= ATOMIC_INIT(1),
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 13460b38b0fb..f7f6027a7dff 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -170,6 +170,24 @@ void unlink_file_vma(struct vm_area_struct *vma)
>  	}
>  }
>  
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +static inline void mm_write_seqlock(struct mm_struct *mm)
> +{
> +	write_seqlock(&mm->mm_seq);
> +}
> +static inline void mm_write_sequnlock(struct mm_struct *mm)
> +{
> +	write_sequnlock(&mm->mm_seq);
> +}
> +#else
> +static inline void mm_write_seqlock(struct mm_struct *mm)
> +{
> +}
> +static inline void mm_write_sequnlock(struct mm_struct *mm)
> +{
> +}
> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
> +
>  /*
>   * Close a vm structure and free it, returning the next.
>   */
> @@ -445,26 +463,32 @@ static void vma_gap_update(struct vm_area_struct *vma)
>  }
>  
>  static inline void vma_rb_insert(struct vm_area_struct *vma,
> -				 struct rb_root *root)
> +				 struct mm_struct *mm)
>  {
> +	struct rb_root *root = &mm->mm_rb;
> +
>  	/* All rb_subtree_gap values must be consistent prior to insertion */
>  	validate_mm_rb(root, NULL);
>  
>  	rb_insert_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
>  }
>  
> -static void __vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
> +static void __vma_rb_erase(struct vm_area_struct *vma, struct mm_struct *mm)
>  {
> +	struct rb_root *root = &mm->mm_rb;
> +
>  	/*
>  	 * Note rb_erase_augmented is a fairly large inline function,
>  	 * so make sure we instantiate it only once with our desired
>  	 * augmented rbtree callbacks.
>  	 */
> +	mm_write_seqlock(mm);
>  	rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
> +	mm_write_sequnlock(mm);	/* wmb */
>  }
>  
>  static __always_inline void vma_rb_erase_ignore(struct vm_area_struct *vma,
> -						struct rb_root *root,
> +						struct mm_struct *mm,
>  						struct vm_area_struct *ignore)
>  {
>  	/*
> @@ -472,21 +496,21 @@ static __always_inline void vma_rb_erase_ignore(struct vm_area_struct *vma,
>  	 * with the possible exception of the "next" vma being erased if
>  	 * next->vm_start was reduced.
>  	 */
> -	validate_mm_rb(root, ignore);
> +	validate_mm_rb(&mm->mm_rb, ignore);
>  
> -	__vma_rb_erase(vma, root);
> +	__vma_rb_erase(vma, mm);
>  }
>  
>  static __always_inline void vma_rb_erase(struct vm_area_struct *vma,
> -					 struct rb_root *root)
> +					 struct mm_struct *mm)
>  {
>  	/*
>  	 * All rb_subtree_gap values must be consistent prior to erase,
>  	 * with the possible exception of the vma being erased.
>  	 */
> -	validate_mm_rb(root, vma);
> +	validate_mm_rb(&mm->mm_rb, vma);
>  
> -	__vma_rb_erase(vma, root);
> +	__vma_rb_erase(vma, mm);
>  }
>  
>  /*
> @@ -601,10 +625,12 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * immediately update the gap to the correct value. Finally we
>  	 * rebalance the rbtree after all augmented values have been set.
>  	 */
> +	mm_write_seqlock(mm);
>  	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
>  	vma->rb_subtree_gap = 0;
>  	vma_gap_update(vma);
> -	vma_rb_insert(vma, &mm->mm_rb);
> +	vma_rb_insert(vma, mm);
> +	mm_write_sequnlock(mm);
>  }
>  
>  static void __vma_link_file(struct vm_area_struct *vma)
> @@ -680,7 +706,7 @@ static __always_inline void __vma_unlink_common(struct mm_struct *mm,
>  {
>  	struct vm_area_struct *next;
>  
> -	vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
> +	vma_rb_erase_ignore(vma, mm, ignore);
>  	next = vma->vm_next;
>  	if (has_prev)
>  		prev->vm_next = next;
> @@ -2674,7 +2700,7 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
>  	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
>  	vma->vm_prev = NULL;
>  	do {
> -		vma_rb_erase(vma, &mm->mm_rb);
> +		vma_rb_erase(vma, mm);
>  		mm->map_count--;
>  		tail_vma = vma;
>  		vma = vma->vm_next;
> -- 
> 2.21.0
> 

