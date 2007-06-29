Date: Thu, 28 Jun 2007 18:33:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 4/4] oom: serialize for cpusets
In-Reply-To: <alpine.DEB.0.99.0706281104490.20980@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0706281830280.9573@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261950140.24949@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
 <20070627151334.9348be8e.pj@sgi.com> <alpine.DEB.0.99.0706272313410.12292@chino.kir.corp.google.com>
 <20070628003334.1ed6da96.pj@sgi.com> <alpine.DEB.0.99.0706280039510.17762@chino.kir.corp.google.com>
 <20070628020302.bb0eea6a.pj@sgi.com> <alpine.DEB.0.99.0706281104490.20980@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Paul Jackson <pj@sgi.com>, andrea@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jun 2007, David Rientjes wrote:

> If you attach all your system tasks to a single small node and then 
> attempt to allocate large amounts of memory in that node, tasks get killed 
> unnecessarily.  This is a good way to approximate a cpuset's memory 
> pressure in real-world examples.  The actual rogue task can avoid getting 
> killed by simply not allocating the last N kB in that node while other 
> tasks, such as sshd or sendmail, require memory on a spurious basis.  So 
> we've often seen tasks such as those get OOM killed even though they don't 
> alleviate the condition much at all: sshd and sendmail are not normally 
> memory hogs.

Yeah but to get there seems to require intention on the part of the 
rogue tasks.

> The much better policy in terms of sharing memory among a cpuset's task is 
> to kill the actual rogue task which we can estimate pretty well with 
> select_bad_process() since it takes into consideration, most importantly, 
> the total VM size.

Sorry that is too expensive. I did not see that initially. Thanks Paul for 
reminding me. I am at the OLS and my mindshare for this is pretty limited 
right now.

> So my belief is that it is better to kill one large memory-hogging task in 
> a cpuset instead of killing multiple smaller ones based on their 
> scheduling and unfortunate luck of being the one to enter the OOM killer.  
> Even worse is when the OOM killer, which is not at all serialized for 
> cpuset-constrained allocations at present, kills multiple smaller tasks 
> before killing the rogue task.  Then those previous kills were unnecessary 
> and certainly would qualify as a strong example for why current git's 
> behavior is broken.

The current behavior will usually kill the memory hogging task and it can 
do so with minimal effort. If there is a whole array of memory hogging 
tasks then the existing approach will be much easier on the system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
