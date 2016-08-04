Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17F3F6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 14:46:13 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id n59so350301839uan.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 11:46:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m22si9089223qta.60.2016.08.04.11.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 11:46:12 -0700 (PDT)
Date: Thu, 4 Aug 2016 14:46:07 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
In-Reply-To: <20160803144229.GD1490@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1608041439420.21662@file01.intranet.prod.int.rdu2.redhat.com>
References: <1468831285-27242-1-git-send-email-mhocko@kernel.org> <1468831285-27242-2-git-send-email-mhocko@kernel.org> <87oa5q5abi.fsf@notabene.neil.brown.name> <20160722091558.GF794@dhcp22.suse.cz> <878twt5i1j.fsf@notabene.neil.brown.name>
 <alpine.LRH.2.02.1607251730280.11852@file01.intranet.prod.int.rdu2.redhat.com> <87invr4tjm.fsf@notabene.neil.brown.name> <alpine.LRH.2.02.1607270948040.1779@file01.intranet.prod.int.rdu2.redhat.com> <20160727184021.GF21859@dhcp22.suse.cz>
 <alpine.LRH.2.02.1608030853430.15274@file01.intranet.prod.int.rdu2.redhat.com> <20160803144229.GD1490@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: NeilBrown <neilb@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>



On Wed, 3 Aug 2016, Michal Hocko wrote:

> > > Even mempool allocations shouldn't allow reclaim to
> > > scan pages too quickly even when LRU lists are full of dirty pages. But
> > > as I've said that would restrict the success rates even under light page
> > > cache load. Throttling on the wait_iff_congested should be quite rare.
> > > 
> > > Anyway do you see an excessive throttling with the patch posted
> > > http://lkml.kernel.org/r/20160725192344.GD2166@dhcp22.suse.cz ? Or from
> > 
> > It didn't have much effect.
> > 
> > Since the patch 4e390b2b2f34b8daaabf2df1df0cf8f798b87ddb (revert of the 
> > limitless mempool allocations), swapping to dm-crypt works in the simple 
> > example.
> 
> OK. Do you see any throttling due to wait_iff_congested?

No, but I've seen occasional stalls of mempool allocations in 
throttle_vm_writeout - but the patch that removed throttle_vm_writeout 
didn't improve overall speed, so the stalls were only minor.

> writeback_wait_iff_congested trace point should help here. If not maybe
> we should start with the above patch and see how it works in practise.
> If the there is still an excessive and unexpected throttling then we
> should move on to a more mempool/block layer users specific solution.

Currently, dm-crypt reports the device congested only if the underlying 
block device is congested.

But as others suggested, dm-crypt should report congested status if is 
clogged due to slow encryption progress - and in that case you should not 
throttle mempool allocations (because such throttling would decrease 
encryption speed even more).

Mikulas

> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
