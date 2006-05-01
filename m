Date: Mon, 1 May 2006 11:04:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/7] PM cleanup: Drop nr_refs in remove_references()
In-Reply-To: <1146505865.5216.57.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0605011056420.15588@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
  <20060429032306.4999.92029.sendpatchset@schroedinger.engr.sgi.com>
 <1146499789.5216.20.camel@localhost.localdomain>
 <Pine.LNX.4.64.0605010912140.15017@schroedinger.engr.sgi.com>
 <1146505865.5216.57.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 May 2006, Lee Schermerhorn wrote:

> > And AFAIK your patch relies on only migrating pages with mapcount = 0. In 
> > that case I think you can call the migration functions directly without 
> > having to unmap. I thought this would actually be better for your case.
> 
> This only occurs if I find a cached, "misplaced" page in the fault path 
> with mapcount==0.  But the fault path does add another ref on lookup,
> so the refcounts are all one higher in this case.

I send you a set of patches that split migrate_pages(). Maybe that is what 
you are looking for?

You only need one additional refcount to hold the page. This is the same 
as in the case of migrate_pages(). Where does the second refcount come from?

> > No. The mapping may have been removed and this check is necessary to not 
> > migrate a page that is already gone.
> 
> OK  I couldn't see how a page could be removed from its mapping while
> we hold it locked.  I'll look closer...

zap_pte_range() can remove a mapcount without obtaining a lock. Hmmm... 
Seems to do nothing with the mapping though. Removal of anonymous mappings 
are deferred until we reach free_page() so that does not apply. Check the 
file I/O functions.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
