Date: Mon, 1 May 2006 11:53:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/7] PM cleanup: Drop nr_refs in remove_references()
In-Reply-To: <1146508468.5216.88.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0605011150490.16261@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
  <20060429032306.4999.92029.sendpatchset@schroedinger.engr.sgi.com>
 <1146499789.5216.20.camel@localhost.localdomain>
 <Pine.LNX.4.64.0605010912140.15017@schroedinger.engr.sgi.com>
 <1146505865.5216.57.camel@localhost.localdomain>
 <Pine.LNX.4.64.0605011056420.15588@schroedinger.engr.sgi.com>
 <1146508468.5216.88.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 May 2006, Lee Schermerhorn wrote:

> > You only need one additional refcount to hold the page. This is the same 
> > as in the case of migrate_pages(). Where does the second refcount come from?
> 
> One from the cache [where I find the page on fault], one from
> find_get_page().

The function alrady considers the reference from mapping. The 
find_get_page() ref is basically the same that isolate_lru_page() takes.

> Plus 1 from page_private(page) buf refs, if any.  Also, to match the

That is also considered in the function.

> page
> state for direct migration, I isolate the page from the lru so it can't
> be found, except through the cache, while I'm migrating it; and that
> adds
> yet another ref.  Net is 1 extra ref in the fault path.

Since you already have a ref from find_get_page() I would not think that 
you would not need an additional one from isolate_lru_page().

> > zap_pte_range() can remove a mapcount without obtaining a lock. Hmmm... 
> > Seems to do nothing with the mapping though. Removal of anonymous mappings 
> > are deferred until we reach free_page() so that does not apply. Check the 
> > file I/O functions.
> 
> I did.  Looked like page->mapping only gets NULLed out in 
> [__]remove_from_page_cache().  I backtracked all of the
> refs I could find, and all seemed to hold page lock.  But, again,
> I could have missed some [cscope can lie, as can my eyes].

If there is none then we can completely remove that check. We already 
check for the mapping to be non null earlier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
