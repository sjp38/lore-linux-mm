Received: by nf-out-0910.google.com with SMTP id h3so38524nfh
        for <linux-mm@kvack.org>; Fri, 13 Jul 2007 16:15:24 -0700 (PDT)
Message-ID: <29495f1d0707131615u75ffc714h2f4a2785a8e458ec@mail.gmail.com>
Date: Fri, 13 Jul 2007 16:15:24 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
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
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com, clameter@sgi.com, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On 7/13/07, Adam Litke <agl@us.ibm.com> wrote:
> On Fri, 2007-07-13 at 13:05 -0700, Paul Jackson wrote:
> > Adam wrote:
> > > +   /*
> > > +    * I haven't figured out how to incorporate this cpuset bodge into
> > > +    * the dynamic hugetlb pool yet.  Hopefully someone more familiar with
> > > +    * cpusets can weigh in on their desired semantics.  Maybe we can just
> > > +    * drop this check?
> > > +    *
> > >     if (chg > cpuset_mems_nr(free_huge_pages_node))
> > >             return -ENOMEM;
> > > +    */
> >
> > I can't figure out the value of this check either -- Ken Chen added it, perhaps
> > he can comment.
>
> To be honest, I just don't think a global hugetlb pool and cpusets are
> compatible, period.  I wonder if moving to the mempool interface and
> having dynamic adjustable per-cpuset hugetlb mempools (ick) could make
> things work saner.  It's on my list to see if mempools could be used to
> replace the custom hugetlb pool code.  Otherwise, Mel's zone_movable
> stuff could possibly remove the need for hugetlb pools as we know them.
>
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

<snip>

<snip>

> Perhaps if we make sure __alloc_fresh_huge_page() can be restricted to a
> nodemask then we can avoid stealing pages from other cpusets.  But we'd
> still be stuck with the existing problem for shared mappings: cpusets +
> our strict_reservation algorithm cannot provide guarantees (like we can
> without cpusets).

<snip>

> I'll cook up a __alloc_fresh_huge_page(nodemask) patch and see if that
> makes things better.  Thanks for your review and comments.

Already done, to some extent. Please see my set of three patches
(which I'll be posting again shortly), which stack on Christoph's
memoryless nodes patches. The first, which fixes hugepage interleaving
on memoryless node systems addes a mempolicy to
alloc_fresh_huge_page(). The second numafies most of the hugetlb.c API
to make things a little clearer. It might make sense to rebase some of
these patches of those changes? The third adds a per-node sysfs
interface for hugepage allocation. I think given those three, we might
be able to make cpusets and hugepages co-exist easier?

I'll post soon, just waiting for some test results to return.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
