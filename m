From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 16/16] mm: filemap: Prefetch page->flags if !PageUptodate
Date: Sat, 19 Apr 2014 12:23:48 +0100
Message-ID: <20140419112347.GD4225@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
 <1397832643-14275-17-git-send-email-mgorman@suse.de>
 <alpine.LSU.2.11.1404181149310.13030@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1404181149310.13030@eggly.anvils>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Hugh Dickins <hughd@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Fri, Apr 18, 2014 at 12:16:23PM -0700, Hugh Dickins wrote:
> On Fri, 18 Apr 2014, Mel Gorman wrote:
> 
> > The write_end handler is likely to call SetPageUptodate which is an atomic
> > operation so prefetch the line.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> This one seems a little odd to me: it feels as if you're compensating
> for your mark_page_accessed() movement,

Not as such. We take the penalty anyway, it's just a case of when. As
the penalty was semi-obviously in one place it seemed like a reasonable
thing to do.

> but in too shmem-specific a way.
> 
> I see write_ends do SetPageUptodate more often than I was expecting
> (with __block_commit_write() doing so even when PageUptodate already),
> but even so...
> 

Good point. I'll search for those and clean them up.

> Given that the write_end is likely to want to SetPageDirty, and sure
> to want to clear_bit_unlock(PG_locked, &page->flags), wouldn't it be
> better and less mysterious just to prefetchw(&page->flags) here
> unconditionally?
> 

Again, good point. I'm travelling at the moment but will audit the write_end
handlers when I get back and see if filesystems generally benefit or if
I was aiming at shmem too much.

> (But I'm also afraid that this sets a precedent for an avalanche of
> dubious prefetchw patches all over.)
> 

I'll include figures the next time to see if it's justified. However,
even in that case I recognise that not all CPUs treat prefetchw the same
and we might still want to drop this patch as a result regardless of
what result I see on one test machine.

Thanks Hugh

-- 
Mel Gorman
SUSE Labs
