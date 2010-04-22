Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A7F2E6B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 06:35:06 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3MAZ4K7017176
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Apr 2010 19:35:04 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EF0045DE57
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 19:35:04 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DF95845DE51
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 19:35:03 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C024D1DB8015
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 19:35:03 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D7381DB8016
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 19:35:03 +0900 (JST)
Date: Thu, 22 Apr 2010 19:31:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
 PageSwapCache  pages
Message-Id: <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
	<alpine.DEB.2.00.1004210927550.4959@router.home>
	<20100421150037.GJ30306@csn.ul.ie>
	<alpine.DEB.2.00.1004211004360.4959@router.home>
	<20100421151417.GK30306@csn.ul.ie>
	<alpine.DEB.2.00.1004211027120.4959@router.home>
	<20100421153421.GM30306@csn.ul.ie>
	<alpine.DEB.2.00.1004211038020.4959@router.home>
	<20100422092819.GR30306@csn.ul.ie>
	<20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	<x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010 19:13:12 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Thu, Apr 22, 2010 at 6:46 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > Hmm..in my test, the case was.
> >
> > Before try_to_unmap:
> > A  A  A  A mapcount=1, SwapCache, remap_swapcache=1
> > After remap
> > A  A  A  A mapcount=0, SwapCache, rc=0.
> >
> > So, I think there may be some race in rmap_walk() and vma handling or
> > anon_vma handling. migration_entry isn't found by rmap_walk.
> >
> > Hmm..it seems this kind patch will be required for debug.
> 
> I looked do_swap_page, again.
> lock_page is called long after migration_entry_wait.
> It means lock_page can't close the race.
> 
> So I think this BUG is possible.
> What do you think?
> 

I think it's not a problem.
When migration-entry-wait is called, enry_wait() does

	pte_lock();
	check migration_pte
	check it's locked.

And after wait_on_page_locked(), it just returns to user and cause
page fault again. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
