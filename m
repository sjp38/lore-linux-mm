Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EE1DC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:22:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B7E32064A
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:22:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B7E32064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE8BC6B0005; Thu, 18 Apr 2019 18:22:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E98526B0006; Thu, 18 Apr 2019 18:22:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D87AC6B0007; Thu, 18 Apr 2019 18:22:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B82EE6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 18:22:21 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id b1so3320171qtk.11
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:22:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4sXQaNqlRRTRdxOjRFxaauId6kyfzqxGAIe1B5ze7PQ=;
        b=E3mn/SAt3DeNiVUh55fgsM4b4mOH7gFndhMGNFmaeG0WaPJNKnek1+Bi38nwe7hM7x
         J251JzPgKLky4WiCK70w5TFxr+vseRg5r+C4hdEB1VHCRDNcMmpq96vKa2eiULzkjoUy
         H5G+5AhU0rBz4VMpMR7t+9npOvgnRW/zbXKiYDix9B9uIFgj3WxGyYyDSpBFjc43qUNb
         dKhD0ii+CYn+Vjnua0IQVh7ubBCWC+2uffrJ74qqhygii4g7uwxsw0ojxtoKBvGuCoOW
         G87hocrrQiI7Lk9X4TrWEwlvDPMl1h+KZeTxZiGh7rHId8UDZYnZxKkU2Gkjin8QpSqF
         TBnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW6qKkxQ0xFmrArDNkOcfHelae2nJaIQ7+pXkItu9ko/zdVA4AD
	wPG0fdJIE7iSoMTkOZtahvL+cHLc7LvXABgssA8W/hj4I51h7TRdVOpSrXDyfBvmpz+vi37dkoC
	bGqYhXbR4KLW5VXvTkXPGbbVfz3qWG5EZ7H76bV8wclrrlqrr+3rXPp1vtrcfseFXBQ==
X-Received: by 2002:ac8:2ca3:: with SMTP id 32mr543268qtw.60.1555626141518;
        Thu, 18 Apr 2019 15:22:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvebDWu6ZiSOD09hlxhPhA2GRGXbrGTQeRifGPERjf2QrDg8SFkwK+RwF+lKFIt9XjV/uQ
X-Received: by 2002:ac8:2ca3:: with SMTP id 32mr543211qtw.60.1555626140733;
        Thu, 18 Apr 2019 15:22:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555626140; cv=none;
        d=google.com; s=arc-20160816;
        b=MxCT79hhxaT8oSCes3rNRliiNVj4nN58QHgxTwmpLQr3MNsMMZeYzUZGxH42Njp+UK
         5uiwLl6F1+tDW4lsRP2EnXnq4SPvzRoCGaLV16lNokyr3nHt3qMKvR6g1X1k+8MU9i4T
         LNTFQXq5M9G5DYaUvymnRzDD8TQUEtz5q5n2H96btkxIylcoRmoQrxwW+lMzLykPt9rN
         myVT7lUqZwHINJM9TnbLkQlGa+UBYNvshd0lzZauLdlQwQ90MTFvr27LhcV0eLY25J1l
         IlhvbRf2YwdwIpwpfQPAfgfNUhhUmWzaER6HNfqJNr1pfOwNRSxogJlk2xhlYUriwq38
         uMUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4sXQaNqlRRTRdxOjRFxaauId6kyfzqxGAIe1B5ze7PQ=;
        b=xSaf1BIsxB+L2jQJnPltNP33+wHpuPiWvPsnfEkJaMKrvU9gHZ7TnxuT7eXatl/gfs
         JjDIxHHek/Vn8M7Vh4+6/dfe1UESkYJO58yXtKu/FAdxmSRziVwcvsm4/Lrt09gxpg5l
         wQIY9nykjQ0rC6kJfywAvrkpXSwZKW2JzxRfa3KDKq2khUBqda54WI2x69jdv0v3VQ5j
         9RwfDCZPHpeoX3MugK+qM5uazLlNws6F49qT/xue5ZX/hLjyq+mrdVJAPMp38wc5T9jf
         NKWep4RtHYIq2ZpfDMbtsfDulohFJg64+hIwQWDhz0KJQkmd3880Te6juRfm0CBWF5kI
         pXEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 27si2292111qvx.58.2019.04.18.15.22.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 15:22:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 05FE4C066462;
	Thu, 18 Apr 2019 22:22:19 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id ED5475D9CC;
	Thu, 18 Apr 2019 22:22:14 +0000 (UTC)
