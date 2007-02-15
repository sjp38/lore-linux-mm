Date: Wed, 14 Feb 2007 21:39:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/7] Logic to move mlocked pages
Message-Id: <20070214213925.13b1111a.akpm@linux-foundation.org>
In-Reply-To: <20070215012510.5343.52706.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
	<20070215012510.5343.52706.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Feb 2007 17:25:10 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:

> Add logic to lazily remove/add mlocked pages from LRU
> 
> This is the core of the patchset. It adds the necessary logic to
> remove mlocked pages from the LRU and put them back later. The basic idea
> by Andrew Morton and others has been around for awhile.
> 
> During reclaim we attempt to unmap pages. In order to do so we have
> to scan all vmas that a page belongs to to check for VM_LOCKED.
> 
> If we find that VM_LOCKED is set for a page then we remove the page from
> the LRU and mark it with SetMlocked. We must mark the page with a special
> flag bit. Without PageMLocked we have later no way to distinguish pages that
> are off the LRU because of mlock from pages that are off the LRU for other
> reasons. We should only feed back mlocked pages to the LRU and not the pages
> that were removed for other reasons.

There are various proposals and patches floating about to similarly leave
anonyous pages off the LRU if there's no swap available: CONFIG_SWAP=n, no
swapfiles online or even no-swapspace-left.  Handling this is probably more
useful to more people than handling the munlock case, frankly.

I think that modifying this code to also provide that function is pretty
darn simple, and that this code should perhaps be designed with that
extension in mind.

In which case it might be better to rename at least the user-visible
meminfo fields (so we don't have to change them later) and perhaps things
like PG_mlocked and NR_MLOCKED.  To PG_nonlru and NR_NONLRU, perhaps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
