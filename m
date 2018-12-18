Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5F68E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 08:52:00 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b7so12626750eda.10
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 05:52:00 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id p10si2552321eds.243.2018.12.18.05.51.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 05:51:59 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 967611C2743
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 13:51:58 +0000 (GMT)
Date: Tue, 18 Dec 2018 13:51:56 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 09/14] mm, compaction: Ignore the fragmentation avoidance
 boost for isolation and compaction
Message-ID: <20181218135156.GK29005@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-10-mgorman@techsingularity.net>
 <f8aeec16-65de-b873-3362-3c7cb30c4ac6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <f8aeec16-65de-b873-3362-3c7cb30c4ac6@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Tue, Dec 18, 2018 at 01:36:42PM +0100, Vlastimil Babka wrote:
> On 12/15/18 12:03 AM, Mel Gorman wrote:
> > When pageblocks get fragmented, watermarks are artifically boosted to pages
> > are reclaimed to avoid further fragmentation events. However, compaction
> > is often either fragmentation-neutral or moving movable pages away from
> > unmovable/reclaimable pages. As the actual watermarks are preserved,
> > allow compaction to ignore the boost factor.
> 
> Right, I should have realized that when reviewing the boost patch. I
> think it would be useful to do the same change in
> __compaction_suitable() as well. Compaction has its own "gap".
> 

That gap is somewhat static though so I'm a bit more wary of it.  However,
the check in __isolate_free_page looks too agressive. We isolate in
units of COMPACT_CLUSTER_MAX yet the watermark check there is based on
the allocation request. That means for THP that we check if 512 pages
can be allocated when only somewhere between 1 and 32 is needed for that
compaction cycle to complete. Adjusting that might be more appropriate?

-- 
Mel Gorman
SUSE Labs
