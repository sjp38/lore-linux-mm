Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6592A6B006C
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 12:18:26 -0400 (EDT)
Received: by wiun10 with SMTP id n10so23976698wiu.1
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 09:18:25 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id p10si4814384wjz.24.2015.04.30.09.18.24
        for <linux-mm@kvack.org>;
        Thu, 30 Apr 2015 09:18:24 -0700 (PDT)
Date: Thu, 30 Apr 2015 19:18:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 03/11] mm: debug: dump VMA into a string rather than
 directly on screen
Message-ID: <20150430161822.GB17344@node.dhcp.inet.fi>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
 <1429044993-1677-4-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429044993-1677-4-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, Apr 14, 2015 at 04:56:25PM -0400, Sasha Levin wrote:
> This lets us use regular string formatting code to dump VMAs, use it
> in VM_BUG_ON_VMA instead of just printing it to screen as well.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  include/linux/mmdebug.h |    8 ++++++--
>  lib/vsprintf.c          |    7 +++++--
>  mm/debug.c              |   26 ++++++++++++++------------
>  3 files changed, 25 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
> index 877ef22..506e405 100644
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -10,10 +10,10 @@ struct mm_struct;
>  extern void dump_page(struct page *page, const char *reason);
>  extern void dump_page_badflags(struct page *page, const char *reason,
>  			       unsigned long badflags);
> -void dump_vma(const struct vm_area_struct *vma);
>  void dump_mm(const struct mm_struct *mm);
>  
>  #ifdef CONFIG_DEBUG_VM
> +char *format_vma(const struct vm_area_struct *vma, char *buf, char *end);
>  #define VM_BUG_ON(cond) BUG_ON(cond)
>  #define VM_BUG_ON_PAGE(cond, page)					\
>  	do {								\
> @@ -25,7 +25,7 @@ void dump_mm(const struct mm_struct *mm);
>  #define VM_BUG_ON_VMA(cond, vma)					\
>  	do {								\
>  		if (unlikely(cond)) {					\
> -			dump_vma(vma);					\
> +			pr_emerg("%pZv", vma);				\
>  			BUG();						\
>  		}							\
>  	} while (0)
> @@ -40,6 +40,10 @@ void dump_mm(const struct mm_struct *mm);
>  #define VM_WARN_ON_ONCE(cond) WARN_ON_ONCE(cond)
>  #define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
>  #else
> +static char *format_vma(const struct vm_area_struct *vma, char *buf, char *end)
> +{

Again: print address ?

> +	return buf;
> +}
>  #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
>  #define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
>  #define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
