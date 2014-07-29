Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id AC6D26B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 19:51:41 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id h18so6295282igc.6
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 16:51:41 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id o10si27977031igh.56.2014.07.29.16.51.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 16:51:41 -0700 (PDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so457810iec.19
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 16:51:40 -0700 (PDT)
Date: Tue, 29 Jul 2014 16:51:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 05/14] mm, compaction: move pageblock checks up from
 isolate_migratepages_range()
In-Reply-To: <20140729232142.GB17685@node.dhcp.inet.fi>
Message-ID: <alpine.DEB.2.02.1407291646590.961@chino.kir.corp.google.com>
References: <1406553101-29326-1-git-send-email-vbabka@suse.cz> <1406553101-29326-6-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1407281709050.8998@chino.kir.corp.google.com> <53D7690D.5070307@suse.cz> <alpine.DEB.2.02.1407291559130.20991@chino.kir.corp.google.com>
 <20140729232142.GB17685@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, 30 Jul 2014, Kirill A. Shutemov wrote:

> > Hmm, I'm confused at how that could be true, could you explain what 
> > memory other than thp can return true for PageTransHuge()?
> 
> PageTransHuge() will be true for any head of compound page if THP is
> enabled compile time: hugetlbfs, slab, whatever.
> 

I was meaning in the context of the patch :)  Since PageLRU is set, that 
discounts slab so we're left with thp or hugetlbfs.  Logically, both 
should have sizes that are >= the size of the pageblock itself so I'm not 
sure why we don't unconditionally align up to pageblock_nr_pages here.  Is 
there a legitimiate configuration where a pageblock will span multiple 
pages of HPAGE_PMD_ORDER?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
