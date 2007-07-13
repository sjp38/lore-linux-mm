Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id l6DLOl5f001188
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 22:24:47 +0100
Received: from an-out-0708.google.com (anab33.prod.google.com [10.100.53.33])
	by zps77.corp.google.com with ESMTP id l6DLOWOB015843
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 14:24:32 -0700
Received: by an-out-0708.google.com with SMTP id b33so115358ana
        for <linux-mm@kvack.org>; Fri, 13 Jul 2007 14:24:32 -0700 (PDT)
Message-ID: <b040c32a0707131424t6195ece8scbed2490af554624@mail.gmail.com>
Date: Fri, 13 Jul 2007 14:24:32 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
In-Reply-To: <1184360742.16671.55.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070713151621.17750.58171.stgit@kernel>
	 <20070713151717.17750.44865.stgit@kernel>
	 <20070713130508.6f5b9bbb.pj@sgi.com>
	 <1184360742.16671.55.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On 7/13/07, Adam Litke <agl@us.ibm.com> wrote:
> To be honest, I just don't think a global hugetlb pool and cpusets are
> compatible, period.

Agreed.  It's a mess.


> > But the cpuset behaviour of this hugetlb stuff looks suspicious to me:
> >  1) The code in alloc_fresh_huge_page() seems to round robin over
> >     the entire system, spreading the hugetlb pages uniformly on all nodes.
> >     If one a task in one small cpuset starts aggressively allocating hugetlb
> >     pages, do you think this will work, Adam -- looks to me like we will end
> >     up calling alloc_fresh_huge_page() many times, most of which will fail to
> >     alloc_pages_node() anything because the 'static nid' clock hand will be
> >     pointing at a node outside of the current tasks cpuset (not in that tasks
> >     mems_allowed).  Inefficient, but I guess ok.
>
> Very good point.  I guess we call alloc_fresh_huge_page in two scenarios
> now... 1) By echoing a number into /proc/sys/vm/nr_hugepages, and 2) by
> trying to dynamically increase the pool size for a particular process.
> Case 1 is not in the context of any process (per se) and so
> node_online_map makes sense.  For case 2 we could teach the
> __alloc_fresh_huge_page() to take a nodemask.  That could get nasty
> though since we'd have to move away from a static variable to get proper
> interleaving.

alloc_fresh_huge_page
    alloc_pages_node
        get_page_from_freelist {
            ...
            if ((alloc_flags & ALLOC_CPUSET) &&
                        !cpuset_zone_allowed_softwall(zone, gfp_mask))
                                goto try_next_zone;
            ...

It looks to me that cpuset rule is buried deep down in the buddy
allocator.  So the cpuset mem_allowed rule is enforced in both pool
reservation time (in get_page_from_freelist) and hugetlb page fault
time in dequeue_huge_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
