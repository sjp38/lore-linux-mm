Date: Fri, 13 Jun 2008 22:15:01 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.26-rc5-mm2 (swap_state.c:77)
In-Reply-To: <20080613134507.3f08820e@cuia.bos.redhat.com>
Message-ID: <Pine.LNX.4.64.0806132135460.10183@blonde.site>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
 <200806101848.22237.nickpiggin@yahoo.com.au> <20080611140902.544e59ec@bree.surriel.com>
 <200806120958.38545.nickpiggin@yahoo.com.au> <20080612152905.6cb294ae@cuia.bos.redhat.com>
 <Pine.LNX.4.64.0806122131330.10415@blonde.site> <20080613134507.3f08820e@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jun 2008, Rik van Riel wrote:
> On Thu, 12 Jun 2008 22:15:54 +0100 (BST)
> Hugh Dickins <hugh@veritas.com> wrote:
> > 
> > I don't know how to fix this problem in a nice way.  For the moment,
> > to proceed with testing, I'm using the hack below.  But perhaps that
> > screws things up for the other !mapping_cap_account_dirty filesystems
> > e.g. ramfs, I just haven't tried them yet - nor shall in the next
> > couple of days.
> 
> Yeah, it will break ramfs.  Also, we need to take care of
> splice going in the opposite direction (moving a page from
> SwapBacked to filesystem backed).

No, that's a different, and blessedly non-existent, problem.

The swap_state.c:77s we're seeing with loop-on-tmpfs-file just comes
from __generic_file_splice_read doing add_to_page_cache_lru without
knowing that the filesystem it's dealing with is tmpfs, which unlike
every other filesystem sets and expects PageSwapBacked on its pages.
(I expect you started out without that, then hit problems when tmpfs
moved its file pages to swap cache, so you therefore elected to make
them SwapBacked from the start.)

You could certainly argue that tmpfs should therefore have its own
shmem_file_splice_read instead of using generic_file_splice_read;
but I'd rather hate to duplicate that splice code within shmem.c just
for this reason, would prefer that __generic_file_splice_read deduce it's
dealing with tmpfs and SetPageSwapBacked before add_to_page_cache_lru
(probably better that way than within add_to_page_cache_lru as I did).

Though I'd even more prefer to find a way of avoiding it altogether:
I've yet to think through on that.

But this is hardly a splice problem, it's just that splice is the
only thing which ever goes the problematic shmem_readpage route.

When above you say that we also need to take care of going the
opposite direction, you're thinking about splice stealing pages
from one mapping and giving them to another, the essence of splice.
But see Nick's year-old 485ddb4b9741bafb70b22e5c1f9b4f37dc3e85bd
"splice: dont steal" patch: that stealing is currently dead code,
so you shouldn't spend time worrying about how to deal with it.
Though we've all forgotten to either remove or correct that code.

> I guess we'll need per-mapping flags to help determine where
> a page goes at add_to_page_cache_lru() time.

The better way would be to add a backing_dev_info flag.  (At one
point I had been going to criticize your per-mapping AS_UNEVICTABLE,
to say that one should be a backing_dev_info flag; but no, you're
right, you've the SHM_LOCK case where it has to be per-mapping.)

> This does not remove our need for the page flags, because
> those need to survive until the del_page_from_lru() call
> in __page_cache_release(), by which time the page->mapping
> will be long gone.

Yes, I see that.

> > Am I right to think that the memcontrol stuff is now all broken,
> > because memcontrol.c hasn't yet been converted to the more LRUs?
> > Certainly I'm now hanging when trying to run in a restricted memcg.
> 
> I believe memcontrol has been converted.  Of course, maybe
> they changed some stuff under me that I didn't notice :(

Ah, yes, there are NR_LRU_LISTS arrays in there now, so it has
the appearance of having been converted.  Fine, then it's worth
my looking into why it isn't actually working as intended.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
