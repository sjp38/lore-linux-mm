Date: Wed, 19 Sep 2007 11:21:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 6/4] oom: pass null to kfree if zonelist is not cleared
In-Reply-To: <20070919100922.16be90c0.pj@sgi.com>
Message-ID: <alpine.DEB.0.9999.0709191110480.19414@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random> <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180246580.21326@chino.kir.corp.google.com> <Pine.LNX.4.64.0709181256260.3953@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709181306140.22984@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709181314160.3953@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709181340060.27785@chino.kir.corp.google.com> <Pine.LNX.4.64.0709181400440.4494@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709181406490.31545@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709181423250.4494@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709181509420.2461@chino.kir.corp.google.com> <20070919100922.16be90c0.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, akpm@linux-foundation.org, andrea@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, Paul Jackson wrote:

> David wrote:
> > Why would it be constrained by the cpuset policy if there is no 
> > __GFP_HARDWALL?
> 
> Er eh ... because it is ;)
> 
> With or without GFP_HARDWALL, allocations are constrained by cpuset
> policy.
> 
> It's just a different policy (the nearest ancestor cpuset marked
> mem_exclusive) without GFP_HARDWALL, rather than the current cpuset.
> 

The question is: why do we care?  I don't understand why it makes so much 
of a difference if the kzalloc fails and we fall back to non-serialized 
behavior, even though the updated patchset sets PF_MEMALLOC in current to 
avoid watermarks in its allocation.

We could set TIF_MEMDIE in current momentarily only for the kzalloc, but I 
think it's unnecessary and possibly troublesome because that task can be 
detected in parallel OOM killings and it suddenly becomes a no-op.  Even 
if we aren't serialized, the parallel OOM-killed task will be marked 
TIF_MEMDIE and we'll detect that and not kill anything because we've 
serialized on callback_mutex.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
