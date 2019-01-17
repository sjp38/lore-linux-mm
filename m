Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B56DC8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:35:16 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so3973301ede.14
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:35:16 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id z4si4608945edz.205.2019.01.17.09.35.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 09:35:15 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id B7D321C2AB4
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 17:35:14 +0000 (GMT)
Date: Thu, 17 Jan 2019 17:35:13 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 16/25] mm, compaction: Check early for huge pages
 encountered by the migration scanner
Message-ID: <20190117173512.GL27437@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-17-mgorman@techsingularity.net>
 <724b7599-8300-15b5-2675-eecab2450f45@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <724b7599-8300-15b5-2675-eecab2450f45@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Thu, Jan 17, 2019 at 06:01:18PM +0100, Vlastimil Babka wrote:
> On 1/4/19 1:50 PM, Mel Gorman wrote:
> > When scanning for sources or targets, PageCompound is checked for huge
> > pages as they can be skipped quickly but it happens relatively late after
> > a lot of setup and checking. This patch short-cuts the check to make it
> > earlier. It might still change when the lock is acquired but this has
> > less overhead overall. The free scanner advances but the migration scanner
> > does not. Typically the free scanner encounters more movable blocks that
> > change state over the lifetime of the system and also tends to scan more
> > aggressively as it's actively filling its portion of the physical address
> > space with data. This could change in the future but for the moment,
> > this worked better in practice and incurred fewer scan restarts.
> > 
> > The impact on latency and allocation success rates is marginal but the
> > free scan rates are reduced by 32% and system CPU usage is reduced by
> > 2.6%. The 2-socket results are not materially different.
> 
> Hmm, interesting that adjusting migrate scanner affected free scanner. Oh well.
> 

Russian Roulette again. The exact scan rates depend on the system state
which are non-deterministic.  It's not until very late in the series that
they stabilise somewhat. In fact, during the development of the series,
I had to reorder patches multiple times when a corner case was dealt with
to avoid 1 in every 3-6 runs having crazy insane scan rates. The final
ordering was based on *relative* stability.

> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Nit below.
> 

Nit fixed.

-- 
Mel Gorman
SUSE Labs
