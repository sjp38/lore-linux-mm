Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 23C376B0005
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 05:25:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t7-v6so1644514edh.20
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 02:25:16 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id f12-v6si462830edq.89.2018.08.16.02.25.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 02:25:14 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 6D2111C2F22
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 10:25:14 +0100 (IST)
Date: Thu, 16 Aug 2018 10:25:08 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: actually ignore mempolicies for high
 priority allocations
Message-ID: <20180816092507.GA1719@techsingularity.net>
References: <20180612122624.8045-1-vbabka@suse.cz>
 <20180815151652.05d4c4684b7dff2282b5c046@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180815151652.05d4c4684b7dff2282b5c046@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Wed, Aug 15, 2018 at 03:16:52PM -0700, Andrew Morton wrote:
> From: Vlastimil Babka <vbabka@suse.cz>
> Subject: mm, page_alloc: actually ignore mempolicies for high priority allocations
> 
> The __alloc_pages_slowpath() function has for a long time contained code
> to ignore node restrictions from memory policies for high priority
> allocations.  The current code that resets the zonelist iterator however
> does effectively nothing after commit 7810e6781e0f ("mm, page_alloc: do
> not break __GFP_THISNODE by zonelist reset") removed a buggy zonelist
> reset.  Even before that commit, mempolicy restrictions were still not
> ignored, as they are passed in ac->nodemask which is untouched by the
> code.
> 
> We can either remove the code, or make it work as intended.  Since
> ac->nodemask can be set from task's mempolicy via alloc_pages_current()
> and thus also alloc_pages(), it may indeed affect kernel allocations, and
> it makes sense to ignore it to allow progress for high priority
> allocations.
> 
> Thus, this patch resets ac->nodemask to NULL in such cases.  This assumes
> all callers can handle it (i.e.  there are no guarantees as in the case of
> __GFP_THISNODE) which seems to be the case.  The same assumption is
> already present in check_retry_cpuset() for some time.
> 
> The expected effect is that high priority kernel allocations in the
> context of userspace tasks (e.g.  OOM victims) restricted by mempolicies
> will have higher chance to succeed if they are restricted to nodes with
> depleted memory, while there are other nodes with free memory left.
> 
> 
> Ot's not a new intention, but for the first time the code will match the
> intention, AFAICS.  It was intended by commit 183f6371aac2 ("mm: ignore
> mempolicies when using ALLOC_NO_WATERMARK") in v3.6 but I think it never
> really worked, as mempolicy restriction was already encoded in nodemask,
> not zonelist, at that time.
> 
> So originally that was for ALLOC_NO_WATERMARK only.  Then it was adjusted
> by e46e7b77c909 ("mm, page_alloc: recalculate the preferred zoneref if the
> context can ignore memory policies") and cd04ae1e2dc8 ("mm, oom: do not
> rely on TIF_MEMDIE for memory reserves access") to the current state.  So
> even GFP_ATOMIC would now ignore mempolicies after the initial attempts
> fail - if the code worked as people thought it does.
> 
> Link: http://lkml.kernel.org/r/20180612122624.8045-1-vbabka@suse.cz
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

FWIW, I thought I acked this already.

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs
