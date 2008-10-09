Subject: Re: [patch 5/8] mm: write_cache_pages integrity fix
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20081009174822.621353840@suse.de>
References: <20081009155039.139856823@suse.de>
	 <20081009174822.621353840@suse.de>
Content-Type: text/plain
Date: Thu, 09 Oct 2008 08:52:45 -0400
Message-Id: <1223556765.14090.2.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-10-10 at 02:50 +1100, npiggin@suse.de wrote:
> plain text document attachment (mm-wcp-integrity-fix.patch)
> In write_cache_pages, nr_to_write is heeded even for data-integrity syncs, so
> the function will return success after writing out nr_to_write pages, even if
> that was not sufficient to guarantee data integrity.
> 
> The callers tend to set it to values that could break data interity semantics
> easily in practice. For example, nr_to_write can be set to mapping->nr_pages *
> 2, however if a file has a single, dirty page, then fsync is called, subsequent
> pages might be concurrently added and dirtied, then write_cache_pages might
> writeout two of these newly dirty pages, while not writing out the old page
> that should have been written out.
> 
> Fix this by ignoring nr_to_write if it is a data integrity sync.
> 

Thanks for working on these.

We should have a wbc->integrity flag because WB_SYNC_NONE is somewhat
over used, and it is often used in data integrity syncs.

See fs/sync.c:do_sync_mapping_range()

There are many valid uses where we don't want to wait on pages that are
already writeback but we do want to write everything else.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
