Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE008E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:46:05 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id l45so5076738edb.1
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 06:46:05 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id s21si6987419edq.293.2019.01.18.06.46.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 06:46:03 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 75BCE1C33B2
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 14:46:03 +0000 (GMT)
Date: Fri, 18 Jan 2019 14:46:01 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 25/25] mm, compaction: Do not direct compact remote memory
Message-ID: <20190118144601.GS27437@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-26-mgorman@techsingularity.net>
 <84a7b23a-1cb7-b888-4245-6b1e829f472b@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <84a7b23a-1cb7-b888-4245-6b1e829f472b@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Fri, Jan 18, 2019 at 02:51:00PM +0100, Vlastimil Babka wrote:
> On 1/4/19 1:50 PM, Mel Gorman wrote:
> > Remote compaction is expensive and possibly counter-productive. Locality
> > is expected to often have better performance characteristics than remote
> > high-order pages. For small allocations, it's expected that locality is
> > generally required or fallbacks are possible. For larger allocations such
> > as THP, they are forbidden at the time of writing but if __GFP_THISNODE
> > is ever removed, then it would still be preferable to fallback to small
> > local base pages over remote THP in the general case. kcompactd is still
> > woken via kswapd so compaction happens eventually.
> > 
> > While this patch potentially has both positive and negative effects,
> > it is best to avoid the possibility of remote compaction given the cost
> > relative to any potential benefit.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Generally agree with the intent, but what if there's e.g. high-order (but not
> costly) kernel allocation on behalf of user process on cpu belonging to a
> movable node, where the only non-movable node is node 0. It will have to keep
> reclaiming until a large enough page is formed, or wait for kcompactd?

Nnnggghhh, movable nodes. Yes, in such a case it would have to wait for
reclaim or kcompactd which could be problematic. This would have to be
special cased further.

> So maybe do this only for costly orders?
> 

This was written on the basis of the __GFP_THISNODE discussion which is
THP specific so costly didn't come into my thinking. If that ever gets
resurrected properly, this patch can be revisited. It would be trivial to
check if the preferred node is a movable node and allow remote compaction
in such cases but I'm not aiming at any specific problem with this patch
so it's too hand-wavy.

> Also I think compaction_zonelist_suitable() should be also updated, or we might
> be promising the reclaim-compact loop e.g. that we will compact after enough
> reclaim, but then we won't.
> 

True. I think I'll kill this patch as __GFP_THISNODE is now used again
for THP (regardless of how one feels about the subject) and we don't have
good examples where remote compaction for lower-order kernel allocations
is a problem.

-- 
Mel Gorman
SUSE Labs
