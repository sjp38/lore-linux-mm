Date: Wed, 21 Feb 2007 19:09:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Take anonymous pages off the LRU if we have no swap
In-Reply-To: <45DCFD22.2020300@redhat.com>
Message-ID: <Pine.LNX.4.64.0702211900340.29703@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702211409001.27422@schroedinger.engr.sgi.com>
 <45DCD309.5010109@redhat.com> <Pine.LNX.4.64.0702211600430.28364@schroedinger.engr.sgi.com>
 <45DCFD22.2020300@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Feb 2007, Rik van Riel wrote:

> > > http://linux-mm.org/PageReplacementDesign
> > 
> > I do not see how this issue would be solved there.
> 
> If there is no swap space, we do not bother scanning the anonymous
> page pool.  When swap space becomes available, we may end up scanning
> it again.

Ok. This is for linux 3.0?

> I would like to move the kernel towards something that fixes all
> of the problem workloads, instead of thinking about one problem
> at a time and reintroducing bugs for other workloads.

Problem workloads appear as machines grow to handle more memory.
 
> Changes still need to be introduced incrementally, of course, but
> I think it would be good if we had an idea where we were headed
> in the medium (or even long) term.

That is difficult to foresee. I am pretty happy right now with what we 
have and it seems to be adaptable enough for different workloads. I am a 
bit concerned about the advanced page replacement algorithms since we 
toyed with them and only found advantages for specialized workloads. LRU 
is simple and easy to handle.

> http://linux-mm.org/ProblemWorkloads

Well these are not the problem workloads that we encounter. Databases seem 
to be using huge pages which are not subject to swap. The startup issue is 
not that easily handled since usually large portions of the code 
may no longer be needed. fadvise may help there.

The very large working set is likely solvable by introducing some 
notion of higher order pages. Higher order pages -> less scanning. We 
already have the issue of having to handle gazillions of page structs if 
we want to write a terabyte to disk. Higher order pages would solve the 
issues on multiple levels. The larger memory gets the more difficult it 
will be to manage the gazillions of ptes and page structs. The chunk that 
we manage needs to be changed. I do not think that the handling of the 
chunks will make much differents. Its a question of the sheer number of 
them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
