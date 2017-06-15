Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35F5A6B02F4
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 04:12:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u101so1798084wrc.2
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 01:12:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w16si2899876wrb.325.2017.06.15.01.12.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 01:12:43 -0700 (PDT)
Date: Thu, 15 Jun 2017 10:12:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/4] hugetlb: add support for preferred node to
 alloc_huge_page_nodemask
Message-ID: <20170615081239.GC1486@dhcp22.suse.cz>
References: <20170613090039.14393-1-mhocko@kernel.org>
 <20170613090039.14393-3-mhocko@kernel.org>
 <bd8baf55-8816-452c-5249-904a5f208fb8@oracle.com>
 <3ac3d6a8-b62f-2386-cb04-f32b3bebffe7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ac3d6a8-b62f-2386-cb04-f32b3bebffe7@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 14-06-17 17:12:31, Mike Kravetz wrote:
> On 06/14/2017 03:12 PM, Mike Kravetz wrote:
> > On 06/13/2017 02:00 AM, Michal Hocko wrote:
> >> From: Michal Hocko <mhocko@suse.com>
> >>
> >> alloc_huge_page_nodemask tries to allocate from any numa node in the
> >> allowed node mask starting from lower numa nodes. This might lead to
> >> filling up those low NUMA nodes while others are not used. We can reduce
> >> this risk by introducing a concept of the preferred node similar to what
> >> we have in the regular page allocator. We will start allocating from the
> >> preferred nid and then iterate over all allowed nodes in the zonelist
> >> order until we try them all.
> >>
> >> This is mimicking the page allocator logic except it operates on
> >> per-node mempools. dequeue_huge_page_vma already does this so distill
> >> the zonelist logic into a more generic dequeue_huge_page_nodemask
> >> and use it in alloc_huge_page_nodemask.
> >>
> >> Signed-off-by: Michal Hocko <mhocko@suse.com>
> >> ---
> > 
> > 
> > I built attempts/hugetlb-zonelists, threw it on a test machine, ran the
> > libhugetlbfs test suite and saw failures.  The failures started with this
> > patch: commit 7e8b09f14495 in your tree.  I have not yet started to look
> > into the failures.  It is even possible that the tests are making bad
> > assumptions, but there certainly appears to be changes in behavior visible
> > to the application(s).
> 
> nm.  The failures were the result of dequeue_huge_page_nodemask() always
> returning NULL.  Vlastimil already noticed this issue and provided a
> solution.

I have pushed my current version to the same branch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
