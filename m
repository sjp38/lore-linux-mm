Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2EB286B00CE
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 22:54:15 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J2sAxg017920
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 11:54:11 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3624A45DE58
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 11:54:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D775945DE57
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 11:54:09 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B528E38003
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 11:54:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E1C4CE38001
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 11:54:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
In-Reply-To: <AANLkTi=1j5ejRyki+2wmKvOitorteW6uL53wfAWiPeAs@mail.gmail.com>
References: <20101019105257.A1C6.A69D9226@jp.fujitsu.com> <AANLkTi=1j5ejRyki+2wmKvOitorteW6uL53wfAWiPeAs@mail.gmail.com>
Message-Id: <20101019113316.A1CF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Oct 2010 11:54:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> >> > Can you please elaborate your intention? Do you think Wu's approach is wrong?
> >>
> >> No. I think Wu's patch may work well. But I agree Andrew.
> >> Couldn't we remove the too_many_isolated logic? If it is, we can solve
> >> the problem simply.
> >> But If we remove the logic, we will meet long time ago problem, again.
> >> So my patch's intention is to prevent OOM and deadlock problem with
> >> simple patch without adding new heuristic in too_many_isolated.
> >
> > But your patch is much false positive/negative chance because isolated pages timing
> > and too_many_isolated_zone() call site are in far distance place.
> 
> Yes.
> How about the returning *did_some_progress can imply too_many_isolated
> fail by using MSB or new variable?
> Then, page_allocator can check it whether it causes read reclaim fail
> or parallel reclaim.
> The point is let's throttle without holding FS/IO lock.

Wu's version sleep in shrink_inactive_list(). your version sleep in __alloc_pages_slowpath()
by wait_iff_congested(). both don't release lock, I think.
But, if alloc_pages() return fail if GFP_NOIO, we introduce another issue.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
