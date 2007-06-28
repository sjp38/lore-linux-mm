Date: Thu, 28 Jun 2007 11:13:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/4] oom: serialize for cpusets
In-Reply-To: <20070628020302.bb0eea6a.pj@sgi.com>
Message-ID: <alpine.DEB.0.99.0706281104490.20980@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261950140.24949@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
 <20070627151334.9348be8e.pj@sgi.com> <alpine.DEB.0.99.0706272313410.12292@chino.kir.corp.google.com>
 <20070628003334.1ed6da96.pj@sgi.com> <alpine.DEB.0.99.0706280039510.17762@chino.kir.corp.google.com>
 <20070628020302.bb0eea6a.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, andrea@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jun 2007, Paul Jackson wrote:

> Do you have real world cases where your change is necessary?  Perhaps
> you could describe those scenarios a bit, so that we can separate out
> what's going wrong, from the possible remedies, and so we can get a
> sense of the importance of this proposed tweak.
> 

It's pretty simple to show how killing current is not the best choice for 
cpuset-constrained memory allocations that encounter an OOM condition.

If you attach all your system tasks to a single small node and then 
attempt to allocate large amounts of memory in that node, tasks get killed 
unnecessarily.  This is a good way to approximate a cpuset's memory 
pressure in real-world examples.  The actual rogue task can avoid getting 
killed by simply not allocating the last N kB in that node while other 
tasks, such as sshd or sendmail, require memory on a spurious basis.  So 
we've often seen tasks such as those get OOM killed even though they don't 
alleviate the condition much at all: sshd and sendmail are not normally 
memory hogs.

The much better policy in terms of sharing memory among a cpuset's task is 
to kill the actual rogue task which we can estimate pretty well with 
select_bad_process() since it takes into consideration, most importantly, 
the total VM size.

So my belief is that it is better to kill one large memory-hogging task in 
a cpuset instead of killing multiple smaller ones based on their 
scheduling and unfortunate luck of being the one to enter the OOM killer.  
Even worse is when the OOM killer, which is not at all serialized for 
cpuset-constrained allocations at present, kills multiple smaller tasks 
before killing the rogue task.  Then those previous kills were unnecessary 
and certainly would qualify as a strong example for why current git's 
behavior is broken.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
