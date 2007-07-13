Date: Fri, 13 Jul 2007 13:05:08 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
Message-Id: <20070713130508.6f5b9bbb.pj@sgi.com>
In-Reply-To: <20070713151717.17750.44865.stgit@kernel>
References: <20070713151621.17750.58171.stgit@kernel>
	<20070713151717.17750.44865.stgit@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com, clameter@sgi.com, kenchen@google.com
List-ID: <linux-mm.kvack.org>

Adam wrote:
> +	/*
> +	 * I haven't figured out how to incorporate this cpuset bodge into
> +	 * the dynamic hugetlb pool yet.  Hopefully someone more familiar with
> +	 * cpusets can weigh in on their desired semantics.  Maybe we can just
> +	 * drop this check?
> +	 *
>  	if (chg > cpuset_mems_nr(free_huge_pages_node))
>  		return -ENOMEM;
> +	 */

I can't figure out the value of this check either -- Ken Chen added it, perhaps
he can comment.

But the cpuset behaviour of this hugetlb stuff looks suspicious to me:
 1) The code in alloc_fresh_huge_page() seems to round robin over
    the entire system, spreading the hugetlb pages uniformly on all nodes.
    If one a task in one small cpuset starts aggressively allocating hugetlb
    pages, do you think this will work, Adam -- looks to me like we will end
    up calling alloc_fresh_huge_page() many times, most of which will fail to
    alloc_pages_node() anything because the 'static nid' clock hand will be
    pointing at a node outside of the current tasks cpuset (not in that tasks
    mems_allowed).  Inefficient, but I guess ok.
 2) I don't see what keeps us from picking hugetlb pages off -any- node in the
    system, perhaps way outside the current cpuset.  We shouldn't be looking for
    enough available (free_huge_pages - resv_huge_pages) pages in the whole
    system.  Rather we should be looking for and reserving enough such pages
    that are in the current tasks cpuset (set in its mems_allowed, to be precise)
    Folks aren't going to want their hugetlb pages coming from outside their
    tasks cpuset.
 3) If there is some code I missed (good chance) that enforces the rule that
    a task can only get a hugetlb page from a node in its cpuset, then this
    uniform global allocation of hugetlb pages, as noted in (1) above, can't
    be right.  Either it will force all nodes, including many nodes outside
    of the current tasks cpuset, to bulk up on free hugetlb pages, just to
    get enough of them on nodes allowed by the current tasks cpuset, or else
    it will fail to get enough on nodes local to the current tasks cpuset.
    I don't understand the logic well enough to know which, but either way
    sucks.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
