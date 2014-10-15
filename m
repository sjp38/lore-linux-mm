Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 358F16B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 16:05:14 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id hi2so13979788wib.3
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 13:05:13 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.197])
        by mx.google.com with ESMTP id az6si7610488wib.91.2014.10.15.13.05.12
        for <linux-mm@kvack.org>;
        Wed, 15 Oct 2014 13:05:12 -0700 (PDT)
Date: Wed, 15 Oct 2014 23:05:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 1/2] mm: free compound page with correct order
Message-ID: <20141015200501.GA17066@node.dhcp.inet.fi>
References: <1413400805-15547-1-git-send-email-yuzhao@google.com>
 <20141015123044.03f38a520b01c5d332e3d9a5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141015123044.03f38a520b01c5d332e3d9a5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yu Zhao <yuzhao@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Wed, Oct 15, 2014 at 12:30:44PM -0700, Andrew Morton wrote:
> > @@ -232,7 +232,7 @@ static unsigned long shrink_huge_zero_page_scan(struct shrinker *shrink,
> >  	if (atomic_cmpxchg(&huge_zero_refcount, 1, 0) == 1) {
> >  		struct page *zero_page = xchg(&huge_zero_page, NULL);
> >  		BUG_ON(zero_page == NULL);
> > -		__free_page(zero_page);
> > +		__free_pages(zero_page, compound_order(zero_page));
> 
> But I'm surprised that this is also rare.  It makes me wonder if this
> code is working correctly.

This should be rare too. To get here we need a situation when huge zero
page is allocated, but not mapped and we get memory presure to trigger
shrinker.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
