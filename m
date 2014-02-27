Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 69D246B0031
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 16:23:52 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so3060944pbb.14
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 13:23:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id nc5si542594pab.126.2014.02.27.13.23.51
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 13:23:51 -0800 (PST)
Date: Thu, 27 Feb 2014 13:23:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: call vma_adjust_trans_huge() only for
 thp-enabled vma
Message-Id: <20140227132350.9378977e0ccbb3a7cf74ee18@linux-foundation.org>
In-Reply-To: <1393475977-3381-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1393475977-3381-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 26 Feb 2014 23:39:37 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> vma_adjust() is called also for vma(VM_HUGETLB) and it could happen that
> we happen to try to split hugetlbfs hugepage. So exclude the possibility.
> 

It would be nice to have a more complete changelog here please.  Under
what circumstances does this cause problems and what are the
user-observable effects?

> --- next-20140220.orig/mm/mmap.c
> +++ next-20140220/mm/mmap.c
> @@ -772,7 +772,8 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		}
>  	}
>  
> -	vma_adjust_trans_huge(vma, start, end, adjust_next);
> +	if (transparent_hugepage_enabled(vma))
> +		vma_adjust_trans_huge(vma, start, end, adjust_next);
>  
>  	anon_vma = vma->anon_vma;
>  	if (!anon_vma && adjust_next)
> -- 
> 1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
