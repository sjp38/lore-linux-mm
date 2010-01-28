Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 308776B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 20:09:24 -0500 (EST)
Date: Thu, 28 Jan 2010 09:50:44 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 28 of 30] memcg huge memory
Message-Id: <20100128095044.f3177111.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <4B602304.9000709@linux.vnet.ibm.com>
References: <patchbomb.1264054824@v2.random>
	<4c405faf58cfe5d1aa6e.1264054852@v2.random>
	<20100121161601.6612fd79.kamezawa.hiroyu@jp.fujitsu.com>
	<20100121160807.GB5598@random.random>
	<20100122091317.39db5546.kamezawa.hiroyu@jp.fujitsu.com>
	<4B602304.9000709@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jan 2010 16:57:00 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> On Friday 22 January 2010 05:43 AM, KAMEZAWA Hiroyuki wrote:
> > 
> >> Now the only real pain remains in the LRU list accounting, I tried to
> >> solve it but found no clean way that didn't require mess all over
> >> vmscan.c. So for now hugepages in lru are accounted as 4k pages
> >> ;). Nothing breaks just stats won't be as useful to the admin...
> >>
> > Hmm, interesting/important problem...I keep it in my mind.
> 
> I hope the memcg accounting is not broken, I see you do the right thing
> while charging pages. The patch overall seems alright. Could you please
> update the Documentation/cgroups/memory.txt file as well with what these
> changes mean and memcg_tests.txt to indicate how to test the changes?
> 
I think we need update memcg's stats too. Otherwise the usage_in_bytes in root
cgroup become wrong(of course, those stats are also important for other cgroups).
If new vm_stat for transparent hugepage is added, it would be better to add it
to memcg too.

Moreover, considering the behavior of split_huge_page, we should update both
css->refcnt and pc->mem_cgroup about all the tail pages. Otherwise, if a transparent
hugepage splitted, tail pages of it become stale from the viewpoint of memcg,
i.e. those pages are not linked to any memcg's LRU.
It's another topic where we should update those data. IMHO, css->refcnt can be update
in try_charge/uncharge(I think __css_get()/__css_put(), which are now defined in mmotm,
can be used for it w/o adding big overhead). As for pc->mem_cgroup, I think it would
be better to update them by adding some hook in __split_huge_page_map() or some
to avoid adding some overhead to hot-path(charge/uncharge).


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
