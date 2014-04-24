Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6518F6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 16:04:08 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kx10so2291754pab.39
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 13:04:08 -0700 (PDT)
Received: from mail-pb0-x22a.google.com (mail-pb0-x22a.google.com [2607:f8b0:400e:c01::22a])
        by mx.google.com with ESMTPS id pb4si3282072pac.482.2014.04.24.13.04.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 13:04:07 -0700 (PDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so2328234pbc.15
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 13:04:07 -0700 (PDT)
Date: Thu, 24 Apr 2014 13:02:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Dirty/Access bits vs. page content
In-Reply-To: <CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1404241252520.3455@eggly.anvils>
References: <53558507.9050703@zytor.com> <CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com> <53559F48.8040808@intel.com> <CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com> <CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
 <20140422075459.GD11182@twins.programming.kicks-ass.net> <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com> <alpine.LSU.2.11.1404221847120.1759@eggly.anvils> <20140423184145.GH17824@quack.suse.cz> <CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com>
 <20140424065133.GX26782@laptop.programming.kicks-ass.net> <alpine.LSU.2.11.1404241110160.2443@eggly.anvils> <CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Thu, 24 Apr 2014, Linus Torvalds wrote:
> On Thu, Apr 24, 2014 at 11:40 AM, Hugh Dickins <hughd@google.com> wrote:
> > safely with page_mkclean(), as it stands at present anyway.
> >
> > I think that (in the exceptional case when a shared file pte_dirty has
> > been encountered, and this mm is active on other cpus) zap_pte_range()
> > needs to flush TLB on other cpus of this mm, just before its
> > pte_unmap_unlock(): then it respects the usual page_mkclean() protocol.
> >
> > Or has that already been rejected earlier in the thread,
> > as too costly for some common case?
> 
> Hmm. The problem is that right now we actually try very hard to batch
> as much as possible in order to avoid extra TLB flushes (we limit it
> to around 10k pages per batch, but that's still a *lot* of pages). The
> TLB flush IPI calls are noticeable under some loads.
> 
> And it's certainly much too much to free 10k pages under a spinlock.
> The latencies would be horrendous.

There is no need to free all the pages immediately after doing the
TLB flush: that's merely how it's structured at present; page freeing
can be left until the end as now, or when out from under the spinlock.

What's sadder, I think, is that we would have to flush TLB for each
page table spanned by the mapping (if other cpus are really active);
but that's still much better batching than what page_mkclean() itself
does (none).

> 
> We could add some special logic that only triggers for the dirty pages
> case, but it would still have to handle the case of "we batched up
> 9000 clean pages, and then we hit a dirty page", so it would get
> rather costly quickly.
> 
> Or we could have a separate array for dirty pages, and limit those to
> a much smaller number, and do just the dirty pages under the lock, and
> then the rest after releasing the lock. Again, a fair amount of new
> complexity.
> 
> I would almost prefer to have some special (per-mapping?) lock or
> something, and make page_mkclean() be serialize with the unmapping
> case.

Yes, that might be a possibility.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
