Date: Thu, 13 Nov 2008 03:00:59 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
	one page into another
Message-ID: <20081113020059.GC10818@random.random>
References: <Pine.LNX.4.64.0811111522150.27767@quilx.com> <20081111221753.GK10818@random.random> <Pine.LNX.4.64.0811111626520.29222@quilx.com> <20081111231722.GR10818@random.random> <Pine.LNX.4.64.0811111823030.31625@quilx.com> <20081112022701.GT10818@random.random> <Pine.LNX.4.64.0811112109390.10501@quilx.com> <20081112173258.GX10818@random.random> <Pine.LNX.4.64.0811121412130.31606@quilx.com> <1226527744.7560.93.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1226527744.7560.93.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 12, 2008 at 05:09:03PM -0500, Lee Schermerhorn wrote:
> Maybe not so wild, given the complexity of these interactions... 

Perhaps Christoph's right it's just wild ideas, but see below.

You both seem to agree the first theory of the tree_lock is bogus
as it's lockless for find_get_page.

The second theory of why it shouldn't happen thanks to the refcount
freezing is bogus too...

CPU0 migrate.c			CPU1 filemap.c
-------				----------
				find_get_page
				radix_tree_lookup_slot returns the oldpage
page_count still = expected_count
freeze_ref (oldpage->count = 0)
radix_tree_replace (too late, other side already got the oldpage)
unfreeze_ref (oldpage->count = 2)
				page_cache_get_speculative(old_page)
				set count to 3 and succeeds

Admittedly I couldn't understand what the freeze_ref was about, I
thought it was something related to the radix tree internals (which I
didn't check as they weren't relevant at that point besides being
lockless) as there was nothing inside that freeze/unfreeze critical
section that could affect find_get_page, so I ignored it. If if was
meant to stop find_get_page to get the oldpage it clearly isn't
working.

Perhaps I'm still missing something...

If I'm right my suggested fix is to simply change the
remove_migration_ptes to set the pte to point to the swapcache,
instead of leaving the swapentry in it. That will make do_swap_page
bailout like every other path in memory.c in the pte_same check, and
additionally it'll avoid an unnecessary minor fault.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
