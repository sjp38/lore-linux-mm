Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id A329B6B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:29:50 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hi2so6628363wib.4
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 09:29:50 -0700 (PDT)
Received: from mail-wg0-x22c.google.com (mail-wg0-x22c.google.com [2a00:1450:400c:c00::22c])
        by mx.google.com with ESMTPS id ev6si21188898wjb.171.2014.09.10.09.29.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 09:29:39 -0700 (PDT)
Received: by mail-wg0-f44.google.com with SMTP id y10so4401139wgg.15
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 09:29:38 -0700 (PDT)
Date: Wed, 10 Sep 2014 18:29:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140910162936.GI25219@dhcp22.suse.cz>
References: <54061505.8020500@sr71.net>
 <5406262F.4050705@intel.com>
 <54062F32.5070504@sr71.net>
 <20140904142721.GB14548@dhcp22.suse.cz>
 <5408CB2E.3080101@sr71.net>
 <20140905092537.GC26243@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140905092537.GC26243@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 05-09-14 11:25:37, Michal Hocko wrote:
> On Thu 04-09-14 13:27:26, Dave Hansen wrote:
> > On 09/04/2014 07:27 AM, Michal Hocko wrote:
> > > Ouch. free_pages_and_swap_cache completely kills the uncharge batching
> > > because it reduces it to PAGEVEC_SIZE batches.
> > > 
> > > I think we really do not need PAGEVEC_SIZE batching anymore. We are
> > > already batching on tlb_gather layer. That one is limited so I think
> > > the below should be safe but I have to think about this some more. There
> > > is a risk of prolonged lru_lock wait times but the number of pages is
> > > limited to 10k and the heavy work is done outside of the lock. If this
> > > is really a problem then we can tear LRU part and the actual
> > > freeing/uncharging into a separate functions in this path.
> > > 
> > > Could you test with this half baked patch, please? I didn't get to test
> > > it myself unfortunately.
> > 
> > 3.16 settled out at about 11.5M faults/sec before the regression.  This
> > patch gets it back up to about 10.5M, which is good.
> 
> Dave, would you be willing to test the following patch as well? I do not
> have a huge machine at hand right now. It would be great if you could

I was playing with 48CPU with 32G of RAM machine but the res_counter
lock didn't show up in the traces much (this was with 96 processes doing
mmap (256M private file, faul, unmap in parallel):
                          |--0.75%-- __res_counter_charge
                          |          res_counter_charge
                          |          try_charge
                          |          mem_cgroup_try_charge
                          |          |          
                          |          |--81.56%-- do_cow_fault
                          |          |          handle_mm_fault
                          |          |          __do_page_fault
                          |          |          do_page_fault
                          |          |          page_fault
[...]
                          |          |          
                          |           --18.44%-- __add_to_page_cache_locked
                          |                     add_to_page_cache_lru
                          |                     mpage_readpages
                          |                     ext4_readpages
                          |                     __do_page_cache_readahead
                          |                     ondemand_readahead
                          |                     page_cache_async_readahead
                          |                     filemap_fault
                          |                     __do_fault
                          |                     do_cow_fault
                          |                     handle_mm_fault
                          |                     __do_page_fault
                          |                     do_page_fault
                          |                     page_fault

Nothing really changed in that regards when I reduced mmap size to 128M
and run with 4*CPUs.

I do not have a bigger machine to play with unfortunately. I think the
patch makes sense on its own. I would really appreciate if you could
give it a try on your machine with !root memcg case to see how much it
helped. I would expect similar results to your previous testing without
the revert and Johannes' patch.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
