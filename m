Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FE65C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 19:44:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4627421851
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 19:44:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="V+41nzxS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4627421851
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC9886B0006; Wed, 17 Jul 2019 15:44:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7A9A8E0001; Wed, 17 Jul 2019 15:44:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C938B6B000A; Wed, 17 Jul 2019 15:44:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93AA06B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 15:44:34 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a21so8389938pgv.0
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 12:44:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=gvjPZWoufoHncj5iyWeqiWRKnFrwf8zGjNBYtpZ6tKQ=;
        b=L9VU7/2usTypIIk3nV9ZO4VGpmDY+T9tJtDaD3ZNdzD6Qe4Xi/Z0R8zB0VSa7rt7wI
         lRMx729JyoKRMhlfEa8n6lU7JowtnLUL+QkuZUu3BkF3pIuTLvp4kPofCJZ4lrSwN2vh
         CgpQSydS56DapXJESMsu72Iwp2gafjBoZR3xD5eHOuVztS6VQDF1fCBEmBxEC8kykpdn
         jon9QKGjKprEh4GMQWfyeYGRwXWPjiU6ADcT/VxZO9jH/mpcokquvAcAfAedXkPu/+Un
         yNGDCGr6UbCJb3559c5k9lZWUZnP9B2q9eAXeIyPbwopgfji02GSCa1OYbRSlxGHANa1
         S1Mw==
X-Gm-Message-State: APjAAAX8kKBefrRLBBtWDCdIjjUR//okNzrkRvso8mrAMvyQWjmrbBMI
	pQnz8iv5ZLe///Ustrx2AYTr9HF/9i8xFZck4QVMvp+2hj15otq2+8CpsZtD5qSyx66X5+canTP
	cVmckE3VBBKknrcQR57tuDDpx083xNLy0NnoyKkFnyHfHFSPQuqoWDfxUtP//yR0tRw==
X-Received: by 2002:a17:902:6b81:: with SMTP id p1mr42564214plk.91.1563392674271;
        Wed, 17 Jul 2019 12:44:34 -0700 (PDT)
X-Received: by 2002:a17:902:6b81:: with SMTP id p1mr42564173plk.91.1563392673500;
        Wed, 17 Jul 2019 12:44:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563392673; cv=none;
        d=google.com; s=arc-20160816;
        b=BrcMbCfCiLS9pRVvSawuEhXVjKon6KOHt3nge45XRoXpHvhy4Pi0smk+zt24b4hGEW
         uxWclOwzt2gDmM68YSG9ZOxpOsJHRYUevSNCa0ZKaD8yGTgla9Be624XHk+e5fz5yXTU
         HTniiHxYhy/poZp2VL8ryMncKEMhEYEcs45grT8yTUinEnjcbC5UDaD5hp/Y05fHfAGg
         c2kppVNnAOx34jzh28TMUulF7pkYp6sBKln4w1ilMu4GDP/BqF8GWCJS9Xwo2OADLPGs
         UOHrWnLMzkZsLXltlRy+kgICK3ZmCGXNvHFyeCsEBGa50Ru2ysyafByEawcBe/R5dYZL
         Me4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=gvjPZWoufoHncj5iyWeqiWRKnFrwf8zGjNBYtpZ6tKQ=;
        b=nEIllp+afVPVjkqI7E1xmJzQX5NXiWUJiFAVLbCsf3VCrR5n09LAVtY1ICqXGJDWIA
         cka9dWx/leqN+HEijpthwksxllJHt6MdFJbUJ1alGmX/JV8H3AjRYXdL18U0tFj1RCSx
         28PHor73NtiBFktTQXUC1qW1svkooDy+9fKIvlWdvp9sHkwReXKqiNl+VcVHIQMMim+b
         HJYK+gh8jiSs7X2vk4XKNH9gXXElX7K48yeE7ues+JfKHEDTuXZAql6MZOz0Bp+j7UcE
         3SWdcpm5jf4lctTJPISNJDMv+5SVr6aQ8elgm2ZmUMFSG2srQQV1wTpYGS4wwLkbXHBq
         8rFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=V+41nzxS;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m37sor30484630pla.6.2019.07.17.12.44.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 12:44:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=V+41nzxS;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=gvjPZWoufoHncj5iyWeqiWRKnFrwf8zGjNBYtpZ6tKQ=;
        b=V+41nzxSMtHHtuKjjlYe2GfJUL8OkwTW54lqpP4dzM4zgY3shyyLaX0K65MjCbgkMA
         JbEoFVMktVLB3yjSnRHiCY/QGDeT/Ry1EtepMiiQZBtORT4LcsanPu+wmDHPU5A8ImJZ
         ldVpzOO2iZ7YzyDbWT2fLzrjfofjjisJtzT8oJ+LheNWez/iuEh8rIrXccIbc6wOmENU
         bymQc2QANDdpuvEugqEqUY33+9C5zNaq8aNQvWYnJfl2VIYp+NDrL1dmaf/yoMoe+wia
         PQa0y1K4sc3F7Xf58nEjx6tNNBQQWv75mlgYI1ha4k6Jhx5wCMoMPtZyRCR9AsEli8l9
         8+aw==
