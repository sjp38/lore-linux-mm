Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E4F4C8D003A
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 01:46:28 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2AA883EE0B6
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:46:27 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 14C4145DE52
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:46:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ED07645DE50
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:46:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D01DCEF8001
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:46:26 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F304EF8009
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:46:26 +0900 (JST)
Date: Wed, 9 Feb 2011 15:40:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmotm] BUG: Bad page state in process khugepaged ?
Message-Id: <20110209154017.f6489f4e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110209151036.f24a36a6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110209151036.f24a36a6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Wed, 9 Feb 2011 15:10:36 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 2nd log, "kernel BUG at include/linux/mm.h:420!" is  This one.
> ==
> static inline void __ClearPageBuddy(struct page *page)
> {
>         VM_BUG_ON(!PageBuddy(page));
>         atomic_set(&page->_mapcount, -1);
> }
> ==
> But this is just a tail of bad_page().
> ==
> static void bad_page(struct page *page)
> {
>         static unsigned long resume;
>         static unsigned long nr_shown;
>         static unsigned long nr_unshown;
> ...
>         dump_stack();
> out:
>         /* Leave bad fields for debug, except PageBuddy could make trouble */
>         __ClearPageBuddy(page);
>         add_taint(TAINT_BAD_PAGE);
> }
> ==
> So, what important is bad_page().
> 
> BAD page says
> ==
> BUG: Bad page state in process khugepaged  pfn:1e9800
> page:ffffea0006b14000 count:0 mapcount:0 mapping:          (null) index:0x2800
> page flags: 0x40000000004000(head)
> pc:ffff880214a30000 pc->flags:2146246697418756 pc->mem_cgroup:ffffc9000177a000
> ==
> 
> Maybe page_mapcount(page) was > 0. and ->mapping was NULL.
Sorry please ignore above. bad_page() used page_mapcount().


Regards,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
