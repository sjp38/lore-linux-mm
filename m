Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 61724831F3
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 19:29:13 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id x188so595415itb.3
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 16:29:13 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id z21si11540781pgf.270.2017.04.21.16.29.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 16:29:12 -0700 (PDT)
Message-ID: <1492817351.3209.56.camel@linux.intel.com>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Fri, 21 Apr 2017 16:29:11 -0700
In-Reply-To: <87tw5idjv9.fsf@yhuang-dev.intel.com>
References: <20170407064901.25398-1-ying.huang@intel.com>
	 <20170418045909.GA11015@bbox> <87y3uwrez0.fsf@yhuang-dev.intel.com>
	 <20170420063834.GB3720@bbox> <874lxjim7m.fsf@yhuang-dev.intel.com>
	 <87tw5idjv9.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

On Fri, 2017-04-21 at 20:29 +0800, Huang, Ying wrote:
> "Huang, Ying" <ying.huang@intel.com> writes:
> 
> > 
> > Minchan Kim <minchan@kernel.org> writes:
> > 
> > > 
> > > On Wed, Apr 19, 2017 at 04:14:43PM +0800, Huang, Ying wrote:
> > > > 
> > > > Minchan Kim <minchan@kernel.org> writes:
> > > > 
> > > > > 
> > > > > Hi Huang,
> > > > > 
> > > > > On Fri, Apr 07, 2017 at 02:49:01PM +0800, Huang, Ying wrote:
> > > > > > 
> > > > > > From: Huang Ying <ying.huang@intel.com>
> > > > > > 
> > > > > > A void swapcache_free_entries(swp_entry_t *entries, int n)
> > > > > > A {
> > > > > > A 	struct swap_info_struct *p, *prev;
> > > > > > @@ -1075,6 +1083,10 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
> > > > > > A 
> > > > > > A 	prev = NULL;
> > > > > > A 	p = NULL;
> > > > > > +
> > > > > > +	/* Sort swap entries by swap device, so each lock is only taken once. */
> > > > > > +	if (nr_swapfiles > 1)
> > > > > > +		sort(entries, n, sizeof(entries[0]), swp_entry_cmp, NULL);
> > > > > Let's think on other cases.
> > > > > 
> > > > > There are two swaps and they are configured by priority so a swap's usage
> > > > > would be zero unless other swap used up. In case of that, this sorting
> > > > > is pointless.
> > > > > 
> > > > > As well, nr_swapfiles is never decreased so if we enable multiple
> > > > > swaps and then disable until a swap is remained, this sorting is
> > > > > pointelss, too.
> > > > > 
> > > > > How about lazy sorting approach? IOW, if we found prev != p and,
> > > > > then we can sort it.
> > > > Yes.A A That should be better.A A I just don't know whether the added
> > > > complexity is necessary, given the array is short and sort is fast.
> > > Huh?
> > > 
> > > 1. swapon /dev/XXX1
> > > 2. swapon /dev/XXX2
> > > 3. swapoff /dev/XXX2
> > > 4. use only one swap
> > > 5. then, always pointless sort.
> > Yes.A A In this situation we will do unnecessary sorting.A A What I don't
> > know is whether the unnecessary sorting will hurt performance in real
> > life.A A I can do some measurement.
> I tested the patch with 1 swap device and 1 process to eat memory
> (remove the "if (nr_swapfiles > 1)" for test).A A 

It is possible that nr_swapfiles > 1 when we have only 1 swapfile due
to swapoff. A The nr_swapfiles never decrement on swapoff.
We will need to use another counter in alloc_swap_info and
swapoff to track the true number of swapfiles in use to have a fast path
that avoid the search and sort for the 1 swap case.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
