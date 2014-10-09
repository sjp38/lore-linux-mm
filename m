Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0B58D6B0069
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 06:36:07 -0400 (EDT)
Received: by mail-oi0-f43.google.com with SMTP id u20so1933001oif.30
        for <linux-mm@kvack.org>; Thu, 09 Oct 2014 03:36:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id f9si2753458oel.66.2014.10.09.03.36.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Oct 2014 03:36:05 -0700 (PDT)
Date: Thu, 9 Oct 2014 12:35:59 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/4] mm: gup: add FOLL_TRIED
Message-ID: <20141009103559.GK4750@worktop.programming.kicks-ass.net>
References: <1412153797-6667-1-git-send-email-aarcange@redhat.com>
 <1412153797-6667-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1412153797-6667-2-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>

On Wed, Oct 01, 2014 at 10:56:34AM +0200, Andrea Arcangeli wrote:
> From: Andres Lagar-Cavilla <andreslc@google.com>

This needs a changelog....

> Reviewed-by: Radim KrA?mA!A? <rkrcmar@redhat.com>
> Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/mm.h | 1 +
>  mm/gup.c           | 4 ++++
>  2 files changed, 5 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8981cc8..0f4196a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1985,6 +1985,7 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
>  #define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
>  #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
>  #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
> +#define FOLL_TRIED	0x800	/* a retry, previous pass started an IO */
>  
>  typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
>  			void *data);
> diff --git a/mm/gup.c b/mm/gup.c
> index 91d044b..af7ea3e 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -281,6 +281,10 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
>  		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
>  	if (*flags & FOLL_NOWAIT)
>  		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
> +	if (*flags & FOLL_TRIED) {
> +		VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
> +		fault_flags |= FAULT_FLAG_TRIED;
> +	}
>  
>  	ret = handle_mm_fault(mm, vma, address, fault_flags);
>  	if (ret & VM_FAULT_ERROR) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
