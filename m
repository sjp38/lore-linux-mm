Date: Tue, 7 Aug 2007 17:13:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
In-Reply-To: <20070806103658.603735000@chello.nl>
Message-ID: <Pine.LNX.4.64.0708071702560.4941@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl> <20070806103658.603735000@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Peter Zijlstra wrote:

> Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
> contexts that are entitled to it.

Is this patch actually necessary?

If you are in an atomic context and bound to a cpu then a per cpu slab is 
assigned to you and no one else can take object aways from that process 
since nothing else can run on the cpu. The point of the patch is to avoid 
other processes draining objects right? So you do not need the 
modifications in that case.

If you are not in an atomic context and are preemptable or can switch 
allocation context then you can create another context in which reclaim 
could be run to remove some clean pages and get you more memory. Again no 
need for the patch.

I guess you may be limited in not being able to call into reclaim again 
because it is already running. Maybe that can be fixed? F.e. zone reclaim 
does that for the NUMA case. It simply scans for easily reclaimable pages.

We could guarantee easily reclaimable pages to exist in much larger 
numbers than the reserves of min_free_kbytes. So in a tight spot one could 
reclaim from those.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
