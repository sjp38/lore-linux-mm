Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C83236B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 01:36:02 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 28E903EE0B5
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:35:59 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0ECB245DF4F
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:35:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E067B45DF48
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:35:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CCA731DB8040
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:35:58 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E46F1DB803E
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:35:58 +0900 (JST)
Date: Thu, 13 Oct 2011 14:35:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
Message-Id: <20111013143501.a59efa5c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1110121654120.30123@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
	<20110901100650.6d884589.rdunlap@xenotime.net>
	<20110901152650.7a63cb8b@annuminas.surriel.com>
	<alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com>
	<20111010153723.6397924f.akpm@linux-foundation.org>
	<65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com>
	<20111011125419.2702b5dc.akpm@linux-foundation.org>
	<65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com>
	<20111011135445.f580749b.akpm@linux-foundation.org>
	<65795E11DBF1E645A09CEC7EAEE94B9CB516D055@USINDEVS02.corp.hds.com>
	<alpine.DEB.2.00.1110121537380.16286@chino.kir.corp.google.com>
	<65795E11DBF1E645A09CEC7EAEE94B9CB516D0EA@USINDEVS02.corp.hds.com>
	<alpine.DEB.2.00.1110121654120.30123@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Hugh Dickins <hughd@google.com>, hannes@cmpxchg.org

On Wed, 12 Oct 2011 17:01:21 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 12 Oct 2011, Satoru Moriya wrote:

> > I understand what you concern. But in some area such as banking,
> > stock exchange, train/power/plant control sysemts etc this kind
> > of tunable is welcomed because they can tune their systems at
> > their own risk.
> > 
> 
> You haven't tried the patch that increases the priority of kswapd when 
> such a latency sensitive thread triggers background reclaim?

I don't read full story but....how about adding a new syscall like

==
sys_mem_shrink(int nid, int nr_scan_pages, int flags)

This system call scans LRU of specified nodes and free pages on LRU.
This scan nr_scan_pages in LRU and returns the number of successfully
freed pages.
==

Then, running this progam in SCHED_IDLE, a user can make free pages while
the system is idle. If running in the highest priority, a user can keep
free pages as he want. If a user run this under a memcg, user can free
pages in a memcg. 

Maybe many guys don't want to export memory-shrink facility to userland ;)
This is just an idea.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
