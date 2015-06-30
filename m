Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id C635A6B006E
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 19:35:49 -0400 (EDT)
Received: by igcur8 with SMTP id ur8so77295570igc.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 16:35:49 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id sb10si18949igb.13.2015.06.30.16.35.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 16:35:47 -0700 (PDT)
Received: by igcsj18 with SMTP id sj18so120439070igc.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 16:35:47 -0700 (PDT)
Date: Tue, 30 Jun 2015 16:35:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 05/11] mm: debug: dump page into a string rather than
 directly on screen
In-Reply-To: <1431623414-1905-6-git-send-email-sasha.levin@oracle.com>
Message-ID: <alpine.DEB.2.10.1506301627030.5359@chino.kir.corp.google.com>
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com> <1431623414-1905-6-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill@shutemov.name

On Thu, 14 May 2015, Sasha Levin wrote:

> diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
> index 202ebdf..8b3f5a0 100644
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -7,9 +7,7 @@ struct page;
>  struct vm_area_struct;
>  struct mm_struct;
>  
> -extern void dump_page(struct page *page, const char *reason);
> -extern void dump_page_badflags(struct page *page, const char *reason,
> -			       unsigned long badflags);
> +char *format_page(struct page *page, char *buf, char *end);
>  
>  #ifdef CONFIG_DEBUG_VM
>  char *format_vma(const struct vm_area_struct *vma, char *buf, char *end);
> @@ -18,7 +16,7 @@ char *format_mm(const struct mm_struct *mm, char *buf, char *end);
>  #define VM_BUG_ON_PAGE(cond, page)					\
>  	do {								\
>  		if (unlikely(cond)) {					\
> -			dump_page(page, "VM_BUG_ON_PAGE(" __stringify(cond)")");\
> +			pr_emerg("%pZp", page);				\
>  			BUG();						\
>  		}							\
>  	} while (0)
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index 595bf50..1f045ae 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -1382,6 +1382,8 @@ char *mm_pointer(char *buf, char *end, const void *ptr,
>  	switch (fmt[1]) {
>  	case 'm':
>  		return format_mm(ptr, buf, end);
> +	case 'p':
> +		return format_page(ptr, buf, end);
>  	case 'v':
>  		return format_vma(ptr, buf, end);
>  	default:
> @@ -1482,9 +1484,10 @@ int kptr_restrict __read_mostly;
>   *        (legacy clock framework) of the clock
>   * - 'Cr' For a clock, it prints the current rate of the clock
>   * - 'T' task_struct->comm
> - * - 'Z[mv]' Outputs a readable version of a type of memory management struct:
> + * - 'Z[mpv]' Outputs a readable version of a type of memory management struct:
>   *		v struct vm_area_struct
>   *		m struct mm_struct
> + *		p struct page
>   *
>   * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
>   * function pointers are really function descriptors, which contain a
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index fcad832..88b3cae 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -187,7 +187,7 @@ void balloon_page_putback(struct page *page)
>  		put_page(page);
>  	} else {
>  		WARN_ON(1);
> -		dump_page(page, "not movable balloon page");
> +		pr_alert("Not movable balloon page:\n%pZp", page);
>  	}
>  	unlock_page(page);
>  }

I don't know how others feel, but this looks strange to me and seems like 
it's only a result of how we must now dump page information 
(dump_page(page) is no longer available, we must do pr_alert("%pZp", 
page)).

Since we're relying on print formats, this would arguably be better as

	pr_alert("Not movable balloon page:\n");
	pr_alert("%pZp", page);

to avoid introducing newlines into potentially lengthy messages that need 
a specified loglevel like you've done above.

But that's not much different than the existing dump_page() 
implementation.

So for this to be worth it, it seems like we'd need a compelling usecase 
for something like pr_alert("%pZp %pZv", page, vma) and I'm not sure we're 
ever actually going to see that.  I would argue that

	dump_page(page);
	dump_vma(vma);

would be simpler in such circumstances.

I do understand the problem with the current VM_BUG_ON_PAGE() and 
VM_BUG_ON_VMA() stuff, and it compels me to ask about just going back to 
the normal

	VM_BUG_ON(cond);

coupled with dump_page(), dump_vma(), dump_whatever().  It all seems so 
much simpler to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