X-Google-Smtp-Source: APXvYqxyIhVLV3+xZdZyruXl0Q+nykHdkO769WGjExr3291Arvp8ld8l1OClYHmZUBHqkGiwRJjaKw==
X-Received: by 2002:a17:902:9041:: with SMTP id w1mr46275249plz.132.1563392672552;
        Wed, 17 Jul 2019 12:44:32 -0700 (PDT)
Received: from [100.112.64.100] ([104.133.8.100])
        by smtp.gmail.com with ESMTPSA id 14sm24016805pfy.40.2019.07.17.12.44.31
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 Jul 2019 12:44:31 -0700 (PDT)
Date: Wed, 17 Jul 2019 12:44:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Yang Shi <yang.shi@linux.alibaba.com>
cc: hughd@google.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, 
    vbabka@suse.cz, rientjes@google.com, akpm@linux-foundation.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v3 PATCH 2/2] mm: thp: fix false negative of shmem vma's THP
 eligibility
In-Reply-To: <1560401041-32207-3-git-send-email-yang.shi@linux.alibaba.com>
Message-ID: <alpine.LSU.2.11.1907171243400.1177@eggly.anvils>
References: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com> <1560401041-32207-3-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jun 2019, Yang Shi wrote:

> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
> vma") introduced THPeligible bit for processes' smaps. But, when checking
> the eligibility for shmem vma, __transparent_hugepage_enabled() is
> called to override the result from shmem_huge_enabled().  It may result
> in the anonymous vma's THP flag override shmem's.  For example, running a
> simple test which create THP for shmem, but with anonymous THP disabled,
> when reading the process's smaps, it may show:
> 
> 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
> Size:               4096 kB
> ...
> [snip]
> ...
> ShmemPmdMapped:     4096 kB
> ...
> [snip]
> ...
> THPeligible:    0
> 
> And, /proc/meminfo does show THP allocated and PMD mapped too:
> 
> ShmemHugePages:     4096 kB
> ShmemPmdMapped:     4096 kB
> 
> This doesn't make too much sense.  The shmem objects should be treated
> separately from anonymous THP.  Calling shmem_huge_enabled() with checking
> MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
> dax vma check since we already checked if the vma is shmem already.
> 
> Also check if vma is suitable for THP by calling
> transhuge_vma_suitable().
> 
> And minor fix to smaps output format and documentation.
> 
> Fixes: 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each vma")
> Cc: Hugh Dickins <hughd@google.com>

Thanks,
Acked-by: Hugh Dickins <hughd@google.com>

> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  Documentation/filesystems/proc.txt | 4 ++--
>  fs/proc/task_mmu.c                 | 3 ++-
>  mm/huge_memory.c                   | 9 +++++++--
>  mm/shmem.c                         | 3 +++
>  4 files changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index 66cad5c..b0ded06 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -477,8 +477,8 @@ replaced by copy-on-write) part of the underlying shmem object out on swap.
>  "SwapPss" shows proportional swap share of this mapping. Unlike "Swap", this
>  does not take into account swapped out page of underlying shmem objects.
>  "Locked" indicates whether the mapping is locked in memory or not.
> -"THPeligible" indicates whether the mapping is eligible for THP pages - 1 if
> -true, 0 otherwise.
> +"THPeligible" indicates whether the mapping is eligible for allocating THP
> +pages - 1 if true, 0 otherwise. It just shows the current status.
>  
>  "VmFlags" field deserves a separate description. This member represents the kernel
>  flags associated with the particular virtual memory area in two letter encoded
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 01d4eb0..6a13882 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -796,7 +796,8 @@ static int show_smap(struct seq_file *m, void *v)
>  
>  	__show_smap(m, &mss);
>  
> -	seq_printf(m, "THPeligible:    %d\n", transparent_hugepage_enabled(vma));
> +	seq_printf(m, "THPeligible:		%d\n",
> +		   transparent_hugepage_enabled(vma));
>  
>  	if (arch_pkeys_enabled())
>  		seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 4bc2552..36f0225 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -65,10 +65,15 @@
>  
>  bool transparent_hugepage_enabled(struct vm_area_struct *vma)
>  {
> +	/* The addr is used to check if the vma size fits */
> +	unsigned long addr = (vma->vm_end & HPAGE_PMD_MASK) - HPAGE_PMD_SIZE;
> +
> +	if (!transhuge_vma_suitable(vma, addr))
> +		return false;
>  	if (vma_is_anonymous(vma))
>  		return __transparent_hugepage_enabled(vma);
> -	if (vma_is_shmem(vma) && shmem_huge_enabled(vma))
> -		return __transparent_hugepage_enabled(vma);
> +	if (vma_is_shmem(vma))
> +		return shmem_huge_enabled(vma);
>  
>  	return false;
>  }
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 1bb3b8d..a807712 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -3872,6 +3872,9 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
>  	loff_t i_size;
>  	pgoff_t off;
>  
> +	if ((vma->vm_flags & VM_NOHUGEPAGE) ||
> +	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
> +		return false;
>  	if (shmem_huge == SHMEM_HUGE_FORCE)
>  		return true;
>  	if (shmem_huge == SHMEM_HUGE_DENY)
> -- 
> 1.8.3.1

