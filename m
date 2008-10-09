Subject: Re: [patch 5/8] mm: write_cache_pages integrity fix
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20081009145024.GF9941@wotan.suse.de>
References: <20081009155039.139856823@suse.de>
	 <20081009174822.621353840@suse.de>
	 <1223556765.14090.2.camel@think.oraclecorp.com>
	 <20081009132711.GB9941@wotan.suse.de>
	 <1223559358.14090.11.camel@think.oraclecorp.com>
	 <20081009135538.GC9941@wotan.suse.de>
	 <1223561575.14090.14.camel@think.oraclecorp.com>
	 <20081009142124.GD9941@wotan.suse.de>
	 <1223563163.14090.18.camel@think.oraclecorp.com>
	 <20081009145024.GF9941@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 09 Oct 2008 11:16:34 -0400
Message-Id: <1223565394.14090.34.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-10-09 at 16:50 +0200, Nick Piggin wrote:
> On Thu, Oct 09, 2008 at 10:39:23AM -0400, Chris Mason wrote:
> > On Thu, 2008-10-09 at 16:21 +0200, Nick Piggin wrote:
> > > On Thu, Oct 09, 2008 at 10:12:55AM -0400, Chris Mason wrote:
> > > > On Thu, 2008-10-09 at 15:55 +0200, Nick Piggin wrote:
> > > > > On Thu, Oct 09, 2008 at 09:35:58AM -0400, Chris Mason wrote:
> > > > > > On Thu, 2008-10-09 at 15:27 +0200, Nick Piggin wrote:
> > > > > > 
> > > > > > I don't think do_sync_mapping_range is broken as is.  It simply splits
> > > > > > the operations into different parts.  The caller can request that we
> > > > > > wait for pending IO first.
> > > > > 
> > > > > It is. Not because of it's whacky API, but because it uses WB_SYNC_NONE. 
> > > > > 
> > > > > 
> > > > > > WB_SYNC_NONE none just means don't wait for IO in flight, and there are
> > > > > > valid uses for it that will slow down if you switch them all to
> > > > > > WB_SYNC_ALL.
> > > > > 
> > > > > To write_cache_pages it means that, but further down the chain (eg.
> > > > > block_write_full_page) it also means not to wait on other stuff.
> > > > > 
> > > > > It has broadly meant "don't worry about data integirty" for a long time
> > > > > AFAIKS.
> > > > 
> > > > Sadly it has broadly meant different things to different people ;)
> > > > You're right, block_write_full_page is broken.
> > > 
> > > Well, I really just think it is do_sync_mapping_range that is broken.
> > > Because __sync_single_inode treats WB_SYNC_NONE as a general "nowait",
> > > so does __writeback_single_inode. Weakest semantics define the API :)
> > 
> > Unfortunately these things are using the flag differently
> > __sync_single_inode and __writeback_single_inode do different things
> > with the flag than people that end up directly calling the writepages
> > methods.
> 
> Sure, but it's the "nowait" semantics that they want, right? And *they*
> eventually call into writepages. So they want similar semantics from
> writepages, presumably. 
> 
> The comment in WB_SYNC_NONE definition kind of suggests it meant don't
> wait for anything when it was written...

That seems to have turned into wbc->nonblocking.  WB_SYNC_NONE doesn't
stop other blocking inside the FS (delalloc and other fun).

> 
> 
> > At the write_cache_pages level, WB_SYNC_NONE should only change the
> > waiting for IO in flight.
> 
> Aside from do_sync_mapping_range, what are other reasons to enforce
> the same thing all up and down the writeout stack? If there are good
> reasons, let's add WB_SYNC_WRITEBACK?

Your change to skip writeback pages that aren't dirty makes WB_SYNC_ALL
almost the same as WB_SYNC_WRITEBACK.  With that in place we're pretty
deep into grey areas where people may not want to go around rewriting
pages that were dirtied after their sync began.

At least that's what I think the idea behind do_sync_mapping_range using
WB_SYNC_NONE was.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
