Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 06B226B00E9
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 09:53:05 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id f8so6188127wiw.10
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 06:53:05 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id o10si7358384wix.20.2014.06.10.06.53.00
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 06:53:00 -0700 (PDT)
Date: Tue, 10 Jun 2014 16:52:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RFC 00/10] THP refcounting redesign
Message-ID: <20140610135246.GA3728@node.dhcp.inet.fi>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
 <5396BD90.4060104@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5396BD90.4060104@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 10, 2014 at 10:10:56AM +0200, Vlastimil Babka wrote:
> On 06/09/2014 06:04 PM, Kirill A. Shutemov wrote:
> >Hello everybody,
> >
> >We've discussed few times that is would be nice to allow huge pages to be
> >mapped with 4k pages too. Here's my first attempt to actually implement
> >this. It's early prototype and not stabilized yet, but I want to share it
> >to discuss any potential show stoppers early.
> >
> >The main reason why we can't map THP with 4k is how refcounting on THP
> >designed. It built around two requirements:
> >
> >   - split of huge page should never fail;
> >   - we can't change interface of get_user_page();
> >
> >To be able to split huge page at any point we have to track which tail
> >page was pinned. It leads to tricky and expensive get_page() on tail pages
> >and also occupy tail_page->_mapcount.
> >
> >Most split_huge_page*() users want PMD to be split into table of PTEs and
> >don't care whether compound page is going to be split or not.
> >
> >The plan is:
> >
> >  - allow split_huge_page() to fail if the page is pinned. It's trivial to
> >    split non-pinned page and it doesn't require tail page refcounting, so
> >    tail_page->_mapcount is free to be reused.
> >
> >  - introduce new routine -- split_huge_pmd() -- to split PMD into table of
> >    PTEs. It splits only one PMD, not touching other PMDs the page is
> >    mapped with or underlying compound page. Unlike new split_huge_page(),
> >    split_huge_pmd() never fails.
> >
> >Fortunately, we have only few places where split_huge_page() is needed:
> >swap out, memory failure, migration, KSM. And all of them can handle
> >split_huge_page() fail.
> >
> >In new scheme we use tail_page->_mapcount is used to account how many time
> >the tail page is mapped. head_page->_mapcount is used for both PMD mapping
> >of whole huge page and PTE mapping of the firt 4k page of the compound
> >page. It seems work fine, except the fact that we don't have a cheap way
> >to check whether the page mapped with PMDs or not.
> >
> >Introducing split_huge_pmd() effectively allows THP to be mapped with 4k.
> >It can break some kernel expectations. I.e. VMA now can start and end in
> >middle of compound page. IIUC, it will break compactation and probably
> >something else (any hints?).
> 
> I don't think compaction cares at all about VMA's. Unless the underlying
> page migration does. What will break is munlock due to
> VM_BUG_ON(PageTail(page)) in the PageTransHuge() check.

We have PageTransCompound() if caller doesn't care which part of THP the
page is.

> >Also munmap() on part of huge page will not split and free unmapped part
> >immediately. We need to be careful here to keep memory footprint under
> >control.
> 
> So who will take care of it, if it's not done immediately?

I mean the whole compound page will not be freed until the last part page
is unmapped. It can lead to excessive memory overhead for some workloads.
We can try to be smarter and call split_huge_page() instead of
split_huge_pmd() if see that the huge page is not mapped as 2M or
something. But we don't have a cheap way to check this...

> >As side effect we don't need to mark PMD splitting since we have
> >split_huge_pmd(). get_page()/put_page() on tail of THP is cheaper (and
> >cleaner) now.
> 
> But per patch 2, PageAnon() is more expensive.

I don't think it's significant: for non-compound page it's probably
near-free (page->flags is most likely hot). For compound page it costs
additional cacheline. Not a big deal from my POV.

For get_page()/put_page() on tail THP we saved one atomic operation and
few checks. This is important because refcounting on tail pages is going to
be more common, since they can be mapped individually now. Acctually, I'm
not sure if these operation is cheap enough: we still use compound_lock
there to serialize against splitting.

> Also there are no side effects to this change?

Of course there are :) That only what came to mind. The patchset is very
early, I don't have whole picture yet. I expect more PageCompound() and
compound_head() will be needed ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
