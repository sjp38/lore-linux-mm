Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4EBCA828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 15:33:02 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id 65so14361038pff.2
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 12:33:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 14si7123039pfa.12.2016.01.08.12.33.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 12:33:01 -0800 (PST)
Date: Fri, 8 Jan 2016 12:33:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] mm: soft-offline: exit with failure for non
 anonymous thp
Message-Id: <20160108123300.843d370916d3248be297d831@linux-foundation.org>
In-Reply-To: <1452237842-11076-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1452237842-11076-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Fri,  8 Jan 2016 16:24:02 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently memory_failure() doesn't handle non anonymous thp case, because we
> can hardly expect the error handling to be successful, and it can just hit
> some corner case which results in BUG_ON or something severe like that.
> This is also a case for soft offline code, so let's make it in the same way.
> 
> ...
>
> --- v4.4-rc8/mm/memory-failure.c
> +++ v4.4-rc8_patched/mm/memory-failure.c
> @@ -1751,9 +1751,11 @@ int soft_offline_page(struct page *page, int flags)
>  		return -EBUSY;
>  	}
>  	if (!PageHuge(page) && PageTransHuge(hpage)) {
> -		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
> -			pr_info("soft offline: %#lx: failed to split THP\n",
> -				pfn);
> +		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
> +			if (!PageAnon(hpage))
> +				pr_info("soft offline: %#lx: non anonymous thp\n", pfn);
> +			else
> +				pr_info("soft offline: %#lx: thp split failed\n", pfn);
>  			if (flags & MF_COUNT_INCREASED)
>  				put_hwpoison_page(page);
>  			return -EBUSY;

Kirill's
http://ozlabs.org/~akpm/mmots/broken-out/thp-mm-split_huge_page-caller-need-to-lock-page.patch
mucks with this code as well.  Could you please redo this patch against
linux-next?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
