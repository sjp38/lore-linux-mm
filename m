Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 338956B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 17:58:48 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id xb4so1695136pbc.15
        for <linux-mm@kvack.org>; Wed, 20 Mar 2013 14:58:47 -0700 (PDT)
Date: Wed, 20 Mar 2013 14:58:17 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 4/4 v3]swap: make cluster allocation per-cpu
In-Reply-To: <20130320135618.a476f40e4683cf20509b904d@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1303201437380.7431@eggly.anvils>
References: <20130221021858.GD32580@kernel.org> <alpine.LNX.2.00.1303191540220.5966@eggly.anvils> <20130320135618.a476f40e4683cf20509b904d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, linux-mm@kvack.org

On Wed, 20 Mar 2013, Andrew Morton wrote:
> On Tue, 19 Mar 2013 16:09:01 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> 
> > But I'm not all that keen on this one.  Partly because I suspect that
> > this per-cpu'ing won't in the end be the right approach
> 
> That was my reaction.  The CPU isn't the logical thing upon which to
> key the clustering.  It mostly-works, because of the way in which the
> kernel operates but it's a bit of a flukey hack.  A more logical thing
> around which to subdivide the clustering is the mm_struct.

You do suggest that from time to time, and someone did once send a patch
to organize it by vma.  That probably behaves very nicely under a simple
load, when pages coming off the bottom of the lru are from increasing
addresses of the same mm; but what we have already works well enough
for such a simple case (or should do: bugs can creep in and upset it).

Under a heavier mixed load, it behaved much worse than what we do
at present.  That was in swapping to hard disk, where the additional
seeks to place pages from different vmas in separate locations were
costly; SSDs don't have seek cost, but I'd expect their erase blocks
to impose an equivalent (not necessarily equal) cost.

One of the great attractions of SSD for swap is the absence of seek
cost when faulting back in; and even with hard disk, we don't know
whether or when pages will be faulted back in.  The better we can
allocate contiguously when swapping out, the faster swap will be.
I say we need to allocate disk location just in time before writing.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
