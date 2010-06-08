Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 295336B01E2
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:01 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bfv50014489
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:41:57 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 80FAC45DE79
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DACF45DE6F
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5254AE38005
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:56 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D837D1DB803A
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <alpine.DEB.2.00.1006041333550.27219@chino.kir.corp.google.com>
References: <20100604195328.72D9.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006041333550.27219@chino.kir.corp.google.com>
Message-Id: <20100608172820.7645.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> > Have you review the actual patches? And No, I don't think "complete 
> > replace with no test result" is adequate development way.
> 
> I have repeatedly said that the oom killer no longer kills KDE when run on 
> my desktop in the presence of a memory hogging task that was written 
> specifically to oom the machine.  That's a better result than the 
> current implementation and was discussed thoroughly during the discussion 
> on this mailing list back in February that inspired this rewrite to begin 
> with.  I don't think there's any mystery there since you've referred to 
> that change specifically for KDE in this thread yourself.

And, Revewers repeatedly said your patches have overplus material for
saving KDE. and ask you the reason. We haven't said KDE is unimportant.


> > And, When developers post large patch set, Usually _you_ request show
> > demonstrate result. I haven't seen such result in this activity.
> 
> You want to see a log that says "Killed process 1234 (memory-hogger)..." 
> instead of "Killed process 1234 (kdeinit)..."?  You've supported the 
> change from total_vm to rss as a baseline to begin with.  And after all 
> this discussion, this is the first time you've ever said you wanted to see 
> that type of log or anything like it.

Did you only test the above crazy meaningless case??
We don't want you any acrobatic unactionable thing. Simply you just show
what you did, please.

> > However, It doesn't give any reason to avoid code review and violate
> > our development process.
> > 
> 
> Nobody is avoiding code review here, that's pretty obvious, and I have no 
> idea you're referring to when you're saying I'm violating the development 
> process because this happens to rewrite an entire function and requires a 
> new user interface and callsite fixups to be meaningful.  You specifically 
> asked me to push the forkbomb detector in a different patch and I did that 
> because it makes sense to seperate that heuristic, but even then you just 
> wrote "nack" and haven't responded with why even after I've replied twice 
> asking.  I'm really confused this behavior.

Not exactly correct.
I also requested separate adding forkbomb feature and adding forkbomb knob.
I often requested the same thing to a patch author repeatedly and repeatedly.

Why?

Frist of all, The patch description of your forkbomb detection is here

	> Add a forkbomb penalty for processes that fork an excessively large
	> number of children to penalize that group of tasks and not others.  A
	> threshold is configurable from userspace to determine how many first-
	> generation execve children (those with their own address spaces) a task
	> may have before it is considered a forkbomb.  This can be tuned by
	> altering the value in /proc/sys/vm/oom_forkbomb_thres, which defaults to
	> 1000.
	> 
	> When a task has more than 1000 first-generation children with different
	> address spaces than itself, a penalty of
	> 
	> 	(average rss of children) * (# of 1st generation execve children)
	> 	-----------------------------------------------------------------
	> 			oom_forkbomb_thres
	> 
	> is assessed.  So, for example, using the default oom_forkbomb_thres of
	> 1000, the penalty is twice the average rss of all its execve children if
	> there are 2000 such tasks.  A task is considered to count toward the
	> threshold if its total runtime is less than one second; for 1000 of such
	> tasks to exist, the parent process must be forking at an extremely high
	> rate either erroneously or maliciously.
	> 
	> Even though a particular task may be designated a forkbomb and selected as
	> the victim, the oom killer will still kill the 1st generation execve child
	> with the highest badness() score in its place.  The avoids killing
	> important servers or system daemons.  When a web server forks a very large
	> number of threads for client connections, for example, it is much better
	> to kill one of those threads than to kill the server and make it
	> unresponsive.

This have two rotten smell. 1) the sentence is unnecessary mess. it is smell
of the patch don't concentrate one thing. 2) That is strongly concentrate 
"what and how to implement". But reviewers don't want such imformation so much 
because they can read C language. reviewers need following information.
  - background
  - why do the author choose this way?
  - why do the author choose this default value?
  - how to confirm your concept and implementation correct?
  - etc etc

