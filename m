Subject: Re: [PATCH 4/7] PM cleanup: Drop nr_refs in remove_references()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0605010912140.15017@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
	 <20060429032306.4999.92029.sendpatchset@schroedinger.engr.sgi.com>
	 <1146499789.5216.20.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0605010912140.15017@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 01 May 2006 13:51:05 -0400
Message-Id: <1146505865.5216.57.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-05-01 at 09:15 -0700, Christoph Lameter wrote:
> On Mon, 1 May 2006, Lee Schermerhorn wrote:
> 
> > > Remove the early check for the number of references since we are
> > > checking page_mapcount() earlier. Ultimately only the refcount
> > > matters after the tree_lock has been obtained.
> > True for direct migration.  I'll still need to know whether we're in the
> > fault path for migrate-on-fault.  I don't think I can count on using the
> > mapcount as you now already remove the mapping before calling migrate_page(),
> > even for direct migration...
> 
> Well there is currently agreement that we wont include your patch because 
> it is not clear that the patch will be beneficial.

Ouch!  That's harsh!  Guess I missed that meeting... ;-) 

Seriously, of course, the onus is on me to show benefit.  And I hope to,
once the base migration code stabilizes...

> 
> And AFAIK your patch relies on only migrating pages with mapcount = 0. In 
> that case I think you can call the migration functions directly without 
> having to unmap. I thought this would actually be better for your case.

This only occurs if I find a cached, "misplaced" page in the fault path 
with mapcount==0.  But the fault path does add another ref on lookup,
so the refcounts are all one higher in this case.

> 
> > > -	if (!page_mapping(page) || page_count(page) != nr_refs ||
> > > +	if (!page_mapping(page) ||
> >                    ^^^^^^^^^^^^^^^^^
> > As part of patch 6/7, can you change this to just 'mapping'--i.e., the
> > added address_space argument?
> 
> No. The mapping may have been removed and this check is necessary to not 
> migrate a page that is already gone.

OK  I couldn't see how a page could be removed from its mapping while
we hold it locked.  I'll look closer...

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
