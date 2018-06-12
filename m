Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B1E756B0275
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 03:46:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g73-v6so6006786wmc.5
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 00:46:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t12-v6si489241edk.129.2018.06.12.00.46.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jun 2018 00:46:49 -0700 (PDT)
Date: Tue, 12 Jun 2018 09:46:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/madvise: allow MADV_DONTNEED to free memory that is
 MLOCK_ONFAULT
Message-ID: <20180612074646.GS13364@dhcp22.suse.cz>
References: <1528484212-7199-1-git-send-email-jbaron@akamai.com>
 <20180611072005.GC13364@dhcp22.suse.cz>
 <4c4de46d-c55a-99a8-469f-e1e634fb8525@akamai.com>
 <20180611150330.GQ13364@dhcp22.suse.cz>
 <775adf2d-140c-1460-857f-2de7b24bafe7@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <775adf2d-140c-1460-857f-2de7b24bafe7@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Baron <jbaron@akamai.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org, emunson@mgebm.net

On Mon 11-06-18 12:23:58, Jason Baron wrote:
> On 06/11/2018 11:03 AM, Michal Hocko wrote:
> > So can we start discussing whether we want to allow MADV_DONTNEED on
> > mlocked areas and what downsides it might have? Sure it would turn the
> > strong mlock guarantee to have the whole vma resident but is this
> > acceptable for something that is an explicit request from the owner of
> > the memory?
> > 
> 
> If its being explicity requested by the owner it makes sense to me. I
> guess there could be a concern about this breaking some userspace that
> relied on MADV_DONTNEED not freeing locked memory?

Yes, this is always the fear when changing user visible behavior.  I can
imagine that a userspace allocator calling MADV_DONTNEED on free could
break. The same would apply to MLOCK_ONFAULT/MCL_ONFAULT though. We
have the new flag much shorter so the probability is smaller but the
problem is very same. So I _think_ we should treat both the same because
semantically they are indistinguishable from the MADV_DONTNEED POV. Both
remove faulted and mlocked pages. Mlock, once applied, should guarantee
no later major fault and MADV_DONTNEED breaks that obviously.

So the more I think about it the more I am worried about this but I am
more and more convinced that making ONFAULT special is just a wrong way
around this.
-- 
Michal Hocko
SUSE Labs
