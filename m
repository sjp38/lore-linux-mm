Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id D6B3A6B0037
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 05:28:46 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id e4so2618556wiv.8
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 02:28:46 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id s20si2144015wiv.55.2014.09.05.02.28.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 02:28:44 -0700 (PDT)
Received: by mail-wg0-f42.google.com with SMTP id b13so11336884wgh.25
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 02:28:43 -0700 (PDT)
Date: Fri, 5 Sep 2014 11:28:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140905092841.GD26243@dhcp22.suse.cz>
References: <54061505.8020500@sr71.net>
 <5406262F.4050705@intel.com>
 <54062F32.5070504@sr71.net>
 <20140904142721.GB14548@dhcp22.suse.cz>
 <5408CB2E.3080101@sr71.net>
 <5408ED7A.5010908@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5408ED7A.5010908@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave@sr71.net>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 04-09-14 15:53:46, Dave Hansen wrote:
> On 09/04/2014 01:27 PM, Dave Hansen wrote:
> > On 09/04/2014 07:27 AM, Michal Hocko wrote:
> >> Ouch. free_pages_and_swap_cache completely kills the uncharge batching
> >> because it reduces it to PAGEVEC_SIZE batches.
> >>
> >> I think we really do not need PAGEVEC_SIZE batching anymore. We are
> >> already batching on tlb_gather layer. That one is limited so I think
> >> the below should be safe but I have to think about this some more. There
> >> is a risk of prolonged lru_lock wait times but the number of pages is
> >> limited to 10k and the heavy work is done outside of the lock. If this
> >> is really a problem then we can tear LRU part and the actual
> >> freeing/uncharging into a separate functions in this path.
> >>
> >> Could you test with this half baked patch, please? I didn't get to test
> >> it myself unfortunately.
> > 
> > 3.16 settled out at about 11.5M faults/sec before the regression.  This
> > patch gets it back up to about 10.5M, which is good.  The top spinlock
> > contention in the kernel is still from the resource counter code via
> > mem_cgroup_commit_charge(), though.
> > 
> > I'm running Johannes' patch now.
> 
> This looks pretty good.  The area where it plateaus (above 80 threads
> where hyperthreading kicks in) might be a bit slower than it was in
> 3.16, but that could easily be from other things.

Good news indeed. But I think it would be safer to apply Johannes'
revert for now. Both changes are still worth having anyway because they
have potential to improve memcg case.

> > https://www.sr71.net/~dave/intel/bb.html?1=3.16.0-rc4-g67b9d76/&2=3.17.0-rc3-g57b252f
> 
> Feel free to add my Tested-by:

Thanks a lot! I have posted another patch which reduces the batching for
LRU handling because this would be too risky. So I haven't added your
Tested-by yet.
 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
