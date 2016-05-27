Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 75D546B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 09:12:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n2so60924466wma.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 06:12:50 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id g129si12224354wmd.66.2016.05.27.06.12.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 06:12:49 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id e3so14785528wme.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 06:12:49 -0700 (PDT)
Date: Fri, 27 May 2016 15:12:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] mm, thp: remove duplication and fix locking issues
 in swapin
Message-ID: <20160527131247.GM27686@dhcp22.suse.cz>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
 <20160523172929.GA4406@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160523172929.GA4406@debian>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com

On Mon 23-05-16 20:29:29, Ebru Akagunduz wrote:
> On Mon, May 23, 2016 at 08:14:08PM +0300, Ebru Akagunduz wrote:
> > This patch series removes duplication of included header
> > and fixes locking inconsistency in khugepaged swapin
> > 
> > Ebru Akagunduz (3):
> >   mm, thp: remove duplication of included header
> >   mm, thp: fix possible circular locking dependency caused by
> >     sum_vm_event()
> >   mm, thp: make swapin readahead under down_read of mmap_sem
> > 
> >  mm/huge_memory.c | 39 ++++++++++++++++++++++++++++++---------
> >  1 file changed, 30 insertions(+), 9 deletions(-)
> > 
> 
> Hi Andrew,
> 
> I prepared this patch series to solve rest of
> problems of khugepaged swapin.
> 
> I have seen the discussion:
> http://marc.info/?l=linux-mm&m=146373278424897&w=2
> 
> In my opinion, checking whether kswapd is wake up
> could be good.

This is still not enough because it doesn't help memcg loads. kswapd
might be sleeping but the memcg reclaim can still be active. So I think
we really need to do ~__GFP_DIRECT_RECLAIM thing.

> It's up to you. I can take an action according to community's decision.

IMHO we should drop the current ALLOCSTALL heuristic and replace it with
~__GFP_DIRECT_RECLAIM.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
