Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1A44C46470
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 18:29:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F0EC20873
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 18:29:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="k+urY/Lp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F0EC20873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBE1F6B0005; Wed, 15 May 2019 14:29:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6F2E6B0006; Wed, 15 May 2019 14:29:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5D476B0007; Wed, 15 May 2019 14:29:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFBA6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 14:29:15 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h7so338404pfq.22
        for <linux-mm@kvack.org>; Wed, 15 May 2019 11:29:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=7+hUfi1h+Bngg1k8l3ufdDrFoDNEm3R9nWvZ8QiNuEE=;
        b=Z20LPpdwPTCmx7r6gQj6kHjVwEOydBEGqILie+y5Y4eLvcdKXF0RyiXz3L6PkvLdrK
         fL6pQ0L0PGPOIhYFXFLOfEgKzbYRjAgGOomOnf3liQ3MpLnBga3FfnkUa0+rVk0h3y3N
         5MJkKazfF8CeUjPYKNz0/SM1aSXHhuIfYru0+rGB4BPcjZg4S9wh0VUyNw8la2c1hmw8
         5rjhi3HTuSbIHogludCyVKsTZPyXC0a+kZk8f/j/XTvdZGLSva8cys1IBN7F4c2N5fPE
         rMapToA+lLpJRzQ0cYIQQbKp8U9eVQAhyJDZ7/I+MBQ6kksB8DQnsMJbmnQ+nAh7cQY8
         qWqQ==
X-Gm-Message-State: APjAAAWoB04ftAuE11xzHp05dau+XqVWTnOm6cyzbiim4IRooSNtmFZl
	jMiQtNU0bakQva/iltDASFhRFPe9FKbcqYiwKlarrop6knuvemiNfqVZk/vZ466b5fit4zOsx89
	nH5kgRX7brsthTYtj9RCclQ1oLKeNbrlaAv1YoBuesmcZmfRqpZSqbLGmHYNCoQX27Q==
X-Received: by 2002:a63:5b5c:: with SMTP id l28mr1876978pgm.158.1557944955020;
        Wed, 15 May 2019 11:29:15 -0700 (PDT)
X-Received: by 2002:a63:5b5c:: with SMTP id l28mr1876890pgm.158.1557944953881;
        Wed, 15 May 2019 11:29:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557944953; cv=none;
        d=google.com; s=arc-20160816;
        b=ajyV3mps6fS7GCNinMBNkHx2tp/fkbX4aFzj5GKrPSIKiXrxmiK0Q7AM0Rk+bvEajZ
         u/DWi82gkC+E3svKR4sk3iqgYQcwzsvPRe4+1nlDxw+5nOOJXDpJW4d02BEhR0k5L4tf
         evPbHybiHjo52Aq1yEFsODzZ4e5Uo0vglnLGHQnuG70cjyRF2QbDvkdw9aagYnVygtfI
         8RVTyrBOqDXka3YSxRK01Z/LJiq+UOwP94hABBE5TkEzGwBIU2FtU0S+DDkWn7Iko5kQ
         Vt4ef+8b+MXJlhfp74NZnbBJpdPguXY3Tw3hFZNg00WyB8EuEez26MSbXuRMIrUXD9PN
         uzsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=7+hUfi1h+Bngg1k8l3ufdDrFoDNEm3R9nWvZ8QiNuEE=;
        b=bSxZtYiziXJ9Nw91qtB/+7BTgzZltQeEA6Z9wHi3n14wvK47xrGVlt9DxjEpromEdS
         RWDrf77q9gM6bvDtXQPCkmKmDNoVMNFv6RJTPZA3uzpbs98BRvE9YDbXgoj5cyztjSG1
         qecUvZmCwSJYswvyfRKQRZnLIv8sdV3w3KPUVGqY7dtp9VuokC1QWsDVfCXSDf/ISGCY
         Xg31ynEcSIIiduP9NCPk8AQ1iaxy3J6KsBqM8ZJgYn3fhJ7s35t4sas0PA9I2S8MUlzp
         uvyVzH/u46ViKP+c2pE+bTPF6aweN1uCgEMvyfzJ7YR4ZF8wdsdAmzUoch5pQqWxMGI4
         s2mA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="k+urY/Lp";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r2sor3198171pls.71.2019.05.15.11.29.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 11:29:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="k+urY/Lp";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=7+hUfi1h+Bngg1k8l3ufdDrFoDNEm3R9nWvZ8QiNuEE=;
        b=k+urY/LpRJdhfcGoDiIRnxykgWw75d2T0WzNWNCh1I+Sy+ZnSD6Vbk/5aOTdL9Xyd8
         DN92RSqYON5e2+oS4ckPYB//dyFh5p67wzUlQiG0UGwXABC0885ntb7i+9DZzWsUQBXd
         aOTT+kWnX3Rw1fjc6MbTPLxdVY5qiFGX85n0E=
