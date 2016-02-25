Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 55EEA6B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:07:26 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id g62so41378540wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 11:07:26 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id n5si5654892wma.70.2016.02.25.11.07.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Feb 2016 11:07:25 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id CAA7D99138
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 19:07:24 +0000 (UTC)
Date: Thu, 25 Feb 2016 19:07:23 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
Message-ID: <20160225190723.GY2854@techsingularity.net>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
 <1456425170.15821.77.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1456425170.15821.77.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 25, 2016 at 01:32:50PM -0500, Rik van Riel wrote:
> On Thu, 2016-02-25 at 17:12 +0000, Mel Gorman wrote:
> 
> > THP gives impressive gains in some cases but only if they are quickly
> > available.  We're not going to reach the point where they are
> > completely
> > free so lets take the costs out of the fast paths finally and defer
> > the
> > cost to kswapd, kcompactd and khugepaged where it belongs.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> I agree with your conclusions, but with the caveat
> that if we do not try to defragment memory for THP
> at fault time, mlocked programs might not have any
> opportunity at all to get transparent huge pages.
> 
> I wonder if we should consider mlock one of the slow
> paths where we should try to actually take the time
> to create THPs.
> 

It would be a significant rework of mlock because it's not just mlocking
memory, it's doing something similar to khugepaged and actively trying
to collapse pages. I'm not against the idea as such but I'm not sure how
much of a benefit it would be really.

> Also, we might consider doing THP collapse from the
> NUMA page migration opportunistically, if there is a
> free 2MB page available on the destination host.
> 

While not necessarily a bad idea, it goes back to an old problem whereby
there can be false sharing of NUMA pages within a THP boundary. Consider
for example if threads are calculating 4K blocks and then it gets migrated
as a THP including unrelated threads. It's not necessarily a win. We knew
that THP false sharing was a potential problem at the start but never went
much further than acknowleding it's a theoritical issue.

> Having said all that ...
> 
> Acked-by: Rik van Riel <riel@redhat.com>

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
