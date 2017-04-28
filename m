Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B5D486B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 04:05:29 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p21so10579527pgc.21
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 01:05:29 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t9si5508787pge.239.2017.04.28.01.05.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 01:05:28 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
References: <20170407064901.25398-1-ying.huang@intel.com>
	<20170418045909.GA11015@bbox> <87y3uwrez0.fsf@yhuang-dev.intel.com>
	<20170420063834.GB3720@bbox> <874lxjim7m.fsf@yhuang-dev.intel.com>
	<87tw5idjv9.fsf@yhuang-dev.intel.com> <20170424045213.GA11287@bbox>
	<87y3un2vdp.fsf@yhuang-dev.intel.com> <20170427043545.GA1726@bbox>
	<87r30dz6am.fsf@yhuang-dev.intel.com> <20170428074257.GA19510@bbox>
Date: Fri, 28 Apr 2017 16:05:26 +0800
In-Reply-To: <20170428074257.GA19510@bbox> (Minchan Kim's message of "Fri, 28
	Apr 2017 16:42:57 +0900")
Message-ID: <871ssdvtx5.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

Minchan Kim <minchan@kernel.org> writes:

> On Fri, Apr 28, 2017 at 09:09:53AM +0800, Huang, Ying wrote:
>> Minchan Kim <minchan@kernel.org> writes:
>> 
>> > On Wed, Apr 26, 2017 at 08:42:10PM +0800, Huang, Ying wrote:
>> >> Minchan Kim <minchan@kernel.org> writes:
>> >> 
>> >> > On Fri, Apr 21, 2017 at 08:29:30PM +0800, Huang, Ying wrote:
>> >> >> "Huang, Ying" <ying.huang@intel.com> writes:
>> >> >> 
>> >> >> > Minchan Kim <minchan@kernel.org> writes:
>> >> >> >
>> >> >> >> On Wed, Apr 19, 2017 at 04:14:43PM +0800, Huang, Ying wrote:
>> >> >> >>> Minchan Kim <minchan@kernel.org> writes:
>> >> >> >>> 
>> >> >> >>> > Hi Huang,
>> >> >> >>> >
>> >> >> >>> > On Fri, Apr 07, 2017 at 02:49:01PM +0800, Huang, Ying wrote:
>> >> >> >>> >> From: Huang Ying <ying.huang@intel.com>
>> >> >> >>> >> 
>> >> >> >>> >>  void swapcache_free_entries(swp_entry_t *entries, int n)
>> >> >> >>> >>  {
>> >> >> >>> >>  	struct swap_info_struct *p, *prev;
>> >> >> >>> >> @@ -1075,6 +1083,10 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
>> >> >> >>> >>  
>> >> >> >>> >>  	prev = NULL;
>> >> >> >>> >>  	p = NULL;
>> >> >> >>> >> +
>> >> >> >>> >> +	/* Sort swap entries by swap device, so each lock is only taken once. */
>> >> >> >>> >> +	if (nr_swapfiles > 1)
>> >> >> >>> >> +		sort(entries, n, sizeof(entries[0]), swp_entry_cmp, NULL);
>> >> >> >>> >
>> >> >> >>> > Let's think on other cases.
>> >> >> >>> >
>> >> >> >>> > There are two swaps and they are configured by priority so a swap's usage
>> >> >> >>> > would be zero unless other swap used up. In case of that, this sorting
>> >> >> >>> > is pointless.
>> >> >> >>> >
>> >> >> >>> > As well, nr_swapfiles is never decreased so if we enable multiple
>> >> >> >>> > swaps and then disable until a swap is remained, this sorting is
>> >> >> >>> > pointelss, too.
>> >> >> >>> >
>> >> >> >>> > How about lazy sorting approach? IOW, if we found prev != p and,
>> >> >> >>> > then we can sort it.
>> >> >> >>> 
>> >> >> >>> Yes.  That should be better.  I just don't know whether the added
>> >> >> >>> complexity is necessary, given the array is short and sort is fast.
>> >> >> >>
>> >> >> >> Huh?
>> >> >> >>
>> >> >> >> 1. swapon /dev/XXX1
>> >> >> >> 2. swapon /dev/XXX2
>> >> >> >> 3. swapoff /dev/XXX2
>> >> >> >> 4. use only one swap
>> >> >> >> 5. then, always pointless sort.
>> >> >> >
>> >> >> > Yes.  In this situation we will do unnecessary sorting.  What I don't
>> >> >> > know is whether the unnecessary sorting will hurt performance in real
>> >> >> > life.  I can do some measurement.
>> >> >> 
>> >> >> I tested the patch with 1 swap device and 1 process to eat memory
>> >> >> (remove the "if (nr_swapfiles > 1)" for test).  I think this is the
>> >> >> worse case because there is no lock contention.  The memory freeing time
>> >> >> increased from 1.94s to 2.12s (increase ~9.2%).  So there is some
>> >> >> overhead for some cases.  I change the algorithm to something like
>> >> >> below,
>> >> >> 
>> >> >>  void swapcache_free_entries(swp_entry_t *entries, int n)
>> >> >>  {
>> >> >>  	struct swap_info_struct *p, *prev;
>> >> >>  	int i;
>> >> >> +	swp_entry_t entry;
>> >> >> +	unsigned int prev_swp_type;
>> >> >>  
>> >> >>  	if (n <= 0)
>> >> >>  		return;
>> >> >>  
>> >> >> +	prev_swp_type = swp_type(entries[0]);
>> >> >> +	for (i = n - 1; i > 0; i--) {
>> >> >> +		if (swp_type(entries[i]) != prev_swp_type)
>> >> >> +			break;
>> >> >> +	}
>> >> >
>> >> > That's really what I want to avoid. For many swap usecases,
>> >> > it adds unnecessary overhead.
>> >> >
>> >> >> +
>> >> >> +	/* Sort swap entries by swap device, so each lock is only taken once. */
>> >> >> +	if (i)
>> >> >> +		sort(entries, n, sizeof(entries[0]), swp_entry_cmp, NULL);
>> >> >>  	prev = NULL;
>> >> >>  	p = NULL;
>> >> >>  	for (i = 0; i < n; ++i) {
>> >> >> -		p = swap_info_get_cont(entries[i], prev);
>> >> >> +		entry = entries[i];
>> >> >> +		p = swap_info_get_cont(entry, prev);
>> >> >>  		if (p)
>> >> >> -			swap_entry_free(p, entries[i]);
>> >> >> +			swap_entry_free(p, entry);
>> >> >>  		prev = p;
>> >> >>  	}
>> >> >>  	if (p)
>> >> >> 
>> >> >> With this patch, the memory freeing time increased from 1.94s to 1.97s.
>> >> >> I think this is good enough.  Do you think so?
>> >> >
>> >> > What I mean is as follows(I didn't test it at all):
>> >> >
>> >> > With this, sort entries if we found multiple entries in current
>> >> > entries. It adds some condition checks for non-multiple swap
>> >> > usecase but it would be more cheaper than the sorting.
>> >> > And it adds a [un]lock overhead for multiple swap usecase but
>> >> > it should be a compromise for single-swap usecase which is more
>> >> > popular.
>> >> >
>> >> 
>> >> How about the following solution?  It can avoid [un]lock overhead and
>> >> double lock issue for multiple swap user case and has good performance
>> >> for one swap user case too.
>> >
>> > How worse with approach I suggested compared to as-is?
>> 
>> The performance difference between your version and my version is small
>> for my testing.
>
> If so, why should we add code to optimize further?
>
>> 
>> > Unless it's too bad, let's not add more complicated thing to just
>> > enhance the minor usecase in such even *slow* path.
>> > It adds code size/maintainance overead.
>> > With your suggestion, it might enhance a bit with speicific benchmark
>> > but not sure it's really worth for real practice.
>> 
>> I don't think the code complexity has much difference between our latest
>> versions.  As for complexity, I think my original version which just
>
> What I suggested is to avoid pointless overhead for *major* usecase
> and the code you are adding now is to optimize further for *minor*
> usecase. And now I dobut the code you are adding is really worth
> unless it makes a meaningful output.
> If it doesn't, it adds just overhead(code size, maintainance, power and
> performance). You might argue it's really *small* so it would be okay
> but think about that you would be not only one in the community so
> kernel bloats day by day with code to handle corner cases.
>
>> uses nr_swapfiles to avoid sort() for single swap device is simple and
>> good enough for this task.  Maybe we can just improve the correctness of
>
> But it hurts *major* usecase.
>
>> swap device counting as Tim suggested.
>
> I don't know what Tim suggested. Anyway, my point is that minor
> usecase doesn't hurt major usecase and justify the benefit
> if you want to put more. So I'm okay with either solution to
> meet it.

Tim suggested to add a mechanism to correctly track how many swap
devices are in use in swapon/swapoff.  So we only sort if the number of
the swap device > 1.  This will not cover multiple swap devices with
different priorities, but will cover the major usecases.  The code
should be simpler.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
