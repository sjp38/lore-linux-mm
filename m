Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 35E496B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 09:37:07 -0500 (EST)
Received: by mail-lb0-f172.google.com with SMTP id sv6so168348416lbb.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 06:37:07 -0800 (PST)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id ul9si32603949lbb.110.2016.01.05.06.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 06:37:05 -0800 (PST)
Received: by mail-lf0-x234.google.com with SMTP id y184so295046767lfc.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 06:37:05 -0800 (PST)
Date: Tue, 5 Jan 2016 16:37:03 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] mm, thp: clear PG_mlocked when last mapping gone
Message-ID: <20160105143702.GB19907@node.shutemov.name>
References: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1451421990-32297-3-git-send-email-kirill.shutemov@linux.intel.com>
 <568B8ECE.7020605@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <568B8ECE.7020605@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Tue, Jan 05, 2016 at 10:37:18AM +0100, Vlastimil Babka wrote:
> On 12/29/2015 09:46 PM, Kirill A. Shutemov wrote:
> >I missed clear_page_mlock() in page_remove_anon_compound_rmap().
> >It usually shouldn't cause any problems since we munlock pages
> >explicitly, but in conjunction with missed munlock in __oom_reap_vmas()
> >it causes problems:
> >  http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com
> >
> >Let's put it in place an mirror behaviour for small pages.
> >
> >NOTE: I'm not entirely sure why we ever need clear_page_mlock() in
> >page_remove_rmap() codepath. It looks redundant to me as we munlock
> >pages anyway. But this is out of scope of the patch.
> 
> Git blame actually quickly points to commit e6c509f854550 which explains it
> :)

Okay, it explains situation somewhat.

The thing which still makes me a bit uncomfortable with the situation is
that we remove PG_mlocked only when the last mapping of the page gone.
It's not necessary the mapping which was VM_LOCKED. It means we can rely
on the clear_page_mlock() inside page_remove_rmap() only when remove all
page mappings at once (like in truncate case).

The clear_page_mlock() also helps hide real mlock leak bugs, like fixed by
patch 1/2: we saliently munlock page when last mapping gone, even if the
VMA was never been mlocked in the first place.

That's kinda suboptimal.

> 
> >
> >The patch can be folded into
> >  "thp: allow mlocked THP again"
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Ack.
> 
> >Reported-by: Sasha Levin <sasha.levin@oracle.com>
> >---
> >  mm/rmap.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> >diff --git a/mm/rmap.c b/mm/rmap.c
> >index 384516fb7495..68af2e32f7ed 100644
> >--- a/mm/rmap.c
> >+++ b/mm/rmap.c
> >@@ -1356,6 +1356,9 @@ static void page_remove_anon_compound_rmap(struct page *page)
> >  		nr = HPAGE_PMD_NR;
> >  	}
> >
> >+	if (unlikely(PageMlocked(page)))
> >+		clear_page_mlock(page);
> >+
> >  	if (nr) {
> >  		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
> >  		deferred_split_huge_page(page);
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
