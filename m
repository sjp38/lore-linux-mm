Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED626B0450
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 18:30:19 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y71so363061045pgd.0
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 15:30:19 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u135si19447002pgc.153.2016.11.20.15.30.17
        for <linux-mm@kvack.org>;
        Sun, 20 Nov 2016 15:30:18 -0800 (PST)
Date: Mon, 21 Nov 2016 08:30:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2] mm: support anonymous stable page
Message-ID: <20161120233015.GA14113@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Darrick J . Wong" <darrick.wong@oracle.com>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Nov 18, 2016 at 01:26:59PM -0800, Hugh Dickins wrote:
> On Fri, 18 Nov 2016, Minchan Kim wrote:
> > On Thu, Nov 17, 2016 at 08:35:10PM -0800, Hugh Dickins wrote:
> > > 
> > > Maybe add SWP_STABLE_WRITES in include/linux/swap.h, and set that
> > > in swap_info->flags according to bdi_cap_stable_pages_required(),
> > > leaving mapping->host itself NULL as before?
> > 
> > The problem with the approach is that we need to get swap_info_struct
> > in reuse_swap_page so maybe, every caller should pass swp_entry_t
> > into reuse_swap_page. It would be no problem if swap slot is really
> > referenced the page(IOW, pte is real swp_entry_t) but some cases
> > where swap slot is already empty but the page remains in only
> > swap cache, we cannot pass swp_entry_t which means that we cannot
> > get swap_info_struct.
> 
> I don't see the problem: if the page is PageSwapCache (and page
> lock is held), then the swp_entry_t is there in page->private:
> see page_swapcount(), which reuse_swap_page() just called.

Right you are!!

> 
> > 
> > So, if I didn't miss, another option I can imagine is to move
> > SWP_STABLE_WRITES to address_space->flags as AS_STABLE_WRITES.
> > With that, we can always get the information without passing
> > swp_entry_t. Is there any better idea?
> 
> I think what you suggest below would work fine (and be quicker
> than looking up the swap_info again): but is horribly misleading
> for anyone else interested in stable writes, for whom the info is
> kept in the bdi, and not in this new mapping flag.
> 
> So I'd much prefer that you keep the swap special case inside the
> world of swap, with a SWP_STABLE_WRITES flag.  Maybe unfold
> page_swapcount() inside reuse_swap_page(), so that it only
> needs a single lookup (or perhaps I'm optimizing prematurely).
> 

I toally agree.
Here is new one.
