Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 96AE45F0003
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:01:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n51Nsvu8007709
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Jun 2009 08:54:57 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 68AE745DE57
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 08:54:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 43AC045DD79
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 08:54:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 173C91DB803A
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 08:54:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B915D1DB8038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 08:54:53 +0900 (JST)
Date: Tue, 2 Jun 2009 08:53:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Inconsistency (bug) of vm_insert_page with high order
 allocations
Message-Id: <20090602085319.e0c23910.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <202cde0e0905292242k313148b8nbc1a47e558f97a1c@mail.gmail.com>
References: <202cde0e0905272207y2926d679s7380a0f26f6c6e71@mail.gmail.com>
	<20090528143524.e8a2cde7.kamezawa.hiroyu@jp.fujitsu.com>
	<202cde0e0905280002o5614f279r9db7c8c52ad7df10@mail.gmail.com>
	<20090528162108.a6adcc36.kamezawa.hiroyu@jp.fujitsu.com>
	<202cde0e0905292242k313148b8nbc1a47e558f97a1c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: linux-mm@kvack.org, greg@kroah.com, vijaykumar@bravegnu.org
List-ID: <linux-mm.kvack.org>

On Sat, 30 May 2009 17:42:35 +1200
Alexey Korolev <akorolex@gmail.com> wrote:

> Kame San,
> 
> Thank you for your answers. I've decided to use split_pages function.
> >
> >  - write a patch for adding alloc_page_exact_nodemask()  // this is not difficult.
> >  - explain why you need this.
> >  - discuss.
> >
> Writing the patch is not dificult - but it will be hard to explain why
> it is necessary in kernel...
> > IMHO, considering other mmap/munmap/zap_pte, etc... page_count() and page_mapocunt()
> > should be controlled per pte. Then, you'll have to map pages one by one.
> >
> This is quite interesting. I tried to understand this code but it is
> much complicated. I clearly understand why pages have to be mapped one
> by one. By I don't understand how counters relate to this. (it is just
> a curiosity question - I won't be upset if no one answer it)
> 
The kernel/cpu cannot handle changes to multiple ptes/TLBs at once. Then,
if mapcount/count is not per pte, there will be "partially mapped/unmapped" racy
state. That's a bad and we'll need a complicated synchronization technique to
map/unmap multiple ptes/TLBs at once. It seems impossible.(and not worth to try)

Thanks
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
