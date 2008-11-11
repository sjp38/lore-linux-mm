Date: Wed, 12 Nov 2008 00:17:22 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
	one page into another
Message-ID: <20081111231722.GR10818@random.random>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <1226409701-14831-2-git-send-email-ieidus@redhat.com> <1226409701-14831-3-git-send-email-ieidus@redhat.com> <20081111114555.eb808843.akpm@linux-foundation.org> <20081111210655.GG10818@random.random> <Pine.LNX.4.64.0811111522150.27767@quilx.com> <20081111221753.GK10818@random.random> <Pine.LNX.4.64.0811111626520.29222@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0811111626520.29222@quilx.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 11, 2008 at 04:30:22PM -0600, Christoph Lameter wrote:
> On Tue, 11 Nov 2008, Andrea Arcangeli wrote:
> 
> > this page_count check done with only the tree_lock won't prevent a
> > task to start O_DIRECT after page_count has been read in the above line.
> >
> > If a thread starts O_DIRECT on the page, and the o_direct is still in
> > flight by the time you copy the page to the new page, the read will
> > not be represented fully in the newpage leading to userland data
> > corruption.
> 
> O_DIRECT does not take a refcount on the page in order to prevent this?

It definitely does, it's also the only thing it does.

The whole point is that O_DIRECT can start the instruction after
page_count returns as far as I can tell.

If you check the three emails I linked in answer to Andrew on the
topic, we agree the o_direct can't start under PT lock (or under
mmap_sem in write mode but migrate.c rightefully takes the read
mode). So the fix used in ksm page_wrprotect and in fork() is to check
page_count vs page_mapcount inside PT lock before doing anything on
the pte. If you just mark the page wprotect while O_DIRECT is in
flight, that's enough for fork() to generate data corruption in the
parent (not the child where the result would be undefined). But in the
parent the result of the o-direct is defined and it'd never corrupt if
this was a cached-I/O. The moment the parent pte is marked readonly, a thread
in the parent could write to the last 512bytes of the page, leading to
the first 512bytes coming with O_DIRECT from disk being lost (as the
write will trigger a cow before I/O is complete and the dma will
complete on the oldpage).

We do the check in page_wprotect because that's the _first_ place
where we mark a pte readonly. Same as fork. And we can't convert a pte
from writeable to wrprotected without doing this check inside PT lock
or we generate data corruption with o_direct (again same as the bug in
fork).

We don't have to check the page_count vs mapcount later in
replace_page because we know if anybody started an O_DIRECT read from
disk, it would have triggered a cow, and the pte_same check that we
have to do for other reasons would take care of bailing out the
replace_page.

> Oh they could be migrated if you had a callback to the devices method for
> giving up references. Same as slab defrag.

The oldpage is a regular anonymous page for us, not the 'strange'
object called PageKSM. And we need to migrate many anonymous pages
having destination a single PageKSM page already preallocated and not
being an anonymous page. We never migrate PageKSM to anything, that's
always the destination.

> Seems that we are tinkering around with the concept of what an anonymous
> page is? Doesnt shmem have some means of converting pages to file backed?
> Swizzling?

Anonymous page is anything with page->mapping pointing to an anon_vma
or swapcache_space instead of an address_space of a real inode backed
by the vfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
