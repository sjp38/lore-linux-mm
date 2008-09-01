Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <48BBB326.3080505@linux.vnet.ibm.com>
References: <20080831174756.GA25790@balbir.in.ibm.com>
	 <48BBAFDD.1000902@openvz.org>  <48BBB326.3080505@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Mon, 01 Sep 2008 15:19:22 +0200
Message-Id: <1220275162.8426.61.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-09-01 at 14:47 +0530, Balbir Singh wrote:
> Pavel Emelyanov wrote:
> > Balbir Singh wrote:
> >> This is a rewrite of a patch I had written long back to remove struct page
> >> (I shared the patches with Kamezawa, but never posted them anywhere else).
> >> I spent the weekend, cleaning them up for 2.6.27-rc5-mmotm (29 Aug 2008).
> >>
> >> I've tested the patches on an x86_64 box, I've run a simple test running
> >> under the memory control group and the same test running concurrently under
> >> two different groups (and creating pressure within their groups). I've also
> >> compiled the patch with CGROUP_MEM_RES_CTLR turned off.
> >>
> >> Advantages of the patch
> >>
> >> 1. It removes the extra pointer in struct page
> >>
> >> Disadvantages
> >>
> >> 1. It adds an additional lock structure to struct page_cgroup
> >> 2. Radix tree lookup is not an O(1) operation, once the page is known
> >>    getting to the page_cgroup (pc) is a little more expensive now.
> > 
> > And besides, we also have a global lock, that protects even lookup
> > from this structure. Won't this affect us too much on bug-smp nodes?
> 
> Sorry, not sure I understand. The lookup is done under RCU. Updates are done
> using the global lock. It should not be hard to make the radix tree per node
> later (as an iterative refinement).

Or you could have a look at the concurrent radix tree, esp for dense
trees it can save a lot on lock bouncing.

Latest code available at:

http://programming.kicks-ass.net/kernel-patches/concurrent-pagecache/27-rc3/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
