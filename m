Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70AE96B0311
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 12:48:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 194so30154337pfv.11
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 09:48:04 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s89si3220633pfi.317.2017.04.27.09.48.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 09:48:03 -0700 (PDT)
Message-ID: <1493311682.3209.150.camel@linux.intel.com>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Thu, 27 Apr 2017 09:48:02 -0700
In-Reply-To: <87efwe3as0.fsf@yhuang-dev.intel.com>
References: <20170407064901.25398-1-ying.huang@intel.com>
	 <20170418045909.GA11015@bbox> <87y3uwrez0.fsf@yhuang-dev.intel.com>
	 <20170420063834.GB3720@bbox> <874lxjim7m.fsf@yhuang-dev.intel.com>
	 <87tw5idjv9.fsf@yhuang-dev.intel.com> <20170424045213.GA11287@bbox>
	 <87y3un2vdp.fsf@yhuang-dev.intel.com>
	 <1493237623.3209.142.camel@linux.intel.com>
	 <87efwe3as0.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

On Thu, 2017-04-27 at 09:21 +0800, Huang, Ying wrote:
> Tim Chen <tim.c.chen@linux.intel.com> writes:
> 
> > 
> > > 
> > > 
> > > From 7bd903c42749c448ef6acbbdee8dcbc1c5b498b9 Mon Sep 17 00:00:00 2001
> > > From: Huang Ying <ying.huang@intel.com>
> > > Date: Thu, 23 Feb 2017 13:05:20 +0800
> > > Subject: [PATCH -v5] mm, swap: Sort swap entries before free
> > > 
> > > A 
> > > ---
> > > A mm/swapfile.c | 43 ++++++++++++++++++++++++++++++++++++++-----
> > > A 1 file changed, 38 insertions(+), 5 deletions(-)
> > > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > > index 71890061f653..10e75f9e8ac1 100644
> > > --- a/mm/swapfile.c
> > > +++ b/mm/swapfile.c
> > > @@ -37,6 +37,7 @@
> > > A #include <linux/swapfile.h>
> > > A #include <linux/export.h>
> > > A #include <linux/swap_slots.h>
> > > +#include <linux/sort.h>
> > > A 
> > > A #include <asm/pgtable.h>
> > > A #include <asm/tlbflush.h>
> > > @@ -1065,20 +1066,52 @@ void swapcache_free(swp_entry_t entry)
> > > A 	}
> > > A }
> > > A 
> > > +static int swp_entry_cmp(const void *ent1, const void *ent2)
> > > +{
> > > +	const swp_entry_t *e1 = ent1, *e2 = ent2;
> > > +
> > > +	return (int)(swp_type(*e1) - swp_type(*e2));
> > > +}
> > > +
> > > A void swapcache_free_entries(swp_entry_t *entries, int n)
> > > A {
> > > A 	struct swap_info_struct *p, *prev;
> > > -	int i;
> > > +	int i, m;
> > > +	swp_entry_t entry;
> > > +	unsigned int prev_swp_type;
> > I think it will be clearer to name prev_swp_type as first_swp_type
> > as this is the swp type of the first entry.
> Yes.A A That is better!A A Will do that.
> 
> > 
> > > 
> > > A 
> > > A 	if (n <= 0)
> > > A 		return;
> > > A 
> > > A 	prev = NULL;
> > > A 	p = NULL;
> > > -	for (i = 0; i < n; ++i) {
> > > -		p = swap_info_get_cont(entries[i], prev);
> > > -		if (p)
> > > -			swap_entry_free(p, entries[i]);
> > > +	m = 0;
> > > +	prev_swp_type = swp_type(entries[0]);
> > > +	for (i = 0; i < n; i++) {
> > > +		entry = entries[i];
> > > +		if (likely(swp_type(entry) == prev_swp_type)) {
> > > +			p = swap_info_get_cont(entry, prev);
> > > +			if (likely(p))
> > > +				swap_entry_free(p, entry);
> > > +			prev = p;
> > > +		} else if (!m)
> > > +			m = i;
> > > +	}
> > > +	if (p)
> > > +		spin_unlock(&p->lock);
> > > +	if (likely(!m))
> > > +		return;
> > > +
> > We could still have prev_swp_type at the first entry after sorting.
> > and we can avoid an unlock/relock for this case if we do this:
> > 
> > 	if (likely(!m)) {
> > 		if (p)
> > 			spin_unlock(&p->lock);
> > 		return;
> > 	}
> > 		
> > > 
> > > +	/* Sort swap entries by swap device, so each lock is only taken once. */
> > > +	sort(entries + m, n - m, sizeof(entries[0]), swp_entry_cmp, NULL);
> > > +	prev = NULL;
> > Can eliminate prev=NULL if we adopt the above change.
> > 
> > > 
> > > +	for (i = m; i < n; i++) {
> > > +		entry = entries[i];
> > > +		if (swp_type(entry) == prev_swp_type)
> > > +			continue;
> > The if/continue statement seems incorrect. When swp_type(entry) == prev_swp_type
> > we also need to free entry. A The if/continue statement should be deleted.
> > 
> > Say we have 3 entries with swp_type
> > 1,2,1
> > 
> > We will get prev_swp_type as 1 and free the first entry
> > and sort the remaining two. A The last entry with
> > swp_type 1 will not be freed.
> The first loop in the function will scan all elements of the array, so
> the first and third entry will be freed in the first loop.A A Then the the
> second and the third entry will be sorted.A A But all entries with the
> same swap type (device) of the first entry needn't to be freed again.
> The key point is that we will scan all elements of the array in the
> first loop, record the first entry that has different swap type
> (device).

I was under the wrong impression that the code break from the first
loop when it finds a different swp type. A Yes, we should skip the
free in the second loop if the first loop scan the whole list.

Thanks.

Tim

> 
> Best Regards,
> Huang, Ying
> 
> > 
> > > 
> > > +		p = swap_info_get_cont(entry, prev);
> > > +		if (likely(p))
> > > +			swap_entry_free(p, entry);
> > > A 		prev = p;
> > > A 	}
> > > A 	if (p)
> > Thanks.
> > 
> > Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
