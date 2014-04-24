Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 934716B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 02:51:52 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id j5so2050153qga.25
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 23:51:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id u89si1753278qga.83.2014.04.23.23.51.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Apr 2014 23:51:51 -0700 (PDT)
Date: Thu, 24 Apr 2014 08:51:33 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Dirty/Access bits vs. page content
Message-ID: <20140424065133.GX26782@laptop.programming.kicks-ass.net>
References: <53558507.9050703@zytor.com>
 <CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>
 <53559F48.8040808@intel.com>
 <CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>
 <CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
 <20140422075459.GD11182@twins.programming.kicks-ass.net>
 <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
 <alpine.LSU.2.11.1404221847120.1759@eggly.anvils>
 <20140423184145.GH17824@quack.suse.cz>
 <CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Wed, Apr 23, 2014 at 12:33:15PM -0700, Linus Torvalds wrote:
> On Wed, Apr 23, 2014 at 11:41 AM, Jan Kara <jack@suse.cz> wrote:
> >
> > Now I'm not sure how to fix Linus' patches. For all I care we could just
> > rip out pte dirty bit handling for file mappings. However last time I
> > suggested this you corrected me that tmpfs & ramfs need this. I assume this
> > is still the case - however, given we unconditionally mark the page dirty
> > for write faults, where exactly do we need this?
> 
> Honza, you're missing the important part: it does not matter one whit
> that we unconditionally mark the page dirty, when we do it *early*,
> and it can be then be marked clean before it's actually clean!
> 
> The problem is that page cleaning can clean the page when there are
> still writers dirtying the page. Page table tear-down removes the
> entry from the page tables, but it's still there in the TLB on other
> CPU's. 

> So other CPU's are possibly writing to the page, when
> clear_page_dirty_for_io() has marked it clean (because it didn't see
> the page table entries that got torn down, and it hasn't seen the
> dirty bit in the page yet).

So page_mkclean() does an rmap walk to mark the page RO, it does mm wide
TLB invalidations while doing so.

zap_pte_range() only removes the rmap entry after it does the
ptep_get_and_clear_full(), which doesn't do any TLB invalidates.

So as Linus says the page_mkclean() can actually miss a page, because
it's already removed from rmap() but due to zap_pte_range() can still
have active TLB entries.

So in order to fix this we'd have to delay the page_remove_rmap() as
well, but that's tricky because rmap walkers cannot deal with
in-progress teardown. Will need to think on this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
