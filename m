Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8752E6B0007
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 06:02:24 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x25-v6so10083552pfn.21
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 03:02:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o184-v6si14081963pga.92.2018.06.19.03.02.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 03:02:23 -0700 (PDT)
Date: Tue, 19 Jun 2018 12:02:18 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180619100218.GN2458@hirez.programming.kicks-ass.net>
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 19, 2018 at 07:34:16AM +0800, Yang Shi wrote:

> diff --git a/mm/mmap.c b/mm/mmap.c
> index fc41c05..e84f80c 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2686,6 +2686,141 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
>  	return __split_vma(mm, vma, addr, new_below);
>  }
>  
> +/* Consider PUD size or 1GB mapping as large mapping */
> +#ifdef HPAGE_PUD_SIZE
> +#define LARGE_MAP_THRESH	HPAGE_PUD_SIZE
> +#else
> +#define LARGE_MAP_THRESH	(1 * 1024 * 1024 * 1024)
> +#endif
> +
> +/* Unmap large mapping early with acquiring read mmap_sem */
> +static int do_munmap_zap_early(struct mm_struct *mm, unsigned long start,
> +			       size_t len, struct list_head *uf)
> +{
> +	unsigned long end = 0;
> +	struct vm_area_struct *vma = NULL, *prev, *last, *tmp;
> +	bool success = false;
> +	int ret = 0;
> +
> +	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE - start)
> +		return -EINVAL;
> +
> +	len = (PAGE_ALIGN(len));
> +	if (len == 0)
> +		return -EINVAL;
> +
> +	/* Just deal with uf in regular path */
> +	if (unlikely(uf))
> +		goto regular_path;
> +
> +	if (len >= LARGE_MAP_THRESH) {
> +		down_read(&mm->mmap_sem);
> +		vma = find_vma(mm, start);
> +		if (!vma) {
> +			up_read(&mm->mmap_sem);
> +			return 0;
> +		}
> +
> +		prev = vma->vm_prev;
> +
> +		end = start + len;
> +		if (vma->vm_start > end) {
> +			up_read(&mm->mmap_sem);
> +			return 0;
> +		}
> +
> +		if (start > vma->vm_start) {
> +			int error;
> +
> +			if (end < vma->vm_end &&
> +			    mm->map_count > sysctl_max_map_count) {
> +				up_read(&mm->mmap_sem);
> +				return -ENOMEM;
> +			}
> +
> +			error = __split_vma(mm, vma, start, 0);
> +			if (error) {
> +				up_read(&mm->mmap_sem);
> +				return error;
> +			}
> +			prev = vma;
> +		}
> +
> +		last = find_vma(mm, end);
> +		if (last && end > last->vm_start) {
> +			int error = __split_vma(mm, last, end, 1);
> +
> +			if (error) {
> +				up_read(&mm->mmap_sem);
> +				return error;
> +			}
> +		}
> +		vma = prev ? prev->vm_next : mm->mmap;

Hold up, two things: you having to copy most of do_munmap() didn't seem
to suggest a helper function? And second, since when are we allowed to
split VMAs under a read lock?
