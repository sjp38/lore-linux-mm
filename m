Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2B3A46B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 23:51:19 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3J3pFVw022904
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 19 Apr 2010 12:51:15 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A8AA45DE4F
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 12:51:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5108945DE4E
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 12:51:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D0EA31DB805B
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 12:51:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F83C1DB803F
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 12:51:13 +0900 (JST)
Date: Mon, 19 Apr 2010 12:47:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: question about COW
Message-Id: <20100419124722.d4691122.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4BC95E2E.5040801@browserseal.com>
References: <4BC95E2E.5040801@browserseal.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sasha Sirotkin <buildroot@browserseal.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 17 Apr 2010 10:07:26 +0300
Sasha Sirotkin <buildroot@browserseal.com> wrote:

> There is an "early COW" mechanism in __do_fault() which, if the page is 
> not present and the fault is FAULT_PAGE_WRITE goes ahead and copies the 
> page in order to prevent the next exception.
> 
> The question - why the code in __do_fault() does not decrease the shared 
> map count of the old page as do_wp_page does ? And while we are at it, 
> while this "early COW" code is much more simple than do_wp_page()?
> 
> Thanks.
> 
IIUC.

Case 1) A task cause a write page fault because pte is not set as PRESENT.
        __do_fault() is called. And the kernel found vma is not-SHARED.

       Do eary-COW. In this case, the old page was not _mapped_...IOW, the task's
       this pte was not accounted into old_page->mapcount.
       We just increase new_page->mapcount. Don't touch old_page->mapcount.

Case 2) A task caused a write page fault because pte was not WRITABLE.
       
       do_wp_page() is called because the page was _mapped_.
       If the page is shared, decrease old_page->mapcount, increae new_page->mapcount.

Regard,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
