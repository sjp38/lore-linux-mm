Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3BD6B025E
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 07:00:17 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so63001567wma.2
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 04:00:17 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id h132si54055812wmd.145.2016.12.29.04.00.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Dec 2016 04:00:14 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 7D3E91C1E6A
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 12:00:14 +0000 (GMT)
Date: Thu, 29 Dec 2016 12:00:13 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: convert page_group_by_mobility_disable
 to static key
Message-ID: <20161229120013.lscts45z6yec2ecg@techsingularity.net>
References: <20161220134312.17332-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161220134312.17332-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Dec 20, 2016 at 02:43:12PM +0100, Vlastimil Babka wrote:
> The flag is rarely enabled or even changed, so it's an ideal static key
> candidate. Since it's being checked in the page allocator fastpath via
> gfpflags_to_migratetype(), it may actually save some valuable cycles.
> 
> Here's a diff excerpt from __alloc_pages_nodemask() assembly:
> 
>         -movl    page_group_by_mobility_disabled(%rip), %ecx
> 	+.byte 0x0f,0x1f,0x44,0x00,0
>          movl    %r9d, %eax
>          shrl    $3, %eax
>          andl    $3, %eax
>         -testl   %ecx, %ecx
>         -movl    $0, %ecx
>         -cmovne  %ecx, %eax
> 
> I.e. a NOP instead of test, conditional move and some assisting moves.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
