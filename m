Date: Wed, 27 Jun 2007 23:24:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/4] oom: serialize for cpusets
In-Reply-To: <20070627151334.9348be8e.pj@sgi.com>
Message-ID: <alpine.DEB.0.99.0706272313410.12292@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261950140.24949@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
 <20070627151334.9348be8e.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, andrea@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jun 2007, Paul Jackson wrote:

> I did have this vague recollection that I had seen something
> like this before, and it got shot down, because even tasks
> in entirely nonoverlapping cpusets might be holding memory
> resources on the nodes where we're running out of memory.
> 

There's only three cases I'm aware of (and correct me if I'm wrong) where 
that can happen: the GFP_ATOMIC exception, tasks that have switched their 
cpuset attachment, or a change in p->mems_allowed and left pages behind in 
other nodes with memory_migrate set to 0.

My patches do nothing but improve the behavior because what mainline 
does right now is simply kill current.  If that doesn't work, for whatever 
reason, in oom_kill_process() because its mm is detached, its 
OOM_DISABLE'd, etc, then the OOM killer becomes a no-op and we rely on 
another task to also fail a memory allocation later to enter the OOM 
killer and hope that it is killable.  So, unless we have two OOM'ing 
cpusets on the system and current turns out to hold memory allocations on 
another because of one of the three reasons above (which are unlikely), 
that is the only time when it would benefit the other OOM'ing cpuset to 
kill current.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
