Date: Tue, 11 Nov 2008 22:06:55 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
	one page into another
Message-ID: <20081111210655.GG10818@random.random>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <1226409701-14831-2-git-send-email-ieidus@redhat.com> <1226409701-14831-3-git-send-email-ieidus@redhat.com> <20081111114555.eb808843.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081111114555.eb808843.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 11, 2008 at 11:45:55AM -0800, Andrew Morton wrote:
> page migration already kinda does that.  Is there common ground?

btw, page_migration likely is buggy w.r.t. o_direct too (and now
unfixable with gup_fast until the 2.4 brlock is added around it or
similar) if it does the same thing but without any page_mapcount vs
page_count check.

page_migration does too much for us, so us calling into migrate.c may
not be ideal. It has to convert a fresh page to a VM page. In KSM we
don't convert the newpage to be a VM page, we just replace the anon
page with another page. The new page in the KSM case is not a page
known by the VM, not in the lru etc...

The way to go could be to change the page_migration to use
replace_page (or __replace_page if called in some shared inner-lock
context) after preparing the newpage to be a regular VM page. If we
can do that, migrate.c will get the o_direct race fixed too for free.

> I don't understand the restrictions on anonymous pages.  Please expand
> the changelog so that reviewers can understand the reasons for this
> restriction.

That's a good question but I don't have a definitive answer as I
didn't account for exactly how complex it would be yet.

Suppose a file has 0-4k equal to 4k-8k. A MAP_SHARED that maps both
pages with the same physical page sounds tricky. The shared pages are
KSM owned and invisible to the VM (later could be made visible with an
external-rmap), but pagecache can't be just KSM owned, they at least
must go in pagecache radix tree so that requires patching the radix
tree etc... All things we don't need for anon ram. I think first thing
to extend is to add external-rmap and make ksm swappable, then we can
think if something can be done about MAP_SHARED/MAP_PRIVATE too
(MAP_PRIVATE post-COW already works, the question is pre-COW). One
excuse of why I didn't think too much about it yet is because in
effect KSM it's mostly useful to the anon ram, the pagecache can be
solved in userland with hardlinks with openvz, and shared libs already
do all they can to share .text (the not-shared post dynamic link
should be covered by ksm already).

> Again, we could make the presence of this code selectable by subsystems
> which want it.

Indeed!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
