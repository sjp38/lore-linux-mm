Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 283436B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:24:04 -0400 (EDT)
Received: by wibg7 with SMTP id g7so70797813wib.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:24:03 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id ew17si21947073wid.0.2015.03.25.03.24.02
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 03:24:02 -0700 (PDT)
Date: Wed, 25 Mar 2015 12:23:44 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 05/16] page-flags: define behavior of FS/IO-related flags
 on compound pages
Message-ID: <20150325102344.GA10471@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1426784902-125149-6-git-send-email-kirill.shutemov@linux.intel.com>
 <550B15A0.9090308@intel.com>
 <20150319200252.GA13348@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1503221613280.2680@eggly.anvils>
 <20150323121726.GB30088@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1503241406270.1591@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1503241406270.1591@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>, alsa-devel@alsa-project.org

On Tue, Mar 24, 2015 at 03:54:00PM -0700, Hugh Dickins wrote:
> On Mon, 23 Mar 2015, Kirill A. Shutemov wrote:
> > Should we avoid dirtying them in the first place?
> 
> I don't think so: to do so would add more branches in hot paths,
> just to avoid a rare case which works fine without them; and
> prevent a driver from using it, in the unlikely case that's so.

It's branches vs. useless atomic oprations.

> > GUP pin would screw up page_mapcount() on these pages. It would affect
> > memory stats for the process and probably something else.
> 
> Yes, the GUP pin would increment page_mapcount() without an additional
> mapping - but can only happen once the page has already been mapped,
> so FILE_MAPPED stats unaffected?  I'm not sure; but surely it wouldn't
> work as well when unmapped before unpinned, since the unmapping will
> see "still mapped" and the unpinning won't do anything with FILE_MAPPED.
> 
> Unmapping before unpinning is an uncommon path; but it can't be ignored,
> it is the path which demanded __GFP_COMP in the first place.
> 
> Looks like extending THP by-mapcount refcounting to other compound pages
> was not such a good idea.  But since nobody has noticed, we may not need
> a more urgent fix than your simplification of THP refcounting.

I think PSS and /proc/kpagecount are broken by this.

> > I think we can get __compound_tail_refcounted() ignore these pages by
> > checking if page->mapping is NULL.
> 
> I forget what's in page->mapping on the THP tails.

NULL. We never set ->mapping on any tail pages. That's why I want outlaw
using that value: it's just doesn't match with head page ->mapping for
some of compound pages. And for others it matches just because nobody
touches it for any subpage.

> Or do you mean page->mapping of head?  It would be better not to rely on
> that, I'm not certain that no driver could set page->mapping of compound
> head.  There's probably some field or flag on the tails that you could
> use; but I don't know that it's needed in a hurry.

We only need tail refcounting for THP, so I think this should fix the issue:

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4a3a38522ab4..9ab432660adb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -456,7 +456,7 @@ static inline int page_count(struct page *page)
 
 static inline bool __compound_tail_refcounted(struct page *page)
 {
-       return !PageSlab(page) && !PageHeadHuge(page);
+       return !PageSlab(page) && !PageHeadHuge(page) && PageAnon(page);
 }
 
 /*

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
