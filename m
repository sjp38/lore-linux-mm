Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05B596B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 14:24:15 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so2107031lfw.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 11:24:14 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id 198si8894927wmi.81.2016.07.27.11.24.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 11:24:13 -0700 (PDT)
Received: by mail-wm0-f41.google.com with SMTP id i5so74753728wmg.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 11:24:13 -0700 (PDT)
Date: Wed, 27 Jul 2016 20:24:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
Message-ID: <20160727182411.GE21859@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-2-git-send-email-mhocko@kernel.org>
 <87oa5q5abi.fsf@notabene.neil.brown.name>
 <20160722091558.GF794@dhcp22.suse.cz>
 <878twt5i1j.fsf@notabene.neil.brown.name>
 <20160725083247.GD9401@dhcp22.suse.cz>
 <87lh0n4ufs.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lh0n4ufs.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mikulas Patocka <mpatocka@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 27-07-16 13:43:35, NeilBrown wrote:
> On Mon, Jul 25 2016, Michal Hocko wrote:
> 
> > On Sat 23-07-16 10:12:24, NeilBrown wrote:
[...]
> >> > My thinking was that throttle_vm_writeout is there to prevent from
> >> > dirtying too many pages from the reclaim the context.  PF_LESS_THROTTLE
> >> > is part of the writeout so throttling it on too many dirty pages is
> >> > questionable (well we get some bias but that is not really reliable). It
> >> > still makes sense to throttle when the backing device is congested
> >> > because the writeout path wouldn't make much progress anyway and we also
> >> > do not want to cycle through LRU lists too quickly in that case.
> >> 
> >> "dirtying ... from the reclaim context" ??? What does that mean?
> >
> > Say you would cause a swapout from the reclaim context. You would
> > effectively dirty that anon page until it gets written down to the
> > storage.
> 
> I should probably figure out how swap really works.  I have vague ideas
> which are probably missing important details...
> Isn't the first step that the page gets moved into the swap-cache - and
> marked dirty I guess.  Then it gets written out and the page is marked
> 'clean'.
> Then further memory pressure might push it out of the cache, or an early
> re-use would pull it back from the cache.
> If so, then "dirtying in reclaim context" could also be described as
> "moving into the swap cache" - yes?

Yes that is basically correct

> So should there be a limit on dirty
> pages in the swap cache just like there is for dirty pages in any
> filesystem (the max_dirty_ratio thing) ??
> Maybe there is?

There is no limit AFAIK. We are relying that the reclaim is throttled
when necessary.
 
> >> The use of PF_LESS_THROTTLE in current_may_throttle() in vmscan.c is to
> >> avoid a live-lock.  A key premise is that nfsd only allocates unbounded
> >> memory when it is writing to the page cache.  So it only needs to be
> >> throttled when the backing device it is writing to is congested.  It is
> >> particularly important that it *doesn't* get throttled just because an
> >> NFS backing device is congested, because nfsd might be trying to clear
> >> that congestion.
> >
> > Thanks for the clarification. IIUC then removing throttle_vm_writeout
> > for the nfsd writeout should be harmless as well, right?
> 
> Certainly shouldn't hurt from the perspective of nfsd.
> 
> >> >> The purpose of that flag is to allow a thread to dirty a page-cache page
> >> >> as part of cleaning another page-cache page.
> >> >> So it makes sense for loop and sometimes for nfsd.  It would make sense
> >> >> for dm-crypt if it was putting the encrypted version in the page cache.
> >> >> But if dm-crypt is just allocating a transient page (which I think it
> >> >> is), then a mempool should be sufficient (and we should make sure it is
> >> >> sufficient) and access to an extra 10% (or whatever) of the page cache
> >> >> isn't justified.
> >> >
> >> > If you think that PF_LESS_THROTTLE (ab)use in mempool_alloc is not
> >> > appropriate then would a PF_MEMPOOL be any better?
> >> 
> >> Why a PF rather than a GFP flag?
> >
> > Well, short answer is that gfp masks are almost depleted.
> 
> Really?  We have 26.
> 
> pagemap has a cute hack to store both GFP flags and other flag bits in
> the one 32 it number per address_space.  'struct address_space' could
> afford an extra 32 number I think.
> 
> radix_tree_root adds 3 'tag' flags to the gfp_mask.
> There is 16bits of free space in radix_tree_node (between 'offset' and
> 'count').  That space on the root node could store a record of which tags
> are set anywhere.  Or would that extra memory de-ref be a killer?

Yes these are reasons why adding new gfp flags is more complicated.

> I think we'd end up with cleaner code if we removed the cute-hacks.  And
> we'd be able to use 6 more GFP flags!!  (though I do wonder if we really
> need all those 26).

Well, maybe we are able to remove those hacks, I wouldn't definitely
be opposed.  But right now I am not even convinced that the mempool
specific gfp flags is the right way to go.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
