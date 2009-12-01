Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 867C0600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 19:42:43 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB10gfjo031003
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Dec 2009 09:42:41 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B315345DE57
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 09:42:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CBB845DE4F
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 09:42:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 702021DB8044
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 09:42:39 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AA981DB803E
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 09:42:38 +0900 (JST)
Date: Tue, 1 Dec 2009 09:39:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-Id: <20091201093945.8c24687f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091130120705.GD30235@random.random>
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
	<Pine.LNX.4.64.0911241640590.25288@sister.anvils>
	<20091130094616.8f3d94a7.kamezawa.hiroyu@jp.fujitsu.com>
	<20091130120705.GD30235@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Nov 2009 13:07:05 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Mon, Nov 30, 2009 at 09:46:16AM +0900, KAMEZAWA Hiroyuki wrote:
> > Hmm. I'm not sure how many pages are shared in a system but
> > can't we add some threshold for avoidng too much scan against shared pages ?
> > (in vmscan.c)
> > like..
> >       
> >        if (page_mapcount(page) > (XXXX >> scan_priority))
> > 		return 1;
> > 
> > I saw terrible slow downs in shmem-swap-out in old RHELs (at user support).
> > (Added kosaki to CC.)
> 
> If those ptes are all old there's no reason to keep those pages in ram
> more... I don't like those magic number levels. If you saw slowdowns
> it'd be interesting to get more information on those workloads. I
> never seen swap out workloads in real life that are not 99% I/O
> dominated, there's nothing that loads the cpu anything close to 100%,
> so nothing that a magic check like above could affect. 

I saw an user incident that all 64cpus hangs on shmem's spinlock and get
great slow down, cluster fail over. 
As workaround, we recommend them to use hugepage. It's not scanned.

Hmm. Can KSM coalesce 10000+ of pages to a page ? In such case, lru
need to scan 10000+ ptes with 10000+ anon_vma->lock and 10000+ pte locks
for reclaiming a page.


> Besides tmpfs
> unmap methods are different from ksm and anon pages unmap methods, and
> certain locks are coarser if there's userland taking i_mmap_lock for
> I/O during paging.
> 
maybe. 

Hmm, Larry Woodman reports another? issue.
http://marc.info/?l=linux-mm&m=125961823921743&w=2

Maybe some modification to lru scanning is necessary independent from ksm.
I think.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
