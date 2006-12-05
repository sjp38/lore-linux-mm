Date: Tue, 5 Dec 2006 12:59:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: la la la la ... swappiness
In-Reply-To: <20061205124859.333d980d.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0612051254110.19561@schroedinger.engr.sgi.com>
References: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
 <Pine.LNX.4.64.0612050754020.3542@woody.osdl.org> <20061205085914.b8f7f48d.akpm@osdl.org>
 <f353cb6c194d4.194d4f353cb6c@texas.rr.com> <Pine.LNX.4.64.0612051031170.11860@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0612051038250.3542@woody.osdl.org>
 <Pine.LNX.4.64.0612051130200.18569@schroedinger.engr.sgi.com>
 <20061205120256.b1db9887.akpm@osdl.org> <Pine.LNX.4.64.0612051207240.18863@schroedinger.engr.sgi.com>
 <20061205124859.333d980d.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Aucoin <aucoin@houston.rr.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Tim Schmielau' <tim@physik3.uni-rostock.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Dec 2006, Andrew Morton wrote:

> > This is the same scenario as mlocked memory.
> 
> Not quite - mlocked pages are on the page LRU and hence contribute to the
> arithmetic in there.   The hugetlb pages are simply gone.

They cannot be swapped out and AFAICT the ratio calculations are assuming 
that pages can be evicted.

> > So if a 
> > cpuset is just 1/10th of the whole machine then we will never be able to 
> > reach the dirty limits, all the nodes of a cpuset may be filled up with 
> > dirty pages. A simple cp of a large file will bring the machine into a 
> > continual reclaim on all nodes.
> 
> It shouldn't be continual and it shouldn't be on all nodes.  What _should_

I meant all nodes of the cpuset.

> happen in this situation is that the dirty pages in those zones are written
> back off the LRU by the vm scanner.

Right in the best case that occurs. However, since we do not recognize 
that we are in a dirty overload situation we may not do synchrononous 
writes but return without having reclaimed any memory (a particular 
problem exists here in connections with NFS well known memory 
problems). If memory gets completely clogged then we OOM.

> That's less efficient from an IO scheduling POV than writing them back via
> the inodes, but it should work OK and it shouldn't affect other zones.

Could we get to the inode from the reclaim path and just start writing out 
all dirty pages of the indoe?

> If the activity is really "continual" and "on all nodes" then we have some
> bugs to fix.

Its continual on the nodes of the cpuset. Reclaim is constantly running 
and becomes very inefficient.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
