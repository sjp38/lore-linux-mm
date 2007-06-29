Date: Thu, 28 Jun 2007 21:07:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/4] oom: serialize for cpusets
In-Reply-To: <Pine.LNX.4.64.0706281830280.9573@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.99.0706282055170.21525@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261950140.24949@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
 <20070627151334.9348be8e.pj@sgi.com> <alpine.DEB.0.99.0706272313410.12292@chino.kir.corp.google.com>
 <20070628003334.1ed6da96.pj@sgi.com> <alpine.DEB.0.99.0706280039510.17762@chino.kir.corp.google.com>
 <20070628020302.bb0eea6a.pj@sgi.com> <alpine.DEB.0.99.0706281104490.20980@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706281830280.9573@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, andrea@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jun 2007, Christoph Lameter wrote:

> > If you attach all your system tasks to a single small node and then 
> > attempt to allocate large amounts of memory in that node, tasks get killed 
> > unnecessarily.  This is a good way to approximate a cpuset's memory 
> > pressure in real-world examples.  The actual rogue task can avoid getting 
> > killed by simply not allocating the last N kB in that node while other 
> > tasks, such as sshd or sendmail, require memory on a spurious basis.  So 
> > we've often seen tasks such as those get OOM killed even though they don't 
> > alleviate the condition much at all: sshd and sendmail are not normally 
> > memory hogs.
> 
> Yeah but to get there seems to require intention on the part of the 
> rogue tasks.
> 

I'm confused.  The "rogue" task has avoided getting killed because it just 
barely got the memory it required and now other tasks, such as the 
examples of sendmail or sshd, which have spurious memory usage will get 
killed with current git and probably not do a darn thing to alleviate the 
OOM condition.  That's broken behavior.

> > The much better policy in terms of sharing memory among a cpuset's task is 
> > to kill the actual rogue task which we can estimate pretty well with 
> > select_bad_process() since it takes into consideration, most importantly, 
> > the total VM size.
> 
> Sorry that is too expensive. I did not see that initially. Thanks Paul for 
> reminding me. I am at the OLS and my mindshare for this is pretty limited 
> right now.
> 

Please see patch 5 posted today which uses select_bad_process() to find 
the task to kill the default but allows you to
echo 1 > /dev/cpuset/my_cpuset/oom_kill_asking_task to cheaply kill 
current instead.

And can you please explain why this is only objected to in the 
CONSTRAINT_CPUSET case and not CONSTRAINT_NONE where this is an even more 
expensive operation?

> The current behavior will usually kill the memory hogging task and it can 
> do so with minimal effort. If there is a whole array of memory hogging 
> tasks then the existing approach will be much easier on the system.
> 

No, it kills the current task.  You cannot make the inference that the 
task that exceeded the available cpuset memory is the one that should be 
killed.  And if you do, you'll kill tasks unnecessarily regardless of 
whether the cpuset OOM killer is serialized or not.

If my application requests more memory than it should have or it's 
leaking but it hasn't yet reached an OOM state and then sshd wants a small 
amount of memory and OOM's, we kill it even though it's futile because my 
application is going to continue to leak.  Eventually we'll get around to 
killing my application because of scheduling decisions and I will OOM, but 
sshd and any other task that was unlucky enough to be scheduled before me 
will already be dead.  That's broken behavior, but we have enabled it 
through the oom_kill_asking_task flag on a per-cpuset basis for special 
situations where killing current would be acceptable.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
