Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 81C8F6B01C3
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:30:30 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o517URIC005958
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:30:27 -0700
Received: from pxi3 (pxi3.prod.google.com [10.243.27.3])
	by hpaq6.eem.corp.google.com with ESMTP id o517UN9D030222
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:30:23 -0700
Received: by pxi3 with SMTP id 3so2250647pxi.24
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 00:30:22 -0700 (PDT)
Date: Tue, 1 Jun 2010 00:30:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oom killer rewrite
In-Reply-To: <20100528131125.7E1E.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006010022591.30615@chino.kir.corp.google.com>
References: <20100524100840.1E95.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1005250246170.8045@chino.kir.corp.google.com> <20100528131125.7E1E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 28 May 2010, KOSAKI Motohiro wrote:

> > When you see these "funny parts," please let me know what they are.  The 
> > were was no incompatibility issue after 
> > oom-reintroduce-and-deprecate-oom_kill_allocating_task.patch was merged, 
> > the interface was simply deprecated.  Arguing against the deprecation is 
> > understandable and quite frankly something I'd like to avoid since it's 
> > apparently hanging up the larger importance of the work, so I've dropped 
> > the consolidation (and subsequent deprecation of oom_kill_allocating_task) 
> > of the sysctls from my latest patch series.
> 
> That's said, don't deprecated current interface. Other MM developers makes
> effort to reduce a number of oom bug report. I don't hope you run just opposite
> direction.
> 

It's dropped, as I said above.

> > > > oom-badness-heuristic-rewrite.patch
> > > 	No. All of rewrite is bad idea. Please make separate some
> > > 	individual patches.
> > > 	All rewrite thing break bisectability. Perhaps it can steal
> > > 	a lot of time from MM developers.
> > 
> > We've talked about that before, and I remember specifically addressing why 
> > it couldn't be broken apart with any coherent understanding of what was 
> > happening.  I think the patchset itself was fairly well divided, but this 
> > specific patch touches many different areas and function signatures but 
> > are mainly localized to the oom killer.
> 
> Heh, that's ok.
> I'll merge apart of this one If you can't. The rule is simple, rewrite 
> all patches will never merge. but ok too. you can choice no merge.
> 

You can't break this patch apart functionally into anything that's 
meaninful, it doesn't help to go around changing function signatures in 
one patch when the arguments are left unused, or adding sysctls in one 
patch when its unused, etc.  I gave a tip for reviewing of this particular 
patch since all of the changes are isolated in oom_badness(): merge the 
patch into your own tree and review the heuristic.

> > > 	This patch have following parts.
> > > 	1) Add oom_score_adj
> > 
> > A patch that only adds oom_score_adj but doesn't do anything else?  It 
> > can't be used with the current badness function, it requires the rewrite 
> > of oom_badness().
> 
> ok. you can drop oom_score_adj too.
> 

I don't know what this means.  oom_score_adj is the new tunable that is in 
the units that the new heuristic uses, they obviously need to be merged 
together.

> > > 	2) OOM score normalization
> > 
> > I prefer to do that with the addition of oom_score_adj since that tunable 
> > is meaninless until the score uses it.
> 
> No. This one have no justification. BAD IDEA.
> Any core heuristic change need to prove to improve desktop use case.
> 

This entire rewrite was largely based on improving the desktop use case, 
the new heuristic doesn't kill KDE when you fork a large memory-hogging 
process on the desktop when it currently does.

> That's said, now lkml have one or two oom bug report per month. We have
> to make effort to reduce it. Please don't append new confusion source.
> 

My heuristic is far superior to the current heuristic and this introduces 
a new tunable that allows userspace to tune oom killer prioritization in 
units that admins understand and in a linear way, not exponentially on the 
total VM size that the current heuristic does.

> > > 	3) forkbomb detector
> > 
> > Ok, I can seperate that out but that's only a small part of the overall 
> > code.  Are there specific issues you'd like to address with that now 
> > instead of later?
> 
> reviewability and bisectability are one of most important issue. that's all.
> 

This is done and has been proposed as patch 09/18 in my latest posting, 
thanks.

> > >  	5) Root user get 3% bonus instead 400%
> > 
> > I don't understand this.
> 
> Now, our oom have "if (root-user) points /= 4" logic, I wrote it as 400%.
> 

This bias should be equivalent to that given in __vm_enough_memory() as 
specified in the patch description.

> > I can't add a copyright under the GPL for the new heuristic?  Why?
> 
> 1) too small work

 14 files changed, 680 insertions(+), 332 deletions(-)

That's too small?

> 2) In this area, almost work had been lead to kamezawa-san. you don't have
>    proper right.
> 

Absolutely ridiculous, the only thing that this entire patchset builds 
upon is the use of MM_SWAPENTS which was introduced to be exported via 
/proc/pid/status.

> (1) mean other people of joining this improvement can't append it too.
> 

I don't know what this means.

If you object to adding Google's copyright to this work, please merge that 
as an additional patch and submit it to Andrew along with my nacked-by.  
He can remove Google's copyright to the rewrite if he'd like.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
