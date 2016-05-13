Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED686B025E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 08:06:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w143so8797889wmw.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 05:06:00 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id k4si21853081wjd.240.2016.05.13.05.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 05:05:59 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e201so3282916wme.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 05:05:59 -0700 (PDT)
Date: Fri, 13 May 2016 14:05:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 06/13] mm, thp: remove __GFP_NORETRY from khugepaged and
 madvised allocations
Message-ID: <20160513120558.GL20141@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-7-git-send-email-vbabka@suse.cz>
 <20160512162043.GA4261@dhcp22.suse.cz>
 <57358F03.5080707@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57358F03.5080707@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 13-05-16 10:23:31, Vlastimil Babka wrote:
> On 05/12/2016 06:20 PM, Michal Hocko wrote:
> > On Tue 10-05-16 09:35:56, Vlastimil Babka wrote:
> > [...]
> > > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > > index 570383a41853..0cb09714d960 100644
> > > --- a/include/linux/gfp.h
> > > +++ b/include/linux/gfp.h
> > > @@ -256,8 +256,7 @@ struct vm_area_struct;
> > >   #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
> > >   #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
> > >   #define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
> > > -			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
> > > -			 ~__GFP_RECLAIM)
> > > +			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
> > 
> > I am not sure this is the right thing to do. I think we should keep
> > __GFP_NORETRY and clear it where we want a stronger semantic. This is
> > just too suble that all callsites are doing the right thing.
> 
> That would complicate alloc_hugepage_direct_gfpmask() a bit, but if you
> think it's worth it, I can turn the default around, OK.

Hmm, on the other hand it is true that GFP_TRANSHUGE is clearing both
reclaim flags by default and then overwrites that. This is just too
ugly. Can we make GFP_TRANSHUGE to only define flags we care about and
then tweak those that should go away at the callsites which matter now
that we do not rely on is_thp_gfp_mask?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
