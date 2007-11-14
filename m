Subject: Re: [patch] nfs: use GFP_NOFS preloads for radix-tree insertion
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20071114042011.GE557@wotan.suse.de>
References: <20071108013723.GF3227@wotan.suse.de>
	 <20071107190254.4e65812a.akpm@linux-foundation.org>
	 <20071108031645.GI3227@wotan.suse.de>
	 <20071107201242.390aec38.akpm@linux-foundation.org>
	 <20071108045404.GJ3227@wotan.suse.de>
	 <20071107210204.62070047.akpm@linux-foundation.org>
	 <20071108054445.GA20162@wotan.suse.de>
	 <20071107220200.85e9cb59.akpm@linux-foundation.org>
	 <20071108065633.GB28216@wotan.suse.de> <1194951345.6983.24.camel@twins>
	 <20071114042011.GE557@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 14 Nov 2007 10:06:27 +0100
Message-Id: <1195031187.6924.1.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, davem@davemloft.net, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-11-14 at 05:20 +0100, Nick Piggin wrote:
> On Tue, Nov 13, 2007 at 11:55:45AM +0100, Peter Zijlstra wrote:
> > 
> > On Thu, 2007-11-08 at 07:56 +0100, Nick Piggin wrote:
> > > Here is the NFS version. I guess Trond should ack it before you pick it
> > > up.
> > > 
> > > --
> > > 
> > > NFS should use GFP_NOFS mode radix tree preloads rather than GFP_ATOMIC
> > > allocations at radix-tree insertion-time. This is important to reduce the
> > > atomic memory requirement.
> > 
> > In another mail you said:
> > 
> > > Anyway we can also simplify the code because the insertion can't fail with a
> > > preload.
> > 
> > Can we please avoid adding strict dependencies on that as the preload
> > API is unsupportable in -rt.
> 
> You can surely support it. You just have to do per-thread preloads if you
> want preemption left on.

Well, true, but that would mean adding stuff to task_struct, not the end
of the world I guess.

But as it is leaving the error handling on each individual
radix_tree_insert() allows us to just use GFP_KERNEL for everything.

The other, nicer option, is to do preload on the radix_tree_context
object instead.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
