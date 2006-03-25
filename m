Date: Fri, 24 Mar 2006 17:44:48 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: Add gfp flag __GFP_POLICY to control policies and cpusets
 redirection of allocations
Message-Id: <20060324174448.0ac4a520.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603221342170.24959@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603221342170.24959@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Christoph Lameter <clameter@sgi.com>, ak@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew,

I am NAQ'ing this patch, aka:

  add-gfp-flag-__gfp_policy-to-control-policies-and-cpusets-redirection.patch added to -mm tree

This patch does not always fix the problem that first motivated it of
failed memory migrations, and it changes the semantics of the
interaction of the kernel page allocators with the cpuset and mempolicy
memory policies in ways that, in my view, need more analysis first.

I intend to send a patch with a different solution on about Monday
three days from now, hopefully with Christoph's review and ACK.

Details ... for the curious:

  We have two sets of problems here.

  1) Invoking memory migration via the cpuset interface 'memory_migrate'
     would fail (do nothing, without complaint or explanation) if
     the task invoking the migration was not in the target cpuset of
     the migration.  This caused much confusion and befuddlement of
     Christoph, myself and our test engineers.

     The key problem was that we are trying to allocate the new pages
     to receive the migration in the context of the task invoking the
     migration.  If that tasks cpusets (or mbind mempolicy) doesn't allow
     allocation on those nodes, the migration will move the target
     task to some nodes that are in the invoking tasks cpuset instead.

     This needs fixing sooner rather than later.  The ordinary user
     of memory migration will often find it broken until we fix this.

     My next attempt to fix this will have the kernel migration code
     temporarilly and silently and automatically put the invoking task
     in the necessary cpuset, so that the migration code can allocate
     the new pages on the requested nodes.  I hope to prepare this
     patch this weekend, so Christoph can review it Monday, and we
     can submit it then.

  2) The GFP flags and the interaction with various kernel allocators
     and the cpuset and mm/mempolicy memory policies have some strange
     '(mis)features'.  In the normal case, when there is enough memory
     where asked for, they are ok.

     Or, at least, no one has actually noticed the breakage, even
     though much of it has been there for over a year.

     The 2 patches that Christoph and I sent so far (the above
     NAQ'd patch and its predecessor) both addressed some of these
     '(mis)features', with the side affect of fixing (most of the time,
     not all cases) the failed migrations of problem (1) above.

     But both patches were partial bandaids.

     More thought will be required before we offer up solutions for
     (2).  If I get the chance this weekend, I will at least try to
     write up an lkml post describing some of the '(mis)features' we
     observed during our analysis of this area, under some such Subject
     as "Misfeatures of the kernel allocators and memory policy."

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
