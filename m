Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 4C9B26B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 22:08:27 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3B5FE3EE0BB
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:08:25 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E237045DE4F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:08:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C915E45DE4D
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:08:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B42BF1DB8037
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:08:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B0EF1DB802F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:08:24 +0900 (JST)
Date: Tue, 24 Jan 2012 12:07:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: Enable MAP_UNINITIALIZED for archs with mmu
Message-Id: <20120124120704.3f09b206.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F1E013E.9060009@fb.com>
References: <1326912662-18805-1-git-send-email-asharma@fb.com>
	<20120119114206.653b88bd.kamezawa.hiroyu@jp.fujitsu.com>
	<4F1E013E.9060009@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sharma <asharma@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, akpm@linux-foundation.org

On Mon, 23 Jan 2012 16:54:22 -0800
Arun Sharma <asharma@fb.com> wrote:

> On 1/18/12 6:42 PM, KAMEZAWA Hiroyuki wrote:
> >
> > Hmm, then,
> > 1. a new task jumped into this cgroup can see any uncleared data...
> > 2. if a memcg pointer is reused, the information will be leaked.
> 
> You're suggesting mm_match_cgroup() is good enough for accounting 
> purposes, but not usable for cases where its important to get the 
> equality right?
> 

I think there is no 100% solution to check reuse of object.



> > 3. If VM_UNINITALIZED is set, the process can see any data which
> >     was freed by other process which doesn't know VM_UNINITALIZED at all.
> >
> > 4. The process will be able to see file cache data which the it has no
> >     access right if it's accessed by memcg once.
> >
> > 3&  4 seems too danger.
> 
> Yes - these are the risks that I'm hoping we can document, so the 
> cgroups admin can avoid opting-in if not everything running in the 
> cgroup is trusted.
> 

I guess admins/users can't handle that.

> >
> > Isn't it better to have this as per-task rather than per-memcg ?
> > And just allow to reuse pages the page has freed ?
> >
> 
> I'm worrying that the additional complexity of maintaining a per-task 
> page list would be a problem. It might slow down workloads that 
> alloc/free a lot because of the added code. It'll probably touch the 
> kswapd as well (for reclaiming pages from the per-task free lists under 
> low mem conditions).
> 
> Did you have some implementation ideas which would not have the problems 
> above?
> 

If you just want to reduce latency of GFP_ZERO, you may be able to
clear pages by (rate limited) kernel daemon for minimize latency.

But, what I'm not sure is the effect of cpu cache. Now, user process
can expect the page is on cpu cache when it faulted. page-fault
does all prefetching by clearing pages. This helps performance much
in general. So, I think it's limited situation that no-clear-page-at-fault
is good for total applications performance.
You can see reduction of clear_page() cost by removing GFP_ZERO but
what's your application's total performance ? Is it good enough considering
many risks ?


Thanks,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
