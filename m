Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2922A6B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 04:05:28 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2G85Pam006440
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 16 Mar 2009 17:05:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EB5045DE51
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:05:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8357C45DD72
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:05:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 734421DB8043
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:05:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EC657E18004
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:05:21 +0900 (JST)
Date: Mon, 16 Mar 2009 17:03:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: BUG?: PAGE_FLAGS_CHECK_AT_PREP seems to be cleared too early (Was
 Re: I just got got another Oops
Message-Id: <20090316170359.858e7a4e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090316115509.40ea13da.kamezawa.hiroyu@jp.fujitsu.com>
References: <200903120133.11583.gene.heskett@gmail.com>
	<49B8C98D.3020309@davidnewall.com>
	<200903121431.49437.gene.heskett@gmail.com>
	<20090316115509.40ea13da.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "hugh@veritas.com" <hugh@veritas.com>
Cc: Gene Heskett <gene.heskett@gmail.com>, David Newall <davidn@davidnewall.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,
I'm sorry if I miss something..

>From this patch
==
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=79f4b7bf393e67bbffec807cc68caaefc72b82ee
==
#define PAGE_FLAGS_CHECK_AT_PREP       ((1 << NR_PAGEFLAGS) - 1)
...
@@ -468,16 +467,16 @@ static inline int free_pages_check(struct page *page)
                (page_count(page) != 0)  |
                (page->flags & PAGE_FLAGS_CHECK_AT_FREE)))
....
+       if (PageReserved(page))
+               return 1;
+       if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
+               page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+       return 0;
 }
==

PAGE_FLAGS_CHECK_AT_PREP is cleared by free_pages_check().

This means PG_head/PG_tail(PG_compound) flags are cleared here and Compound page
will never be freed in sane way.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
