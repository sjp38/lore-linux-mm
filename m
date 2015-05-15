Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 795936B0032
	for <linux-mm@kvack.org>; Fri, 15 May 2015 09:31:37 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so39001353wic.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 06:31:37 -0700 (PDT)
Received: from johanna1.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id a15si2816596wjr.81.2015.05.15.06.31.35
        for <linux-mm@kvack.org>;
        Fri, 15 May 2015 06:31:35 -0700 (PDT)
Date: Fri, 15 May 2015 16:31:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 00/28] THP refcounting redesign
Message-ID: <20150515133124.GB6625@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <5555B49B.3050901@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5555B49B.3050901@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 15, 2015 at 10:55:55AM +0200, Vlastimil Babka wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> >Hello everybody,
> >
> >Here's reworked version of my patchset. All known issues were addressed.
> >
> >The goal of patchset is to make refcounting on THP pages cheaper with
> >simpler semantics and allow the same THP compound page to be mapped with
> >PMD and PTEs. This is required to get reasonable THP-pagecache
> >implementation.
> >
> >With the new refcounting design it's much easier to protect against
> >split_huge_page(): simple reference on a page will make you the deal.
> >It makes gup_fast() implementation simpler and doesn't require
> >special-case in futex code to handle tail THP pages.
> >
> >It should improve THP utilization over the system since splitting THP in
> >one process doesn't necessary lead to splitting the page in all other
> >processes have the page mapped.
> >
> >The patchset drastically lower complexity of get_page()/put_page()
> >codepaths. I encourage reviewers look on this code before-and-after to
> >justify time budget on reviewing this patchset.
> >
> >= Changelog =
> >
> >v5:
> >   - Tested-by: Sasha Levin!a?c
> >   - re-split patchset in hope to improve readability;
> >   - rebased on top of page flags and ->mapping sanitizing patchset;
> >   - uncharge compound_mapcount rather than mapcount for hugetlb pages
> >     during removing from rmap;
> >   - differentiate page_mapped() from page_mapcount() for compound pages;
> >   - rework deferred_split_huge_page() to use shrinker interface;
> >   - fix race in page_remove_rmap();
> >   - get rid of __get_page_tail();
> >   - few random bug fixes;
> >v4:
> >   - fix sizes reported in smaps;
> >   - defines instead of enum for RMAP_{EXCLUSIVE,COMPOUND};
> >   - skip THP pages on munlock_vma_pages_range(): they are never mlocked;
> >   - properly handle huge zero page on FOLL_SPLIT;
> >   - fix lock_page() slow path on tail pages;
> >   - account page_get_anon_vma() fail to THP_SPLIT_PAGE_FAILED;
> >   - fix split_huge_page() on huge page with unmapped head page;
> >   - fix transfering 'write' and 'young' from pmd to ptes on split_huge_pmd;
> >   - call page_remove_rmap() in unfreeze_page under ptl.
> >
> >= Design overview =
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
> >In new scheme we use page->_mapcount is used to account how many time
> >the page is mapped with PTEs. We have separate compound_mapcount() to
> >count mappings with PMD. page_mapcount() returns sum of PTE and PMD
> >mappings of the page.
> 
> It would be very beneficial to describe the scheme in full, both before in
> after. The latter goes also for the Documentation patch, where you fixed
> what wasn't true anymore, but I think the picture wasn't complete neither
> before, nor is it now. There's the lwn article [1] which helps a lot, but we
> shouldn't rely on that exclusively.
> 
> So the full scheme should include at least:
> - where were/are pins and mapcounts stored
> - what exactly get_page()/put_page() did/does now
> - etc.
> 
> [1] https://lwn.net/Articles/619738/

Okay. Will do.
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