Date: Thu, 18 Apr 2019 18:22:13 -0400
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
Subject: Re: [PATCH v12 08/31] mm: introduce INIT_VMA()
Message-ID: <20190418222212.GH11645@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-9-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190416134522.17540-9-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 18 Apr 2019 22:22:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:44:59PM +0200, Laurent Dufour wrote:
> Some VMA struct fields need to be initialized once the VMA structure is
> allocated.
> Currently this only concerns anon_vma_chain field but some other will be
> added to support the speculative page fault.
> 
> Instead of spreading the initialization calls all over the code, let's
> introduce a dedicated inline function.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> ---
>  fs/exec.c          | 1 +
>  include/linux/mm.h | 5 +++++
>  kernel/fork.c      | 2 +-
>  mm/mmap.c          | 3 +++
>  mm/nommu.c         | 1 +
>  5 files changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index 2e0033348d8e..9762e060295c 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -266,6 +266,7 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
>  	vma->vm_start = vma->vm_end - PAGE_SIZE;
>  	vma->vm_flags = VM_SOFTDIRTY | VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;
>  	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
> +	INIT_VMA(vma);
>  
>  	err = insert_vm_struct(mm, vma);
>  	if (err)
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4ba2f53f9d60..2ceb1d2869a6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1407,6 +1407,11 @@ struct zap_details {
>  	pgoff_t last_index;			/* Highest page->index to unmap */
>  };
>  
> +static inline void INIT_VMA(struct vm_area_struct *vma)

Can we leave capital names for macro ? Also i prefer vma_init_struct() (the
one thing i like in C++ is namespace and thus i like namespace_action() for
function name).

Also why not doing a coccinelle patch for this:

@@
struct vm_area_struct *vma;
@@
-INIT_LIST_HEAD(&vma->anon_vma_chain);
+vma_init_struct(vma);


Untested ...

> +{
> +	INIT_LIST_HEAD(&vma->anon_vma_chain);
> +}
> +
>  struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>  			     pte_t pte, bool with_public_device);
>  #define vm_normal_page(vma, addr, pte) _vm_normal_page(vma, addr, pte, false)
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 915be4918a2b..f8dae021c2e5 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -341,7 +341,7 @@ struct vm_area_struct *vm_area_dup(struct vm_area_struct *orig)
>  
>  	if (new) {
>  		*new = *orig;
> -		INIT_LIST_HEAD(&new->anon_vma_chain);
> +		INIT_VMA(new);
>  	}
>  	return new;
>  }
> diff --git a/mm/mmap.c b/mm/mmap.c
> index bd7b9f293b39..5ad3a3228d76 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1765,6 +1765,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  	vma->vm_flags = vm_flags;
>  	vma->vm_page_prot = vm_get_page_prot(vm_flags);
>  	vma->vm_pgoff = pgoff;
> +	INIT_VMA(vma);
>  
>  	if (file) {
>  		if (vm_flags & VM_DENYWRITE) {
> @@ -3037,6 +3038,7 @@ static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long fla
>  	}
>  
>  	vma_set_anonymous(vma);
> +	INIT_VMA(vma);
>  	vma->vm_start = addr;
>  	vma->vm_end = addr + len;
>  	vma->vm_pgoff = pgoff;
> @@ -3395,6 +3397,7 @@ static struct vm_area_struct *__install_special_mapping(
>  	if (unlikely(vma == NULL))
>  		return ERR_PTR(-ENOMEM);
>  
> +	INIT_VMA(vma);
>  	vma->vm_start = addr;
>  	vma->vm_end = addr + len;
>  
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 749276beb109..acf7ca72ca90 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1210,6 +1210,7 @@ unsigned long do_mmap(struct file *file,
>  	region->vm_flags = vm_flags;
>  	region->vm_pgoff = pgoff;
>  
> +	INIT_VMA(vma);
>  	vma->vm_flags = vm_flags;
>  	vma->vm_pgoff = pgoff;
>  
> -- 
> 2.21.0
> 

