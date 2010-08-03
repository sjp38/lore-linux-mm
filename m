Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AA76F6008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 03:10:37 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id o737GLT3009005
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 00:16:21 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by hpaq5.eem.corp.google.com with ESMTP id o737GJQH015550
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 00:16:20 -0700
Received: by pwi5 with SMTP id 5so1492184pwi.5
        for <linux-mm@kvack.org>; Tue, 03 Aug 2010 00:16:19 -0700 (PDT)
Date: Tue, 3 Aug 2010 00:16:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
In-Reply-To: <20100803114624.5A6F.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008030002500.20849@chino.kir.corp.google.com>
References: <20100730195338.4AF6.A69D9226@jp.fujitsu.com> <20100802134312.c0f48615.akpm@linux-foundation.org> <20100803114624.5A6F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010, KOSAKI Motohiro wrote:

> Tue,  8 Jun 2010
> KOSAKI Motohiro wrote:
> > Sorry I can't ack this. again and again, I try to explain why this is wrong
> > (hopefully last)
> > 
> > 1) incompatibility
> >    oom_score is one of ABI. then, we can't change this. from enduser view,
> >    this change is no merit. In general, an incompatibility is allowed on very
> >    limited situation such as that an end-user get much benefit than compatibility.
> >    In other word, old style ABI doesn't works fine from end user view.
> >    But, in this case, it isn't.
> > 

oom_score is unchanged from its documented purpose, it still reports the 
value that the oom_badness() function returns to decide which task to 
kill, and it's unchanged that the greatest score from the set of allowed 
tasks is the one selected (or its child sacrificed).  The implementation 
of oom_badness() has never been tied directly to the reporting of 
/proc/pid/oom_score.  (With the old heuristic, the score also changed 
based on the cpuset placement and even runtime!)

> > 2) technically incorrect
> >    this math is not correct math. this is not represented "allowed memory".
> >    example, 1) this is not accumulated mlocked memory, but it can be freed
> >    task kill 2) SHM_LOCKED memory freeablility depend on IPC_RMID did or not.
> >    if not, task killing doesn't free SYSV IPC memory.
> >    In additon, 3) This normalization doesn't works on asymmetric numa. 
> >    total pages and oom are not related almostly. 4) scalability. if the 
> >    system 10TB memory, 1 point oom score mean 10GB memory consumption.
> >    it seems too rough. generically, a value suppression itself is evil for
> >    scalability software.
> > 

I responded to this and said that I would change the denominator of the 
fraction from accounting only anonymous and pagecache to all allowed 
memory (totalram_pages, memcg limit, or the aggregate of 
node_spanned_pages).

> Andrew Morton wrote:

I responded directly to this message that akpm wrote and addressed all his 
points.  It went unanswered.  For your convenience, my response is 
archived at http://marc.info/?l=linux-mm&m=127675274612692 from a couple 
months ago.  Why you would quote his email and not my reply is strange.

> Another summize here, 
> 
> 1. I pointed out oom_score_adj is too google specific and harmful for
>    desktop user.
> 

oom_score_adj does nothing if the desktop user doesn't tune it, so I don't 
know what you're referring to here.  The desktop user need not know about 
it.

> I thought he agree to remove desktop regression and back to requirement 
> analisys and make much better patches. but It didn't happen. I'm sad.
> 

There's no desktop regression.

> Although someone think google usecase is most important in the world, _I_
> don't think so yet. I still worry about rest almost all user.
> 

This isn't specific at all to Google, oom_score_adj is a much more 
powerful userspace interface that allows the badness heuristic to be 
influenced in ways that we currently can't.  That's because it actually 
has a unit and works in a predictable and well-defined way.  Arguing that 
we must live with a bitshift on the badness score is not in anyone's best 
interest.

> I didn't say he didn't tested. I'd say, need to confirm test cases
> match typical use case. About two month ago, David posted previous 
> patch series. he and you talked about this is well tested. but When
> I ran, forkbom detection feature of it don't works at all in typical
> case. That said, google testing/production enviromnnet is a bit
> differenct from other almost world. I'm worry about this.
> 

The forkbomb detector was removed because I found it was too controversial 
and I didn't want to hold up making progress on this rewrite which is a 
clear win for both desktop and server users.

> > I think I'll merge it into 2.6.36.  That gives us two months to
> > continue to review it, to test it and if necessary, to fix it or revert
> > it.
> 
> I have question. Why did you changed your mention? All of your question
> were solved? if so, can you please share your conclustion and decision
> reason?
> 

Perhaps he was satisfied with my response to his email that I wrote that 
addressed his concerns either directly or with changes to this most recent 
revision.  The patch that is now merged in -mm is different from previous 
versions: the denominator of the fraction was changed (at your request) 
and the forkbomb detector was removed (at yours and others request).

> So, I would propose minimum oom_score_adj reverting patch here.
> I don't worry rest parts so much. because they don't have ABI change.
> so we can revert them later if we've found another issue later.
> 
> Thanks.
> 
> 
> 
> ============================================================
> Subject: [PATCH] revert oom_score_adj
> 
> oom_score_adj bring to a lot of harm than its worth. and It haven't
> get any concensus. so revert it.
> 

This is becoming very typical, KOSAKI, and it's getting old.  You're 
proposing sweeping changes without any reasoning behind them.  If you have 
a problem with /proc/pid/oom_score_adj, please enumerate them here and now 
and we can discuss them.  Nobody here is interested in looking at old 
revisions of this change, looking through hundreds of emails, or trying to 
infer what you're talking about.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
