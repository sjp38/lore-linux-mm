Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BB23D9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 05:00:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 23A123EE0C7
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 18:00:37 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FCA945DEB3
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 18:00:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 12F0D45DEA6
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 18:00:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 022801DB8042
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 18:00:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BB49C1DB803B
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 18:00:35 +0900 (JST)
Date: Wed, 28 Sep 2011 17:59:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/9] kstaled: rate limit pages scanned per second.
Message-Id: <20110928175947.d3af52f0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CANN689GFE_hqtndKY6i4ouBBe+gVU_pqOK2HRrc-U1LJMONaXw@mail.gmail.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-7-git-send-email-walken@google.com>
	<20110928171309.b45c684f.kamezawa.hiroyu@jp.fujitsu.com>
	<CANN689GFE_hqtndKY6i4ouBBe+gVU_pqOK2HRrc-U1LJMONaXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Wed, 28 Sep 2011 01:19:50 -0700
Michel Lespinasse <walken@google.com> wrote:

> On Wed, Sep 28, 2011 at 1:13 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 27 Sep 2011 17:49:04 -0700
> > Michel Lespinasse <walken@google.com> wrote:
> >
> >> Scan some number of pages from each node every second, instead of trying to
> >> scan the entime memory at once and being idle for the rest of the configured
> >> interval.
> >>
> >> In addition to spreading the CPU usage over the entire scanning interval,
> >> this also reduces the jitter between two consecutive scans of the same page.
> >>
> >>
> >> Signed-off-by: Michel Lespinasse <walken@google.com>
> >
> > Does this scan thread need to be signle thread ?
> 
> It tends to perform worse if we try making it multithreaded. What
> happens is that the scanning threads call page_referenced() a lot, and
> if they both try scanning pages that belong to the same file that
> causes the mapping's i_mmap_mutex lock to bounce. Same things happens
> if they try scanning pages that belong to the same anon VMA too.
> 

Hmm. with brief thinking, if you can scan list of page tables,
you can set young flags without any locks. 
For inode pages, you can hook page lookup, I think.

You only need to clear Young flag by scanning [pfn, end_pfn].
Then, multi-threaded. ?


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
