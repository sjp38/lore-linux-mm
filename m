Date: Fri, 10 Oct 2008 04:40:39 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 5/8] mm: write_cache_pages integrity fix
Message-ID: <20081010024039.GA13779@wotan.suse.de>
References: <20081009174822.621353840@suse.de> <1223556765.14090.2.camel@think.oraclecorp.com> <20081009132711.GB9941@wotan.suse.de> <1223559358.14090.11.camel@think.oraclecorp.com> <20081009135538.GC9941@wotan.suse.de> <1223561575.14090.14.camel@think.oraclecorp.com> <20081009142124.GD9941@wotan.suse.de> <1223563163.14090.18.camel@think.oraclecorp.com> <20081009145024.GF9941@wotan.suse.de> <1223565394.14090.34.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223565394.14090.34.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 09, 2008 at 11:16:34AM -0400, Chris Mason wrote:
> On Thu, 2008-10-09 at 16:50 +0200, Nick Piggin wrote:
> > 
> > The comment in WB_SYNC_NONE definition kind of suggests it meant don't
> > wait for anything when it was written...
> 
> That seems to have turned into wbc->nonblocking.  WB_SYNC_NONE doesn't
> stop other blocking inside the FS (delalloc and other fun).

Right, and neither does nonblocking in all cases ;)

Anyway, I completely agree that it is unclear at best and could really
use a spring clean of the fields and their semantics.


> > > At the write_cache_pages level, WB_SYNC_NONE should only change the
> > > waiting for IO in flight.
> > 
> > Aside from do_sync_mapping_range, what are other reasons to enforce
> > the same thing all up and down the writeout stack? If there are good
> > reasons, let's add WB_SYNC_WRITEBACK?
> 
> Your change to skip writeback pages that aren't dirty makes WB_SYNC_ALL
> almost the same as WB_SYNC_WRITEBACK.  With that in place we're pretty
> deep into grey areas where people may not want to go around rewriting
> pages that were dirtied after their sync began.

Yeah, they definitely do, though that's a slightly different problem. At
the moment, any dirty pages found in a data integrity operation *must* be
written out. Because we have no idea when they were dirtied. This is
how sync can get stuck behind write(2) for a long time (and this is why our
sync has traditionally bailed out after ->nrpages*2).

I have further patches to add a new tag to the radix-tree to mark all the
pages to sync up-front to solve this nicely. Mikulas has a different
approach to instead throttle the dirtiers. Whichever approach is favoured 
should be the next step after this round of patches.


> At least that's what I think the idea behind do_sync_mapping_range using
> WB_SYNC_NONE was.

do_sync_mapping_range indeed can ignore dirty,writeback pages, because its
data integrity operation would wait for writeback, then write dirty, then
wait for writeback again. This is quite a corner-case, for its unusual
semantics though. You may just as well not wait for writeback to start
with, but wait for them in the writeout pass (and only if they are dirty):
that will likely be as fast or faster anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
