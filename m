Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id DC6BA6B0116
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 18:37:43 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id t60so2982482wes.0
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 15:37:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id p3si38972123wjz.30.2014.06.10.15.37.41
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 15:37:42 -0700 (PDT)
Date: Wed, 11 Jun 2014 00:37:34 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH, RFC 00/10] THP refcounting redesign
Message-ID: <20140610223734.GH19660@redhat.com>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.10.1406101518510.19364@gentwo.org>
 <20140610204640.GA9594@node.dhcp.inet.fi>
 <20140610220451.GG19660@redhat.com>
 <20140610221431.GA10634@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140610221431.GA10634@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Lameter <cl@gentwo.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 11, 2014 at 01:14:31AM +0300, Kirill A. Shutemov wrote:
> On Wed, Jun 11, 2014 at 12:04:51AM +0200, Andrea Arcangeli wrote:
> > On Tue, Jun 10, 2014 at 11:46:40PM +0300, Kirill A. Shutemov wrote:
> > > Agreed. The patchset drops tail page refcounting.
> > 
> > Very possibly I misread something or a later patch fixes this up, I
> > just did a basic code review, but from the new code of split_huge_page
> > it looks like it returns -EBUSY after checking the individual tail
> > page refcounts, so it's not clear how that defines as "dropped".
> 
> page_mapcount() here is really mapcount: how many times the page is
> mapped, not pins on tail pages as we have it now.

Ok then I may suggest to rename the variable from tail_count to
tail_mapcount to make it more self explanatory... of course then it is
compared to the head page count, which means the tail pins have to be
in the head already, but calling it tail_mapcount would be more clear
if you're used to the current semantics of mapcount on tail pages. I
was confused myself what the benefits were... if it didn't drop the
tail page refcounting.

The other suggestions on doing split_huge_page inside split_huge_pmd
(not required to succeed) and fix it up later in khugepaged so the
leak of memory is not permanent, and the accounting issues it creates
with malicious apps sounds like the two things left to address to make
this design change an interesting tradeoff.

> > 
> > +       for (i = 0; i < HPAGE_PMD_NR; i++)
> > +               tail_count += page_mapcount(page + i);
> > +       if (tail_count != page_count(page) - 1) {
> > +               BUG_ON(tail_count > page_count(page) - 1);
> > +               compound_unlock(page);
> > +               spin_unlock_irq(&zone->lru_lock);
> > +               return -EBUSY;
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> 
> -- 
>  Kirill A. Shutemov
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
