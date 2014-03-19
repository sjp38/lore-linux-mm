Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 43DEF6B017C
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 16:33:08 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so9461425pbb.33
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 13:33:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bo2si69139pbb.250.2014.03.19.13.33.07
        for <linux-mm@kvack.org>;
        Wed, 19 Mar 2014 13:33:07 -0700 (PDT)
Date: Wed, 19 Mar 2014 13:33:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND -mm 2/2] mm/mempolicy.c: add comment in
 queue_pages_hugetlb()
Message-Id: <20140319133305.13cb7a03f6bd3745889f65b3@linux-foundation.org>
In-Reply-To: <1395196179-4075-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1395196179-4075-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1395196179-4075-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 18 Mar 2014 22:29:39 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> We have a race where we try to migrate an invalid page, resulting in
> hitting VM_BUG_ON_PAGE in isolate_huge_page().
> queue_pages_hugetlb() is OK to fail, so let's check !PageHeadHuge to keep
> invalid hugepage from queuing.
> 
> ..
>
> --- v3.14-rc7-mmotm-2014-03-18-16-37.orig/mm/mempolicy.c
> +++ v3.14-rc7-mmotm-2014-03-18-16-37/mm/mempolicy.c
> @@ -530,6 +530,17 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long addr,
>  	if (!pte_present(entry))
>  		return 0;
>  	page = pte_page(entry);
> +
> +	/*
> +	 * Trinity found that page could be a non-hugepage. This is an
> +	 * unexpected behavior, but it's not clear how this problem happens.
> +	 * So let's simply skip such corner case. Page migration can often
> +	 * fail for various reasons, so it's ok to just skip the address
> +	 * unsuitable to hugepage migration.
> +	 */
> +	if (!PageHeadHuge(page))
> +		return 0;
> +

Whoa, we won't be doing this thanks.  The day we resort to this sort of
thing is the day we revert to the 2.2.26 VM.

I suppose I'd be OK with putting

	if (WARN_ON(!PageHeadHuge(page)))
		return 0;

in there as a temporary be-kind-to-testers thing, but we must get a
full understanding of what's happening in there.

Was this problem caused by or exposed by the pagetable walker patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
