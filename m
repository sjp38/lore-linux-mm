Date: Tue, 11 Nov 2008 23:17:53 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
	one page into another
Message-ID: <20081111221753.GK10818@random.random>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <1226409701-14831-2-git-send-email-ieidus@redhat.com> <1226409701-14831-3-git-send-email-ieidus@redhat.com> <20081111114555.eb808843.akpm@linux-foundation.org> <20081111210655.GG10818@random.random> <Pine.LNX.4.64.0811111522150.27767@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0811111522150.27767@quilx.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 11, 2008 at 03:26:57PM -0600, Christoph Lameter wrote:
> On Tue, 11 Nov 2008, Andrea Arcangeli wrote:
> 
> > btw, page_migration likely is buggy w.r.t. o_direct too (and now
> > unfixable with gup_fast until the 2.4 brlock is added around it or
> > similar) if it does the same thing but without any page_mapcount vs
> > page_count check.
> 
> Details please?

  spin_lock_irq(&mapping->tree_lock);

  pslot = radix_tree_lookup_slot(&mapping->page_tree,
			page_index(page));

			expected_count = 2 + !!PagePrivate(page);
			if (page_count(page) != expected_count ||

this page_count check done with only the tree_lock won't prevent a
task to start O_DIRECT after page_count has been read in the above line.

If a thread starts O_DIRECT on the page, and the o_direct is still in
flight by the time you copy the page to the new page, the read will
not be represented fully in the newpage leading to userland data
corruption.

> > page_migration does too much for us, so us calling into migrate.c may
> > not be ideal. It has to convert a fresh page to a VM page. In KSM we
> > don't convert the newpage to be a VM page, we just replace the anon
> > page with another page. The new page in the KSM case is not a page
> > known by the VM, not in the lru etc...
> 
> A VM page as opposed to pages not in the VM? ???

Yes, you migrate old VM pages to new VM pages. We replace VM pages
with unknown stuff called KSM pages. So in the inner function where you
replace the pte-migration-placeholder with a pte pointing to the
newpage, you also rightfully do unconditional stuff we can't be doing
like page_add_*_rmap. It's VM pages you're dealing with. Not for us.

> page migration requires the page to be on the LRU. That could be changed
> if you have a different means of isolating a page from its page tables.

Yes we'd need to change those bits to be able to use migrate.c.

> Define a regular VM page? A page on the LRU?

Yes, pages owned, allocated and worked on by the VM. So they can be
swapped, collected, migrated etc... You can't possibly migrate a
device driver page for example and infact those device driver pages
can't be migrated either.

The KSM page initially is a driver page, later we'd like to teach the
VM how to swap it by introducing rmap methods and adding it to the
LRU. As long as it's only anonymous memory that we're sharing/cloning,
we won't have to patch pagecache radix tree and other stuff. BTW, if
we ever decice to clone pagecache we could generate immense metadata
ram overhead in the radix tree with just a single page of data. All
issues that don't exist for anon ram.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
