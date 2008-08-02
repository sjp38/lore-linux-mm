Received: from [172.20.26.134]([172.20.26.134]) (1416 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1KPD2u-000161C@megami.veritas.com>
	for <linux-mm@kvack.org>; Sat, 2 Aug 2008 02:05:04 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Sat, 2 Aug 2008 10:05:18 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: s390's PageSwapCache test
Message-ID: <Pine.LNX.4.64.0808020944330.1992@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Martin,

I'm slightly bothered by that PageSwapCache() test you've just added
in page_remove_rmap(), before s390's page_test_dirty():

		if ((!PageAnon(page) || PageSwapCache(page)) &&
		    page_test_dirty(page)) {
			page_clear_dirty(page);
			set_page_dirty(page);
		}

It's not wrong; but if it's necessary, then I need to understand why;
and if it's unnecessary, then we'd do better to remove it (optimizing
your optimization a little).

I believe it's unnecessary: it is possible, yes, to arrive here and
find the anon page dirty with respect to what's on swap disk; but
because anon pages are COWed, never sharing modification with other
users, that will only be so if we're the only user of that page, and
about to free it, in which case no point in doing the set_page_dirty().

For a very similar case, see the PageAnon() test in zap_pte_range(),
where we also skip the set_page_dirty().

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
