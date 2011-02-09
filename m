Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 25EE18D003A
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 01:58:58 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 45DEC3EE0B5
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:58:55 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D0D6845DE5C
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:58:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E63445DE59
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:58:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 913CFE78002
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:58:54 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EE7DE08002
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:58:54 +0900 (JST)
Date: Wed, 9 Feb 2011 15:52:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmotm] BUG: Bad page state in process khugepaged ?
Message-Id: <20110209155246.69a7f3a1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110209155001.0e369475.nishimura@mxp.nes.nec.co.jp>
References: <20110209151036.f24a36a6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110209155001.0e369475.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Wed, 9 Feb 2011 15:50:01 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > 
> > In hex, pc->flags was 7A00000000004 and this means PCG_USED bit is set.
> > This implies page_remove_rmap() may not be called but ->mapping is NULL. Hmm?
> > (7A is encoding of section number.)
> > 
> Sigh.. it seems another freed-but-not-uncharged problem..
> 

Ah, ok, this is maybe caused by this. I'm sorry that I missed this.
==
static inline int free_pages_check(struct page *page)
{
        if (unlikely(page_mapcount(page) |
                (page->mapping != NULL)  |
                (atomic_read(&page->_count) != 0) |
                (page->flags & PAGE_FLAGS_CHECK_AT_FREE) |
                (mem_cgroup_bad_page_check(page)))) {    <==========(*)
                bad_page(page);
                return 1;
==

Then, ok, this is a memcgroup and hugepage issue.

I'll look into.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
