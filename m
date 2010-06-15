Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E34DC6B0225
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 08:50:16 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5FCf1wU022655
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 06:41:01 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o5FCo85T256972
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 06:50:09 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5FCnwkZ008452
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 06:49:58 -0600
Date: Tue, 15 Jun 2010 18:19:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
Message-ID: <20100615124955.GF4306@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100611045600.GE5191@balbir.in.ibm.com>
 <4C15E3C8.20407@redhat.com>
 <20100614084810.GT5191@balbir.in.ibm.com>
 <1276528376.6437.7176.camel@nimitz>
 <20100614165853.GW5191@balbir.in.ibm.com>
 <1276535371.6437.7417.camel@nimitz>
 <20100614171624.GY5191@balbir.in.ibm.com>
 <4C1727EC.2020500@redhat.com>
 <20100615075210.GB4306@balbir.in.ibm.com>
 <4C174DD7.3000608@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4C174DD7.3000608@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Avi Kivity <avi@redhat.com> [2010-06-15 12:54:31]:

> On 06/15/2010 10:52 AM, Balbir Singh wrote:
> >>>
> >>>That is why the policy (in the next set) will come from the host. As
> >>>to whether the data is truly duplicated, my experiments show up to 60%
> >>>of the page cache is duplicated.
> >>Isn't that incredibly workload dependent?
> >>
> >>We can't expect the host admin to know whether duplication will
> >>occur or not.
> >>
> >I was referring to cache = (policy) we use based on the setup. I don't
> >think the duplication is too workload specific. Moreover, we could use
> >aggressive policies and restrict page cache usage or do it selectively
> >on ballooning. We could also add other options to make the ballooning
> >option truly optional, so that the system management software decides.
> 
> Consider a read-only workload that exactly fits in guest cache.
> Without trimming, the guest will keep hitting its own cache, and the
> host will see no access to the cache at all.  So the host (assuming
> it is under even low pressure) will evict those pages, and the guest
> will happily use its own cache.  If we start to trim, the guest will
> have to go to disk.  That's the best case.
>
> Now for the worst case.  A random access workload that misses the
> cache on both guest and host.  Now every page is duplicated, and
> trimming guest pages allows the host to increase its cache, and
> potentially reduce misses.  In this case trimming duplicated pages
> works.
> 
> Real life will see a mix of this.  Often used pages won't be
> duplicated, and less often used pages may see some duplication,
> especially if the host cache portion dedicated to the guest is
> bigger than the guest cache.
> 
> I can see that trimming duplicate pages helps, but (a) I'd like to
> be sure they are duplicates and (b) often trimming them from the
> host is better than trimming them from the guest.
>

Lets see the behaviour with these patches

The first patch is a proactive approach to keep more memory around.
Enabling the parameter implies we are OK paying the cost of some
overhead. My data shows that leaves a significant amount of free
memory with a small 5% (in my case) overhead. This brings us back to
what you can do with free memory.

The second patch shows no overhead and selectively tries to use free
cache to return back on memory pressure (as indicated by the balloon
driver). We've discussed the reasons for doing this

1. In the situations where cache is duplicated this should benefit
us. Your contention is that we need to be specific about the
duplication. That falls under the realm of CMM.
2. In the case of slab cache, duplication does not matter, it is a
free page, that should be reclaimed ahead of mapped pages ideally.
If the slab grows, it will get another new page.

What is the cost of (1)

In the worst case, we select a non-duplicated page, but for us to
select it, it should be inactive, in that case we do I/O to bring back
the page.

> Trimming from the guest is worthwhile if the pages are not used very
> often (but enough that caching them in the host is worth it) and if
> the host cache can serve more than one guest.  If we can identify
> those pages, we don't risk degrading best-case workloads (as defined
> above).
> 
> (note ksm to some extent identifies those pages, though it is a bit
> expensive, and doesn't share with the host pagecache).
>

I see that you are hinting towards finding exact duplicates, I don't
know if the cost and complexity justify it. I hope more users can try
the patches with and without the boot parameter and provide additional
feedback.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
