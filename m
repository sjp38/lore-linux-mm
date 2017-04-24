Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD486B02C4
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 12:03:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v1so4884262pgv.8
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:03:32 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id w128si19500956pfb.153.2017.04.24.09.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 09:03:31 -0700 (PDT)
Message-ID: <1493049811.3209.61.camel@linux.intel.com>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Mon, 24 Apr 2017 09:03:31 -0700
In-Reply-To: <87pog3b6x8.fsf@yhuang-dev.intel.com>
References: <20170407064901.25398-1-ying.huang@intel.com>
	 <20170418045909.GA11015@bbox> <87y3uwrez0.fsf@yhuang-dev.intel.com>
	 <20170420063834.GB3720@bbox> <874lxjim7m.fsf@yhuang-dev.intel.com>
	 <87tw5idjv9.fsf@yhuang-dev.intel.com>
	 <1492817351.3209.56.camel@linux.intel.com>
	 <87pog3b6x8.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

On Sun, 2017-04-23 at 21:16 +0800, Huang, Ying wrote:
> Tim Chen <tim.c.chen@linux.intel.com> writes:
> 
> > 
> > On Fri, 2017-04-21 at 20:29 +0800, Huang, Ying wrote:
> > > 
> > > "Huang, Ying" <ying.huang@intel.com> writes:
> > > 
> > > > 
> > > > 
> > > > Minchan Kim <minchan@kernel.org> writes:
> > > > 
> > > > > 
> > > > > 
> > > > > On Wed, Apr 19, 2017 at 04:14:43PM +0800, Huang, Ying wrote:
> > > > > > 
> > > > > > 
> > > > > > Minchan Kim <minchan@kernel.org> writes:
> > > > > > 
> > > > > > > 
> > > > > > > 
> > > > > > > Hi Huang,
> > > > > > > 
> > > > > > > On Fri, Apr 07, 2017 at 02:49:01PM +0800, Huang, Ying wrote:
> > > > > > > > 
> > > > > > > > 
> > > > > > > > From: Huang Ying <ying.huang@intel.com>
> > > > > > > > 
> > > > > > > > A void swapcache_free_entries(swp_entry_t *entries, int n)
> > > > > > > > A {
> > > > > > > > A 	struct swap_info_struct *p, *prev;
> > > > > > > > @@ -1075,6 +1083,10 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
> > > > > > > > A 
> > > > > > > > A 	prev = NULL;
> > > > > > > > A 	p = NULL;
> > > > > > > > +
> > > > > > > > +	/* Sort swap entries by swap device, so each lock is only taken once. */
> > > > > > > > +	if (nr_swapfiles > 1)
> > > > > > > > +		sort(entries, n, sizeof(entries[0]), swp_entry_cmp, NULL);
> > > > > > > Let's think on other cases.
> > > > > > > 
> > > > > > > There are two swaps and they are configured by priority so a swap's usage
> > > > > > > would be zero unless other swap used up. In case of that, this sorting
> > > > > > > is pointless.
> > > > > > > 
> > > > > > > As well, nr_swapfiles is never decreased so if we enable multiple
> > > > > > > swaps and then disable until a swap is remained, this sorting is
> > > > > > > pointelss, too.
> > > > > > > 
> > > > > > > How about lazy sorting approach? IOW, if we found prev != p and,
> > > > > > > then we can sort it.
> > > > > > Yes.A A That should be better.A A I just don't know whether the added
> > > > > > complexity is necessary, given the array is short and sort is fast.
> > > > > Huh?
> > > > > 
> > > > > 1. swapon /dev/XXX1
> > > > > 2. swapon /dev/XXX2
> > > > > 3. swapoff /dev/XXX2
> > > > > 4. use only one swap
> > > > > 5. then, always pointless sort.
> > > > Yes.A A In this situation we will do unnecessary sorting.A A What I don't
> > > > know is whether the unnecessary sorting will hurt performance in real
> > > > life.A A I can do some measurement.
> > > I tested the patch with 1 swap device and 1 process to eat memory
> > > (remove the "if (nr_swapfiles > 1)" for test).A A 
> > It is possible that nr_swapfiles > 1 when we have only 1 swapfile due
> > to swapoff. A The nr_swapfiles never decrement on swapoff.
> > We will need to use another counter in alloc_swap_info and
> > swapoff to track the true number of swapfiles in use to have a fast path
> > that avoid the search and sort for the 1 swap case.
> Yes.A A That is a possible optimization.A A But it doesn't cover another use
> cases raised by Minchan (two swap device with different priority).A A So
> in general, we still need to check whether there are entries from
> multiple swap devices in the array.A A Given the cost of the checking code
> is really low, I think maybe we can just always use the checking code.
> Do you think so?

The single swap case is very common. It will be better if we can bypass the
extra logic and cost for multiple swap. A Yes, we still need the proper
check to see if sort is necessary as you proposed for the multiple swap case.

Tim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
