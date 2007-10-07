From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 5/7] shmem_getpage return page locked
Date: Sun, 7 Oct 2007 18:01:59 +1000
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com> <Pine.LNX.4.64.0710062145160.16223@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0710062145160.16223@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710071801.59947.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sunday 07 October 2007 06:46, Hugh Dickins wrote:
> In the new aops, write_begin is supposed to return the page locked:
> though I've seen no ill effects, that's been overlooked in the case
> of shmem_write_begin, and should be fixed.  Then shmem_write_end must
> unlock the page: do so _after_ updating i_size, as we found to be
> important in other filesystems (though since shmem pages don't go
> the usual writeback route, they never suffered from that corruption).

I guess my thinking on this is that write_begin doesn't actually _have_
to return the page locked, it just has to return the page in a state where
it may be written into.

Generic callers obviously cannot assume that the page *isn't* locked,
but I can't think it would be too helpful for them to be able to assume
the page is locked (they already have a ref, which prevents reclaim;
and i_mutex, which prevents truncate).

However, this does make tmpfs apis a little simpler and in general is more
like other filesystems, so I have absolutely no problems with it.

I think the other patches are pretty fine too, and really like that you were
able to remove shmem_file_write!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
