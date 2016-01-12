Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 59FA7828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 18:50:01 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id cy9so347623693pac.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 15:50:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b1si13177828pat.100.2016.01.12.15.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 15:50:00 -0800 (PST)
Date: Tue, 12 Jan 2016 15:49:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/2] mm: soft-offline: exit with failure for non
 anonymous thp
Message-Id: <20160112154959.009a3944dd094dc2234e2f65@linux-foundation.org>
In-Reply-To: <1452568245-10412-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20160108123300.843d370916d3248be297d831@linux-foundation.org>
	<1452568245-10412-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1452568245-10412-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Tue, 12 Jan 2016 12:10:45 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently memory_failure() doesn't handle non anonymous thp case, because we
> can hardly expect the error handling to be successful, and it can just hit
> some corner case which results in BUG_ON or something severe like that.
> This is also the case for soft offline code, so let's make it in the same way.
> 
> Orignal code has a MF_COUNT_INCREASED check before put_hwpoison_page(), but
> it's unnecessary because get_any_page() is already called when running on
> this code, which takes a refcount of the target page regardress of the flag.
> So this patch also removes it.
> 
> ...
>
> --- next-20160111/mm/memory-failure.c
> +++ next-20160111_patched/mm/memory-failure.c
> @@ -1691,16 +1691,16 @@ static int soft_offline_in_use_page(struct page *page, int flags)
>  
>  	if (!PageHuge(page) && PageTransHuge(hpage)) {
>  		lock_page(hpage);
> -		ret = split_huge_page(hpage);
> -		unlock_page(hpage);
> -		if (unlikely(ret || PageTransCompound(page) ||
> -			     !PageAnon(page))) {
> -			pr_info("soft offline: %#lx: failed to split THP\n",
> -				page_to_pfn(page));
> -			if (flags & MF_COUNT_INCREASED)
> -				put_hwpoison_page(hpage);
> +		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
> +			unlock_page(hpage);
> +			if (!PageAnon(hpage))
> +				pr_info("soft offline: %#lx: non anonymous thp\n", pfn);
> +			else
> +				pr_info("soft offline: %#lx: thp split failed\n", pfn);
> +			put_hwpoison_page(hpage);
>  			return -EBUSY;
>  		}

hm, what happened there.

mm/memory-failure.c: In function 'soft_offline_in_use_page':
mm/memory-failure.c:1697: error: 'pfn' undeclared (first use in this function)
mm/memory-failure.c:1697: error: (Each undeclared identifier is reported only once
mm/memory-failure.c:1697: error: for each function it appears in.)

--- a/mm/memory-failure.c~mm-soft-offline-exit-with-failure-for-non-anonymous-thp-fix
+++ a/mm/memory-failure.c
@@ -1694,9 +1694,9 @@ static int soft_offline_in_use_page(stru
 		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
 			unlock_page(hpage);
 			if (!PageAnon(hpage))
-				pr_info("soft offline: %#lx: non anonymous thp\n", pfn);
+				pr_info("soft offline: %#lx: non anonymous thp\n", page_to_pfn(page));
 			else
-				pr_info("soft offline: %#lx: thp split failed\n", pfn);
+				pr_info("soft offline: %#lx: thp split failed\n", page_to_pfn(page));
 			put_hwpoison_page(hpage);
 			return -EBUSY;
 		}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
