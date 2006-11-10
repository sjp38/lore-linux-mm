Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id kAACs6kY252504
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 23:54:10 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAACkXmI207188
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 23:46:43 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAACh74p012357
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 23:43:07 +1100
Message-ID: <455473CD.10609@in.ibm.com>
Date: Fri, 10 Nov 2006 18:12:53 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 8/8] RSS controller support reclamation
References: <20061109193523.21437.86224.sendpatchset@balbir.in.ibm.com> <20061109193636.21437.11778.sendpatchset@balbir.in.ibm.com> <45543E36.2080600@openvz.org> <45544362.9040805@in.ibm.com> <4554466F.8010602@openvz.org>
In-Reply-To: <4554466F.8010602@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelianov <xemul@openvz.org>
Cc: Linux MM <linux-mm@kvack.org>, dev@openvz.org, ckrm-tech@lists.sourceforge.net, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, haveblue@us.ibm.com, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

Pavel Emelianov wrote:
> Balbir Singh wrote:
> 
> [snip]
> 
>>> And what about a hard limit - how would you fail in page fault in
>>> case of limit hit? SIGKILL/SEGV is not an option - in this case we
>>> should run synchronous reclamation. This is done in beancounter
>>> patches v6 we've sent recently.
>>>
>> I thought about running synchronous reclamation, but then did not follow
>> that approach, I was not sure if calling the reclaim routines from the
>> page fault context is a good thing to do. It's worth trying out, since
> 
> Each page fault potentially calls reclamation by allocating
> required page with __GFP_IO | __GFP_FS bits set. Synchronous
> reclamation in page fault is really normal.

True. I don't know what I was thinking, thanks for making me think
straight.

> 
> [snip]
> 
>>> Please correct me if I'm wrong, but does this reclamation work like
>>> "run over all the zones' lists searching for page whose controller
>>> is sc->container" ?
>>>
>> Yeah, that's correct. The code can also reclaim memory from all over-the-limit
> 
> OK. What if I have a container with 100 pages limit in a 4Gb
> (~ million of pages) machine and this group starts reclaiming
> its pages. In case this group uses its pages heavily they will
> be at the beginning of an LRU list and reclamation code would
> have to scan through all (million) pages before it finds proper
> ones. This is not optimal!
> 

Yes, thats possible. The trade off is between

The cost associated with traversing that list while reclaiming
and the complexity associated with task migration. If we keep
a per-container list of pages, during task migration, you'll have
to migrate pages (of the task) from the list to the new container.

>> containers (by passing SC_OVERLIMIT_ALL). The idea behind using such a scheme
>> is to ensure that the global LRU list is not broken.
> 
> isolate_lru_pages() helps in this. As far as I remember this
> was introduced to reduce lru lock contention and keep lru
> lists integrity.
> 
> In beancounters patches this is used to shrink BC's pages.

I'll look at isolate_lru_pages() to see if the reclaim can be optimized.

Thanks for your feedback,


-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
