Date: Mon, 1 May 2006 09:15:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/7] PM cleanup: Drop nr_refs in remove_references()
In-Reply-To: <1146499789.5216.20.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0605010912140.15017@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
  <20060429032306.4999.92029.sendpatchset@schroedinger.engr.sgi.com>
 <1146499789.5216.20.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 May 2006, Lee Schermerhorn wrote:

> > Remove the early check for the number of references since we are
> > checking page_mapcount() earlier. Ultimately only the refcount
> > matters after the tree_lock has been obtained.
> True for direct migration.  I'll still need to know whether we're in the
> fault path for migrate-on-fault.  I don't think I can count on using the
> mapcount as you now already remove the mapping before calling migrate_page(),
> even for direct migration...

Well there is currently agreement that we wont include your patch because 
it is not clear that the patch will be beneficial.

And AFAIK your patch relies on only migrating pages with mapcount = 0. In 
that case I think you can call the migration functions directly without 
having to unmap. I thought this would actually be better for your case.

> > -	if (!page_mapping(page) || page_count(page) != nr_refs ||
> > +	if (!page_mapping(page) ||
>                    ^^^^^^^^^^^^^^^^^
> As part of patch 6/7, can you change this to just 'mapping'--i.e., the
> added address_space argument?

No. The mapping may have been removed and this check is necessary to not 
migrate a page that is already gone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
