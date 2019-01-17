Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97BC28E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:37:44 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b3so3991777edi.0
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:37:44 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id p26-v6si774403eji.30.2019.01.17.09.37.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 09:37:43 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id CBF161C3047
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 17:37:42 +0000 (GMT)
Date: Thu, 17 Jan 2019 17:37:41 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 17/25] mm, compaction: Keep cached migration PFNs synced
 for unusable pageblocks
Message-ID: <20190117173741.GM27437@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-18-mgorman@techsingularity.net>
 <2e384ff6-a4fd-5047-428d-b90cfa95be2e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2e384ff6-a4fd-5047-428d-b90cfa95be2e@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Thu, Jan 17, 2019 at 06:17:28PM +0100, Vlastimil Babka wrote:
> On 1/4/19 1:50 PM, Mel Gorman wrote:
> > Migrate has separate cached PFNs for ASYNC and SYNC* migration on the
> > basis that some migrations will fail in ASYNC mode. However, if the cached
> > PFNs match at the start of scanning and pageblocks are skipped due to
> > having no isolation candidates, then the sync state does not matter.
> > This patch keeps matching cached PFNs in sync until a pageblock with
> > isolation candidates is found.
> > 
> > The actual benefit is marginal given that the sync scanner following the
> > async scanner will often skip a number of pageblocks but it's useless
> > work. Any benefit depends heavily on whether the scanners restarted
> > recently so overall the reduction in scan rates is a mere 2.8% which
> > is borderline noise.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> My easlier suggestion to check more thoroughly if pages can be migrated (which
> depends on the mode) before isolating them wouldn't play nice with this :)
> 

No, unfortunately it wouldn't. I did find though that sync_light often
ran very quickly after async when compaction was having trouble
succeeding. The time window was short enough that states like
Dirty/Writeback were highly unlikely to be cleared. It might have played
nice when fragmentation was very low but any benefit then would be very
difficult to detect.

-- 
Mel Gorman
SUSE Labs
