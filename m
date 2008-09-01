Date: Mon, 1 Sep 2008 13:03:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Message-Id: <20080901130351.f005d5b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48BB6160.4070904@linux.vnet.ibm.com>
References: <20080831174756.GA25790@balbir.in.ibm.com>
	<20080901090102.46b75141.kamezawa.hiroyu@jp.fujitsu.com>
	<48BB6160.4070904@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, 01 Sep 2008 08:58:32 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Sun, 31 Aug 2008 23:17:56 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> >> This is a rewrite of a patch I had written long back to remove struct page
> >> (I shared the patches with Kamezawa, but never posted them anywhere else).
> >> I spent the weekend, cleaning them up for 2.6.27-rc5-mmotm (29 Aug 2008).
> >>
> > It's just because I think there is no strong requirements for 64bit count/mapcount.
> > There is no ZERO_PAGE() for ANON (by Nick Piggin. I add him to CC.)
> > (shmem still use it but impact is not big.)
> > 
> 
> I understand the comment, but not it's context. Are you suggesting that the
> sizeof _count and _mapcount can be reduced? Hence the impact of having a member
> in struct page is not all that large? I think the patch is definitely very
> important for 32 bit systems.
Maybe they cannot be reduced. For 32bit systems, if the machine doesn't equip
crazy amounts of memory (as 32GB) I don't think this 32bit is not very large.

Let's calculate. 1GB/4096 x 4 bytes = 1 MB per 1GB. 
But you adds spinlock_t, then what this patch reduce is not so big. Maybe only
hundreds of kilobytes. (All pages in HIGHMEM will be used with structpage_cgroup.)


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
> >>
> >> This is an initial RFC for comments
> >>
> >> TODOs
> >>
> >> 1. Test the page migration changes
> >> 2. Test the performance impact of the patch/approach
> >>
> >> Comments/Reviews?
> >>
> > plz wait until lockless page cgroup....
> > 
> 
> That depends, if we can get the lockless page cgroup done quickly, I don't mind
> waiting, but if it is going to take longer, I would rather push these changes
> in. 
The development of lockless-page_cgroup is not stalled. I'm just waiting for
my 8cpu box comes back from maintainance...
If you want to see, I'll post v3 with brief result on small (2cpu) box.

> There should not be too much overhead in porting lockless page cgroup patch
> on top of this (remove pc->lock and use pc->flags). I'll help out, so as to
> avoid wastage of your effort.
> 
> > And If you don't support radix-tree-delete(), pre-allocating all at boot is better.
> > 
> 
> We do use radix-tree-delete() in the code, please see below. Pre-allocating has
> the disadvantage that we will pre-allocate even for kernel pages, etc.
> 
Sorry. I missed pc==NULL case.


> > BTW, why pc->lock is necessary ? It increases size of struct page_cgroup and reduce 
> > the advantege of your patch's to half (8bytes -> 4bytes).
> > 
> 
> Yes, I've mentioned that as a disadvantage. Are you suggesting that with
> lockless page cgroup we won't need pc->lock?
> 
Not so clear at this stage. 

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
