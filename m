Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 78FA86B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 08:35:40 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id l4so855826lbv.8
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 05:35:39 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id o7si2814005lbi.59.2014.09.05.05.35.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 05:35:34 -0700 (PDT)
Date: Fri, 5 Sep 2014 08:35:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140905123517.GA21208@cmpxchg.org>
References: <54061505.8020500@sr71.net>
 <5406262F.4050705@intel.com>
 <54062F32.5070504@sr71.net>
 <20140904142721.GB14548@dhcp22.suse.cz>
 <5408CB2E.3080101@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5408CB2E.3080101@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Sep 04, 2014 at 01:27:26PM -0700, Dave Hansen wrote:
> On 09/04/2014 07:27 AM, Michal Hocko wrote:
> > Ouch. free_pages_and_swap_cache completely kills the uncharge batching
> > because it reduces it to PAGEVEC_SIZE batches.
> > 
> > I think we really do not need PAGEVEC_SIZE batching anymore. We are
> > already batching on tlb_gather layer. That one is limited so I think
> > the below should be safe but I have to think about this some more. There
> > is a risk of prolonged lru_lock wait times but the number of pages is
> > limited to 10k and the heavy work is done outside of the lock. If this
> > is really a problem then we can tear LRU part and the actual
> > freeing/uncharging into a separate functions in this path.
> > 
> > Could you test with this half baked patch, please? I didn't get to test
> > it myself unfortunately.
> 
> 3.16 settled out at about 11.5M faults/sec before the regression.  This
> patch gets it back up to about 10.5M, which is good.  The top spinlock
> contention in the kernel is still from the resource counter code via
> mem_cgroup_commit_charge(), though.

Thanks for testing, that looks a lot better.

But commit doesn't touch resource counters - did you mean try_charge()
or uncharge() by any chance?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