X-Google-Smtp-Source: APXvYqwzeuzwdSAb17NG/VN2bqkRVwXbeegC2PpIbh9dhlKA9H7UdWVV6Ui/mDP6toS7Jy6o2bQVCw==
X-Received: by 2002:a17:902:8214:: with SMTP id x20mr23136175pln.308.1557944953361;
        Wed, 15 May 2019 11:29:13 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id k63sm4286573pfb.108.2019.05.15.11.29.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 11:29:12 -0700 (PDT)
Date: Wed, 15 May 2019 11:29:10 -0700
From: Kees Cook <keescook@chromium.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
	keith.busch@intel.com, kirill.shutemov@linux.intel.com,
	pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
	ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
	vbabka@suse.cz, cl@linux.com, riel@surriel.com, hannes@cmpxchg.org,
	npiggin@gmail.com, mathieu.desnoyers@efficios.com,
	shakeelb@google.com, guro@fb.com, aarcange@redhat.com,
	hughd@google.com, jglisse@redhat.com, mgorman@techsingularity.net,
	daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Jann Horn <jannh@google.com>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH RFC 5/5] mm: Add process_vm_mmap()
Message-ID: <201905151018.42009E4868@keescook>
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
 <155793310413.13922.4749810361688380807.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155793310413.13922.4749810361688380807.stgit@localhost.localdomain>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 06:11:44PM +0300, Kirill Tkhai wrote:
> This adds a new syscall to map from or to another
> process vma. Flag PVMMAP_FIXED may be specified,
> its meaning is similar to mmap()'s MAP_FIXED.
> 
> @pid > 0 means to map from process of @pid to current,
> @pid < 0 means to map from current to @pid process.
> 
> VMA are merged on destination, i.e. if source task
> has VMA with address [start; end], and we map it sequentially
> twice:
> 
> process_vm_mmap(@pid, start, start + (end - start)/2, ...);
> process_vm_mmap(@pid, start + (end - start)/2, end,   ...);
> 
> the destination task will have single vma [start, end].
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
> [...]
> diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> index abd238d0f7a4..44cb6cf77e93 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -28,6 +28,11 @@
>  /* 0x0100 - 0x80000 flags are defined in asm-generic/mman.h */
>  #define MAP_FIXED_NOREPLACE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
>  
> +/*
> + * Flags for process_vm_mmap
> + */
> +#define PVMMAP_FIXED	0x01

I think PVMMAP_FIXED_NOREPLACE should be included from the start too. It
seems like providing the "do not overwrite existing remote mapping"
from the start would be good. :)

