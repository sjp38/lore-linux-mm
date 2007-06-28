Date: Thu, 28 Jun 2007 11:55:37 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch 4/4] oom: serialize for cpusets
Message-Id: <20070628115537.56344465.pj@sgi.com>
In-Reply-To: <alpine.DEB.0.99.0706281104490.20980@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261949490.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261950140.24949@chino.kir.corp.google.com>
	<Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
	<20070627151334.9348be8e.pj@sgi.com>
	<alpine.DEB.0.99.0706272313410.12292@chino.kir.corp.google.com>
	<20070628003334.1ed6da96.pj@sgi.com>
	<alpine.DEB.0.99.0706280039510.17762@chino.kir.corp.google.com>
	<20070628020302.bb0eea6a.pj@sgi.com>
	<alpine.DEB.0.99.0706281104490.20980@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: clameter@sgi.com, andrea@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> So my belief is that it is better to kill one large memory-hogging task in 
> a cpuset instead of killing multiple smaller ones based on their 
> scheduling and unfortunate luck of being the one to enter the OOM killer.  

So ... sounds like you're arguing from principle, not from having some
specific customer biting at your heels.

Ok.

My guess is that what happened here is that, back in the earlier days of
cpusets, when most people looked on it with a bit of suspicion, and few
depended on it for their livelihood, my good colleague Christoph Lameter
got in a change to avoid the OOM scoring for cpuset constrained tasks,
and instead just shoot the messenger - kill the task asking for the
memory.

At the time, I was a little surprised he got that change in, but it
suited the needs of our particular customers, so I happily kept quiet.

Now, cpusets are finding wider usage, in ways I never would have
imagined. I guess by and large I did a good enough job of designing
them from principle, not from the specific needs of my (rather odd)
customers that now cpusets have found other users and uses.  Good.

But this particular change, avoiding OOM scoring on cpuset constrained
tasks, is probably more of a heuristic that will fit some uses, not others.

Sounds like its time for a tunable, to determine whether or not to OOM
score cpuset constrained tasks.

As for the default of the tunable, I could argue that it should default to
the current behaviour (avoid OOM scoring cpuset constrained tasks), for
compatibility.  And you could argue that it should default to OOM scoring
even cpuset constrained tasks, because that is what a larger set of users
will expect and need.  Grumble, grumble ... I wish I could think of a
reason why you'd be wrong to say that, and thereby save myself some work
adding hooks to my user space code to flip this tunable to the way I need
it (don't OOM score cpuset constrained tasks.) ... so far nothing ... drat.

Would you like to propose a patch, adding a per-cpuset Boolean flag
that has inheritance properties similar to the memory_spread_* flags?
Set at the top and inherited on cpuset creation; overridable per-cpuset.

How about calling it "oom_kill_asking_task", defaulting to 0 (the
default you will like, not the one I will use for my customers.)

You can leave it up to me to provide such a patch, but I can pretty much
promise I won't get to it for the next two or three months, at least.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
