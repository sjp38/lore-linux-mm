Received: by ik-out-1112.google.com with SMTP id c28so8262ika
        for <linux-mm@kvack.org>; Tue, 17 Jul 2007 16:42:39 -0700 (PDT)
Message-ID: <29495f1d0707171642t7c1a26d7l1c36a896e1ba3b47@mail.gmail.com>
Date: Tue, 17 Jul 2007 16:42:39 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
In-Reply-To: <20070713143838.02c3fa95.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070713151621.17750.58171.stgit@kernel>
	 <20070713151717.17750.44865.stgit@kernel>
	 <20070713130508.6f5b9bbb.pj@sgi.com>
	 <1184360742.16671.55.camel@localhost.localdomain>
	 <20070713143838.02c3fa95.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com, clameter@sgi.com, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On 7/13/07, Paul Jackson <pj@sgi.com> wrote:
> Adam wrote:
> > To be honest, I just don't think a global hugetlb pool and cpusets are
> > compatible, period.
>
> It's not an easy fit, that's for sure ;).

In the context of my patches to make the hugetlb pool's interleave
work with memoryless nodes, I may have pseudo-solution for growing the
pool while respecting cpusets.

Essentially, given that GFP_THISNODE allocations stay on the node
requested (which is the case after Christoph's set of memoryless node
patches go in), we invoke:

  pol = mpol_new(MPOL_INTERLEAVE, &node_states[N_MEMORY])

in the two callers of alloc_fresh_huge_page(pol) in hugetlb.c.
alloc_fresh_huge_page() in turn invokes interleave_nodes(pol) so that
we request hugepages in an interleaved fashion over all nodes with
memory.

Now, what I'm wondering is why interleave_nodes() is not cpuset aware?
Or is it expected that the caller do the right thing with the policy
beforehand? If so, I think I could just make those two callers do

  pol = mpol_new(MPOL_INTERLEAVE, cpuset_mems_allowed(current))

?

Or am I way off here?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
