Date: Fri, 2 Apr 2004 04:22:33 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040402022233.GQ18585@dualathlon.random>
References: <20040402001535.GG18585@dualathlon.random> <Pine.LNX.4.44.0404020145490.2423-100000@localhost.localdomain> <20040402011627.GK18585@dualathlon.random> <20040401173649.22f734cd.akpm@osdl.org> <20040402020022.GN18585@dualathlon.random> <20040401180802.219ece99.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040401180802.219ece99.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 01, 2004 at 06:08:02PM -0800, Andrew Morton wrote:
> Andrea Arcangeli <andrea@suse.de> wrote:
> >
> > I now fixed up the whole compound thing, it made no sense to keep
> > compound off with HUGETLBSF=N, that's a generic setup for all order > 0
> > not just for hugetlbfs, so it has to be enabled always or never, or it's
> > just asking for troubles.
> 
> It was a modest optimisation for non-hugetlb architectures and configs. 
> Having it optional has caused no problem in a year.
> 
> Was there some reason why you _required_ that it be permanently enabled?

Well, I doubt anybody could take advantage of this optimization, since
nobody can ship with hugetlbfs disabled anyways (peraphs with the
exception of the embedded people but then I doubt they want to risk
drivers to break because they could depend on the compound framekwork).
My point is that nobody will ever test with hugetlbfs disabled, so the
fact you don't get bugs it doesn't mean it'll not crash with hugetlbfs
disabled. there must be a defined API that returns multipages, today
most of the testing has been done with hugetlbfs enabled which means
with multipages being compound pages, so I'd rather not disable compound
by default.

I find unreliable that in mainline with hugetlbfs=N we don't set the
page->count of all page_t * to 1, and we still set to 1 only the first
page, that's just a bug waiting to trigger. The fact the MMU people
wanted all of them set to 1 just shows some driver would break with
hugetlbfs turned off. That's fixed.

If our object is to optimize then we could disable the compound by
default and have only hugetlbfs calling alloc_pages with __GFP_COMP,
instead of swapsuspend being the only one calling alloc_pages with
__GFP_NO_COMP, though I preferred not to optimize since the majority of
the testing so far has been done with hugetlbfs=y so I didn't want to
invalidate it. Though if you want to disable compound by default to
optimize everything (not just the hugetlbfs=n compiles) that's fine with
me. Though I understood DaveM just asked for compound being always
available for some network thing and that's what I implemented.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
