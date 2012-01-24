Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 681A66B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 20:42:54 -0500 (EST)
Received: by iadk27 with SMTP id k27so239325iad.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 17:42:53 -0800 (PST)
Date: Mon, 23 Jan 2012 17:42:37 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mm: adjust rss counters for migration entiries
In-Reply-To: <20120118152131.45a47966.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1201231719580.14979@eggly.anvils>
References: <20120106173827.11700.74305.stgit@zurg> <20120106173856.11700.98858.stgit@zurg> <20120111144125.0c61f35f.kamezawa.hiroyu@jp.fujitsu.com> <4F0D46EF.4060705@openvz.org> <20120111174126.f35e708a.kamezawa.hiroyu@jp.fujitsu.com>
 <20120118152131.45a47966.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 18 Jan 2012, Andrew Morton wrote:
> On Wed, 11 Jan 2012 17:41:26 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 11 Jan 2012 12:23:11 +0400
> > Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

I only just got around to looking at these, sorry.

> 
> Putting "fix" in the patch title text is a good way of handling this.
> 
> I renamed [3/3] to "mm: fix rss count leakage during migration" and
> shall queue it for 3.3.  If people think we should also backport it
> into -stable then please let me know.

I don't think it needs backporting to stable: unless I'm forgetting
something, the only thing that actually uses these rss counters is the
OOM killer, and I don't think that will be greatly affected by the bug.

> 
> I reordered the patches and worked the chagnelogs quite a bit.  I now
> have:
> 
> : From: Konstantin Khlebnikov <khlebnikov@openvz.org>
> : Subject: mm: fix rss count leakage during migration
> : 
> : Memory migration fills a pte with a migration entry and it doesn't update
> : the rss counters.  Then it replaces the migration entry with the new page
> : (or the old one if migration failed).  But between these two passes this
> : pte can be unmaped, or a task can fork a child and it will get a copy of
> : this migration entry.  Nobody accounts for this in the rss counters.
> : 
> : This patch properly adjust rss counters for migration entries in
> : zap_pte_range() and copy_one_pte().  Thus we avoid extra atomic operations
> : on the migration fast-path.
> : 
> : Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> : Cc: Hugh Dickins <hughd@google.com>
> : Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

That was a good find, Konstantin: thank you.

> 
> and
> 
> : From: Konstantin Khlebnikov <khlebnikov@openvz.org>
> : Subject: mm: add rss counters consistency check
> : 
> : Warn about non-zero rss counters at final mmdrop.
> : 
> : This check will prevent reoccurences of bugs such as that fixed in "mm:
> : fix rss count leakage during migration".
> : 
> : I didn't hide this check under CONFIG_VM_DEBUG because it rather small and
> : rss counters cover whole page-table management, so this is a good
> : invariant.
> : 
> : Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> : Cc: Hugh Dickins <hughd@google.com>
> : Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I'd be happier with this one if you do hide the check under
CONFIG_VM_DEBUG - or even under CONFIG_DEBUG_VM if you want it to
be compiled in sometimes ;)  I suppose NR_MM_COUNTERS is only 3,
so it isn't a huge overhead; but I think you're overestimating the
importance of these counters, and it would look better under DEBUG_VM.

> 
> and
> 
> : From: Konstantin Khlebnikov <khlebnikov@openvz.org>
> : Subject: mm: postpone migrated page mapping reset
> : 
> : Postpone resetting page->mapping until the final remove_migration_ptes(). 
> : Otherwise the expression PageAnon(migration_entry_to_page(entry)) does not
> : work.
> : 
> : Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> : Cc: Hugh Dickins <hughd@google.com>
> : Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Isn't this one actually an essential part of the fix?  It should have
been part of the same patch, but you split them apart, now Andrew has
reordered them and pushed one part to 3.3, but this needs to go in too?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
