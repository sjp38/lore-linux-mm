Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id EAD856B0270
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 11:18:59 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so67164252wic.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 08:18:59 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id cl14si1286167wjb.118.2015.09.30.08.18.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Sep 2015 08:18:58 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id AFE7B98899
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 15:18:57 +0000 (UTC)
Date: Wed, 30 Sep 2015 16:18:56 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 12/12] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-ID: <20150930151855.GQ3068@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <20150824123015.GJ12432@techsingularity.net>
 <CAAmzW4NbjqOpDhNKp7POVLZyaoUJa6YU5-B9Xz2b+crkzD25+g@mail.gmail.com>
 <20150909123901.GA12432@techsingularity.net>
 <CAMJBoFORrhY++4PeT1xcvHCU=tyNs4T0uMhoUxrKsru6QC1NWw@mail.gmail.com>
 <560BE934.3030808@suse.cz>
 <CAMJBoFOKGchN7LQny+tsWd-wL0LVyt8NL+7FZE__TvskanFhsg@mail.gmail.com>
 <560BF4F4.9010000@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <560BF4F4.9010000@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Vitaly Wool <vitalywool@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Sep 30, 2015 at 04:43:00PM +0200, Vlastimil Babka wrote:
> >>Does a better job regarding what exactly? It does fix the CMA-specific
> >>issue, but so does this patch - without affecting allocation fastpaths by
> >>making them update another counter. But the issues discussed here are not
> >>related to that CMA problem.
> >
> >Let me disagree. Guaranteeing one suitable high-order page is not
> >enough, so the suggested patch does not work that well for me.
> >Existing broken watermark calculation doesn't work for me either, as
> >opposed to the one with my patch applied. Both solutions are related
> >to the CMA issue but one does make compaction work harder and cause
> >bigger latencies -- why do you think these are not related?
> 
> Well you didn't mention which issues you have with this patch. If you did
> measure bigger latencies and more compaction work, please post the numbers
> and details about the test.
> 

And very broadly watch out for decisions that force more reclaim/compaction
to potentially reduce latency in the future. It's trading definite overhead
now combined with potential reclaim of hot pages to reduce a *possible*
high-order allocation request in the future. It's why I think a series that
keeps more high-order pages free to reduce future high-order allocation
latency needs to be treated with care.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
