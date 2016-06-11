Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 153906B0005
	for <linux-mm@kvack.org>; Sat, 11 Jun 2016 15:21:12 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h68so42975042lfh.2
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 12:21:12 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id w135si6201342wme.14.2016.06.11.12.21.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jun 2016 12:21:11 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id n184so5848213wmn.1
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 12:21:10 -0700 (PDT)
Date: Sat, 11 Jun 2016 22:21:06 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [PATCH 0/3] mm, thp: remove duplication and fix locking issues
 in swapin
Message-ID: <20160611192106.GA6662@debian>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
 <20160523172929.GA4406@debian>
 <20160527131247.GM27686@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160527131247.GM27686@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com

On Fri, May 27, 2016 at 03:12:47PM +0200, Michal Hocko wrote:
> On Mon 23-05-16 20:29:29, Ebru Akagunduz wrote:
> > On Mon, May 23, 2016 at 08:14:08PM +0300, Ebru Akagunduz wrote:
> > > This patch series removes duplication of included header
> > > and fixes locking inconsistency in khugepaged swapin
> > > 
> > > Ebru Akagunduz (3):
> > >   mm, thp: remove duplication of included header
> > >   mm, thp: fix possible circular locking dependency caused by
> > >     sum_vm_event()
> > >   mm, thp: make swapin readahead under down_read of mmap_sem
> > > 
> > >  mm/huge_memory.c | 39 ++++++++++++++++++++++++++++++---------
> > >  1 file changed, 30 insertions(+), 9 deletions(-)
> > > 
> > 
> > Hi Andrew,
> > 
> > I prepared this patch series to solve rest of
> > problems of khugepaged swapin.
> > 
> > I have seen the discussion:
> > http://marc.info/?l=linux-mm&m=146373278424897&w=2
> > 
> > In my opinion, checking whether kswapd is wake up
> > could be good.
> 
> This is still not enough because it doesn't help memcg loads. kswapd
> might be sleeping but the memcg reclaim can still be active. So I think
> we really need to do ~__GFP_DIRECT_RECLAIM thing.
> 
> > It's up to you. I can take an action according to community's decision.
> 
> IMHO we should drop the current ALLOCSTALL heuristic and replace it with
> ~__GFP_DIRECT_RECLAIM.
Actually, I don't lean towards to touch do_swap_page giving gfp parameter.
do_swap_page is also used by do_page_fault, it can cause many side effect
that I can't see. 

I've just sent a patch series for converting from optimistic to conservative and take
back allocstall. Maybe that way can be easier to be approved and less problemitical.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
