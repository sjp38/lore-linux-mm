Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 1BE8E6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 18:17:39 -0500 (EST)
Received: by dadv6 with SMTP id v6so2169872dad.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 15:17:38 -0800 (PST)
Date: Thu, 23 Feb 2012 15:17:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
In-Reply-To: <20120223152226.GA2014@x61.redhat.com>
Message-ID: <alpine.DEB.2.00.1202231509510.26362@chino.kir.corp.google.com>
References: <20120222115320.GA3107@x61.redhat.com> <alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com> <20120223152226.GA2014@x61.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Thu, 23 Feb 2012, Rafael Aquini wrote:

> Lets say the slab gets so bloated that for every user task spawned OOM-killer 
> just kills it instantly, or the system falls under severe thrashing, leaving no
> chance for you getting an interactive session to parse /proc/slabinfo, thus 
> making the reset button as your only escape... How would you identify what was 
> the set of caches responsible by the slab swelling?
> 

I think you misunderstand completely how the oom killer works, 
unfortunately.  It, by default unless you have changed oom_score_adj 
tunables, kills the most memory-hogging eligible thread possible.  That 
certainly wouldn't be a freshly forked user task prior to execve() unless 
you've enabled /proc/sys/vm/oom_kill_allocating_task, which you shouldn't 
unless you're running on a machine with 1k cores, for example.  It would 
be existing thread that was using a lot of memory to allow for things 
EXACTLY LIKE forking additional user tasks.  We don't want to get into a 
self-imposed DoS because something is oom and the oom killer does quite a 
good job at ensuring it doesn't.  The goal is to kill a single thread to 
free the most amount of memory possible.

If this is what is affecting you, then you'll need to figure out why you 
have changed the oom killer priority in such a way to do so: check your 
/proc/pid/oom_score_adj values that you have set in a way that when they 
are inherited they will instantly kill the child because it will quickly 
use more memory than the parent.

> IMHO, having such qualified info about slab usage at hand is very useful in
> several occurrences of OOM. It not only helps out developers, but also sysadmins
> on troubleshooting slab usage when OOM-killer is invoked, thus qualifying and 
> showing such data surely does make sense for a lot of people. For those who do 
> not mind/care about such reporting, in the end it just takes a sysctl knob 
> adjustment to make it go quiet.
> 

cat /proc/slabinfo

> > I think this also gives another usecase for a possible /dev/mem_notify in 
> > the future: userspace could easily poll on an eventfd and wait for an oom 
> > to occur and then cat /proc/slabinfo to attain all this.  In other words, 
> > if we had this functionality (which I think we undoubtedly will in the 
> > future), this patch would be obsoleted.
> 
> Great! So, why not letting the time tell us if this feature will be obsoleted
> or not? I'd rather have this patch obsoleted by another one proven better, than
> just stay still waiting for something that might, or might not, happen in the
> future.
> 

Because (1) you're adding a sysctl that we don't want to obsolete and 
remove from the kernel that someone will come to depend on and then have 
to find an alternative solution like /dev/mem_notify, and (2) people parse 
messages like this that are emitted to the kernel log that we don't want 
to break in the future.

So NACK on this approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
