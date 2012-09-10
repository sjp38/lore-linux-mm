Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id D84F76B005D
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 07:55:17 -0400 (EDT)
Date: Mon, 10 Sep 2012 13:55:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + mm-memblock-reduce-overhead-in-binary-search.patch added to
 -mm tree
Message-ID: <20120910115514.GC17437@dhcp22.suse.cz>
References: <20120907235058.A33F75C0219@hpza9.eem.corp.google.com>
 <20120910082035.GA13035@dhcp22.suse.cz>
 <20120910094604.GA7365@hacker.(null)>
 <20120910110550.GA17437@dhcp22.suse.cz>
 <20120910113051.GA15193@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120910113051.GA15193@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, shangw@linux.vnet.ibm.com, yinghai@kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 10-09-12 19:30:51, Wanpeng Li wrote:
> On Mon, Sep 10, 2012 at 01:05:50PM +0200, Michal Hocko wrote:
> >On Mon 10-09-12 17:46:04, Wanpeng Li wrote:
> >> On Mon, Sep 10, 2012 at 10:22:39AM +0200, Michal Hocko wrote:
> >> >[Sorry for the late reply]
> >> >
> >> >On Fri 07-09-12 16:50:57, Andrew Morton wrote:
> >> >> 
> >> >> The patch titled
> >> >>      Subject: mm/memblock: reduce overhead in binary search
> >> >> has been added to the -mm tree.  Its filename is
> >> >>      mm-memblock-reduce-overhead-in-binary-search.patch
> >> >> 
> >> >> Before you just go and hit "reply", please:
> >> >>    a) Consider who else should be cc'ed
> >> >>    b) Prefer to cc a suitable mailing list as well
> >> >>    c) Ideally: find the original patch on the mailing list and do a
> >> >>       reply-to-all to that, adding suitable additional cc's
> >> >> 
> >> >> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> >> >> 
> >> >> The -mm tree is included into linux-next and is updated
> >> >> there every 3-4 working days
> >> >> 
> >> >> ------------------------------------------------------
> >> >> From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> >> >> Subject: mm/memblock: reduce overhead in binary search
> >> >> 
> >> >> When checking that the indicated address belongs to the memory region, the
> >> >> memory regions are checked one by one through a binary search, which will
> >> >> be time consuming.
> >> >
> >> >How many blocks do you have that O(long) is that time consuming?
> >> >
> >> >> If the indicated address isn't in the memory region, then we needn't do
> >> >> the time-consuming search.  
> >> >
> >> >How often does this happen?
> >> >
> >> >> Add a check on the indicated address for that purpose.
> >> >
> >> >We have 2 users of this function. One is exynos_sysmmu_enable and the
> >> >other pfn_valid for unicore32. The first one doesn't seem to be used
> >> >anywhere (as per git grep). The other one could benefit from it but it
> >> >would be nice to hear about how much it really helps becuase if the
> >> >address is (almost) never outside of start,end DRAM bounds then you just
> >> >add a pointless check.
> >> >Besides that, if this kind of optimization is really worth, why don't we
> >> >do the same thing for memblock_is_reserved and memblock_is_region_memory
> >> >as well?
> >> 
> >> As Yinghai said,
> >> 
> >> BIOS could have reserved some ranges, and those ranges are not overlapped by 
> >> RAM. and so those range will not be in memory and reserved array.
> >> 
> >> later kernel will probe some range, and reserved those range, so those
> >> range get inserted into reserved array. reserved and memory array is
> >> different.
> >
> >OK. Thanks for the clarification. The main question remains, though. Is
> >this worth for memblock_is_memory?
> 
> There are many call sites need to call pfn_valid, how can you guarantee all
> the addrs are between memblock_start_of_DRAM() and memblock_end_of_DRAM(), 
> if not can this reduce possible overhead ? 

That was my question. I hoped for an answer in the patch description. I
am really not familiar with unicore32 which is the only user now.

> I add unlikely which means that this will not happen frequently. :-)

unlikely doesn't help much in this case. You would be doing the test for
every pfn_valid invocation anyway. So the main question is. Do you want
to optimize for something that doesn't happen often when it adds a cost
(not a big one but still) for the more probable cases?
I would say yes if we clearly see that the exceptional case really pays
off. Nothing in the changelog convinces me about that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
