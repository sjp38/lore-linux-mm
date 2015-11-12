Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 34FBF6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 15:47:48 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so75681329pab.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 12:47:47 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id qd4si22068554pac.42.2015.11.12.12.47.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 12:47:47 -0800 (PST)
Received: by padhx2 with SMTP id hx2so75625402pad.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 12:47:47 -0800 (PST)
Date: Thu, 12 Nov 2015 12:47:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: get rid of __alloc_pages_high_priority
In-Reply-To: <1447343618-19696-1-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1511121245430.10324@chino.kir.corp.google.com>
References: <1447343618-19696-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, 12 Nov 2015, mhocko@kernel.org wrote:

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
> ---
> 
> Hi,
> I think that this is more a cleanup than any functional change. We
> are rarely screwed so much that __alloc_pages_high_priority would
> fail. Yet I think that __alloc_pages_high_priority is obscuring the
> overal intention more than it is helpful. Another motivation is to
> reduce wait_iff_congested call to a single one in the allocator. I plan
> to do other changes in that area and get rid of it altogether.

I think it's a combination of a cleanup (the inlining of 
__alloc_pages_high_priority) and a functional change (no longer looping 
infinitely around a get_page_from_freelist() call).  I'd suggest doing the 
inlining in one patch and then the reworking of __GFP_NOFAIL when 
ALLOC_NO_WATERMARKS fails just so we could easily revert the latter if 
necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
