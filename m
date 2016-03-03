Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C8BB56B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 07:33:02 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p65so29624224wmp.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 04:33:02 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id cf5si11147662wjb.6.2016.03.03.04.33.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 04:33:01 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id n186so3836425wmn.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 04:33:01 -0800 (PST)
Date: Thu, 3 Mar 2016 13:32:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160303123258.GE26202@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160229203502.GW16930@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
 <20160301133846.GF9461@dhcp22.suse.cz>
 <alpine.LSU.2.11.1603030039430.23352@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1603030039430.23352@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 03-03-16 01:54:43, Hugh Dickins wrote:
> On Tue, 1 Mar 2016, Michal Hocko wrote:
[...]
> > So I have tried the following:
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 4d99e1f5055c..7364e48cf69a 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1276,6 +1276,9 @@ static unsigned long __compaction_suitable(struct zone *zone, int order,
> >  								alloc_flags))
> >  		return COMPACT_PARTIAL;
> >  
> > +	if (order <= PAGE_ALLOC_COSTLY_ORDER)
> > +		return COMPACT_CONTINUE;
> > +
> 
> I gave that a try just now, but it didn't help me: OOMed much sooner,
> after doing half as much work. 

I do not have an explanation why it would cause oom sooner but this
turned out to be incomplete. There is another wmaark check deeper in the
compaction path. Could you try the one from
http://lkml.kernel.org/r/20160302130022.GG26686@dhcp22.suse.cz

I will try to find a machine with more CPUs and try to reproduce this in
the mean time.

I will also have a look at the data you have collected.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
