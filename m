Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3E26B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 05:18:36 -0500 (EST)
Received: by wmww144 with SMTP id w144so22376214wmw.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 02:18:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k197si4601804wmg.106.2015.11.13.02.18.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Nov 2015 02:18:35 -0800 (PST)
Date: Fri, 13 Nov 2015 10:18:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: get rid of __alloc_pages_high_priority
Message-ID: <20151113101831.GF19677@suse.de>
References: <1447343618-19696-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1447343618-19696-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Nov 12, 2015 at 04:53:38PM +0100, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __alloc_pages_high_priority doesn't do anything special other than it
> calls get_page_from_freelist and loops around GFP_NOFAIL allocation
> until it succeeds. It would be better if the first part was done in
> __alloc_pages_slowpath where we modify the zonelist because this would
> be easier to read and understand. And do the retry at the very same
> place because retrying without even attempting to do any reclaim is
> fragile because we are basically relying on somebody else to make the
> reclaim (be it the direct reclaim or OOM killer) for us. The caller
> might be holding resources (e.g. locks) which block other other
> reclaimers from making any progress for example.
> 
> Remove the helper and open code it into its only user. We have to be
> careful about __GFP_NOFAIL allocations from the PF_MEMALLOC context
> even though this is a very bad idea to begin with because no progress
> can be gurateed at all.  We shouldn't break the __GFP_NOFAIL semantic
> here though. It could be argued that this is essentially GFP_NOWAIT
> context which we do not support but PF_MEMALLOC is much harder to check
> for existing users because they might happen deep down the code path
> performed much later after setting the flag so we cannot really rule out
> there is no kernel path triggering this combination.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
