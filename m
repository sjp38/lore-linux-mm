Subject: Re: [PATCH 4/7] PM cleanup: Drop nr_refs in remove_references()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0605011056420.15588@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
	 <20060429032306.4999.92029.sendpatchset@schroedinger.engr.sgi.com>
	 <1146499789.5216.20.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0605010912140.15017@schroedinger.engr.sgi.com>
	 <1146505865.5216.57.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0605011056420.15588@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 01 May 2006 14:34:27 -0400
Message-Id: <1146508468.5216.88.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-05-01 at 11:04 -0700, Christoph Lameter wrote:
> On Mon, 1 May 2006, Lee Schermerhorn wrote:
> 
> > > And AFAIK your patch relies on only migrating pages with mapcount = 0. In 
> > > that case I think you can call the migration functions directly without 
> > > having to unmap. I thought this would actually be better for your case.
> > 
> > This only occurs if I find a cached, "misplaced" page in the fault path 
> > with mapcount==0.  But the fault path does add another ref on lookup,
> > so the refcounts are all one higher in this case.
> 
> I send you a set of patches that split migrate_pages(). Maybe that is what 
> you are looking for?
> 
> You only need one additional refcount to hold the page. This is the same 
> as in the case of migrate_pages(). Where does the second refcount come from?

One from the cache [where I find the page on fault], one from
find_get_page().
Plus 1 from page_private(page) buf refs, if any.  Also, to match the
page
state for direct migration, I isolate the page from the lru so it can't
be found, except through the cache, while I'm migrating it; and that
adds
yet another ref.  Net is 1 extra ref in the fault path.

> 
> > > No. The mapping may have been removed and this check is necessary to not 
> > > migrate a page that is already gone.
> > 
> > OK  I couldn't see how a page could be removed from its mapping while
> > we hold it locked.  I'll look closer...
> 
> zap_pte_range() can remove a mapcount without obtaining a lock. Hmmm... 
> Seems to do nothing with the mapping though. Removal of anonymous mappings 
> are deferred until we reach free_page() so that does not apply. Check the 
> file I/O functions.

I did.  Looked like page->mapping only gets NULLed out in 
[__]remove_from_page_cache().  I backtracked all of the
refs I could find, and all seemed to hold page lock.  But, again,
I could have missed some [cscope can lie, as can my eyes].

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
