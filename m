Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0FFC86B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 10:49:53 -0400 (EDT)
Received: by wicgj17 with SMTP id gj17so64562712wic.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 07:49:52 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id o4si20227008wjx.75.2015.08.07.07.49.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 07:49:51 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so64567618wib.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 07:49:50 -0700 (PDT)
Date: Fri, 7 Aug 2015 17:49:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: page-flags behavior on compound pages: a worry
Message-ID: <20150807144949.GA12177@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1426784902-125149-5-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1508052001350.6404@eggly.anvils>
 <20150806153259.GA2834@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1508061121120.7500@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1508061121120.7500@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 06, 2015 at 12:24:22PM -0700, Hugh Dickins wrote:
> > I'm trying to wrap my head around this mail and not sure if I succeed
> > much. :-|
> 
> Sorry for not being clearer.

Not your fault.

The problem you've pointed to is on edge of my understanding of concurrency.

> On Thu, 6 Aug 2015, Kirill A. Shutemov wrote:
> > > To be more specific: if preemption, or an interrupt, or entry to SMM
> > > mode, or whatever, delays this thread somewhere in that compound_head()
> > > sequence of instructions, how can we be sure that the "head" returned
> > > by compound_head() is good?  We know the page was PageTail just before
> > > looking up page->first_page, and we know it was PageTail just after,
> > > but we don't know that it was PageTail throughout, and we don't know
> > > whether page->first_page is even a good page pointer, or something
> > > else from the private/ptl/slab_cache union.
> > 
> > That looks like a very valid worry to me. For current -mm tree.
> > 
> > But let's take my refcounting rework into picture.
> 
> Okay, let's do so.  I get very confused trying to think based on two
> alternative schemes at the same time, so I'm happy to assume your
> THP refcounting rework (which certainly has plenty to like in it
> from the point of view of cleanup - though at present I think the
> mlock splitting leaves it with a net regression in functionality).

The plan is to bring it a bit later. The refcounting patchset is huge
enough as it is.

> That does say that this page-flags rework should not go to Linus
> separately from your refcounting rework: I don't think the issues
> here are ever likely to break someone's bisection, so it's fine for
> the one series to precede the other, but any release should contain
> both or neither.

Agreed.

> > One thing it simplifies is protection against splitting. Once you've got a
> > reference to a page, it cannot be split under you. It makes PageTail() and
> > ->first_page stable for most callsites.
> 
> Yes, but since you cannot acquire a reference to a tail page itself
> (since it has count 0 throughout), don't you mean there that you
> already hold a reference to the head?
> 
> In which case, why bother to make all the PageFlags operations on
> tails redirect to the head: if the caller must hold a reference to
> the head, then the caller should apply PageFlags to that head, with
> no need for compound_head() redirection inside the operation, just a
> VM_BUG_ON(PageTail).

get_page() and put_page() hide the fact that refcounting is applied to
head page. And that's handy. Otherwise we would need drag pointers to two
pages on caller side, instead of one we have now.

The only special case is again get_page_unless_zero() users. They have to
deal with head vs. tail pages on their own. We have only few such places.
And it's manageable I believe.

> Or so it seems from the outside: perhaps that becomes unworkable
> somehow once you try to implement it.
> 
> > 
> > We can access the page's flags under ptl, without having reference the
> > page. And that's fine: ptl protects against splitting too.
> > 
> > Fast GUP also have a way to protect against split.
> 
> Yes and yes.  Perhaps it's those accesses under ptl which took you
> in this compound_head-inside-PageFlags direction.  Fast GUP is easy
> to do something special in, but there's probably a lot of scattered
> PageFlags operations under ptl, which were tiresome to fiddle with
> when you came to allow pte mappings of THP subpages.

Right.

> > IIUC, the only potentially problematic callsites left are physical memory
> > scanners. This code requires audit. I'll do that.
> 
> Please.

I'll bring some report on this next week.

> > Do I miss something else?
> 
> Probably not; but please check - and I'm afraid you've set things up
> so that every use of a PageFlags operation needs to be thought about,
> if only briefly.
> 
> It's certainly the physical approaches to a page (isolation, compaction,
> formerly lumpy reclaim, are there others?  /proc things?) which have
> always been very tricky to get right.

I didn't think about /proc as potential issue. Thanks.

> I think it was for those that David added the barriered double PageTail
> checking.  I wonder if something extra special should be done just there,
> in the physical scans; and the barriered double PageTail checking avoided
> elsewhere, in the normal places that you reckon are safe already.
> 
> Mind you, shifting the unlikely PageTail handling out of line to a
> called function would reduce the bloat considerably, then maybe it
> wouldn't matter how complicated it gets for the general case.

I'll try that.

> > > Of course it would be very rare for it to go wrong; and most callsites
> > > will obviously be safe for this or that reason; though, sadly, none of
> > > them safe from holding a reference to the tail page in question, since
> > > its count is frozen at 0 and cannot be grabbed by get_page_unless_zero.
> > 
> > Do you mean that grabbing head page's ->_count is not enough to protect
> > against splitting and freeing tail page under you?
> 
> No, I mean that if you know head already then why are you bothering with
> tail; and if you only have tail, then locating head in all the cases where
> the PageFlags operation might be called may be unsafe in a few of them.

See above.

> And that it's not possible to acquire a reference to the tail page to
> make this safe.  But I accept your point above, that the existence of
> a pte in a locked page table amounts to a stable reference, even though
> it does not contribute to that tail page's reference count.
> 
> > 
> > I know a patchset which solves this! ;)
> 
> Oh, and I know a patchset which avoids these problems completely,
> by not using compound pages at all ;)

BTW, I haven't heard anything about the patchset for a while.
What's the status?

Optimizing rmap operations in my patchset (see PG_double_map), I found
that it would be very tricky to expand team pages to anon-THP without
performance regression on rmap side due to amount of atomic ops it
requires.

Is there any clever approach to the issue?

Team pages are probably fine for file mappings due different performance
baseline. I'm less optimistic about anon-THP.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
