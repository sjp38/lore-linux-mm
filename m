Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3EA046B01F0
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 19:56:08 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3MNu5h5017639
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 23 Apr 2010 08:56:05 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 383E245DE4E
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 08:56:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1145F45DE58
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 08:56:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AD5F01DB8061
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 08:56:04 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 39AAC1DB805F
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 08:56:04 +0900 (JST)
Date: Fri, 23 Apr 2010 08:52:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
 PageSwapCache pages
Message-Id: <20100423085203.b43d1cb3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1004221439040.5023@router.home>
References: <20100421153421.GM30306@csn.ul.ie>
	<alpine.DEB.2.00.1004211038020.4959@router.home>
	<20100422092819.GR30306@csn.ul.ie>
	<20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	<x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com>
	<20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com>
	<20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100422141404.GA30306@csn.ul.ie>
	<p2y28c262361004220718m3a5e3e2ekee1fef7ebdae8e73@mail.gmail.com>
	<20100422154003.GC30306@csn.ul.ie>
	<20100422192923.GH30306@csn.ul.ie>
	<alpine.DEB.2.00.1004221439040.5023@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010 14:40:46 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Thu, 22 Apr 2010, Mel Gorman wrote:
> 
> > vma_adjust() is updating anon VMA information without any locks taken.
> > In constract, file-backed mappings use the i_mmap_lock. This lack of
> > locking can result in races with page migration. During rmap_walk(),
> > vma_address() can return -EFAULT for an address that will soon be valid.
> > This leaves a dangling migration PTE behind which can later cause a
> > BUG_ON to trigger when the page is faulted in.
> 
> Isnt this also a race with reclaim /  swap?
> 
Yes, it's also race in reclaim/swap ...
  page_referenced()
  try_to_unmap().
  rmap_walk()  <==== we hit this case.

But above 2 are not considered to be critical.

I'm not sure how this race affect KSM.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
