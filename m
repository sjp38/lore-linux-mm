Date: Sat, 5 Apr 2003 04:44:14 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030405024414.GP16293@dualathlon.random>
References: <20030404163154.77f19d9e.akpm@digeo.com> <12880000.1049508832@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <12880000.1049508832@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 04, 2003 at 06:13:52PM -0800, Martin J. Bligh wrote:
> > Perhaps it is useful to itemise the prblems which we're trying to solve here:
> > 
> > - ZONE_NORMAL consumption by pte_chains
> > 
> >   Solved by objrmap and presumably page clustering.
> > 
> > - ZONE_NORMAL consumption by VMAs
> > 
> >   Solved by remap_file_pages.  Neither objrmap nor page clustering will
> >   help here.
> 
> I'm not convinced that we can't do something with nonlinear mappings for
> this ... we just need to keep a list of linear areas within the nonlinear
> vmas, and use that to do the objrmap stuff with. Dave and I talked about
> this yesterday ... we both had different terminology, but I think the
> same underlying fundamental concept ... I was calling them "sub-vmas"
> for each linear region within the nonlinear space. 

that's wasted memory IMHO, if you need nonlinear, you don't want to
waste further metadata, you only want to pin pages in the pagetables,
the 'window' over the pagecache (incidentally shm)

the vm shouldn't know about it.

> The fundamental problem I came to (and I think Dave had the same problem) 
> is that I couldn't see what problem remap_file_pages was trying to solve,

Oh that's clear, it's only the avoidance of the mmap calls that walks
the rbtree with many vmas allocated. Which is another reason for not
having any kind of metadata associated with the pages attached to the
nonlinear vma. Taking a linearity inside the non-linearity sounds
not worthwhile.

remap_file_pages isn't a regular API, it's a 32bit hack to mangle
pagetables and attach pages into it hard due the lack of address space
that avoids you to map the whole file at once.

Should pin stuff into ram and be enabled by a sysctl, and to be not used
on 64bit archs that can map all at once in a cleaner way that also
allows efficient swapping etc...

> so it was tricky to see if we'd cause the same thing or not. sub-vmas
> could certainly be a lot smaller, but we weren't thinking of 128K of the
> damned things, so ... the other thing is of course the setup and teardown
> time ... but the could be a btree or something for the structure.
> 
> Of course, if we did this, it would get rid of the whole conversion
> to and from object based stuff ;-) I think Dave had some other bright
> idea on this too, but I don't recall what it was ;-(
> 
> > - pte_chain setup and teardown CPU cost.
> > 
> >   objrmap does not seem to help.  Page clustering might, but is unlikely to
> >   be enabled on the machines which actually care about the overhead.
> 
> eh? Not sure what you mean by that. It helped massively ...
> diffprofile from kernbench showed:

Indeed. objrmap is the only way to avoid the big rmap waste. Infact I'm
not even convinced about the hybrid approch, rmap should be avoided even
for the anon pages. And the swap cpu doesn't matter, as far as we can
reach pagteables in linear time that's fine, doesn't matter how many
fixed cycles it takes. Only the complexity factor matters, and objrmap
takes care of it just fine.

> 
>      -4666   -74.9% page_add_rmap
>     -10666   -92.0% page_remove_rmap
> 
> I'd say that about an 85% reduction in cost is pretty damned fine ;-)
> And that was about a 20% overall reduction in the system time for the
> test too ... that was all for partial objrmap (file backed, not anon).
> 
> M.


Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
