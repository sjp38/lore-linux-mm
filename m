Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AE2316B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 19:24:51 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA40OnBb001918
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Nov 2009 09:24:49 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28F0345DE5D
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:24:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0893645DE57
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:24:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E49A11DB803C
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:24:48 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 97E3E1DB8038
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:24:48 +0900 (JST)
Date: Wed, 4 Nov 2009 09:22:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm][PATCH 3/6] oom-killer: count lowmem rss
Message-Id: <20091104092213.02f27075.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0911031220170.25890@chino.kir.corp.google.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091102162617.9d07e05f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911031220170.25890@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Nov 2009 12:24:01 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 2 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Count lowmem rss per mm_struct. Lowmem here means...
> > 
> >    for NUMA, pages in a zone < policy_zone.
> >    for HIGHMEM x86, pages in NORMAL zone.
> >    for others, all pages are lowmem.
> > 
> > Now, lower_zone_protection[] works very well for protecting lowmem but
> > possiblity of lowmem-oom is not 0 even if under good protection in the kernel.
> > (As fact, it's can be configured by sysctl. When we keep it high, there
> >  will be tons of not-for-use memory but system will be protected against
> >  rare event of lowmem-oom.)
> 
> Right, lowmem isn't addressed currently by the oom killer.  Adding this 
> constraint will probably make the heuristics much harder to write and 
> understand.  It's not always clear that we want to kill a task using 
> lowmem just because another task needs some, for instance.
The same  can be said against all oom-kill ;)

> Do you think we'll need a way to defer killing any task is no task is
> heuristically found to be hogging lowmem?

Yes, I think so. But my position is a bit different.

In typical x86-32 server case, which has 4-8G memory, most of memory usage
is highmem. So, if we have no knowledge of lowmem, multiple innocent processes
will be killed in every 30 secs of oom-kill. 

My final goal is migrating lowmem pages to highmem as kswapd-migraion or
oom-migration. Total rewrite for this will be required in future.

Thanks,
-Kame




Thanks,
-Kame



Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
