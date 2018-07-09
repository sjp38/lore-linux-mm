Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C68F16B02AA
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 04:49:49 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x23-v6so9646771pln.11
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 01:49:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a15-v6sor596586pgh.229.2018.07.09.01.49.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 01:49:48 -0700 (PDT)
Date: Mon, 9 Jul 2018 18:49:37 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 0/2] mm/fs: put_user_page() proposal
Message-ID: <20180709184937.7a70c3aa@roar.ozlabs.ibm.com>
In-Reply-To: <20180709080554.21931-1-jhubbard@nvidia.com>
References: <20180709080554.21931-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Mon,  9 Jul 2018 01:05:52 -0700
john.hubbard@gmail.com wrote:

> From: John Hubbard <jhubbard@nvidia.com>
> 
> Hi,
> 
> With respect to tracking get_user_pages*() pages with page->dma_pinned*
> fields [1], I spent a few days retrofitting most of the get_user_pages*()
> call sites, by adding calls to a new put_user_page() function, in place
> of put_page(), where appropriate. This will work, but it's a large effort.
> 
> Design note: I didn't see anything that hinted at a way to fix this
> problem, without actually changing all of the get_user_pages*() call sites,
> so I think it's reasonable to start with that.
> 
> Anyway, it's still incomplete, but because this is a large, tree-wide
> change (that will take some time and testing), I'd like to propose a plan,
> before spamming zillions of people with put_user_page() conversion patches.
> So I picked out the first two patches to show where this is going.
> 
> Proposed steps:
> 
> Step 1:
> 
> Start with the patches here, then continue with...dozens more.
> This will eventually convert all of the call sites to use put_user_page().
> This is easy in some places, but complex in others, such as:
> 
>     -- drivers/gpu/drm/amd
>     -- bio
>     -- fuse
>     -- cifs
>     -- anything from:
>            git grep  iov_iter_get_pages | cut -f1 -d ':' | sort | uniq
> 
> The easy ones can be grouped into a single patchset, perhaps, and the
> complex ones probably each need a patchset, in order to get the in-depth
> review they'll need.
> 
> Furthermore, some of these areas I hope to attract some help on, once
> this starts going.
> 
> Step 2:
> 
> In parallel, tidy up the core patchset that was discussed in [1], (version
> 2 has already been reviewed, so I know what to do), and get it perfected
> and reviewed. Don't apply it until step 1 is all done, though.
> 
> Step 3:
> 
> Activate refcounting of dma-pinned pages (essentially, patch #5, which is
> [1]), but don't use it yet. Place a few WARN_ON_ONCE calls to start
> mopping up any missed call sites.
> 
> Step 4:
> 
> After some soak time, actually connect it up (patch #6 of [1]) and start
> taking action based on the new page->dma_pinned* fields.

You can use my decade old patch!

https://lkml.org/lkml/2009/2/17/113

The problem with blocking in clear_page_dirty_for_io is that the fs is
holding the page lock (or locks) and possibly others too. If you
expect to have a bunch of long term references hanging around on the
page, then there will be hangs and deadlocks everywhere. And if you do
not have such log term references, then page lock (or some similar lock
bit) for the duration of the DMA should be about enough?

I think it has to be more fundamental to the filesystem. Filesystem
would get callbacks to register such long term dirtying on its files.
Then it can do locking, resource allocation, -ENOTSUPP, etc.

Thanks,
Nick
