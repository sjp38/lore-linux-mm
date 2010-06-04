Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 359BC6B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 16:57:31 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id o54KvP8B011275
	for <linux-mm@kvack.org>; Fri, 4 Jun 2010 13:57:25 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by hpaq14.eem.corp.google.com with ESMTP id o54Kv88t024185
	for <linux-mm@kvack.org>; Fri, 4 Jun 2010 13:57:24 -0700
Received: by pxi6 with SMTP id 6so484021pxi.29
        for <linux-mm@kvack.org>; Fri, 04 Jun 2010 13:57:22 -0700 (PDT)
Date: Fri, 4 Jun 2010 13:57:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <20100604195328.72D9.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006041333550.27219@chino.kir.corp.google.com>
References: <20100602225252.F536.A69D9226@jp.fujitsu.com> <20100603161030.074d9b98.akpm@linux-foundation.org> <20100604195328.72D9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jun 2010, KOSAKI Motohiro wrote:

> Have you review the actual patches? And No, I don't think "complete 
> replace with no test result" is adequate development way.
> 

I have repeatedly said that the oom killer no longer kills KDE when run on 
my desktop in the presence of a memory hogging task that was written 
specifically to oom the machine.  That's a better result than the 
current implementation and was discussed thoroughly during the discussion 
on this mailing list back in February that inspired this rewrite to begin 
with.  I don't think there's any mystery there since you've referred to 
that change specifically for KDE in this thread yourself.

> And, When developers post large patch set, Usually _you_ request show
> demonstrate result. I haven't seen such result in this activity.
> 

You want to see a log that says "Killed process 1234 (memory-hogger)..." 
instead of "Killed process 1234 (kdeinit)..."?  You've supported the 
change from total_vm to rss as a baseline to begin with.  And after all 
this discussion, this is the first time you've ever said you wanted to see 
that type of log or anything like it.

> However, It doesn't give any reason to avoid code review and violate
> our development process.
> 

Nobody is avoiding code review here, that's pretty obvious, and I have no 
idea you're referring to when you're saying I'm violating the development 
process because this happens to rewrite an entire function and requires a 
new user interface and callsite fixups to be meaningful.  You specifically 
asked me to push the forkbomb detector in a different patch and I did that 
because it makes sense to seperate that heuristic, but even then you just 
wrote "nack" and haven't responded with why even after I've replied twice 
asking.  I'm really confused this behavior.

> > And I'm going to have to get into it because of you guys' seeming
> > inability to get your act together.
> 
> Inability? What do you mean inability? Almost all developers cooperate 
> for making stabilized kernel. Is this effort inability? or meaningless?
> 

I think he's saying that he expects that we should be able to work 
cooperateively in resolving any differences that we have in a respectful 
and technical manner on this list.

But I'll also add my two cents in that and say that we should probably be 
leaving maintainer duties up to the actual -mm tree maintainer, he knows 
the development process you're talking about pretty well.

> Actually, the descriptions doesn't looks better really. We sometimes
> ask him
>  - which problem occur? how do you reproduce it?

KDE gets killed, memory hogger doesn't.  Run memory hogger on your 
desktop.  KOSAKI, this isn't a surprise to you.

If this is your objection, I can certainly elaborate more in the changelog 
but up until yesterday you've never said you have a problem with it so how 
am I supposed to make any forward progress on this?  I can't read your 
mind when you say "nack" and I'd like to resolve any issues that people 
have, but that requires that they get involved.

>  - which piece solve which issue?

Mostly the baseline heuristic change to rss and swap, as you well know.

>  - how do you measure side effect?

As far as the objective of the oom killer is concerned as listed in 
mm/oom_kill.c's header, there is no side effects.  We're trying to kill a 
task that will free the largest amount of memory and clearly rss and swap 
is a better indication fo that then total_vm.

>  - how do you mesure or consider other workload user
> 

The objective of the oom killer is not different for different workloads.

> But I got only the answer, "My patch is best. resistance is futile". that's
> purely Baaaad.
> 

I haven't said anything new in the above, KOSAKI, you already knew all 
this.  I'll update the changelog to include some of this information for 
the next posting, but I'd really hope that this isn't the major problem 
that you've had the entire time that we've stalled weeks on.

> OK. I don't have any reason to confuse you. I'll fix me. My point is
> really simple. The majority OOM user are in desktop. We must not ignore
> them. such as
> 
>  - Any regression from desktop view are unacceptable

This patchset was specifically designed to improve the oom killer's 
behavior on the desktop!

>  - Any incompatibility of no desktop improvement are unacceptable

I don't understand this.

>  - Any refusing bugfix are unacceptable

I've merged most of Oleg's work into this patchset, the problem that we're 
having is deciding whether any of it is -rc material or not and should be 
pushed first.  I don't think any of it is, Oleg certainly wasn't pushing 
it and to date I don't believe has said it's rc material, so that's 
something you can talk about but I'm not refusing any bugfix.

>  - Any refusing reviewing are unacceptable (IOW, must get any developers ack.
>    I'm ok even if they don't include me)
> 

I've been begging for you to review this.

> 1) fix bugs at fist before making new feature (a.k.a new bugs)

Kame already suggested a new order to the patchset that I'll be 
restructuring.  I'm curious as to why this was removed from -mm though on 
your suggestion before any of this became an issue.  We've yet to hear 
that mysterious information.

> 2) don't mix bugfix and new feature

Andrew said bugfixes should come first, they will in the reposting, but I 
don't consider any of it to be -rc material.

> 3) make separate as natural and individual piece

I can't keep having this conversation, the patch is broken down into one 
functional unit as much as possible.  Please leave the maintainership of 
this code to Andrew who has already said entire implementation changes (in 
this case, a single function rewrite) is allowed if it makes sense.

> 4) keep small and reviewable patch size

Same as above.

> 5) stop ugly excuse, instead repeatedly rewrite until get anyone ack

I don't know what my ugly excuse is, but I'll be reordering the patches 
and sending them with an updated changelog on the badness heuristic 
rewrite.  I hope that will satisfy all your concerns.

> 6) don't ignore another developers bug report
> 

If you have a bug report that is the result of this rewrite, please come 
forward with it and don't carry this out by making me guess again.

> I didn't hope says the same thing twice and he repeatedly ignore
> my opinion, thus, he got short answer. I didn't think this is inadequate
> beucase he can google past mail.
> 

No, you've never said this is the reason why it was dropped from -mm or 
why it was "nack"'d early on.

> However he repeatedly attach our goodwill and blame our tolerance. 
> but also repeatedly said "My workload is important than other!".
> Then, I got upset really.
> 

What??  I don't even have a specific workload that I'm targeting with this 
change, I have no idea what you're referring to, we don't run much stuff 
on the desktop :)

> The fact is, all of good developer never says "my workload is most
> important in the world", it makes no sense and insane. I really hate
> such selfish.

Again, this is just a ridiculous accusation.  I have no idea what you're 
referring to since this rewrite is specifically addressed to fix the oom 
killer problems on the desktop.  I work on servers and systems software, I 
don't have a desktop workload that I'm advocating for here, so perhaps you 
got me confused with someone else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
