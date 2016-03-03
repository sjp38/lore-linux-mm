Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8499D6B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 15:57:32 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id fl4so21144081pad.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 12:57:32 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id p9si400761pfa.74.2016.03.03.12.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 12:57:31 -0800 (PST)
Received: by mail-pf0-x22e.google.com with SMTP id 63so21329525pfe.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 12:57:31 -0800 (PST)
Date: Thu, 3 Mar 2016 12:57:23 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
In-Reply-To: <20160303123258.GE26202@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1603031244430.24359@eggly.anvils>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <20160203132718.GI6757@dhcp22.suse.cz> <alpine.LSU.2.11.1602241832160.15564@eggly.anvils> <20160229203502.GW16930@dhcp22.suse.cz> <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
 <20160301133846.GF9461@dhcp22.suse.cz> <alpine.LSU.2.11.1603030039430.23352@eggly.anvils> <20160303123258.GE26202@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 3 Mar 2016, Michal Hocko wrote:
> On Thu 03-03-16 01:54:43, Hugh Dickins wrote:
> > On Tue, 1 Mar 2016, Michal Hocko wrote:
> [...]
> > > So I have tried the following:
> > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > index 4d99e1f5055c..7364e48cf69a 100644
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -1276,6 +1276,9 @@ static unsigned long __compaction_suitable(struct zone *zone, int order,
> > >  								alloc_flags))
> > >  		return COMPACT_PARTIAL;
> > >  
> > > +	if (order <= PAGE_ALLOC_COSTLY_ORDER)
> > > +		return COMPACT_CONTINUE;
> > > +
> > 
> > I gave that a try just now, but it didn't help me: OOMed much sooner,
> > after doing half as much work. 

I think I exaggerated: sooner, but not _much_ sooner; and I cannot
see now what I based that estimate of "half as much work" on.

> 
> I do not have an explanation why it would cause oom sooner but this
> turned out to be incomplete. There is another wmaark check deeper in the
> compaction path. Could you try the one from
> http://lkml.kernel.org/r/20160302130022.GG26686@dhcp22.suse.cz

I've now added that in: it corrects the "sooner", but does not make
any difference to the fact of OOMing for me.

Hugh

> 
> I will try to find a machine with more CPUs and try to reproduce this in
> the mean time.
> 
> I will also have a look at the data you have collected.
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
