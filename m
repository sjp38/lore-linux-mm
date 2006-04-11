Date: Tue, 11 Apr 2006 08:55:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page Migration: Make do_swap_page redo the fault
In-Reply-To: <1144767501.5160.12.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0604110842140.32343@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0604032228150.24182@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604081312200.14441@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604081058290.16914@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604082022170.12196@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604081430280.17911@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604090357350.5312@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604101933400.26478@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604101303350.24029@schroedinger.engr.sgi.com>
 <1144767501.5160.12.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Apr 2006, Lee Schermerhorn wrote:

> > Hmmm... The increased count is also an argument against having to check 
> > for the race in do_swap_page(). So maybe Lee's lazy migration patchset 
> > should also be fine without these checks and there is actually no need
> > to rely on the ptes not being the same.
> 
> May still be some work in do_swap_page().  The unmap has already
> occurred.  In the general case [support for migrating pages w/ > 1 pte
> mapping], two or more tasks could race faulting the cache pte.  IMO one
> should perform the migration [replacing old page in cache with new
> page], others should block and then use the new page to resolve their
> own faults.  I think this means a check and then at least another cache
> lookup.  Maybe redo the fault, as Christoph has said.
> 
> Don't know about direct migration.

In direct migration the reference counts avoid these problems. 

The worst case scenario that we have imagined so far assumed that 
migration occurs after do_swap_cache has done a lookup of the old page in 
the swap_cache. The check that we had in there was envisioned to protect 
against the case of migration happening after the lookup_swap_cache() 
occurred.

As Hugh noted: lookup_swap_cache() is increasing the page count under 
tree_lock. direct migration also checks page count under the tree lock.

So migration cannot occur after the lookup_swap_cache() has been done and 
returned the old page.

If lookup_swap_cache returns the new page then we will block on 
lock_page() until migration has finished.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
