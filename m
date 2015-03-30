Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7035D6B0038
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 06:42:20 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so172040385pdn.0
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 03:42:20 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id r1si14196311pdh.239.2015.03.30.03.42.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 03:42:19 -0700 (PDT)
Received: by pdbni2 with SMTP id ni2so171899161pdb.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 03:42:18 -0700 (PDT)
Message-ID: <55192885.5010608@gmail.com>
Date: Mon, 30 Mar 2015 19:42:13 +0900
From: Naoya Horiguchi <nao.horiguchi@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] mm: hugetlb: add stub-like do_hugetlb_numa()
References: <1427708426-31610-1-git-send-email-n-horiguchi@ah.jp.nec.com> <20150330102802.GQ4701@suse.de>
In-Reply-To: <20150330102802.GQ4701@suse.de>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 03/30/2015 07:28 PM, Mel Gorman wrote:
> On Mon, Mar 30, 2015 at 09:40:54AM +0000, Naoya Horiguchi wrote:
>> hugetlb doesn't support NUMA balancing now, but that doesn't mean that we
>> don't have to make hugetlb code prepared for PROTNONE entry properly.
>> In the current kernel, when a process accesses to hugetlb range protected
>> with PROTNONE, it causes unexpected COWs, which finally put hugetlb subsystem
>> into broken/uncontrollable state, where for example h->resv_huge_pages is
>> subtracted too much and wrapped around to a very large number, and free
>> hugepage pool is no longer maintainable.
>>
>
> Ouch!
>
>> This patch simply clears PROTNONE when it's caught out. Real NUMA balancing
>> code for hugetlb is not implemented yet (not sure how much it's worth doing.)
>>
>
> It's not worth doing at all. Furthermore, an application that took the
> effort to allocate and use hugetlb pages is not going to appreciate the
> minor faults incurred by automatic balancing for no gain.

OK,

> Why not something
> like the following untested patch?

I'll test this tomorrow.
Thank you very much for the comment.

Naoya Horiguchi

> It simply avoids doing protection updates
> on hugetlb VMAs. If it works for you, feel free to take it and reuse most
> of the same changelog for it. I'll only be intermittently online for the
> next few days and would rather not unnecessarily delay a fix
>
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 7ce18f3c097a..74bfde50fd4e 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -2161,8 +2161,10 @@ void task_numa_work(struct callback_head *work)
>   		vma = mm->mmap;
>   	}
>   	for (; vma; vma = vma->vm_next) {
> -		if (!vma_migratable(vma) || !vma_policy_mof(vma))
> +		if (!vma_migratable(vma) || !vma_policy_mof(vma) ||
> +						is_vm_hugetlb_page(vma)) {
>   			continue;
> +		}
>
>   		/*
>   		 * Shared library pages mapped by multiple processes are not
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
