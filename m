Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id BD4B36B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 18:56:38 -0400 (EDT)
Received: by wixw10 with SMTP id w10so4145002wix.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 15:56:38 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id jd11si25097758wic.14.2015.03.25.15.56.36
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 15:56:37 -0700 (PDT)
Date: Thu, 26 Mar 2015 00:56:33 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: avoid tail page refcounting on non-THP compound pages
Message-ID: <20150325225633.GA14549@node.dhcp.inet.fi>
References: <1427323275-114866-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1503251544120.4490@eggly.anvils>
 <alpine.LSU.2.11.1503251545510.4490@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1503251545510.4490@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 25, 2015 at 03:48:48PM -0700, Hugh Dickins wrote:
> On Wed, 25 Mar 2015, Hugh Dickins wrote:
> > On Thu, 26 Mar 2015, Kirill A. Shutemov wrote:
> > 
> > > THP uses tail page refcounting to be able to split huge page at any
> > > time. Tail page refcounting is not needed for rest users of compound
> > > pages and it's harmful because of overhead.
> > > 
> > > We try to exclude non-THP pages from tail page refcounting using
> > > __compound_tail_refcounted() check. It excludes most common non-THP
> > > compound pages: SL*B and hugetlb, but it doesn't catch rest of
> > > __GFP_COMP users -- drivers.
> > > 
> > > And it's not only about overhead.
> > > 
> > > Drivers might want to use compound pages to get refcounting semantics
> > > suitable for mapping high-order pages to userspace. But tail page
> > > refcounting breaks it.
> > > 
> > > Tail page refcounting uses ->_mapcount in tail pages to store GUP pins
> > > on them. It means GUP pins would affect page_mapcount() for tail pages.
> > > It's not a problem for THP, because it never maps tail pages. But unlike
> > > THP, drivers map parts of compound pages with PTEs and it makes
> > > page_mapcount() be called for tail pages.
> > > 
> > > In particular, GUP pins would shift PSS up and affect /proc/kpagecount
> > > for such pages. But, I'm not aware about anything which can lead to
> > > crash or other serious misbehaviour.
> > > 
> > > Since currently all THP pages are anonymous and all drivers pages are
> > > not, we can fix the __compound_tail_refcounted() check by requiring
> > > PageAnon() to enable tail page refcounting.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > 
> > Acked-by: Hugh Dickins <hughd@google.com>
> 
> Oh, hold on a moment: does this actually build in a tree without your
> page-flags.h consolidation?  It didn't when I tried to add a PageAnon
> test there for my series against v3.19, has something changed in v4.0?

No. I haven't tried to build it without my patchset, but it seems it
wouldn't.

Just check: it would build for me on top of [PATCH 01/16], you've acked.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
