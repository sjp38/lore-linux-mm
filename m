Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 865C0900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 09:28:41 -0400 (EDT)
Received: by wgv5 with SMTP id 5so9261241wgv.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 06:28:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gf1si1919770wib.52.2015.06.03.06.28.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Jun 2015 06:28:39 -0700 (PDT)
Date: Wed, 3 Jun 2015 15:28:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/2] mapping_gfp_mask from the page fault path
Message-ID: <20150603132837.GB16201@dhcp22.suse.cz>
References: <1433163603-13229-1-git-send-email-mhocko@suse.cz>
 <20150602132241.26fbbc98be71920da8485b73@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150602132241.26fbbc98be71920da8485b73@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Tue 02-06-15 13:22:41, Andrew Morton wrote:
> On Mon,  1 Jun 2015 15:00:01 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > I somehow forgot about these patches. The previous version was
> > posted here: http://marc.info/?l=linux-mm&m=142668784122763&w=2. The
> > first attempt was broken but even when fixed it seems like ignoring
> > mapping_gfp_mask in page_cache_read is too fragile because
> > filesystems might use locks in their filemap_fault handlers
> > which could trigger recursion problems as pointed out by Dave
> > http://marc.info/?l=linux-mm&m=142682332032293&w=2.
> > 
> > The first patch should be straightforward fix to obey mapping_gfp_mask
> > when allocating for mapping. It can be applied even without the second
> > one.
> 
> I'm not so sure about that.  If only [1/2] is applied then those
> filesystems which are setting mapping_gfp_mask to GFP_NOFS will now
> actually start using GFP_NOFS from within page_cache_read() etc.  The
> weaker allocation mode might cause problems.

They are using the weaker allocation mode in this context already
because page_cache_alloc_cold is obeying mapping gfp mask. So all this
patch does is to make sure that add_to_page_cache_lru gfp_maks is in
sync with other allocations. So I do not see why this would be a
problem. Quite opposite if the function was called from a real GFP_NOFS
context we could deadlock with the current code.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