thus, reviewers can trace the author thinking and makes good advise and judgement.
example in this case, you wrote
 - default threshold is 1000
 - only accumurate 1st generation execve children
 - time threshold is a second

but not wrote why? mess sentence hide such lack of document. then, I usually enforce
a divide, because a divide naturally reduce to "which place change" document and 
expose what lacking. 

Now I haven't get your intention. no test suite accelerate to can't get
author think which workload is a problem workload.

btw, nit. typically web server don't create so much thread because almost all of
web server have a feature of limit of number of connection. (Othersise the server
easily down by DoS)


> > > And I'm going to have to get into it because of you guys' seeming
> > > inability to get your act together.
> > 
> > Inability? What do you mean inability? Almost all developers cooperate 
> > for making stabilized kernel. Is this effort inability? or meaningless?
> > 
> 
> I think he's saying that he expects that we should be able to work 
> cooperateively in resolving any differences that we have in a respectful 
> and technical manner on this list.
> 
> But I'll also add my two cents in that and say that we should probably be 
> leaving maintainer duties up to the actual -mm tree maintainer, he knows 
> the development process you're talking about pretty well.

Seems I and he have some disagreement. Ho hum. Of cource, you can seek
another reviewer and another ack. but during reach my eye, I enforce
bugfix-at-first policy to everybody.

> 
> > Actually, the descriptions doesn't looks better really. We sometimes
> > ask him
> >  - which problem occur? how do you reproduce it?
> 
> KDE gets killed, memory hogger doesn't.  Run memory hogger on your 
> desktop.  KOSAKI, this isn't a surprise to you.
> 
> If this is your objection, I can certainly elaborate more in the changelog 
> but up until yesterday you've never said you have a problem with it so how 
> am I supposed to make any forward progress on this?  I can't read your 
> mind when you say "nack" and I'd like to resolve any issues that people 
> have, but that requires that they get involved.

And I also read your mind from your description. I'm not ESPer.


> >  - which piece solve which issue?
> 
> Mostly the baseline heuristic change to rss and swap, as you well know.

agreed.

> 
> >  - how do you measure side effect?
> 
> As far as the objective of the oom killer is concerned as listed in 
> mm/oom_kill.c's header, there is no side effects.  We're trying to kill a 
> task that will free the largest amount of memory and clearly rss and swap 
> is a better indication fo that then total_vm.

Wait, wait.
This, you said you don't consider a lot of workloads deeply. really?
I guess no.

perhaps, you wrote this sentence quickly. so, I just only hope to update
your patch description.


> >  - how do you mesure or consider other workload user
> 
> The objective of the oom killer is not different for different workloads.

Seems my question is too short or unclear?

Usually, we makes 5-6 brain simulation, embedded, desktop, web server,
db server, hpc, finance. Different workloads certenally makes big impact.
because oom killer traverce _processces_ in the workload. It's affect how 
to choose badness() heuristics. why not?


> > But I got only the answer, "My patch is best. resistance is futile". that's
> > purely Baaaad.
> > 
> 
> I haven't said anything new in the above, KOSAKI, you already knew all 
> this.  I'll update the changelog to include some of this information for 
> the next posting, but I'd really hope that this isn't the major problem 
> that you've had the entire time that we've stalled weeks on.

Ho Hum. OK.

> 
> > OK. I don't have any reason to confuse you. I'll fix me. My point is
> > really simple. The majority OOM user are in desktop. We must not ignore
> > them. such as
> > 
> >  - Any regression from desktop view are unacceptable
> 
> This patchset was specifically designed to improve the oom killer's 
> behavior on the desktop!

Again, unevaluatable feature is immixed. and reviewers are stalling.


> >  - Any incompatibility of no desktop improvement are unacceptable
> 
> I don't understand this.

In other word,
 - Any incompatibility are unacceptable

because your new feature have no user.


> >  - Any refusing bugfix are unacceptable
> 
> I've merged most of Oleg's work into this patchset, the problem that we're 
> having is deciding whether any of it is -rc material or not and should be 
> pushed first.  I don't think any of it is, Oleg certainly wasn't pushing 
> it and to date I don't believe has said it's rc material, so that's 
> something you can talk about but I'm not refusing any bugfix.

