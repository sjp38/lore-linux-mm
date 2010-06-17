Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 80ADC6B01D0
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 23:28:23 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o5H3SJjt012752
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:28:20 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by wpaz37.hot.corp.google.com with ESMTP id o5H3SITm026945
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:28:18 -0700
Received: by pva18 with SMTP id 18so90124pva.32
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:28:18 -0700 (PDT)
Date: Wed, 16 Jun 2010 20:28:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <20100608164722.9724baf9.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006162023110.21446@chino.kir.corp.google.com>
References: <20100604195328.72D9.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006041333550.27219@chino.kir.corp.google.com> <20100608172820.7645.A69D9226@jp.fujitsu.com> <20100608164722.9724baf9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> > of the patch don't concentrate one thing. 2) That is strongly concentrate 
> > "what and how to implement". But reviewers don't want such imformation so much 
> > because they can read C language. reviewers need following information.
> >   - background
> >   - why do the author choose this way?
> >   - why do the author choose this default value?
> >   - how to confirm your concept and implementation correct?
> >   - etc etc
> > 
> > thus, reviewers can trace the author thinking and makes good advise and judgement.
> > example in this case, you wrote
> >  - default threshold is 1000
> >  - only accumurate 1st generation execve children
> >  - time threshold is a second
> > 
> > but not wrote why? mess sentence hide such lack of document. then, I usually enforce
> > a divide, because a divide naturally reduce to "which place change" document and 
> > expose what lacking. 
> > 
> > Now I haven't get your intention. no test suite accelerate to can't get
> > author think which workload is a problem workload.
> 
> hey, you're starting to sound like me.
> 

I can certainly elaborate on the forkbomb detector's patch description, 
but it would be helpful if people would bring this up as their concern 
rather than obfuscating it with a bunch of "nack"s and guessing.  I had 
_thought_ that the intent was quite clear in the comments that the patch 
added:

/*
 * Tasks that fork a very large number of children with seperate address spaces
 * may be the result of a bug, user error, malicious applications, or even those
 * with a very legitimate purpose such as a webserver.  The oom killer assesses
 * a penalty equaling
 *
 *	(average rss of children) * (# of 1st generation execve children)
 *	-----------------------------------------------------------------
 *			sysctl_oom_forkbomb_thres
 *
 * for such tasks to target the parent.  oom_kill_process() will attempt to
 * first kill a child, so there's no risk of killing an important system daemon
 * via this method.  A web server, for example, may fork a very large number of
 * threads to respond to client connections; it's much better to kill a child
 * than to kill the parent, making the server unresponsive.  The goal here is
 * to give the user a chance to recover from the error rather than deplete all
 * memory such that the system is unusable, it's not meant to effect a forkbomb
 * policy.
 */

I didn't think it had to be duplicated in the changelog.  I'll do that.

> I think I'm beginning to understand your concerns with these patches. 
> Finally.
> 
> Yes, it's a familiar one.  I do fairly commonly see patches where the
> description can be summarised as "change lots and lots of stuff to no
> apparent end" and one does have to push and poke to squeeze out the
> thinking and the reasons.  It's a useful exercise and will sometimes
> cause the originator to have a rethink, and sometimes reveals that it
> just wasn't a good change.
> 

Show me where I have a single undocumented change in the forkbomb detector 
patch, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
