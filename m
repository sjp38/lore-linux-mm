Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F160160021B
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 21:02:44 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB222g14025829
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 2 Dec 2009 11:02:42 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DBE6945DE52
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:02:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A402D45DE50
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:02:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6ECEC1DB803E
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:02:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 130A41DB8043
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:02:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] high system time & lock contention running large mixed workload
In-Reply-To: <20091201124619.GO30235@random.random>
References: <20091201212357.5C3A.A69D9226@jp.fujitsu.com> <20091201124619.GO30235@random.random>
Message-Id: <20091202102111.5C43.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  2 Dec 2009 11:02:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi

> > Avoiding lock contention on light VM pressure is important than
> > strict lru order. I guess we don't need knob.
> 
> Hope so indeed. It's not just lock contention, that is exacerbated by
> certain workloads, but even in total absence of any lock contention I
> generally dislike the cpu waste itself of the pte loop to clear the
> young bit, and the interruption of userland as well when it receives a
> tlb flush for no good reason because 99% of the time plenty of
> unmapped clean cache is available. I know this performs best, even if
> there will be always someone that will want mapped and unmapped cache
> to be threat totally equal in lru terms (which then make me wonder why
> there are still & VM_EXEC magics in vmscan.c if all pages shall be
> threaded equal in the lru... especially given VM_EXEC is often
> meaningless [because potentially randomly set] unlike page_mapcount
> [which is never randomly set]), which is the reason I mentioned the
> knob.

Umm?? I'm puzlled. if almost pages in lru are unmapped file cache, pte walk
is not costly. reverse, if almost pages in lru are mapped pages, we have
to do pte walk, otherwise any pages don't deactivate and system cause
big latency trouble.

I don't want vmscan focus to peak speed and ignore worst case. it isn't proper
behavior in memory shortage situation. Then I hope to focus to solve lock
contention issue. 

Of course, if this cause any trouble to KVM or other usage in real world,
I'll fix it. 
if you have any trouble experience about current VM, please tell us.

[I (and Hugh at least) dislike VM_EXEC logic too. but it seems off topic.]



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
