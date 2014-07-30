Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 413296B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 05:28:18 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so879895wgh.27
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 02:28:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ei7si25293745wid.32.2014.07.30.02.28.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 02:28:06 -0700 (PDT)
Message-ID: <53D8BA9A.8050008@suse.cz>
Date: Wed, 30 Jul 2014 11:27:54 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v5 05/14] mm, compaction: move pageblock checks up from
 isolate_migratepages_range()
References: <1406553101-29326-1-git-send-email-vbabka@suse.cz> <1406553101-29326-6-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1407281709050.8998@chino.kir.corp.google.com> <53D7690D.5070307@suse.cz> <alpine.DEB.2.02.1407291559130.20991@chino.kir.corp.google.com> <20140729232142.GB17685@node.dhcp.inet.fi> <alpine.DEB.2.02.1407291646590.961@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1407291646590.961@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 07/30/2014 01:51 AM, David Rientjes wrote:
> On Wed, 30 Jul 2014, Kirill A. Shutemov wrote:
>
>>> Hmm, I'm confused at how that could be true, could you explain what
>>> memory other than thp can return true for PageTransHuge()?
>>
>> PageTransHuge() will be true for any head of compound page if THP is
>> enabled compile time: hugetlbfs, slab, whatever.
>>
>
> I was meaning in the context of the patch :)  Since PageLRU is set, that
> discounts slab so we're left with thp or hugetlbfs.  Logically, both
> should have sizes that are >= the size of the pageblock itself so I'm not
> sure why we don't unconditionally align up to pageblock_nr_pages here.  Is
> there a legitimiate configuration where a pageblock will span multiple
> pages of HPAGE_PMD_ORDER?

I think Joonsoo mentioned in some previous iteration that some arches 
may have this. But I have no idea.
But perhaps we could use HPAGE_PMD_ORDER instead of compound_order()?

In the locked case we know that PageLRU could not change so it still has 
to be a huge page so we know it's possible order.

In the !locked case, I'm now not even sure if the current code is safe 
enough. What if we pass the PageLRU check, but before the PageTransHuge 
check a compound page (THP or otherwise) materializes and we are at one 
of the tail pages. Then in DEBUG_VM configuration, this could fire in 
PageTransHuge() check: VM_BUG_ON_PAGE(PageTail(page), page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
