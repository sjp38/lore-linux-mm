From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
Date: Fri, 17 Oct 2008 16:56:09 +1100
References: <48F77430.80001@redhat.com> <200810171321.40725.nickpiggin@yahoo.com.au> <20081017143307.FAA9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081017143307.FAA9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810171656.09935.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

On Friday 17 October 2008 16:37, KOSAKI Motohiro wrote:
> Hi Nick,
>
> I don't have any opinion against this patch is good or wrong.
> but I have a question.
>
> > Really, filemap_fault should not mark the page as accessed,
> > zap_pte_range should mark the page has accessed rather than just
> > set referenced, and this patch should not clear referenced.
>
> IIRC, sequential mapping pages are usually touched twice.
>  1. page fault (caused by readahead)
>  2. memcpy in userland
>
> So, if we only drop accessed bit of the page at page fault, the page end up
> having accessed bit by memcpy.
>
> pointless?

Well, the pte will get the accessed bit set by the set_pte call. This
would probably not be set again by the memcpy (unless it was attempted
to be reclaimed in the meantime, but that should be fairly rare).

And the sequential mapping special case ignores the pte bits, so that's
OK.

The problem is that the page fault path also does a mark_page_accessed,
which sets the page's PG_dirty bit. Now this bit is mainly used by the
unmapped pagecache access / reclaim heuristics, but because we set it
here, then the sequential mapping case is forced to clear it. I think it
would be much cleaner not to set the bit in the fault handler to begin
with.

I would like to ask this sequential mapping patch is held off until then,
and I will send a patch to make the mark_page_accessed, after the dust
settles from Andrew's merge. (because I can't make such a change inside
the merge window)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
