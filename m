Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 843E16B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 15:25:59 -0500 (EST)
Received: by igcto18 with SMTP id to18so25200233igc.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 12:25:59 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0249.hostedemail.com. [216.40.44.249])
        by mx.google.com with ESMTPS id p19si9665791igr.55.2015.12.08.12.25.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 12:25:58 -0800 (PST)
Date: Tue, 8 Dec 2015 15:25:55 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3 2/7] mm/gup: add gup trace points
Message-ID: <20151208152555.1c03ae54@gandalf.local.home>
In-Reply-To: <1449603595-718-3-git-send-email-yang.shi@linaro.org>
References: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
	<1449603595-718-3-git-send-email-yang.shi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: akpm@linux-foundation.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Tue,  8 Dec 2015 11:39:50 -0800
Yang Shi <yang.shi@linaro.org> wrote:

> For slow version, just add trace point for raw __get_user_pages since all
> slow variants call it to do the real work finally.
> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---
>  mm/gup.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index deafa2c..44f05c9 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -18,6 +18,9 @@
>  
>  #include "internal.h"
>  
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/gup.h>
> +
>  static struct page *no_page_table(struct vm_area_struct *vma,
>  		unsigned int flags)
>  {
> @@ -462,6 +465,8 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  	if (!nr_pages)
>  		return 0;
>  
> +	trace_gup_get_user_pages(start, nr_pages);
> +
>  	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
>  
>  	/*
> @@ -599,6 +604,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
>  	if (!(vm_flags & vma->vm_flags))
>  		return -EFAULT;
>  
> +	trace_gup_fixup_user_fault(address);
>  	ret = handle_mm_fault(mm, vma, address, fault_flags);
>  	if (ret & VM_FAULT_ERROR) {
>  		if (ret & VM_FAULT_OOM)
> @@ -1340,6 +1346,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  					start, len)))
>  		return 0;
>  
> +	trace_gup_get_user_pages_fast(start, (unsigned long) nr_pages);

typecast shouldn't be needed. But I'm wondering, it would save space in
the ring buffer if we used unsigend int instead of long. Will nr_pages
ever be bigger than 4 billion?

-- Steve

> +
>  	/*
>  	 * Disable interrupts.  We use the nested form as we can already have
>  	 * interrupts disabled by get_futex_key.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
