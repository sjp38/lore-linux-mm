Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12FF0C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:36:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1BCE20859
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:36:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1BCE20859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F8CC6B0006; Mon, 22 Apr 2019 16:36:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A8A66B0007; Mon, 22 Apr 2019 16:36:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 470626B0008; Mon, 22 Apr 2019 16:36:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 228786B0006
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 16:36:55 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id c22so2510310qtk.10
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 13:36:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=D3+m21ih45NvqPnfBe5l9rY8WEBQ+TUJxM2mfrOLCdM=;
        b=WJCUhjjEogeXMWcNjwIBm6zvGvasBZnhxiTaImFvWrAcWLRrH3jhGve/t3XfDIZWHB
         EGw9fh8AIefVg4W5XCLGVqatRS+THAiGfbO+RUMP/xs3WjPLaB5qZy1vlvX6UoSp2592
         VXbtTOrbbQUJYisLbTCGtFM0UG1e2gItcEHv45IguFSCLycF8ImMPGmBW1wTbZ68mrbr
         1l5c05i/Ph3lSwPe2kz9V5kqljs4PTE0k4yy1R/4Ofz+xsLgHqZVDoj6MGneqfTKTFFD
         hX1qULuY/J0e++lJzeF4vC2vHUBe/EsAsIEOClBKhGDTSilXYRT6yoqrjLb4PS3Kk3Fx
         PGLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWHAsoS5o+Z4N4IfUkJdoybe6d/f6xb1k0NieZugIiZXrC7XhQN
	FlWDhSYM3Xl7GPep+M9Mqv15Zy8+5F84dIpD1idkC9RZVqlRopyKbFICNjQQPCknoe7dx+oI07Y
	Ubj7dhQOHwtw9ZQMRN8UdaGkM1Wq/oSc3AtiuDYP9kf/FfDkJBuFlL2wxv1KAzMAjLw==
X-Received: by 2002:a0c:ae7c:: with SMTP id z57mr17710311qvc.244.1555965414881;
        Mon, 22 Apr 2019 13:36:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw44EKJJIaehC8MR2noRpldtz0xr6Qs6358xtEX2H842aBPkyEFDb7BURu4pmoTcLIRp2oq
X-Received: by 2002:a0c:ae7c:: with SMTP id z57mr17710271qvc.244.1555965414123;
        Mon, 22 Apr 2019 13:36:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555965414; cv=none;
        d=google.com; s=arc-20160816;
        b=vO5x43Qep+KaCyobKMugVo4SGEOOLGJ2EIe20MVgBXBat8s3GhtADtZKPBw0ihSorz
         rJj9F1Yq9GKjfLfKGQCRSnDDSD1WgkGm57nGOxGiA/zfIIID6Ieh1Jnhzog/KRdfks/q
         lEyjQd/AuuFsIhWgE0RIdkgvIzcfI4uUzs8O3eoIcqMuwVUX8OegXQ+YsRQKgMnGoRR3
         3M/Mw9jl5z0kS7kTnwC5qPh/eTcV2RghdN3csc46j/WXV8IsEOoc1k+j9zZKnkwONY3f
         qmbvbGDHxVY7Osnr0FiJHY98HyhX/2USHDupNfxmb9sNpSslziLWhnxvic+0Mq1pWNcw
         2dWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=D3+m21ih45NvqPnfBe5l9rY8WEBQ+TUJxM2mfrOLCdM=;
        b=yfRBOu5+/hZztwGaohA4uKDuDH4rjZuzC5pwjqCgfUBb8Q+AGJekA9c+KTLtabUsSW
         +cnhH/+xfe9drsvjKYL1RXQf16OHTC7ziitR1LAP/zUL+qPrZp+KmXWaVQEPGYRj920S
         rMeJeL631yj3ELFrq2nB3+TTKt6tTEjSUBSj0uFIkO8AZKB7pGOi4WxSzU0XkD6Crx1c
         bKoo6IpbZHqWz+I1RBQNgcJtXNTFoc3c0J6xzJnDkeOXEvstqMmPdGVzYU0OdoM51K/r
         p0AXNbjFDSmvFIBpg0EXojAcntNZ7l6jsbPHBszzEr6z0jsEO4vdZhTJYuzyq04MbDsS
         fnLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a20si2880852qvd.39.2019.04.22.13.36.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 13:36:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B387D369CA;
	Mon, 22 Apr 2019 20:36:52 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 131C95C1B5;
	Mon, 22 Apr 2019 20:36:48 +0000 (UTC)