> [...]
> +unsigned long mmap_process_vm(struct mm_struct *src_mm,
> +			      unsigned long src_addr,
> +			      struct mm_struct *dst_mm,
> +			      unsigned long dst_addr,
> +			      unsigned long len,
> +			      unsigned long flags,
> +			      struct list_head *uf)
> +{
> +	struct vm_area_struct *src_vma = find_vma(src_mm, src_addr);
> +	unsigned long gua_flags = 0;
> +	unsigned long ret;
> +
> +	if (!src_vma || src_vma->vm_start > src_addr)
> +		return -EFAULT;
> +	if (len > src_vma->vm_end - src_addr)
> +		return -EFAULT;
> +	if (src_vma->vm_flags & (VM_DONTEXPAND | VM_PFNMAP))
> +		return -EFAULT;
> +	if (is_vm_hugetlb_page(src_vma) || (src_vma->vm_flags & VM_IO))
> +		return -EINVAL;
> +        if (dst_mm->map_count + 2 > sysctl_max_map_count)
> +                return -ENOMEM;

whitespace damage? Also, I think this should be:

	if (dst_mm->map_count >= sysctl_max_map_count - 2) ...

> +	if (!IS_NULL_VM_UFFD_CTX(&src_vma->vm_userfaultfd_ctx))
> +		return -ENOTSUPP;

Are these various checks from other places? I see simliar things in
vma_to_resize(). Should these be collected in a single helper for common
checks in various places?

> +
> +	if (src_vma->vm_flags & VM_SHARED)
> +		gua_flags |= MAP_SHARED;
> +	else
> +		gua_flags |= MAP_PRIVATE;
> +	if (vma_is_anonymous(src_vma) || vma_is_shmem(src_vma))
> +		gua_flags |= MAP_ANONYMOUS;
> +	if (flags & PVMMAP_FIXED)
> +		gua_flags |= MAP_FIXED;

And obviously add MAP_FIXED_NOREPLACE here too...

> +	ret = get_unmapped_area(src_vma->vm_file, dst_addr, len,
> +				src_vma->vm_pgoff +
> +				((src_addr - src_vma->vm_start) >> PAGE_SHIFT),
> +				gua_flags);
> +	if (offset_in_page(ret))
> +                return ret;
> +	dst_addr = ret;
> +
> +	/* Check against address space limit. */
> +	if (!may_expand_vm(dst_mm, src_vma->vm_flags, len >> PAGE_SHIFT)) {
> +		unsigned long nr_pages;
> +
> +		nr_pages = count_vma_pages_range(dst_mm, dst_addr, dst_addr + len);
> +		if (!may_expand_vm(dst_mm, src_vma->vm_flags,
> +					(len >> PAGE_SHIFT) - nr_pages))
> +			return -ENOMEM;
> +	}
> +
> +	ret = do_mmap_process_vm(src_vma, src_addr, dst_mm, dst_addr, len, uf);
> +	if (ret)
> +                return ret;
> +
> +	return dst_addr;
> +}
> +
>  /*
>   * Return true if the calling process may expand its vm space by the passed
>   * number of pages
> diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
> index a447092d4635..7fca2c5c7edd 100644
> --- a/mm/process_vm_access.c
> +++ b/mm/process_vm_access.c
> @@ -17,6 +17,8 @@
>  #include <linux/ptrace.h>
>  #include <linux/slab.h>
>  #include <linux/syscalls.h>
> +#include <linux/mman.h>
> +#include <linux/userfaultfd_k.h>
>  
>  #ifdef CONFIG_COMPAT
>  #include <linux/compat.h>
> @@ -295,6 +297,68 @@ static ssize_t process_vm_rw(pid_t pid,
>  	return rc;
>  }
>  
> +static unsigned long process_vm_mmap(pid_t pid, unsigned long src_addr,
> +				     unsigned long len, unsigned long dst_addr,
> +				     unsigned long flags)
> +{
> +	struct mm_struct *src_mm, *dst_mm;
> +	struct task_struct *task;
> +	unsigned long ret;
> +	int depth = 0;
> +	LIST_HEAD(uf);
> +
> +	len = PAGE_ALIGN(len);
> +	src_addr = round_down(src_addr, PAGE_SIZE);
> +	if (flags & PVMMAP_FIXED)
> +		dst_addr = round_down(dst_addr, PAGE_SIZE);
> +	else
> +		dst_addr = round_hint_to_min(dst_addr);
> +
> +	if ((flags & ~PVMMAP_FIXED) || len == 0 || len > TASK_SIZE ||
> +	    src_addr == 0 || dst_addr > TASK_SIZE - len)
> +		return -EINVAL;

And PVMMAP_FIXED_NOREPLACE here...

> +	task = find_get_task_by_vpid(pid > 0 ? pid : -pid);
> +	if (!task)
> +		return -ESRCH;
> +	if (unlikely(task->flags & PF_KTHREAD)) {
> +		ret = -EINVAL;
> +		goto out_put_task;
> +	}
> +
> +	src_mm = mm_access(task, PTRACE_MODE_ATTACH_REALCREDS);
> +	if (!src_mm || IS_ERR(src_mm)) {
> +		ret = IS_ERR(src_mm) ? PTR_ERR(src_mm) : -ESRCH;
> +		goto out_put_task;
> +	}
> +	dst_mm = current->mm;
> +	mmget(dst_mm);
> +
> +	if (pid < 0)
> +		swap(src_mm, dst_mm);
> +
> +	/* Double lock mm in address order: smallest is the first */
> +	if (src_mm < dst_mm) {
> +		down_write(&src_mm->mmap_sem);
> +		depth = SINGLE_DEPTH_NESTING;
> +	}
> +	down_write_nested(&dst_mm->mmap_sem, depth);
> +	if (src_mm > dst_mm)
> +		down_write_nested(&src_mm->mmap_sem, SINGLE_DEPTH_NESTING);
> +
> +	ret = mmap_process_vm(src_mm, src_addr, dst_mm, dst_addr, len, flags, &uf);
> +
> +	up_write(&dst_mm->mmap_sem);
> +	if (dst_mm != src_mm)
> +		up_write(&src_mm->mmap_sem);
> +
> +	userfaultfd_unmap_complete(dst_mm, &uf);
> +	mmput(src_mm);
> +	mmput(dst_mm);
> +out_put_task:
> +	put_task_struct(task);
> +	return ret;
> +}
> +
>  SYSCALL_DEFINE6(process_vm_readv, pid_t, pid, const struct iovec __user *, lvec,
>  		unsigned long, liovcnt, const struct iovec __user *, rvec,
>  		unsigned long, riovcnt,	unsigned long, flags)
> @@ -310,6 +374,13 @@ SYSCALL_DEFINE6(process_vm_writev, pid_t, pid,
>  	return process_vm_rw(pid, lvec, liovcnt, rvec, riovcnt, flags, 1);
>  }
>  
> +SYSCALL_DEFINE5(process_vm_mmap, pid_t, pid,
> +		unsigned long, src_addr, unsigned long, len,
> +		unsigned long, dst_addr, unsigned long, flags)
> +{
> +	return process_vm_mmap(pid, src_addr, len, dst_addr, flags);
> +}
> +
>  #ifdef CONFIG_COMPAT
>  
>  static ssize_t
> 

Looks pretty interesting. I do wonder about "ATTACH" being a sufficient
description of this feature. "Give me your VMA" and "take this VMA"
is quite a bit stronger than "give me a copy of that memory" and "I
will write to your memory" in the sense that memory content changes are
now happening directly instead of through syscalls. But it's not much
different from regular shared memory, so, I guess it's fine? :)

-- 
Kees Cook

