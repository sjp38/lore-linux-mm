Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2008D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:56:16 -0400 (EDT)
Received: by eyd9 with SMTP id 9so1018134eyd.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 06:56:13 -0700 (PDT)
Date: Mon, 28 Mar 2011 10:56:01 -0300
From: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Subject: Re: [PATCH 2/5] Revert "oom: give the dying task a higher priority"
Message-ID: <20110328135601.GO19007@uudg.org>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com>
 <20110322194721.B05E.A69D9226@jp.fujitsu.com>
 <20110322200657.B064.A69D9226@jp.fujitsu.com>
 <20110324152757.GC1938@barrios-desktop>
 <1301305896.4859.8.camel@twins>
 <20110328122125.GA1892@barrios-desktop>
 <1301315307.4859.13.camel@twins>
 <20110328124025.GC1892@barrios-desktop>
 <20110328131029.GN19007@uudg.org>
 <1301318293.4859.19.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1301318293.4859.19.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Mar 28, 2011 at 03:18:13PM +0200, Peter Zijlstra wrote:
| On Mon, 2011-03-28 at 10:10 -0300, Luis Claudio R. Goncalves wrote:
| > | There was meaningless code in there. I guess it was in there from CFS.
| > | Thanks for the explanation, Peter.
| > 
| > Yes, it was CFS related:
| > 
| >         p = find_lock_task_mm(p);
| >         ...
| >         p->rt.time_slice = HZ; <<---- THIS
| 
| CFS has never used rt.time_slice, that's always been a pure SCHED_RR
| thing.
| 
| > Peter, would that be effective to boost the priority of the dying task?
| 
| The thing you're currently doing, making it SCHED_FIFO ?

I meant the p->rt.time_slice line, but you already answered my question.
Thanks :)
 
| > I mean, in the context of SCHED_OTHER tasks would it really help the dying
| > task to be scheduled sooner to release its resources? 
| 
| That very much depends on how all this stuff works, I guess if everybody
| serializes on OOM and only the first will actually kill a task and all
| the waiting tasks will try to allocate a page again before also doing
| the OOM thing, and the pending tasks are woken after the OOM target task
| has completed dying.. then I don't see much point in boosting things,
| since everybody interested in memory will block and eventually only the
| dying task will be left running.
| 
| Its been a very long while since I stared at the OOM code..
| 
| > If so, as we remove
| > the code in commit 93b43fa5508 we should re-add that old code. 
| 
| It doesn't make any sense to fiddle with rt.time_slice afaict.
---end quoted text---

-- 
[ Luis Claudio R. Goncalves             Red Hat  -  Realtime Team ]
[ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9  2696 7203 D980 A448 C8F8 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