Date: Mon, 22 Apr 2019 16:36:47 -0400
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
Subject: Re: [PATCH v12 20/31] mm: introduce vma reference counter
Message-ID: <20190422203647.GK14666@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-21-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-21-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 22 Apr 2019 20:36:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:45:11PM +0200, Laurent Dufour wrote:
> The final goal is to be able to use a VMA structure without holding the
> mmap_sem and to be sure that the structure will not be freed in our back.
> 
> The lockless use of the VMA will be done through RCU protection and thus a
> dedicated freeing service is required to manage it asynchronously.
> 
> As reported in a 2010's thread [1], this may impact file handling when a
> file is still referenced while the mapping is no more there.  As the final
> goal is to handle anonymous VMA in a speculative way and not file backed
> mapping, we could close and free the file pointer in a synchronous way, as
> soon as we are guaranteed to not use it without holding the mmap_sem. For
> sanity reason, in a minimal effort, the vm_file file pointer is unset once
> the file pointer is put.
> 
> [1] https://lore.kernel.org/linux-mm/20100104182429.833180340@chello.nl/
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Using kref would have been better from my POV even with RCU freeing
but anyway:

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/linux/mm.h       |  4 ++++
>  include/linux/mm_types.h |  3 +++
>  mm/internal.h            | 27 +++++++++++++++++++++++++++
>  mm/mmap.c                | 13 +++++++++----
>  4 files changed, 43 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f14b2c9ddfd4..f761a9c65c74 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -529,6 +529,9 @@ static inline void vma_init(struct vm_area_struct *vma, struct mm_struct *mm)
>  	vma->vm_mm = mm;
>  	vma->vm_ops = &dummy_vm_ops;
>  	INIT_LIST_HEAD(&vma->anon_vma_chain);
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	atomic_set(&vma->vm_ref_count, 1);
> +#endif
>  }
>  
>  static inline void vma_set_anonymous(struct vm_area_struct *vma)
> @@ -1418,6 +1421,7 @@ static inline void INIT_VMA(struct vm_area_struct *vma)
>  	INIT_LIST_HEAD(&vma->anon_vma_chain);
>  #ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>  	seqcount_init(&vma->vm_sequence);
> +	atomic_set(&vma->vm_ref_count, 1);
>  #endif
>  }
>  
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 24b3f8ce9e42..6a6159e11a3f 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -285,6 +285,9 @@ struct vm_area_struct {
>  	/* linked list of VM areas per task, sorted by address */
>  	struct vm_area_struct *vm_next, *vm_prev;
>  
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	atomic_t vm_ref_count;
> +#endif
>  	struct rb_node vm_rb;
>  
>  	/*
> diff --git a/mm/internal.h b/mm/internal.h
> index 9eeaf2b95166..302382bed406 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -40,6 +40,33 @@ void page_writeback_init(void);
>  
>  vm_fault_t do_swap_page(struct vm_fault *vmf);
>  
> +
> +extern void __free_vma(struct vm_area_struct *vma);
> +
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +static inline void get_vma(struct vm_area_struct *vma)
> +{
> +	atomic_inc(&vma->vm_ref_count);
> +}
> +
> +static inline void put_vma(struct vm_area_struct *vma)
> +{
> +	if (atomic_dec_and_test(&vma->vm_ref_count))
> +		__free_vma(vma);
> +}
> +
> +#else
> +
> +static inline void get_vma(struct vm_area_struct *vma)
> +{
> +}
> +
> +static inline void put_vma(struct vm_area_struct *vma)
> +{
> +	__free_vma(vma);
> +}
> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
> +
>  void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>  		unsigned long floor, unsigned long ceiling);
>  
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f7f6027a7dff..c106440dcae7 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -188,6 +188,12 @@ static inline void mm_write_sequnlock(struct mm_struct *mm)
>  }
>  #endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
>  
> +void __free_vma(struct vm_area_struct *vma)
> +{
> +	mpol_put(vma_policy(vma));
> +	vm_area_free(vma);
> +}
> +
>  /*
>   * Close a vm structure and free it, returning the next.
>   */
> @@ -200,8 +206,8 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
>  		vma->vm_ops->close(vma);
>  	if (vma->vm_file)
>  		fput(vma->vm_file);
> -	mpol_put(vma_policy(vma));
> -	vm_area_free(vma);
> +	vma->vm_file = NULL;
> +	put_vma(vma);
>  	return next;
>  }
>  
> @@ -990,8 +996,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  		if (next->anon_vma)
>  			anon_vma_merge(vma, next);
>  		mm->map_count--;
> -		mpol_put(vma_policy(next));
> -		vm_area_free(next);
> +		put_vma(next);
>  		/*
>  		 * In mprotect's case 6 (see comments on vma_merge),
>  		 * we must remove another next too. It would clutter
> -- 
> 2.21.0
> 

