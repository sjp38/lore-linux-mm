Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 66C7D6B0263
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:25:04 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id x79so46334966lff.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:25:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s5si16776726wjs.169.2016.10.13.03.25.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 03:25:03 -0700 (PDT)
Date: Thu, 13 Oct 2016 11:24:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: MPOL_BIND on memory only nodes
Message-ID: <20161013102459.GE20573@suse.de>
References: <57FE0184.6030008@linux.vnet.ibm.com>
 <20161012094337.GH17128@dhcp22.suse.cz>
 <20161012131626.GL17128@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161012131626.GL17128@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

On Wed, Oct 12, 2016 at 03:16:27PM +0200, Michal Hocko wrote:
> On Wed 12-10-16 11:43:37, Michal Hocko wrote:
> > On Wed 12-10-16 14:55:24, Anshuman Khandual wrote:
> [...]
> > > Why we insist on __GFP_THISNODE ?
> > 
> > AFAIU __GFP_THISNODE just overrides the given node to the policy
> > nodemask in case the current node is not part of that node mask. In
> > other words we are ignoring the given node and use what the policy says. 
> > I can see how this can be confusing especially when confronting the
> > documentation:
> > 
> >  * __GFP_THISNODE forces the allocation to be satisified from the requested
> >  *   node with no fallbacks or placement policy enforcements.
> 
> You made me think and look into this deeper. I came to the conclusion
> that this is actually a relict from the past. policy_zonelist is called
> only from 3 places:
> - huge_zonelist - never should do __GFP_THISNODE when going this path
> - alloc_pages_vma - which shouldn't depend on __GFP_THISNODE either
> - alloc_pages_current - which uses default_policy id __GFP_THISNODE is
>   used
> 
> So AFAICS this is essentially a dead code or I am missing something. Mel
> do you remember why we needed it in the past?

I don't recall a specific reason. It was likely due to confusion on my
part at the time on the exact use of __GFP_THISNODE. The expectation is
that flag is not used in fault paths or with policies. It's meant to
enforce node-locality for kernel internal decisions such as the locality
of slab pages and ensuring that a THP collapse from khugepaged is on the
same node.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
