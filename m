Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id BA4836B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 03:33:43 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so101160957pdn.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 00:33:43 -0700 (PDT)
Received: from us-alimail-mta2.hst.scl.en.alidc.net (mail113-249.mail.alibaba.com. [205.204.113.249])
        by mx.google.com with ESMTP id f4si7751567pas.112.2015.03.20.00.33.41
        for <linux-mm@kvack.org>;
        Fri, 20 Mar 2015 00:33:42 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <010501d062df$05125160$0f36f420$@alibaba-inc.com>
In-Reply-To: <010501d062df$05125160$0f36f420$@alibaba-inc.com>
Subject: Re: [PATCH 04/16] page-flags: define PG_locked behavior on compound pages
Date: Fri, 20 Mar 2015 15:32:05 +0800
Message-ID: <010601d062df$f7b5a4d0$e720ee70$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hillf Danton <hillf.zj@alibaba-inc.com>

> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -269,7 +269,7 @@ static inline struct page *compound_head_fast(struct page *page)
>  	return page;
>  }
> 
> -TESTPAGEFLAG(Locked, locked, ANY)
> +__PAGEFLAG(Locked, locked, NO_TAIL)
>  PAGEFLAG(Error, error, ANY) TESTCLEARFLAG(Error, error, ANY)
>  PAGEFLAG(Referenced, referenced, ANY) TESTCLEARFLAG(Referenced, referenced, ANY)
>  	__SETPAGEFLAG(Referenced, referenced, ANY)
[...]
> @@ -490,9 +481,9 @@ extern int wait_on_page_bit_killable_timeout(struct page *page,
> 
>  static inline int wait_on_page_locked_killable(struct page *page)
>  {
> -	if (PageLocked(page))
> -		return wait_on_page_bit_killable(page, PG_locked);
> -	return 0;
> +	if (!PageLocked(page))
> +		return 0;

I am lost here: can we feed any page to NO_TAIL operation?

> +	return wait_on_page_bit_killable(compound_head(page), PG_locked);
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
