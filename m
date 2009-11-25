Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 490FC6B0044
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 12:36:54 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp04.au.ibm.com (8.14.3/8.13.1) with ESMTP id nAPHXb2u025693
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 04:33:37 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAPHXM4W1728622
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 04:33:22 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAPHanZP011588
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 04:36:49 +1100
Date: Wed, 25 Nov 2009 23:06:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/9] ksm: mem cgroup charge swapin copy
Message-ID: <20091125173645.GF2970@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
 <Pine.LNX.4.64.0911241648520.25288@sister.anvils>
 <20091125142355.GD2970@balbir.in.ibm.com>
 <Pine.LNX.4.64.0911251646340.19522@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0911251646340.19522@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh.dickins@tiscali.co.uk> [2009-11-25 17:12:13]:

> On Wed, 25 Nov 2009, Balbir Singh wrote:
> > * Hugh Dickins <hugh.dickins@tiscali.co.uk> [2009-11-24 16:51:13]:
> > 
> > > But ksm swapping does require one small change in mem cgroup handling.
> > > When do_swap_page()'s call to ksm_might_need_to_copy() does indeed
> > > substitute a duplicate page to accommodate a different anon_vma (or a
> > > different index), that page escaped mem cgroup accounting, because of
> > > the !PageSwapCache check in mem_cgroup_try_charge_swapin().
> > > 
> > 
> > The duplicate page doesn't show up as PageSwapCache
> 
> That's right.
> 
> > or are we optimizing
> > for the race condition where the page is not in SwapCache?
> 
> No, optimization wasn't on my mind at all.  To be honest, it's slightly
> worsening the case of the race in which another thread has independently
> faulted it in, and then removed it from swap cache.  But I think we'll
> agree that that's rare enough a case that a few more cycles doing it
> won't matter.
>

Thanks for clarifying, yes I agree that the condition is rare and
nothing for us to worry about about at the moment.
 
> > I should probably look at the full series.
> 
> 2/9 is the one which brings the problem: it's ksm_might_need_to_copy()
> (an inline which tests for the condition) and ksm_does_need_to_copy()
> (which makes a duplicate page when the condition has been found so).
> 
> The problem arises because an Anon struct page contains a pointer to
> its anon_vma, used to locate its ptes when swapping.  Suddenly, with
> KSM swapping, an anon page may get read in from swap, faulted in and
> pointed to its anon_vma, everything fine; but then faulted in again
> somewhere else, and needs to be pointed to a different anon_vma...
> 
> Lose its anon_vma and it becomes unswappable, not a good choice when
> trying to extend swappability: so instead we allocate a duplicate page
> just to point to the different anon_vma; and if they last long enough,
> unchanged, KSM will come around again to find them the same and
> remerge them.  Not an efficient solution, but a simple solution,
> much in keeping with the way KSM already works.
> 
> The duplicate page is not PageSwapCache: certainly it crossed my mind
> to try making it PageSwapCache like the original, but I think that
> raises lots of other problems (how do we make the radix_tree slot
> for that offset hold two page pointers?).
>

Thanks for the detailed explanation, it does help me understand what
is going on. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
