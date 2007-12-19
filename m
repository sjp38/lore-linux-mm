From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 17/20] non-reclaimable mlocked pages
Date: Wed, 19 Dec 2007 11:56:48 +1100
References: <20071218211539.250334036@redhat.com> <20071218211550.186819416@redhat.com>
In-Reply-To: <20071218211550.186819416@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200712191156.48507.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 19 December 2007 08:15, Rik van Riel wrote:

> Rework of a patch by Nick Piggin -- part 1 of 2.
>
> This patch:
>
> 1) defines the [CONFIG_]NORECLAIM_MLOCK sub-option and the
>    stub version of the mlock/noreclaim APIs when it's
>    not configured.  Depends on [CONFIG_]NORECLAIM.
>
> 2) add yet another page flag--PG_mlocked--to indicate that
>    the page is locked for efficient testing in vmscan and,
>    optionally, fault path.  This allows early culling of
>    nonreclaimable pages, preventing them from getting to
>    page_referenced()/try_to_unmap().  Also allows separate
>    accounting of mlock'd pages, as Nick's original patch
>    did.
>
>    Uses a bit available only to 64-bit systems.
>
>    Note:  Nick's original mlock patch used a PG_mlocked
>    flag.  I had removed this in favor of the PG_noreclaim
>    flag + an mlock_count [new page struct member].  I
>    restored the PG_mlocked flag to eliminate the new
>    count field.
>
> 3) add the mlock/noreclaim infrastructure to mm/mlock.c,
>    with internal APIs in mm/internal.h.  This is a rework
>    of Nick's original patch to these files, taking into
>    account that mlocked pages are now kept on noreclaim
>    LRU list.
>
> 4) update vmscan.c:page_reclaimable() to check PageMlocked()
>    and, if vma passed in, the vm_flags.  Note that the vma
>    will only be passed in for new pages in the fault path;
>    and then only if the "cull nonreclaimable pages in fault
>    path" patch is included.
>
> 5) add try_to_unlock() to rmap.c to walk a page's rmap and
>    ClearPageMlocked() if no other vmas have it mlocked.
>    Reuses as much of try_to_unmap() as possible.  This
>    effectively replaces the use of one of the lru list links
>    as an mlock count.  If this mechanism let's pages in mlocked
>    vmas leak through w/o PG_mlocked set [I don't know that it
>    does], we should catch them later in try_to_unmap().  One
>    hopes this will be rare, as it will be relatively expensive.

Hmm, I still don't know (or forgot) why you don't just use the
old scheme of having an mlock count in the LRU bit, and removing
the mlocked page from the LRU completely.

These mlocked pages don't need to be on a non-reclaimable list,
because we can find them again via the ptes when they become
unlocked, and there is no point background scanning them, because
they're always going to be locked while they're mlocked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
