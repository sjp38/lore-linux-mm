Date: Fri, 21 Apr 2006 08:06:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] split zonelist and use nodemask for page allocation [1/4]
In-Reply-To: <20060420235616.b2000f7f.pj@sgi.com>
Message-ID: <Pine.LNX.4.64.0604210800470.26525@schroedinger.engr.sgi.com>
References: <20060421131147.81477c93.kamezawa.hiroyu@jp.fujitsu.com>
 <20060420231751.f1068112.pj@sgi.com> <20060421154916.f1c436d3.kamezawa.hiroyu@jp.fujitsu.com>
 <20060420235616.b2000f7f.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, ak@suse.com
List-ID: <linux-mm.kvack.org>

One thing that also may be good to implement is to get away from traveling 
lists for allocations.

Most of the time you will have multiple nodes at the same distance for 
an allocation. It would be best if we either could do a round robin on 
those nodes or check the amount of memory free and allocate from the one 
with the most memory free. This means that the nodelist would not work and 
that the algorithm for selecting a remote node would get more complex.

Also when going off node: It may be good to increase the amount that 
cannot be touched to reserve more memory for local allocations.

I think there are definitely some challenges here as Paul pointed out. 
However, I think we may be at a dead end with the zonelist. Going away 
from the zonelist would also enable the consolidation of policy and cpuset 
restrictions. If the page allocator can take a list of nodes from which 
allocations are allowed then the cpuset hooks may no longer be necessary.

However, this is certainly not immediately doable but needs careful 
thought and performance measurement to insure that we avoid regressions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
