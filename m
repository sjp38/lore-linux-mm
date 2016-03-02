Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3FEEF828E1
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 07:39:21 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id p65so75905645wmp.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 04:39:21 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id cu9si42846149wjc.53.2016.03.02.04.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 04:39:20 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id p65so9393590wmp.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 04:39:20 -0800 (PST)
Date: Wed, 2 Mar 2016 13:39:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160302123917.GF26686@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160229203502.GW16930@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
 <20160301133846.GF9461@dhcp22.suse.cz>
 <20160302022846.GB22355@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160302022846.GB22355@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 02-03-16 11:28:46, Joonsoo Kim wrote:
> On Tue, Mar 01, 2016 at 02:38:46PM +0100, Michal Hocko wrote:
> > > I'd expect a build in 224M
> > > RAM plus 2G of swap to take so long, that I'd be very grateful to be
> > > OOM killed, even if there is technically enough space.  Unless
> > > perhaps it's some superfast swap that you have?
> > 
> > the swap partition is a standard qcow image stored on my SSD disk. So
> > I guess the IO should be quite fast. This smells like a potential
> > contributor because my reclaim seems to be much faster and that should
> > lead to a more efficient reclaim (in the scanned/reclaimed sense).
> 
> Hmm... This looks like one of potential culprit. If page is in
> writeback, it can't be migrated by compaction with MIGRATE_SYNC_LIGHT.
> In this case, this page works as pinned page and prevent compaction.
> It'd be better to check that changing 'migration_mode = MIGRATE_SYNC' at
> 'no_progress_loops > XXX' will help in this situation.

Would it make sense to use MIGRATE_SYNC for !costly allocations by
default?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
