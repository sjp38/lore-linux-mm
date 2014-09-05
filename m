Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4AB6B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 05:25:42 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id m15so11342751wgh.23
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 02:25:41 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id hj19si2169361wib.36.2014.09.05.02.25.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 02:25:40 -0700 (PDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so461819wiv.2
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 02:25:40 -0700 (PDT)
Date: Fri, 5 Sep 2014 11:25:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140905092537.GC26243@dhcp22.suse.cz>
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
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 04-09-14 13:27:26, Dave Hansen wrote:
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
> patch gets it back up to about 10.5M, which is good.

Dave, would you be willing to test the following patch as well? I do not
have a huge machine at hand right now. It would be great if you could
run the same load within a !root memcg. We have basically the same
sub-optimality there as well. The root bypass will be re-introduced for
now but I think we can make the regular memcg load better regardless and
this would be also preparation for later root bypass removal again.
---
