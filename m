Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8EAB16B0193
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 00:55:54 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 915E43EE0BB
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 13:55:50 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7584445DF49
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 13:55:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 51A8245DF41
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 13:55:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 408671DB8040
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 13:55:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B2011DB803E
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 13:55:50 +0900 (JST)
Date: Fri, 14 Oct 2011 13:54:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/9] kstaled: rate limit pages scanned per second.
Message-Id: <20111014135404.b56bed48.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CANN689HOALiiBKLUHRFuONQEyqp2on0GA1ycEguf0S6WFeuP7w@mail.gmail.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-7-git-send-email-walken@google.com>
	<20110928171309.b45c684f.kamezawa.hiroyu@jp.fujitsu.com>
	<CANN689GFE_hqtndKY6i4ouBBe+gVU_pqOK2HRrc-U1LJMONaXw@mail.gmail.com>
	<20110928175947.d3af52f0.kamezawa.hiroyu@jp.fujitsu.com>
	<CANN689HOALiiBKLUHRFuONQEyqp2on0GA1ycEguf0S6WFeuP7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Thu, 13 Oct 2011 18:25:06 -0700
Michel Lespinasse <walken@google.com> wrote:

> On Wed, Sep 28, 2011 at 1:59 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 28 Sep 2011 01:19:50 -0700
> > Michel Lespinasse <walken@google.com> wrote:
> >> It tends to perform worse if we try making it multithreaded. What
> >> happens is that the scanning threads call page_referenced() a lot, and
> >> if they both try scanning pages that belong to the same file that
> >> causes the mapping's i_mmap_mutex lock to bounce. Same things happens
> >> if they try scanning pages that belong to the same anon VMA too.
> >>
> >
> > Hmm. with brief thinking, if you can scan list of page tables,
> > you can set young flags without any locks.
> > For inode pages, you can hook page lookup, I think.
> 
> It would be possible to avoid taking rmap locks by instead scanning
> all page tables, and transferring the pte young bits observed there to
> the PageYoung page flag. This is a significant design change, but
> would indeed work.
> 
> Just to clarify the idea, how would you go about finding all page
> tables to scan ? The most straightforward approach would be iterate
> over all processes and scan their address spaces, but I don't think we
> can afford to hold tasklist_lock (even for reads) for so long, so we'd
> have to be a bit smarter than that... I can think of a few different
> ways but I'd like to know if you have something specific in mind
> first.

Maybe there are several idea. 

1. how about chasing "pgd" kmem_cache ?
   I'm not sure but in x86 it seems all pgds are lined to pgd_list.
   Now, it's not RCU list but making it as RCU list isn't hard.
   Note: IIUC, struct page for pgd contains pointer to mm_struct.

2. track dup_mm and do_exec.
   insert hook and maintain list of mm_struct.(It's not needed to be
   implemented as list)

3. Like pgd_list, add some flag to pgd pages. Then, you can scan memmap
   and find 'pgd' page and walk into the page table tree.

Hmm ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
