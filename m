Date: Tue, 26 Mar 2002 13:02:12 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] updated radix-tree pagecache
In-Reply-To: <3CA045BC.AA75D788@zip.com.au>
Message-ID: <Pine.LNX.4.21.0203261227570.1084-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Christoph Hellwig <hch@caldera.de>, Christoph Rohland <cr@sap.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, velco@fadata.bg
List-ID: <linux-mm.kvack.org>

On Tue, 26 Mar 2002, Andrew Morton wrote:
> 
> Aside: This is not related to ratcache: shmem_getpage_locked() is
> setting PG_dirty but not adding the page to mapping->dirty_pages.  Is
> this intended?

Yes.  It used to be the case that if a tmpfs file page got on to
mapping->dirty_pages, fsync on that file would never escape from
filemap_fdatasync if there was no swap.  Hence also "SetPageDirty"
in several places which originally said "set_page_dirty".

Nowadays the "if (!PageLaunder(page)) return fail_writepage(page);"
at the start of shmem_writepage would prevent that hang, and
prevents a subtler tmpfs file corruption we realized later on.

But the dirty_pages list is still a waste of time for tmpfs:
its data does not need to be committed to stable storage.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
