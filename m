Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6070E6B0038
	for <linux-mm@kvack.org>; Sat, 22 Aug 2015 16:14:53 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so621971pac.0
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 13:14:53 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id s13si19770405pdi.27.2015.08.22.13.14.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Aug 2015 13:14:52 -0700 (PDT)
Received: by pdrh1 with SMTP id h1so38960792pdr.0
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 13:14:52 -0700 (PDT)
Date: Sat, 22 Aug 2015 13:13:19 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv3 0/5] Fix compound_head() race
In-Reply-To: <20150820163836.b3b69f2bf36dba7020bdc893@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1508221204060.10507@eggly.anvils>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com> <20150820123107.GA31768@node.dhcp.inet.fi> <20150820163836.b3b69f2bf36dba7020bdc893@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 20 Aug 2015, Andrew Morton wrote:
> On Thu, 20 Aug 2015 15:31:07 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > On Wed, Aug 19, 2015 at 12:21:41PM +0300, Kirill A. Shutemov wrote:
> > > Here's my attempt on fixing recently discovered race in compound_head().
> > > It should make compound_head() reliable in all contexts.
> > > 
> > > The patchset is against Linus' tree. Let me know if it need to be rebased
> > > onto different baseline.
> > > 
> > > It's expected to have conflicts with my page-flags patchset and probably
> > > should be applied before it.
> > > 
> > > v3:
> > >    - Fix build without hugetlb;
> > >    - Drop page->first_page;
> > >    - Update comment for free_compound_page();
> > >    - Use 'unsigned int' for page order;
> > > 
> > > v2: Per Hugh's suggestion page->compound_head is moved into third double
> > >     word. This way we can avoid memory overhead which v1 had in some
> > >     cases.
> > > 
> > >     This place in struct page is rather overloaded. More testing is
> > >     required to make sure we don't collide with anyone.
> > 
> > Andrew, can we have the patchset applied, if nobody has objections?
> 
> I've been hoping to hear from Hugh and I wasn't planning on processing
> these before the 4.2 release.

I think this patchset is very good, in a variety of different ways.

Fixes a tricky race, deletes more code than it adds, shrinks kernel text,
deletes tricky functions relying on barriers, frees up a page flag bit,
removes a discrepancy between configs, is really neat in how PageTail
is necessarily false on all lru and lru-candidate pages, probably more.
Good job.

Yes, I did think the compound destructor enum stuff over-engineered,
and would have preferred just direct calls to free_compound_page()
or free_huge_page() myself.  But when I tried to make a patch on
top to do that, even when I left PageHuge out-of-line (which had
certainly not been my intention), it still generated more kernel
text than Kirill's enum version (maybe his "- 1" in compound_head
works better in some places than masking out 3, I didn't study);
so let's forget about that.

I've not actually run and tested with it, but I shall be pleased
when it gets in to mmotm, and will do so then.

As to whether it answers my doubts about his patch-flags patchset
already in mmotm (not your question here, Andrew, but Kirill's in
another of these mails): I'd say that it greatly reduces my doubts,
but does not entirely set me at ease with the bloat.

This set here gives us a compound_head() that is safe to tuck
inside PageFlags ops in that set there: that doesn't worry me
any more.  And the bloat is reduced enough that I don't think
it should be allowed to block Kirill's progress.

But I can't shake off the idea that someone somewhere (0day perf
results? Mel on an __spree?) is going to need to shave away some
of these hidden and rarely needed compound_head() calls one day.

Take __activate_page() in mm/swap.c as an example, something that
begins with a bold PageLRU && !PageActive && !PageUnevictable.
That function contains six sequences of the form
mov 0x20(%rdi),%rax; test $0x1,%al; je over_next; sub $0x1,%rax.

Five of which I expect could be avoided if we just did a
compound_head() conversion on entry.  I suppose any branch
predictor will do a fine job with the last five: am I just too
old-fashioned to be thinking we should (have the ability to)
eliminate them completely?

I'm not saying that we need to convert __activate_page, or anything
else, at this time; but I do think we shall want diet versions of
at least the simple PageFlags tests themselves (we should already
be sparing with the atomic ones), and need to establish convention
now for what the diet versions of PageFlags will be called.

Would __PageFlag be good enough?  Could we say that
__SetPageFlag and __ClearPageFlag omit the compound_head() -
we already have to think carefully when applying those?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
