Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D07126B0254
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 21:28:33 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 4so45786140pfd.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 18:28:33 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 67si12929000pft.56.2016.03.01.18.28.32
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 18:28:33 -0800 (PST)
Date: Wed, 2 Mar 2016 11:28:46 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160302022846.GB22355@js1304-P5Q-DELUXE>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160229203502.GW16930@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
 <20160301133846.GF9461@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160301133846.GF9461@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 01, 2016 at 02:38:46PM +0100, Michal Hocko wrote:
> > I'd expect a build in 224M
> > RAM plus 2G of swap to take so long, that I'd be very grateful to be
> > OOM killed, even if there is technically enough space.  Unless
> > perhaps it's some superfast swap that you have?
> 
> the swap partition is a standard qcow image stored on my SSD disk. So
> I guess the IO should be quite fast. This smells like a potential
> contributor because my reclaim seems to be much faster and that should
> lead to a more efficient reclaim (in the scanned/reclaimed sense).

Hmm... This looks like one of potential culprit. If page is in
writeback, it can't be migrated by compaction with MIGRATE_SYNC_LIGHT.
In this case, this page works as pinned page and prevent compaction.
It'd be better to check that changing 'migration_mode = MIGRATE_SYNC' at
'no_progress_loops > XXX' will help in this situation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
