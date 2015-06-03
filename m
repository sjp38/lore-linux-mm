Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5F334900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 09:42:07 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so9576701wgb.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 06:42:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vf7si1307199wjc.127.2015.06.03.06.42.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Jun 2015 06:42:05 -0700 (PDT)
Date: Wed, 3 Jun 2015 15:42:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/2] mapping_gfp_mask from the page fault path
Message-ID: <20150603134204.GC16201@dhcp22.suse.cz>
References: <1433163603-13229-1-git-send-email-mhocko@suse.cz>
 <20150602132241.26fbbc98be71920da8485b73@linux-foundation.org>
 <201506032204.GAI56216.OOSVJHFLOQtMFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506032204.GAI56216.OOSVJHFLOQtMFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, david@fromorbit.com, neilb@suse.de, hannes@cmpxchg.org, viro@zeniv.linux.org.uk, mgorman@suse.de, riel@redhat.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed 03-06-15 22:04:22, Tetsuo Handa wrote:
[...]
> Michal Hocko wrote:
> > Initialize the default to (mapping_gfp_mask | GFP_IOFS) because this
> > should be safe from the page fault path normally. Why do we care
> > about mapping_gfp_mask at all then? Because this doesn't hold only
> > reclaim protection flags but it also might contain zone and movability
> > restrictions (GFP_DMA32, __GFP_MOVABLE and others) so we have to respect
> > those.
> 
> [2/2] says that mapping_gfp_mask(mapping) might contain bits which are not
> in !GFP_KERNEL. If we do
> 
>   GFP_KERNEL & mapping_gfp_mask(mapping)
> 
> we will drop such bits and will cause problems.

No we won't.

> Thus, "GFP_KERNEL"
> in patch [1/1] should be replaced with "mapping_gfp_mask(mapping)" than
> "GFP_KERNEL & mapping_gfp_mask(mapping)" ?

Those gfp_masks are for LRU handling and that is GFP_KERNEL by
default. We only need to drop those which are not compatible with
mapping_gfp_mask. We do not care about __GFP_MOVABLE, GFP_DMA32 etc...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
