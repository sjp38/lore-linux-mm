Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6CB6B0038
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 17:35:24 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so31347338pad.3
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 14:35:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qt4si20979185pbc.150.2015.03.31.14.35.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 14:35:23 -0700 (PDT)
Date: Tue, 31 Mar 2015 14:35:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: numa: disable change protection for vma(VM_HUGETLB)
Message-Id: <20150331143521.652d655e396d961410179d4d@linux-foundation.org>
In-Reply-To: <20150331014554.GA8128@hori1.linux.bs1.fc.nec.co.jp>
References: <1427708426-31610-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20150330102802.GQ4701@suse.de>
	<55192885.5010608@gmail.com>
	<20150330115901.GR4701@suse.de>
	<20150331014554.GA8128@hori1.linux.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <nao.horiguchi@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 31 Mar 2015 01:45:55 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently when a process accesses to hugetlb range protected with PROTNONE,
> unexpected COWs are triggered, which finally put hugetlb subsystem into
> broken/uncontrollable state, where for example h->resv_huge_pages is subtracted
> too much and wrapped around to a very large number, and free hugepage pool
> is no longer maintainable.
> 
> This patch simply stops changing protection for vma(VM_HUGETLB) to fix the
> problem. And this also allows us to avoid useless overhead of minor faults.
> 
> ...
>
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -2161,8 +2161,10 @@ void task_numa_work(struct callback_head *work)
>  		vma = mm->mmap;
>  	}
>  	for (; vma; vma = vma->vm_next) {
> -		if (!vma_migratable(vma) || !vma_policy_mof(vma))
> +		if (!vma_migratable(vma) || !vma_policy_mof(vma) ||
> +			is_vm_hugetlb_page(vma)) {
>  			continue;
> +		}
>  
>  		/*
>  		 * Shared library pages mapped by multiple processes are not

Which kernel version(s) need this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
