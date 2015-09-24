Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0A41E82F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 12:51:26 -0400 (EDT)
Received: by qkap81 with SMTP id p81so32181576qka.2
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 09:51:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k197si2524727qhk.19.2015.09.24.09.51.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 09:51:25 -0700 (PDT)
Date: Thu, 24 Sep 2015 18:51:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] futex: prevent endless loop on s390x with emulated
 hugepages
Message-ID: <20150924165122.GU25412@redhat.com>
References: <1443107148-28625-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1443107148-28625-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yong Sun <yosun@suse.com>, linux390@de.ibm.com, linux-s390@vger.kernel.org, Zhang Yi <wetpzy@gmail.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>

On Thu, Sep 24, 2015 at 05:05:48PM +0200, Vlastimil Babka wrote:
> The problem is an endless loop in get_futex_key() when
> CONFIG_TRANSPARENT_HUGEPAGE is enabled and the s390x machine has emulated
> hugepages. The code tries to serialize against __split_huge_page_splitting(),
> but __get_user_pages_fast() fails on the hugetlbfs tail page. This happens
> because pmd_large() is false for emulated hugepages, so the code will proceed
> into gup_pte_range() and fail page_cache_get_speculative() through failing
> get_page_unless_zero() as the tail page count is zero. Failing __gup_fast is
> supposed to be temporary due to a race, so get_futex_key() will try again
> endlessly.
> 
> This attempt for a fix is a bandaid solution and probably incomplete.
> Hopefully something better will emerge from the discussion. Fully fixing
> emulated hugepages just for stable backports is unlikely due to them being
> removed. Also THP refcounting redesign should soon remove the trickery from
> get_futex_key().

THP refcounting redesign will simplify things a lot here because the
head page cannot be freed from under us if we hold a reference on the
tail.

With the current split_huge_page that cannot fail, it should be
possible to stop using __get_user_pages_fast to reach the head page
and pin it before it can be freed from under us by using the
compound_lock_irqsave too.

The old code could have done get_page on a already freed head page (if
the THP was splitted after compound_head returned) and this is why it
needed adjustement. Here we just need to safely get a refcount on the
head page.

If we do get_page_unless_zero() on the head page returned by
compound_head, take compound_lock_irqsave and check if the tail page
is still a tail (which means split_huge_page hasn't run yet and it
cannot run anymore by holding the compound_lock), then we can take a
reference on the head page. After we take a reference on the head we
just put_page the tail page and we continue using the page_head.

It should be the very same logic of __get_page_tail, except we don't
want the refcount taken on the tail too (i.e. we must not increase the
mapcount and we should skip the get_huge_page_tail or the head will be
freed again if split_huge_page runs as result of MADV_DONTNEED and it
literally frees the head). We want only one more recount on the head
because the code then only works with page_head and we don't care
about the tail anymore. A new function get_head_page() may work for
that and avoid the pagetable walking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
