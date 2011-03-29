Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 92D638D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 22:46:38 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DCD2F3EE0BC
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:46:34 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C218745DE59
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:46:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AAC1345DE53
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:46:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A4741DB8043
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:46:34 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F47E1DB803F
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:46:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] Revert "oom: give the dying task a higher priority"
In-Reply-To: <1301318293.4859.19.camel@twins>
References: <20110328131029.GN19007@uudg.org> <1301318293.4859.19.camel@twins>
Message-Id: <20110329114703.C088.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 29 Mar 2011 11:46:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: kosaki.motohiro@jp.fujitsu.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi

> > I mean, in the context of SCHED_OTHER tasks would it really help the dying
> > task to be scheduled sooner to release its resources? 
> 
> That very much depends on how all this stuff works, I guess if everybody
> serializes on OOM and only the first will actually kill a task and all
> the waiting tasks will try to allocate a page again before also doing
> the OOM thing, and the pending tasks are woken after the OOM target task
> has completed dying.. then I don't see much point in boosting things,
> since everybody interested in memory will block and eventually only the
> dying task will be left running.

Probably I can answer this question. When OOM occur, kernel has very a
few pages (typically 10 - 100). but not 0. therefore bloody page-in vs
page-out battle (aka allocation vs free battle) is running.

IOW, While we have multiple cpu or per-cpu page queue, we don't see
page cache become completely 0.

Therefore, not killed task doesn't sleep completely. page-out may have
very small allocation successful chance. (but almostly it's fail. pages
are stealed by another task)

Before Luis's patch, kernel livelock on oom may be solved within 30min,
but after his patch, it's solved within 1 second. that's big different
for human response time. That's the test result.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
