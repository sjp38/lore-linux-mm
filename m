Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 018076B0261
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 12:27:01 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so8069397wmf.3
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 09:27:00 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id aj4si34912585wjd.196.2016.12.09.09.26.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 09:26:59 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 3E75B1C2C59
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 17:26:59 +0000 (GMT)
Date: Fri, 9 Dec 2016 17:26:58 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] mm, page_alloc: don't convert pfn to idx when merging
Message-ID: <20161209172658.uebsgt5ju6gtz2bu@techsingularity.net>
References: <20161209093754.3515-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161209093754.3515-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Dec 09, 2016 at 10:37:53AM +0100, Vlastimil Babka wrote:
> In __free_one_page() we do the buddy merging arithmetics on "page/buddy index",
> which is just the lower MAX_ORDER bits of pfn. The operations we do that affect
> the higher bits are bitwise AND and subtraction (in that order), where the
> final result will be the same with the higher bits left unmasked, as long as
> these bits are equal for both buddies - which must be true by the definition of
> a buddy.

Ok, other than the kbuild warning, both patchs look ok. I expect the
benefit is marginal but every little bit helps.

> 
> We can therefore use pfn's directly instead of "index" and skip the zeroing of
> >MAX_ORDER bits. This can help a bit by itself, although compiler might be
> smart enough already. It also helps the next patch to avoid page_to_pfn() for
> memory hole checks.
> 

I expect this benefit only applies to a few archiectures and won't be
visible on x86 but it still makes sense so for both patches;

Acked-by: Mel Gorman <mgorman@techsingularity.net>

As a slight aside, I recently spotted that one of the largest overhead
in the bulk free path was in the page_is_buddy() checks so pretty much
anything that helps that is welcome.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
