Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C04B76B01D6
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 03:50:01 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5F7jbbM013309
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 01:45:37 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5F7ntYp042308
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 01:49:55 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5F7nseb025333
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 01:49:54 -0600
Date: Tue, 15 Jun 2010 13:19:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
Message-ID: <20100615074949.GA4306@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100614084810.GT5191@balbir.in.ibm.com>
 <4C16233C.1040108@redhat.com>
 <20100614125010.GU5191@balbir.in.ibm.com>
 <4C162846.7030303@redhat.com>
 <1276529596.6437.7216.camel@nimitz>
 <4C164E63.2020204@redhat.com>
 <1276530932.6437.7259.camel@nimitz>
 <4C1659F8.3090300@redhat.com>
 <20100614174548.GB5191@balbir.in.ibm.com>
 <4C172499.7090800@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4C172499.7090800@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Avi Kivity <avi@redhat.com> [2010-06-15 09:58:33]:

> On 06/14/2010 08:45 PM, Balbir Singh wrote:
> >
> >>There are two decisions that need to be made:
> >>
> >>- how much memory a guest should be given
> >>- given some guest memory, what's the best use for it
> >>
> >>The first question can perhaps be answered by looking at guest I/O
> >>rates and giving more memory to more active guests.  The second
> >>question is hard, but not any different than running non-virtualized
> >>- except if we can detect sharing or duplication.  In this case,
> >>dropping a duplicated page is worthwhile, while dropping a shared
> >>page provides no benefit.
> >I think there is another way of looking at it, give some free memory
> >
> >1. Can the guest run more applications or run faster
> 
> That's my second question.  How to best use this memory.  More
> applications == drop the page from cache, faster == keep page in
> cache.
> 
> All we need is to select the right page to drop.
>

Do we need to drop to the granularity of the page to drop? I think
figuring out the class of pages and making sure that we don't write
our own reclaim logic, but work with what we have to identify the
class of pages is a good start. 
 
> >2. Can the host potentially get this memory via ballooning or some
> >other means to start newer guest instances
> 
> Well, we already have ballooning.  The question is can we improve
> the eviction algorithm.
> 
> >I think the answer to 1 and 2 is yes.
> >
> >>How the patch helps answer either question, I'm not sure.  I don't
> >>think preferential dropping of unmapped page cache is the answer.
> >>
> >Preferential dropping as selected by the host, that knows about the
> >setup and if there is duplication involved. While we use the term
> >preferential dropping, remember it is still via LRU and we don't
> >always succeed. It is a best effort (if you can and the unmapped pages
> >are not highly referenced) scenario.
> 
> How can the host tell if there is duplication?  It may know it has
> some pagecache, but it has no idea whether or to what extent guest
> pagecache duplicates host pagecache.
> 

Well it is possible in host user space, I for example use memory
cgroup and through the stats I have a good idea of how much is duplicated.
I am ofcourse making an assumption with my setup of the cached mode,
that the data in the guest page cache and page cache in the cgroup
will be duplicated to a large extent. I did some trivial experiments
like drop the data from the guest and look at the cost of bringing it
in and dropping the data from both guest and host and look at the
cost. I could see a difference.

Unfortunately, I did not save the data, so I'll need to redo the
experiment.

> >>>Those tell you how to balance going after the different classes of
> >>>things that we can reclaim.
> >>>
> >>>Again, this is useless when ballooning is being used.  But, I'm thinking
> >>>of a more general mechanism to force the system to both have MemFree
> >>>_and_ be acting as if it is under memory pressure.
> >>If there is no memory pressure on the host, there is no reason for
> >>the guest to pretend it is under pressure.  If there is memory
> >>pressure on the host, it should share the pain among its guests by
> >>applying the balloon.  So I don't think voluntarily dropping cache
> >>is a good direction.
> >>
> >There are two situations
> >
> >1. Voluntarily drop cache, if it was setup to do so (the host knows
> >that it caches that information anyway)
> 
> It doesn't, really.  The host only has aggregate information about
> itself, and no information about the guest.
> 
> Dropping duplicate pages would be good if we could identify them.
> Even then, it's better to drop the page from the host, not the
> guest, unless we know the same page is cached by multiple guests.
>

On the exact pages to drop, please see my comments above on the class
of pages to drop.
There are reasons for wanting to get the host to cache the data

Unless the guest is using cache = none, the data will still hit the
host page cache
The host can do a better job of optimizing the writeouts
 
> But why would the guest voluntarily drop the cache?  If there is no
> memory pressure, dropping caches increases cpu overhead and latency
> even if the data is still cached on the host.
> 

So, there are basically two approaches

1. First patch, proactive - enabled by a boot option
2. When ballooned, we try to (please NOTE try to) reclaim cached pages
first. Failing which, we go after regular pages in the alloc_page()
call in the balloon driver.

> >2. Drop the cache on either a special balloon option, again the host
> >knows it caches that very same information, so it prefers to free that
> >up first.
> 
> Dropping in response to pressure is good.  I'm just not convinced
> the patch helps in selecting the correct page to drop.
>

That is why I've presented data on the experiments I've run and
provided more arguments to backup the approach. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
