Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ADAB06B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 02:36:31 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o8G6aRtZ003146
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 23:36:27 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by kpbe19.cbf.corp.google.com with ESMTP id o8G6aPCE030544
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 23:36:26 -0700
Received: by pwi9 with SMTP id 9so1497471pwi.2
        for <linux-mm@kvack.org>; Wed, 15 Sep 2010 23:36:25 -0700 (PDT)
Date: Wed, 15 Sep 2010 23:36:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] oom: remove totalpage normalization from
 oom_badness()
In-Reply-To: <20100916145452.3BB1.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009152300380.25200@chino.kir.corp.google.com>
References: <20100916144930.3BAE.A69D9226@jp.fujitsu.com> <20100916145452.3BB1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, oss-security@lists.openwall.com, Solar Designer <solar@openwall.com>, Kees Cook <kees.cook@canonical.com>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Nesterov <oleg@redhat.com>, Neil Horman <nhorman@tuxdriver.com>, linux-fsdevel@vger.kernel.org, pageexec@freemail.hu, Brad Spengler <spender@grsecurity.net>, Eugene Teo <eugene@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Sep 2010, KOSAKI Motohiro wrote:

> Current oom_score_adj is completely broken because It is strongly bound
> google usecase and ignore other all.
> 

We've talked about this issue three times already.  The last two times 
you've sent a revert patch, you failed to followup on the threads:

	http://marc.info/?t=128272938200002
	http://marc.info/?t=128324705200002

And now you've gone above Andrew, who is the maintainer of this code, and 
straight to Linus.  Between that and your failure to respond to my answers 
to your questions, I'm really stunned at how unprofessional you've handled 
this.

I've responded to every one of your emails and I've described the power of 
oom_score_adj as it acts on a higher resolution than oom_adj (1/1000th of 
RAM), respects the dynamic nature of cgroups, provides a rough 
approximation to users of oom_adj, and an exact equivalent of polarizing 
users of oom_adj, which is by far the most common usecase.

That feature, as is the entire oom killer rewrite, is not specific in any 
way to Google, which I've stated many times, yet you constantly insist 
that it's so.  Yes, we deal with oom issues on scales you've never seen.  
And instead of carrying internal patches to fix it since oom_adj is _only_ 
useful for polarizing a task and not relative to others competing for the 
same resources, I reworked the entire heuristic from scratch since we're 
not the only ones who want a sane priority killing.

We are not the only ones who add mems to cpusets, adjust memcg limits, add 
nodes to mempolicies, or use memory hotplug.  oom_adj would require a new 
value whenever you did any of those for a static priority.  The fact that 
you constantly ignore is that the amount of memory that an aggregate of 
tasks can access is _dynamic_ and so the kill priority will change unless 
we define it as a static value that has a unit as a proportion of 
available memory as oom_score_adj does.  Nobody cares about static oom 
scores like you introduce here with the revert; static oom scores mean 
_nothing_ because they are only useful in comparison to other eligible 
tasks.

You never respond to any of this, but you just keep pushing your same old 
revert.  You never responded to my email to Andrew that showed how this 
isn't a regression, so I guess I can only ask Linus to read the same 
email since you're pushing it to him now 
(http://marc.info/?l=linux-mm&m=128393429131399).

I really hope we can put this to rest because it's frankly getting old 
competing with a broken record.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
