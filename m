Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD9BA6B02F4
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 00:41:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 18so16352059pfm.18
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 21:41:24 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id s67si1474646pfj.268.2017.04.26.21.41.21
        for <linux-mm@kvack.org>;
        Wed, 26 Apr 2017 21:41:22 -0700 (PDT)
Date: Thu, 27 Apr 2017 13:35:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
Message-ID: <20170427043545.GA1726@bbox>
References: <20170407064901.25398-1-ying.huang@intel.com>
 <20170418045909.GA11015@bbox>
 <87y3uwrez0.fsf@yhuang-dev.intel.com>
 <20170420063834.GB3720@bbox>
 <874lxjim7m.fsf@yhuang-dev.intel.com>
 <87tw5idjv9.fsf@yhuang-dev.intel.com>
 <20170424045213.GA11287@bbox>
 <87y3un2vdp.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y3un2vdp.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

On Wed, Apr 26, 2017 at 08:42:10PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Fri, Apr 21, 2017 at 08:29:30PM +0800, Huang, Ying wrote:
> >> "Huang, Ying" <ying.huang@intel.com> writes:
> >> 
> >> > Minchan Kim <minchan@kernel.org> writes:
> >> >
> >> >> On Wed, Apr 19, 2017 at 04:14:43PM +0800, Huang, Ying wrote:
> >> >>> Minchan Kim <minchan@kernel.org> writes:
> >> >>> 
> >> >>> > Hi Huang,
> >> >>> >
> >> >>> > On Fri, Apr 07, 2017 at 02:49:01PM +0800, Huang, Ying wrote:
> >> >>> >> From: Huang Ying <ying.huang@intel.com>
> >> >>> >> 
> >> >>> >>  void swapcache_free_entries(swp_entry_t *entries, int n)
> >> >>> >>  {
> >> >>> >>  	struct swap_info_struct *p, *prev;
> >> >>> >> @@ -1075,6 +1083,10 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
> >> >>> >>  
> >> >>> >>  	prev = NULL;
> >> >>> >>  	p = NULL;
> >> >>> >> +
> >> >>> >> +	/* Sort swap entries by swap device, so each lock is only taken once. */
> >> >>> >> +	if (nr_swapfiles > 1)
> >> >>> >> +		sort(entries, n, sizeof(entries[0]), swp_entry_cmp, NULL);
> >> >>> >
> >> >>> > Let's think on other cases.
> >> >>> >
> >> >>> > There are two swaps and they are configured by priority so a swap's usage
> >> >>> > would be zero unless other swap used up. In case of that, this sorting
> >> >>> > is pointless.
> >> >>> >
> >> >>> > As well, nr_swapfiles is never decreased so if we enable multiple
> >> >>> > swaps and then disable until a swap is remained, this sorting is
> >> >>> > pointelss, too.
> >> >>> >
> >> >>> > How about lazy sorting approach? IOW, if we found prev != p and,
> >> >>> > then we can sort it.
> >> >>> 
> >> >>> Yes.  That should be better.  I just don't know whether the added
> >> >>> complexity is necessary, given the array is short and sort is fast.
> >> >>
> >> >> Huh?
> >> >>
> >> >> 1. swapon /dev/XXX1
> >> >> 2. swapon /dev/XXX2
> >> >> 3. swapoff /dev/XXX2
> >> >> 4. use only one swap
> >> >> 5. then, always pointless sort.
> >> >
> >> > Yes.  In this situation we will do unnecessary sorting.  What I don't
> >> > know is whether the unnecessary sorting will hurt performance in real
> >> > life.  I can do some measurement.
> >> 
> >> I tested the patch with 1 swap device and 1 process to eat memory
> >> (remove the "if (nr_swapfiles > 1)" for test).  I think this is the
> >> worse case because there is no lock contention.  The memory freeing time
> >> increased from 1.94s to 2.12s (increase ~9.2%).  So there is some
> >> overhead for some cases.  I change the algorithm to something like
> >> below,
> >> 
> >>  void swapcache_free_entries(swp_entry_t *entries, int n)
> >>  {
> >>  	struct swap_info_struct *p, *prev;
> >>  	int i;
> >> +	swp_entry_t entry;
> >> +	unsigned int prev_swp_type;
> >>  
> >>  	if (n <= 0)
> >>  		return;
> >>  
> >> +	prev_swp_type = swp_type(entries[0]);
> >> +	for (i = n - 1; i > 0; i--) {
> >> +		if (swp_type(entries[i]) != prev_swp_type)
> >> +			break;
> >> +	}
> >
> > That's really what I want to avoid. For many swap usecases,
> > it adds unnecessary overhead.
> >
> >> +
> >> +	/* Sort swap entries by swap device, so each lock is only taken once. */
> >> +	if (i)
> >> +		sort(entries, n, sizeof(entries[0]), swp_entry_cmp, NULL);
> >>  	prev = NULL;
> >>  	p = NULL;
> >>  	for (i = 0; i < n; ++i) {
> >> -		p = swap_info_get_cont(entries[i], prev);
> >> +		entry = entries[i];
> >> +		p = swap_info_get_cont(entry, prev);
> >>  		if (p)
> >> -			swap_entry_free(p, entries[i]);
> >> +			swap_entry_free(p, entry);
> >>  		prev = p;
> >>  	}
> >>  	if (p)
> >> 
> >> With this patch, the memory freeing time increased from 1.94s to 1.97s.
> >> I think this is good enough.  Do you think so?
> >
> > What I mean is as follows(I didn't test it at all):
> >
> > With this, sort entries if we found multiple entries in current
> > entries. It adds some condition checks for non-multiple swap
> > usecase but it would be more cheaper than the sorting.
> > And it adds a [un]lock overhead for multiple swap usecase but
> > it should be a compromise for single-swap usecase which is more
> > popular.
> >
> 
> How about the following solution?  It can avoid [un]lock overhead and
> double lock issue for multiple swap user case and has good performance
> for one swap user case too.

How worse with approach I suggested compared to as-is?
Unless it's too bad, let's not add more complicated thing to just
enhance the minor usecase in such even *slow* path.
It adds code size/maintainance overead.
With your suggestion, it might enhance a bit with speicific benchmark
but not sure it's really worth for real practice.

> 
> Best Regards,
> Huang, Ying
> 
> From 7bd903c42749c448ef6acbbdee8dcbc1c5b498b9 Mon Sep 17 00:00:00 2001
> From: Huang Ying <ying.huang@intel.com>
> Date: Thu, 23 Feb 2017 13:05:20 +0800
> Subject: [PATCH -v5] mm, swap: Sort swap entries before free
> 
> To reduce the lock contention of swap_info_struct->lock when freeing
> swap entry.  The freed swap entries will be collected in a per-CPU
> buffer firstly, and be really freed later in batch.  During the batch
> freeing, if the consecutive swap entries in the per-CPU buffer belongs
> to same swap device, the swap_info_struct->lock needs to be
> acquired/released only once, so that the lock contention could be
> reduced greatly.  But if there are multiple swap devices, it is
> possible that the lock may be unnecessarily released/acquired because
> the swap entries belong to the same swap device are non-consecutive in
> the per-CPU buffer.
> 
> To solve the issue, the per-CPU buffer is sorted according to the swap
> device before freeing the swap entries.  Test shows that the time
> spent by swapcache_free_entries() could be reduced after the patch.
> 
> With the patch, the memory (some swapped out) free time reduced
> 13.6% (from 2.59s to 2.28s) in the vm-scalability swap-w-rand test
> case with 16 processes.  The test is done on a Xeon E5 v3 system.  The
> swap device used is a RAM simulated PMEM (persistent memory) device.
> To test swapping, the test case creates 16 processes, which allocate
> and write to the anonymous pages until the RAM and part of the swap
> device is used up, finally the memory (some swapped out) is freed
> before exit.
> 
> Signed-off-by: Huang Ying <ying.huang@intel.com>
> Acked-by: Tim Chen <tim.c.chen@intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> 
> v5:
> 
> - Use a smarter way to determine whether sort is necessary.
> 
> v4:
> 
> - Avoid unnecessary sort if all entries are from one swap device.
> 
> v3:
> 
> - Add some comments in code per Rik's suggestion.
> 
> v2:
> 
> - Avoid sort swap entries if there is only one swap device.
> ---
>  mm/swapfile.c | 43 ++++++++++++++++++++++++++++++++++++++-----
>  1 file changed, 38 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 71890061f653..10e75f9e8ac1 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -37,6 +37,7 @@
>  #include <linux/swapfile.h>
>  #include <linux/export.h>
>  #include <linux/swap_slots.h>
> +#include <linux/sort.h>
>  
>  #include <asm/pgtable.h>
>  #include <asm/tlbflush.h>
> @@ -1065,20 +1066,52 @@ void swapcache_free(swp_entry_t entry)
>  	}
>  }
>  
> +static int swp_entry_cmp(const void *ent1, const void *ent2)
> +{
> +	const swp_entry_t *e1 = ent1, *e2 = ent2;
> +
> +	return (int)(swp_type(*e1) - swp_type(*e2));
> +}
> +
>  void swapcache_free_entries(swp_entry_t *entries, int n)
>  {
>  	struct swap_info_struct *p, *prev;
> -	int i;
> +	int i, m;
> +	swp_entry_t entry;
> +	unsigned int prev_swp_type;
>  
>  	if (n <= 0)
>  		return;
>  
>  	prev = NULL;
>  	p = NULL;
> -	for (i = 0; i < n; ++i) {
> -		p = swap_info_get_cont(entries[i], prev);
> -		if (p)
> -			swap_entry_free(p, entries[i]);
> +	m = 0;
> +	prev_swp_type = swp_type(entries[0]);
> +	for (i = 0; i < n; i++) {
> +		entry = entries[i];
> +		if (likely(swp_type(entry) == prev_swp_type)) {
> +			p = swap_info_get_cont(entry, prev);
> +			if (likely(p))
> +				swap_entry_free(p, entry);
> +			prev = p;
> +		} else if (!m)
> +			m = i;
> +	}
> +	if (p)
> +		spin_unlock(&p->lock);
> +	if (likely(!m))
> +		return;
> +
> +	/* Sort swap entries by swap device, so each lock is only taken once. */
> +	sort(entries + m, n - m, sizeof(entries[0]), swp_entry_cmp, NULL);
> +	prev = NULL;
> +	for (i = m; i < n; i++) {
> +		entry = entries[i];
> +		if (swp_type(entry) == prev_swp_type)
> +			continue;
> +		p = swap_info_get_cont(entry, prev);
> +		if (likely(p))
> +			swap_entry_free(p, entry);
>  		prev = p;
>  	}
>  	if (p)
> -- 
> 2.11.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
