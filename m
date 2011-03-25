Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 34A638D0040
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:00:22 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p2P50Kk5012040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 22:00:20 -0700
Received: from gyf3 (gyf3.prod.google.com [10.243.50.67])
	by wpaz17.hot.corp.google.com with ESMTP id p2P4xtLi008990
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 22:00:19 -0700
Received: by gyf3 with SMTP id 3so420384gyf.17
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 22:00:17 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 24 Mar 2011 22:00:16 -0700
Message-ID: <AANLkTinHBouEU2pAVOfuakxYqA_QFVLz=qY-f8ZW6fTG@mail.gmail.com>
Subject: get_page() vs __split_huge_page_refcount()
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>

Hi,

I am getting up to speed with mainline THP code and was wondering
what's going on with reference counts within
__split_huge_page_refcount():

        for (i = 1; i < HPAGE_PMD_NR; i++) {
                struct page *page_tail = page + i;

                /* tail_page->_count cannot change */
                atomic_sub(atomic_read(&page_tail->_count), &page->_count);
                BUG_ON(page_count(page) <= 0);
                ...

A look at get_page() gave a partial answer. First, the page refcount
is incremented, then, if this was a tail page, the head page is looked
up and its refcount is incremented too. __split_huge_page_refcount()
preserves the refcount of tail pages but substracts it from the head
page, as it'll be an independent page after the split. However this
comment lead to more head scratching:

                /*
                 * This is safe only because
                 * __split_huge_page_refcount can't run under
                 * get_page().
                 */

As I can see, follow_page() with a FOLL_GET flag is careful when it
encounters huge pages. It tests the _PAGE_SPLITTING bit in the pmd
(under protection of page_table_lock) to avoid racing with
__split_huge_page_refcount(). Then, it can safely call get_page() and
not worry about both refcounts updates being visible at once.

My question is this: After someone obtains a page reference using
get_user_pages(), what prevents them from getting additional
references with get_page() ? I always thought it was legal to
duplicate references that way, but now I don't see how it'd be safe
doing so on anon pages with THP enabled.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
