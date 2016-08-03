Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 74BC66B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 08:53:29 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id n59so276618991uan.1
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 05:53:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w3si2064434qkc.12.2016.08.03.05.53.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 05:53:28 -0700 (PDT)
Date: Wed, 3 Aug 2016 08:53:25 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
In-Reply-To: <20160728071711.GB31860@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1608030844470.15274@file01.intranet.prod.int.rdu2.redhat.com>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <1468831285-27242-2-git-send-email-mhocko@kernel.org> <87oa5q5abi.fsf@notabene.neil.brown.name> <20160722091558.GF794@dhcp22.suse.cz>
 <878twt5i1j.fsf@notabene.neil.brown.name> <20160725083247.GD9401@dhcp22.suse.cz> <87lh0n4ufs.fsf@notabene.neil.brown.name> <20160727182411.GE21859@dhcp22.suse.cz> <87eg6e4vhc.fsf@notabene.neil.brown.name> <20160728071711.GB31860@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: NeilBrown <neilb@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>



On Thu, 28 Jul 2016, Michal Hocko wrote:

> > >> I think we'd end up with cleaner code if we removed the cute-hacks.  And
> > >> we'd be able to use 6 more GFP flags!!  (though I do wonder if we really
> > >> need all those 26).
> > >
> > > Well, maybe we are able to remove those hacks, I wouldn't definitely
> > > be opposed.  But right now I am not even convinced that the mempool
> > > specific gfp flags is the right way to go.
> > 
> > I'm not suggesting a mempool-specific gfp flag.  I'm suggesting a
> > transient-allocation gfp flag, which would be quite useful for mempool.
> > 
> > Can you give more details on why using a gfp flag isn't your first choice
> > for guiding what happens when the system is trying to get a free page
> > :-?
> 
> If we get rid of throttle_vm_writeout then I guess it might turn out to
> be unnecessary. There are other places which will still throttle but I
> believe those should be kept regardless of who is doing the allocation
> because they are helping the LRU scanning sane. I might be wrong here
> and bailing out from the reclaim rather than waiting would turn out
> better for some users but I would like to see whether the first approach
> works reasonably well.

If we are swapping to a dm-crypt device, the dm-crypt device is congested 
and the underlying block device is not congested, we should not throttle 
mempool allocations made from the dm-crypt workqueue. Not even a little 
bit.

So, I think, mempool_alloc should set PF_NO_THROTTLE (or 
__GFP_NO_THROTTLE).

Mikulas

> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
