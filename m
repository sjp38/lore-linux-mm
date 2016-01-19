Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 62EDA6B0009
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 20:13:05 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id n128so165749757pfn.3
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 17:13:05 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id v86si43368925pfi.16.2016.01.18.17.13.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 17:13:04 -0800 (PST)
Received: by mail-pa0-x242.google.com with SMTP id gi1so40565269pac.2
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 17:13:04 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Date: Tue, 19 Jan 2016 10:12:57 +0900 (KST)
Subject: Re: [PATCH] mm:mempolicy: skip VM_HUGETLB and VM_MIXEDMAP VMA for
 lazy mbind
In-Reply-To: <1453125834-16546-1-git-send-email-liangchen.linux@gmail.com>
Message-ID: <alpine.DEB.2.10.1601191005350.2469@hxeon>
References: <1453125834-16546-1-git-send-email-liangchen.linux@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Chen <liangchen.linux@gmail.com>
Cc: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, riel@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Gavin Guo <gavin.guo@canonical.com>

Hello Liang,

Just trivial comment below.

On Mon, 18 Jan 2016, Liang Chen wrote:

> VM_HUGETLB and VM_MIXEDMAP vma needs to be excluded to avoid compound
> pages being marked for migration and unexpected COWs when handling
> hugetlb fault.
>
> Thanks to Naoya Horiguchi for reminding me on these checks.
>
> Signed-off-by: Liang Chen <liangchen.linux@gmail.com>
> Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
> ---
> mm/mempolicy.c | 5 +++--
> 1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 436ff411..415de70 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -610,8 +610,9 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
>
> 	if (flags & MPOL_MF_LAZY) {
> 		/* Similar to task_numa_work, skip inaccessible VMAs */
> -		if (vma_migratable(vma) &&
> -			vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
> +		if (vma_migratable(vma) && !is_vm_hugetlb_page(vma) &&
> +			(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)) &&
> +			!(vma->vm_flags & VM_MIXEDMAP))

Isn't there exists few unnecessary parenthesis? IMHO, it makes me hard to 
read the code.

How about below code, instead?

+             if (vma_migratable(vma) && !is_vm_hugetlb_page(vma) &&
+                     vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE) &&
+                     !vma->vm_flags & VM_MIXEDMAP)


Thanks,
SeongJae Park.

> 			change_prot_numa(vma, start, endvma);
> 		return 1;
> 	}
> -- 
> 1.9.1
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
