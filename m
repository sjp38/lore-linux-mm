Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 220C46B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 21:12:16 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id y7-v6so8192619plh.7
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 18:12:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k15si993257pgs.726.2018.04.09.18.12.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 18:12:15 -0700 (PDT)
Date: Mon, 9 Apr 2018 18:12:11 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180410011211.GA31282@bombadil.infradead.org>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
 <7706245c-2661-f28b-f7f9-8f11e1ae932b@huawei.com>
 <20180409144958.GA211679@rodete-laptop-imager.corp.google.com>
 <20180409152032.GB11756@bombadil.infradead.org>
 <20180409230409.GA214542@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409230409.GA214542@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Chao Yu <yuchao0@huawei.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Tue, Apr 10, 2018 at 08:04:09AM +0900, Minchan Kim wrote:
> On Mon, Apr 09, 2018 at 08:20:32AM -0700, Matthew Wilcox wrote:
> > I don't think this is something the radix tree should know about.
> 
> Because shadow entry implementation is hidden by radix tree implemetation.
> IOW, radix tree user cannot know how it works.

I have no idea what you mean.

> > SLAB should be checking for it (the patch I posted earlier in this
> 
> I don't think it's right approach. SLAB constructor can initialize
> some metadata for slab page populated as well as page zeroing.
> However, __GFP_ZERO means only clearing pages, not metadata.
> So it's different semantic. No need to mix out.

No, __GFP_ZERO is specified to clear the allocated memory whether
you're allocating from alloc_pages or from slab.  What makes no sense
is allocating an object from slab with a constructor *and* __GFP_ZERO.
They're in conflict, and slab can't fulfill both of those requirements.

> > thread), but the right place to filter this out is in the caller of
> > radix_tree_maybe_preload -- it's already filtering out HIGHMEM pages,
> > and should filter out GFP_ZERO too.
> 
> radix_tree_[maybe]_preload is exported API, which are error-prone
> for out of modules or upcoming customers.
> 
> More proper place is __radix_tree_preload.

I could not disagree with you more.  It is the responsibility of the
callers of radix_tree_preload to avoid calling it with nonsense flags
like __GFP_DMA, __GFP_HIGHMEM or __GFP_ZERO.
