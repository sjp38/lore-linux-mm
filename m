Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 698316B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 18:00:20 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so27817155pac.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 15:00:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id po7si24220554pbc.6.2015.05.12.15.00.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 15:00:19 -0700 (PDT)
Date: Tue, 12 May 2015 15:00:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/4] mm/memory-failure: introduce get_hwpoison_page()
 for consistent refcount handling
Message-Id: <20150512150017.4172e4b7bd549e16d8772753@linux-foundation.org>
In-Reply-To: <1431423998-1939-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1431423998-1939-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1431423998-1939-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, 12 May 2015 09:46:47 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> memory_failrue() can run in 2 different mode (specified by MF_COUNT_INCREASED)
> in page refcount perspective. When MF_COUNT_INCREASED is set, memory_failrue()
> assumes that the caller takes a refcount of the target page. And if cleared,
> memory_failure() takes it in it's own.
> 
> In current code, however, refcounting is done differently in each caller. For
> example, madvise_hwpoison() uses get_user_pages_fast() and hwpoison_inject()
> uses get_page_unless_zero(). So this inconsistent refcounting causes refcount
> failure especially for thp tail pages. Typical user visible effects are like
> memory leak or VM_BUG_ON_PAGE(!page_count(page)) in isolate_lru_page().
> 
> To fix this refcounting issue, this patch introduces get_hwpoison_page() to
> handle thp tail pages in the same manner for each caller of hwpoison code.
> 
> There's a non-trivial change around unpoisoning, which now returns immediately
> for thp with "MCE: Memory failure is now running on %#lx\n" message. This is
> not right when split_huge_page() fails. So this patch also allows
> unpoison_memory() to handle thp.
>
> ...
>
>  /*
> + * Get refcount for memory error handling:
> + * - @page: raw page
> + */
> +inline int get_hwpoison_page(struct page *page)
> +{
> +	struct page *head = compound_head(page);
> +
> +	if (PageHuge(head))
> +		return get_page_unless_zero(head);
> +	else if (PageTransHuge(head))
> +		if (get_page_unless_zero(head)) {
> +			if (PageTail(page))
> +				get_page(page);
> +			return 1;
> +		} else {
> +			return 0;
> +		}
> +	else
> +		return get_page_unless_zero(page);
> +}

This function is a bit weird.

- The comment looks like kerneldoc but isn't kerneldoc

- Why the inline?  It isn't fastpath?

- The layout is rather painful.  It could be

	if (PageHuge(head))
		return get_page_unless_zero(head);

	if (PageTransHuge(head)) {
		if (get_page_unless_zero(head)) {
			if (PageTail(page))
				get_page(page);
			return 1;
		} else {
			return 0;
		}
	}

	return get_page_unless_zero(page);

- Some illuminating comments would be nice.  In particular that code
  path where it grabs a ref on the tail page as well as on the head
  page.  What's going on there?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
