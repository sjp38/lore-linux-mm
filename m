Subject: Re: [patch 5/8] mm: write_cache_pages integrity fix
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20081009132711.GB9941@wotan.suse.de>
References: <20081009155039.139856823@suse.de>
	 <20081009174822.621353840@suse.de>
	 <1223556765.14090.2.camel@think.oraclecorp.com>
	 <20081009132711.GB9941@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 09 Oct 2008 09:35:58 -0400
Message-Id: <1223559358.14090.11.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-10-09 at 15:27 +0200, Nick Piggin wrote:
> On Thu, Oct 09, 2008 at 08:52:45AM -0400, Chris Mason wrote:
> > On Fri, 2008-10-10 at 02:50 +1100, npiggin@suse.de wrote:
> > > plain text document attachment (mm-wcp-integrity-fix.patch)
> > > In write_cache_pages, nr_to_write is heeded even for data-integrity syncs, so
> > > the function will return success after writing out nr_to_write pages, even if
> > > that was not sufficient to guarantee data integrity.
> > > 
> > > The callers tend to set it to values that could break data interity semantics
> > > easily in practice. For example, nr_to_write can be set to mapping->nr_pages *
> > > 2, however if a file has a single, dirty page, then fsync is called, subsequent
> > > pages might be concurrently added and dirtied, then write_cache_pages might
> > > writeout two of these newly dirty pages, while not writing out the old page
> > > that should have been written out.
> > > 
> > > Fix this by ignoring nr_to_write if it is a data integrity sync.
> > > 
> > 
> > Thanks for working on these.
> 
> No problem. Actually I feel I would be negligent for knowingly shipping
> a kernel with these bugs :( So I don't have much choice...
> 
> 
> > We should have a wbc->integrity flag because WB_SYNC_NONE is somewhat
> > over used, and it is often used in data integrity syncs.
> > 
> > See fs/sync.c:do_sync_mapping_range()
> 
> Oh great, more data integrity bugs.
> 
> I've always disliked the sync_file_range API ;) it seems over complex and
> introduces the concept of writeout to userspace that seems questionable to
> me. I should add SYNC_FILE_RANGE_ASYNC and SYNC_FILE_RANGE_SYNC for people
> who already know POSIX and just want to convert existing fsync or msync to
> a file and range based API, and also get a proper async operation that
> isn't bound to kick off writeback for every page but could hand off page
> cleaning to another thread...
> 
> Anyway, quick fix says we have to change that WB_SYNC_NONE into WB_SYNC_ALL.
> WB_SYNC_NONE is all over the kernel. So do_sync_mapping_range is
> broken as-is. 
> 

I don't think do_sync_mapping_range is broken as is.  It simply splits
the operations into different parts.  The caller can request that we
wait for pending IO first.

WB_SYNC_NONE none just means don't wait for IO in flight, and there are
valid uses for it that will slow down if you switch them all to
WB_SYNC_ALL.

The problem is that we have a few flags and callers that mean almost but
not quite the same thing.  Some people confuse WB_SYNC_NONE with
wbc->nonblocking.

I'd leave WB_SYNC_NONE alone and set wbc->nr_to_write to the max int, or
just make a new flag that says write every dirty page in this range.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
