Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 42F0B6B004D
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 19:01:02 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1O00x6A004514
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Feb 2010 09:00:59 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CC5D45DE4F
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:00:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DE32845DE4D
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:00:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C3AFD1DB803C
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:00:58 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B3231DB8037
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:00:58 +0900 (JST)
Date: Wed, 24 Feb 2010 08:57:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 36/36] khugepaged
Message-Id: <20100224085712.1052ed18.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100223142634.GO11504@random.random>
References: <20100221141009.581909647@redhat.com>
	<20100221141758.658303189@redhat.com>
	<20100223165807.ade20de6.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223142634.GO11504@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010 15:26:34 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Tue, Feb 23, 2010 at 04:58:07PM +0900, KAMEZAWA Hiroyuki wrote:
> > I'm not sure but....where this *hpage is chareged to proper memcg ?
> > I think it's good to charge this newpage in the top of this function.
> > (And cancel it at failure, of course.)
> 
> That is just a temporary page owned by khugepaged, not owned by any
> memcg user. Who should I account it against? If allocation fails
> khugepaged just waits alloc_sleep_msec and tries again later.
> 
I can't track all your code, too complex.

What I can see via this patch 36/36 is 
  - all mapped pages are uncharged at page_remove_rmap(), 
  - huge page (new_page) is not charged.

> When the allocated page is actually used to collapse an hugepage, an
> amount of memory equal to the size of the hpage is released. In turn
> khugepaged changes nothing in the memcg accounting. 

That's wrong. 
We cannot assume all mapped pages are belongs to the same memcg.
You should think
 - all mapped pages are uncharged when page_remove_rmap() is called in
   __collapse_huge_page() from unknown memcg.
 - You have to charge a new hugepage when it's mapped to mm's memcg.

Then, silent account migration occurs. I think it's small problem
but should be documented somewhere.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
