Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id A31C46B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 10:04:29 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id x48so7452055wes.3
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 07:04:27 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id bz3si34363995wjc.41.2014.07.28.07.03.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 07:03:55 -0700 (PDT)
Date: Mon, 28 Jul 2014 10:01:57 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: fix direct reclaim writeback regression
Message-ID: <20140728140157.GM1725@cmpxchg.org>
References: <alpine.LSU.2.11.1407261248140.13796@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1407261248140.13796@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Dave Chinner <david@fromorbit.com>, xfs@oss.sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Jul 26, 2014 at 12:58:23PM -0700, Hugh Dickins wrote:
> Shortly before 3.16-rc1, Dave Jones reported:
> 
> WARNING: CPU: 3 PID: 19721 at fs/xfs/xfs_aops.c:971
>          xfs_vm_writepage+0x5ce/0x630 [xfs]()
> CPU: 3 PID: 19721 Comm: trinity-c61 Not tainted 3.15.0+ #3
> Call Trace:
>  [<ffffffffc023068e>] xfs_vm_writepage+0x5ce/0x630 [xfs]
>  [<ffffffff8316f759>] shrink_page_list+0x8f9/0xb90
>  [<ffffffff83170123>] shrink_inactive_list+0x253/0x510
>  [<ffffffff83170c93>] shrink_lruvec+0x563/0x6c0
>  [<ffffffff83170e2b>] shrink_zone+0x3b/0x100
>  [<ffffffff831710e1>] shrink_zones+0x1f1/0x3c0
>  [<ffffffff83171414>] try_to_free_pages+0x164/0x380
>  [<ffffffff83163e52>] __alloc_pages_nodemask+0x822/0xc90
>  [<ffffffff831abeff>] alloc_pages_vma+0xaf/0x1c0
>  [<ffffffff8318a931>] handle_mm_fault+0xa31/0xc50
> etc.
> 
>  970   if (WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
>  971                   PF_MEMALLOC))
> 
> I did not respond at the time, because a glance at the PageDirty block
> in shrink_page_list() quickly shows that this is impossible: we don't do
> writeback on file pages (other than tmpfs) from direct reclaim nowadays.
> Dave was hallucinating, but it would have been disrespectful to say so.
> 
> However, my own /var/log/messages now shows similar complaints
> WARNING: CPU: 1 PID: 28814 at fs/ext4/inode.c:1881 ext4_writepage+0xa7/0x38b()
> WARNING: CPU: 0 PID: 27347 at fs/ext4/inode.c:1764 ext4_writepage+0xa7/0x38b()
> from stressing some mmotm trees during July.
> 
> Could a dirty xfs or ext4 file page somehow get marked PageSwapBacked,
> so fail shrink_page_list()'s page_is_file_cache() test, and so proceed
> to mapping->a_ops->writepage()?
> 
> Yes, 3.16-rc1's 68711a746345 ("mm, migration: add destination page
> freeing callback") has provided such a way to compaction: if migrating
> a SwapBacked page fails, its newpage may be put back on the list for
> later use with PageSwapBacked still set, and nothing will clear it.
>
> Whether that can do anything worse than issue WARN_ON_ONCEs, and get
> some statistics wrong, is unclear: easier to fix than to think through
> the consequences.
> 
> Fixing it here, before the put_new_page(), addresses the bug directly,
> but is probably the worst place to fix it.  Page migration is doing too
> many parts of the job on too many levels: fixing it in move_to_new_page()
> to complement its SetPageSwapBacked would be preferable, except why is it
> (and newpage->mapping and newpage->index) done there, rather than down in
> migrate_page_move_mapping(), once we are sure of success?  Not a cleanup
> to get into right now, especially not with memcg cleanups coming in 3.17.

That needs verification that no ->migratepage() expects mapping
(working PageAnon()) and index to be set up on newpage.

The freelist putback looks quite fragile, we should probably add
something like free_pages_prepare() / free_page_check() in there.

> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
