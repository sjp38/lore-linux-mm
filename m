Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 26F6F6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 09:29:27 -0500 (EST)
Received: by igl9 with SMTP id 9so98174196igl.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 06:29:27 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0084.hostedemail.com. [216.40.44.84])
        by mx.google.com with ESMTP id p16si30032263igw.68.2015.11.12.06.29.26
        for <linux-mm@kvack.org>;
        Thu, 12 Nov 2015 06:29:26 -0800 (PST)
Date: Thu, 12 Nov 2015 09:29:23 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
Message-ID: <20151112092923.19ee53dd@gandalf.local.home>
In-Reply-To: <1447316462-19645-1-git-send-email-yalin.wang2010@gmail.com>
References: <1447316462-19645-1-git-send-email-yalin.wang2010@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: mingo@redhat.com, akpm@linux-foundation.org, ebru.akagunduz@gmail.com, riel@redhat.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 12 Nov 2015 16:21:02 +0800
yalin wang <yalin.wang2010@gmail.com> wrote:

> This crash is caused by NULL pointer deference, in page_to_pfn() marco,
> when page == NULL :
> 
> [  182.639154 ] Unable to handle kernel NULL pointer dereference at virtual address 00000000


> add the trace point with TP_CONDITION(page),

I wonder if we still want to trace even if page is NULL?

> avoid trace NULL page.
> 
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> ---
>  include/trace/events/huge_memory.h | 20 ++++++++++++--------
>  mm/huge_memory.c                   |  6 +++---
>  2 files changed, 15 insertions(+), 11 deletions(-)
> 
> diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
> index 11c59ca..727647b 100644
> --- a/include/trace/events/huge_memory.h
> +++ b/include/trace/events/huge_memory.h
> @@ -45,12 +45,14 @@ SCAN_STATUS
>  #define EM(a, b)	{a, b},
>  #define EMe(a, b)	{a, b}
>  
> -TRACE_EVENT(mm_khugepaged_scan_pmd,
> +TRACE_EVENT_CONDITION(mm_khugepaged_scan_pmd,
>  
> -	TP_PROTO(struct mm_struct *mm, unsigned long pfn, bool writable,
> +	TP_PROTO(struct mm_struct *mm, struct page *page, bool writable,
>  		 bool referenced, int none_or_zero, int status, int unmapped),
>  
> -	TP_ARGS(mm, pfn, writable, referenced, none_or_zero, status, unmapped),
> +	TP_ARGS(mm, page, writable, referenced, none_or_zero, status, unmapped),
> +
> +	TP_CONDITION(page),
>  
>  	TP_STRUCT__entry(
>  		__field(struct mm_struct *, mm)
> @@ -64,7 +66,7 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
>  
>  	TP_fast_assign(
>  		__entry->mm = mm;
> -		__entry->pfn = pfn;
> +		__entry->pfn = page_to_pfn(page);

Instead of the condition, we could have:

	__entry->pfn = page ? page_to_pfn(page) : -1;


But if there's no reason to do the tracepoint if page is NULL, then
this patch is fine. I'm just throwing out this idea.

-- Steve

>  		__entry->writable = writable;
>  		__entry->referenced = referenced;
>  		__entry->none_or_zero = none_or_zero;
> @@ -106,12 +108,14 @@ TRACE_EVENT(mm_collapse_huge_page,
>  		__print_symbolic(__entry->status, SCAN_STATUS))
>  );
>  
> -TRACE_EVENT(mm_collapse_huge_page_isolate,
> +TRACE_EVENT_CONDITION(mm_collapse_huge_page_isolate,
>  
> -	TP_PROTO(unsigned long pfn, int none_or_zero,
> +	TP_PROTO(struct page *page, int none_or_zero,
>  		 bool referenced, bool  writable, int status),
>  
> -	TP_ARGS(pfn, none_or_zero, referenced, writable, status),
> +	TP_ARGS(page, none_or_zero, referenced, writable, status),
> +
> +	TP_CONDITION(page),
>  
>  	TP_STRUCT__entry(
>  		__field(unsigned long, pfn)
\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
