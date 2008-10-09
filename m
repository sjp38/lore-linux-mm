Date: Thu, 9 Oct 2008 15:55:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 5/8] mm: write_cache_pages integrity fix
Message-ID: <20081009135538.GC9941@wotan.suse.de>
References: <20081009155039.139856823@suse.de> <20081009174822.621353840@suse.de> <1223556765.14090.2.camel@think.oraclecorp.com> <20081009132711.GB9941@wotan.suse.de> <1223559358.14090.11.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223559358.14090.11.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 09, 2008 at 09:35:58AM -0400, Chris Mason wrote:
> On Thu, 2008-10-09 at 15:27 +0200, Nick Piggin wrote:
> 
> I don't think do_sync_mapping_range is broken as is.  It simply splits
> the operations into different parts.  The caller can request that we
> wait for pending IO first.

It is. Not because of it's whacky API, but because it uses WB_SYNC_NONE. 


> WB_SYNC_NONE none just means don't wait for IO in flight, and there are
> valid uses for it that will slow down if you switch them all to
> WB_SYNC_ALL.

To write_cache_pages it means that, but further down the chain (eg.
block_write_full_page) it also means not to wait on other stuff.

It has broadly meant "don't worry about data integirty" for a long time
AFAIKS.


> The problem is that we have a few flags and callers that mean almost but
> not quite the same thing.  Some people confuse WB_SYNC_NONE with
> wbc->nonblocking.
> 
> I'd leave WB_SYNC_NONE alone and set wbc->nr_to_write to the max int, or
> just make a new flag that says write every dirty page in this range.

Well it wouldn't hurt to clarify things. I'd rather introduce a new
WB_SYNC_WRITEBACK or something for that guy. But anyway, as I said,
it's just a minimal fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
