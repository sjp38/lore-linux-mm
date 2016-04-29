Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7ED6B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:41:54 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so85274624lfc.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:41:54 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id a141si3170471wmd.7.2016.04.29.02.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 02:41:53 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id n129so20364045wmn.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:41:53 -0700 (PDT)
Date: Fri, 29 Apr 2016 11:41:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 04/20] arm: get rid of superfluous __GFP_REPEAT
Message-ID: <20160429094152.GF21977@dhcp22.suse.cz>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
 <1461849846-27209-5-git-send-email-mhocko@kernel.org>
 <20160428145545.GN19428@n2100.arm.linux.org.uk>
 <20160428150831.GK31489@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160428150831.GK31489@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org

On Thu 28-04-16 17:08:31, Michal Hocko wrote:
> On Thu 28-04-16 15:55:45, Russell King - ARM Linux wrote:
> > On Thu, Apr 28, 2016 at 03:23:50PM +0200, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > __GFP_REPEAT has a rather weak semantic but since it has been introduced
> > > around 2.6.12 it has been ignored for low order allocations.
> > > 
> > > PGALLOC_GFP uses __GFP_REPEAT but none of the allocation which uses
> > > this flag is for more than order-2. This means that this flag has never
> > > been actually useful here because it has always been used only for
> > > PAGE_ALLOC_COSTLY requests.
> > 
> > I'm unconvinced.  Back in 2013, I was seeing a lot of failures, so:
> > 
> > commit 8c65da6dc89ccb605d73773b1dd617e72982d971
> > Author: Russell King <rmk+kernel@arm.linux.org.uk>
> > Date:   Sat Nov 30 12:52:31 2013 +0000
> > 
> >     ARM: pgd allocation: retry on failure
> > 
> >     Make pgd allocation retry on failure; we really need this to succeed
> >     otherwise fork() can trigger OOMs.
> > 
> >     Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> > 
> > Maybe something has changed again in the MM layer which makes this flag
> > unnecessary again, and it was a temporary blip around that time, I don't
> > know.
> 
> PAGE_ALLOC_COSTLY_ORDER is defined to order 3 since 2007 and even before
> the code was doing
> -               if ((order <= 3) || (gfp_mask & __GFP_REPEAT))
> +               if ((order <= PAGE_ALLOC_COSTLY_ORDER) ||
> +                                               (gfp_mask & __GFP_REPEAT))
>                         do_retry = 1;
> 
> So an order-2 allocation which is the case for this particular code now
> will trigger the OOM killer and fail only when the current task is
> killed by the OOM killer. Other than that order-2 is basically
> GFP_NOFAIL. Have a look at __alloc_pages_slowpath() for more details.

Does this explanation help?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
