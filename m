Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6486B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 03:17:15 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id e7so10531975lfe.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:17:15 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id on9si11517059wjc.179.2016.07.28.00.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 00:17:13 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o80so9743882wme.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:17:13 -0700 (PDT)
Date: Thu, 28 Jul 2016 09:17:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
Message-ID: <20160728071711.GB31860@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-2-git-send-email-mhocko@kernel.org>
 <87oa5q5abi.fsf@notabene.neil.brown.name>
 <20160722091558.GF794@dhcp22.suse.cz>
 <878twt5i1j.fsf@notabene.neil.brown.name>
 <20160725083247.GD9401@dhcp22.suse.cz>
 <87lh0n4ufs.fsf@notabene.neil.brown.name>
 <20160727182411.GE21859@dhcp22.suse.cz>
 <87eg6e4vhc.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87eg6e4vhc.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mikulas Patocka <mpatocka@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu 28-07-16 07:33:19, NeilBrown wrote:
> On Thu, Jul 28 2016, Michal Hocko wrote:
> 
> > On Wed 27-07-16 13:43:35, NeilBrown wrote:
> >> On Mon, Jul 25 2016, Michal Hocko wrote:
> >> 
> >> > On Sat 23-07-16 10:12:24, NeilBrown wrote:
> > [...]
> >> So should there be a limit on dirty
> >> pages in the swap cache just like there is for dirty pages in any
> >> filesystem (the max_dirty_ratio thing) ??
> >> Maybe there is?
> >
> > There is no limit AFAIK. We are relying that the reclaim is throttled
> > when necessary.
> 
> Is that a bit indirect?

Yes it is. Dunno, how much of a problem is that, though.

> It is hard to tell without a clear big-picture.
> Something to keep in mind anyway.
> 
> >
> >> I think we'd end up with cleaner code if we removed the cute-hacks.  And
> >> we'd be able to use 6 more GFP flags!!  (though I do wonder if we really
> >> need all those 26).
> >
> > Well, maybe we are able to remove those hacks, I wouldn't definitely
> > be opposed.  But right now I am not even convinced that the mempool
> > specific gfp flags is the right way to go.
> 
> I'm not suggesting a mempool-specific gfp flag.  I'm suggesting a
> transient-allocation gfp flag, which would be quite useful for mempool.
> 
> Can you give more details on why using a gfp flag isn't your first choice
> for guiding what happens when the system is trying to get a free page
> :-?

If we get rid of throttle_vm_writeout then I guess it might turn out to
be unnecessary. There are other places which will still throttle but I
believe those should be kept regardless of who is doing the allocation
because they are helping the LRU scanning sane. I might be wrong here
and bailing out from the reclaim rather than waiting would turn out
better for some users but I would like to see whether the first approach
works reasonably well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
