Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 64AE36B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 19:08:22 -0500 (EST)
Received: by pdev10 with SMTP id v10so522700pde.7
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:08:22 -0800 (PST)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id e12si707297pat.196.2015.02.24.16.08.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 16:08:21 -0800 (PST)
Received: by pdno5 with SMTP id o5so514997pdn.8
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:08:20 -0800 (PST)
Date: Wed, 25 Feb 2015 09:08:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RFC 1/4] mm: throttle MADV_FREE
Message-ID: <20150225000809.GA6468@blaptop>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <20150224154318.GA14939@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150224154318.GA14939@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com

Hi Michal,

On Tue, Feb 24, 2015 at 04:43:18PM +0100, Michal Hocko wrote:
> On Tue 24-02-15 17:18:14, Minchan Kim wrote:
> > Recently, Shaohua reported that MADV_FREE is much slower than
> > MADV_DONTNEED in his MADV_FREE bomb test. The reason is many of
> > applications went to stall with direct reclaim since kswapd's
> > reclaim speed isn't fast than applications's allocation speed
> > so that it causes lots of stall and lock contention.
> 
> I am not sure I understand this correctly. So the issue is that there is
> huge number of MADV_FREE on the LRU and they are not close to the tail
> of the list so the reclaim has to do a lot of work before it starts
> dropping them?

No, Shaohua already tested deactivating of hinted pages to head/tail
of inactive anon LRU and he said it didn't solve his problem.
I thought main culprit was scanning/rotating/throttling in
direct reclaim path.

> 
> > This patch throttles MADV_FREEing so it works only if there
> > are enough pages in the system which will not trigger backgroud/
> > direct reclaim. Otherwise, MADV_FREE falls back to MADV_DONTNEED
> > because there is no point to delay freeing if we know system
> > is under memory pressure.
> 
> Hmm, this is still conforming to the documentation because the kernel is
> free to free pages at its convenience. I am not sure this is a good
> idea, though. Why some MADV_FREE calls should be treated differently?

It's hint for VM to free pages so I think it's okay to free them instantly
sometime if it can save more important thing like system stall.
IOW, madvise is just hint, not a strict rule.

> Wouldn't that lead to hard to predict behavior? E.g. LIFO reused blocks
> would work without long stalls most of the time - except when there is a
> memory pressure.

True.

> 
> Comparison to MADV_DONTNEED is not very fair IMHO because the scope of the
> two calls is different.

I agree it's not a apple to apple comparison.

Acutally, MADV_FREE moves the cost from hot path(ie, system call path)
to slow path(ie, reclaim context) so it would be slower if there are
much memory pressure continuously due to a lot overhead of freeing pages
in reclaim context. So, it would be good if kernel detects it nicely
and prevent the situation. This patch aims for that.

> 
> > When I test the patch on my 3G machine + 12 CPU + 8G swap,
> > test: 12 processes
> > 
> > loop = 5;
> > mmap(512M);
> 
> Who is eating the rest of the memory?

As I wrote down,  there are 12 processes with below test.
IOW, 512M * 12 = 6G but system RAM is just 3G.

> 
> > while (loop--) {
> > 	memset(512M);
> > 	madvise(MADV_FREE or MADV_DONTNEED);
> > }
> > 
> > 1) dontneed: 6.78user 234.09system 0:48.89elapsed
> > 2) madvfree: 6.03user 401.17system 1:30.67elapsed
> > 3) madvfree + this ptach: 5.68user 113.42system 0:36.52elapsed
> > 
> > It's clearly win.
> > 
> > Reported-by: Shaohua Li <shli@kernel.org>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> I don't know. This looks like a hack with hard to predict consequences
> which might trigger pathological corner cases.

Yeb, it might be. That's why I tagged RFC so hope other guys suggest
better idea.

> 
> > ---
> >  mm/madvise.c | 13 +++++++++++--
> >  1 file changed, 11 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 6d0fcb8921c2..81bb26ecf064 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -523,8 +523,17 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
> >  		 * XXX: In this implementation, MADV_FREE works like
> >  		 * MADV_DONTNEED on swapless system or full swap.
> >  		 */
> > -		if (get_nr_swap_pages() > 0)
> > -			return madvise_free(vma, prev, start, end);
> > +		if (get_nr_swap_pages() > 0) {
> > +			unsigned long threshold;
> > +			/*
> > +			 * If we have trobule with memory pressure(ie,
> > +			 * under high watermark), free pages instantly.
> > +			 */
> > +			threshold = min_free_kbytes >> (PAGE_SHIFT - 10);
> > +			threshold = threshold + (threshold >> 1);
> 
> Why threshold += threshold >> 1 ?

I wanted to trigger this logic if we have free pages under high watermark.

> 
> > +			if (nr_free_pages() > threshold)
> > +				return madvise_free(vma, prev, start, end);
> > +		}
> >  		/* passthrough */
> >  	case MADV_DONTNEED:
> >  		return madvise_dontneed(vma, prev, start, end);
> > -- 
> > 1.9.1
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
