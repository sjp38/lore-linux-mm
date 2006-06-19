Subject: Re: [RFC][PATCH] inactive_clean
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0606190837450.1184@schroedinger.engr.sgi.com>
References: <1150719606.28517.83.camel@lappy>
	 <Pine.LNX.4.64.0606190837450.1184@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 19 Jun 2006 20:10:23 +0200
Message-Id: <1150740624.28517.108.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, Nick Piggin <piggin@cyberone.com.au>, linux-mm <linux-mm@kvack.org>, Nikita Danilov <nikita@clusterfs.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-06-19 at 08:45 -0700, Christoph Lameter wrote:
> On Mon, 19 Jun 2006, Peter Zijlstra wrote:
> 
> > My previous efforts at tracking dirty pages focused on shared pages.
> > But shared pages are not all and, quite often even a small part of the
> > problem. Most 'normal' workloads are dominated by anonymous pages.
> 
> Shared pages are the major problem because we have no way of tracking 
> their dirty state. Shared file mapped pages are a problem because they require 
> writeout which will not occur if we are not aware of them. The dirty state 
> of anonymous pages typically does not matter because these pages are 
> thrown away when a process terminates.
> 
> > So, in order to guarantee easily freeable pages we also have to look
> > at anonymous memory. Thinking about it I arrived at something Rik
> > invented long ago: the inactive_clean list - a third LRU list consisting
> > of clean page
> 
> I fail to see the point. What is the problem with anonymous memory? Swap?

http://linux-mm.org/NetworkStorageDeadlock

Basically, we want to free memory, but freeing costs more memory than we
currently have available.

This patch creates a pool of pages that can be evicted without IO, but
can also be taken back into service, again without IO - hence not
'wasting' memory being free.

The problem is currently being circumvented on several levels with local
mempools, these fragment the available free memory and require extra
complexity to manage.

Yes, raising the number of free pages will have the same effect, however
it wastes memory from another point of view.

Neither of these approaches will really solve the 'Network' problem,
because it does not come with a finite bound of memory. Any networked
storage can require inf. amount of memory for a single writeback.
Usually things are not that bad, esp. with dedicated storage networks
that avoid too much protocols stacks.

The only solution for the networked problem is in dropping non-critical
packets when we start to run low.

Also this does give more leeway to make things like cluster pageout:
http://linuxhacker.ru/~nikita/patches/2.6.15-rc1/05-cluster-pageout.patch
work.

In the end, I want to be able to run a diskless system, with networked
swap and, have stuff like cluster pageout working without the machine
going funny on me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
