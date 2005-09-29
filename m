Date: Thu, 29 Sep 2005 14:32:01 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 0/3] Demand faulting for huge pages
In-Reply-To: <1127939141.26401.32.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.61.0509291420150.27691@goblin.wat.veritas.com>
References: <1127939141.26401.32.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Adam Litke <agl@us.ibm.com>, William Irwin <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Sep 2005, Adam Litke wrote:

> Hi Andrew.  Can we give hugetlb demand faulting a spin in the mm tree?
> And could people with alpha, sparc, and ia64 machines give them a good
> spin?  I haven't been able to test those arches yet.

It's going to be a little confusing if these go in while I'm moving
the page_table_lock inwards.  My patches don't make a big difference
to hugetlb (I've not attempted splitting the lock at all for hugetlb -
there would be per-arch implementation issues and very little point -
though more point if we do move to hugetlb faulting).  But I'm ill at
ease with changing the locking at one end while it's unclear whether
it's right at the other end.

Currently Adam's patches don't include my hugetlb changes already in
-mm; and I don't see any attention in his patches to the issue of
hugetlb file truncation, which I was fixing up in those.

The current hugetlb_prefault guards against this with i_sem held:
which _appears_ to be a lock ordering violation, but may not be,
since the official lock ordering is determined by the possibility
of fault within write, whereas hugetlb mmaps were never faulting.

Presumably on-demand hugetlb faulting would entail truncate_count
checking like do_no_page, and corresponding code in hugetlbfs.

I've no experience of hugetlb use.  Personally, I'd be very happy with
a decision to disallow truncation of hugetlb files (seems odd to allow
ftruncate when read and write are not allowed, and the size normally
determined automatically by mmap size); but I have to assume that it's
been allowed for good reason.

> - htlb-get_user_pages removes an optimization that is no longer valid
> when demand faulting huge pages
> 
> - htlb-fault moves the fault logic from hugetlb_prefault() to
> hugetlb_pte_fault() and find_get_huge_page().
> 
> - htlb-acct adds an overcommit check to maintain the no-overcommit
> semantics provided by hugetlb_prefault()

Yes, I found that last one rather strange too.  Doing it at creation
time based on i_size (and updating if i_size is allowed to change) is
one possibility; doing it at fault time whenever newly allocated is
another possibility; but these pagevec lookups at mmap time seem odd.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