Good deverlopers alywas take another developer/user bug report at first.
And, I'm going to push kill-PF_EXITING patch and dying-task-higher-priority
patch although they don't help your workload. I don't believe your 
opposition reason is logically.
(but if you made alternative patch, I'll review it preferentially)

> > 1) fix bugs at fist before making new feature (a.k.a new bugs)
> 
> Kame already suggested a new order to the patchset that I'll be 
> restructuring.  I'm curious as to why this was removed from -mm though on 
> your suggestion before any of this became an issue.  We've yet to hear 
> that mysterious information.

Again and again and again. You have to get anyone's ack when you are pushing
new feature. and your series still have bug and usually need 3-5 review iteration.
OK, that's a part of Andrew and our reviewer's fault. These patches must 
dropped more earlier. Your patches got 4 times NAK from each another 
developers, each time, the patches had to be dropped. Sigh.


> > 2) don't mix bugfix and new feature
> 
> Andrew said bugfixes should come first, they will in the reposting, but I 
> don't consider any of it to be -rc material.

Oleg's material can be merged, now. but yours are not.


> > 3) make separate as natural and individual piece
> 
> I can't keep having this conversation, the patch is broken down into one 
> functional unit as much as possible.  Please leave the maintainership of 
> this code to Andrew who has already said entire implementation changes (in 
> this case, a single function rewrite) is allowed if it makes sense.

I said, I'll divide them if you don't. 


> > 4) keep small and reviewable patch size
> 
> Same as above.
> 
> > 5) stop ugly excuse, instead repeatedly rewrite until get anyone ack
> 
> I don't know what my ugly excuse is, but I'll be reordering the patches 
> and sending them with an updated changelog on the badness heuristic 
> rewrite.  I hope that will satisfy all your concerns.

I don't talk generic thing in this. instead I've send new bug report
and new reviewing result instead. I hope I get productive response.

> > 6) don't ignore another developers bug report
> > 
> 
> If you have a bug report that is the result of this rewrite, please come 
> forward with it and don't carry this out by making me guess again.
> 
> > I didn't hope says the same thing twice and he repeatedly ignore
> > my opinion, thus, he got short answer. I didn't think this is inadequate
> > beucase he can google past mail.
> > 
> 
> No, you've never said this is the reason why it was dropped from -mm or 
> why it was "nack"'d early on.
> 
> > However he repeatedly attach our goodwill and blame our tolerance. 
> > but also repeatedly said "My workload is important than other!".
> > Then, I got upset really.
> > 
> 
> What??  I don't even have a specific workload that I'm targeting with this 
> change, I have no idea what you're referring to, we don't run much stuff 
> on the desktop :)
>
> > The fact is, all of good developer never says "my workload is most
> > important in the world", it makes no sense and insane. I really hate
> > such selfish.
> 
> Again, this is just a ridiculous accusation.  I have no idea what you're 
> referring to since this rewrite is specifically addressed to fix the oom 
> killer problems on the desktop.  I work on servers and systems software, I 
> don't have a desktop workload that I'm advocating for here, so perhaps you 
> got me confused with someone else.

David, do you know other kernel engineer spent how much time for understanding
a real workload and dialog various open source community and linux user company
and user group?

At least, All developers must make _effort_ to spent some time to investigate 
userland use case when they want to introduce new feature and incompatibility.
Almost developers do. please read various new feature git log. few commit log
are ridiculous quiet (probably the author bother cut-n-paste from ML bug report)
but almost are wrote what is problem.
thus, we can double check the problem and the code are matched correctly.

And, if you can't test your patch on various platform, at least you must to
write theorical background of your patch. it definitely help each are engineer
confirm your patch don't harm their area. However, for principal, if you
want to introduce any imcompatibility, you must investigate how much affect this.

remark: if you think you need mathematical proof or 100% coveraged proof,
it's not correct. you don't need such impossible work. We just require to
confirm you investigate and consider enough large coverage.

Usually, the author of small patch aren't required this. because reviewers can
think affected use-case from the code. almost reviewer have much use case knowledge
than typical kernel developers. but now, you are challenging full
of rewrite. We don't have enough information to finish reviewing.

Last of all, I've send various review result by another mail. Can you please
read it?

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
