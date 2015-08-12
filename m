Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 13B4D6B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 10:48:00 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so32883482wib.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 07:47:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ic1si10963828wid.77.2015.08.12.07.47.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Aug 2015 07:47:57 -0700 (PDT)
Subject: Re: page-flags behavior on compound pages: a worry
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1426784902-125149-5-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1508052001350.6404@eggly.anvils>
 <20150806153259.GA2834@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1508061121120.7500@eggly.anvils>
 <20150812143509.GA12320@node.dhcp.inet.fi>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55CB5C99.9050505@suse.cz>
Date: Wed, 12 Aug 2015 16:47:53 +0200
MIME-Version: 1.0
In-Reply-To: <20150812143509.GA12320@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/12/2015 04:35 PM, Kirill A. Shutemov wrote:
> On Thu, Aug 06, 2015 at 12:24:22PM -0700, Hugh Dickins wrote:
>>> IIUC, the only potentially problematic callsites left are physical memory
>>> scanners. This code requires audit. I'll do that.
>>
>> Please.
>
> I haven't finished the exercise yet. But here's an issue I believe present
> in current *Linus* tree:
>
>  From e78eec7d7a8c4cba8b5952a997973f7741e704f4 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Wed, 12 Aug 2015 17:09:16 +0300
> Subject: [PATCH] mm: fix potential race in isolate_migratepages_block()
>
> Hugh has pointed that compound_head() call can be unsafe in some context.
> There's one example:
>
> 	CPU0					CPU1
>
> isolate_migratepages_block()
>    page_count()
>      compound_head()
>        !!PageTail() == true
> 					put_page()
> 					  tail->first_page = NULL
>        head = tail->first_page
> 					alloc_pages(__GFP_COMP)
> 					   prep_compound_page()
> 					     tail->first_page = head
> 					     __SetPageTail(p);
>        !!PageTail() == true
>      <head == NULL dereferencing>
>
> The race is pure theoretical. I don't it's possible to trigger it in
> practice. But who knows.

It's even less probable thanks to the fact that before this check we 
determined it's a PageLRU (and thus !PageTail).

>
> This can be fixed by avoiding compound_head() in unsafe context.

This is OK because if page becomes tail and we read zero page count, 
it's not fatal.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Fixes: 119d6d59dc ("mm, compaction: avoid isolating pinned pages")

Potentially stable 3.15+ if theoretical races qualify. They don't per 
stable rules, but we seem to be bending that a lot anyway.

> Cc: Hugh Dickins <hughd@google.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/compaction.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 86f04e556f96..bec727b700d3 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -787,7 +787,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>   		 * admittedly racy check.
>   		 */
>   		if (!page_mapping(page) &&
> -		    page_count(page) > page_mapcount(page))
> +		    atomic_read(&page->_count) > page_mapcount(page))
>   			continue;
>
>   		/* If we already hold the lock, we can skip some rechecking */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
