Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 603586B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 08:38:51 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id f134so26860804lfg.6
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 05:38:51 -0700 (PDT)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id o83si8339613lff.70.2016.10.13.05.38.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 05:38:49 -0700 (PDT)
Received: by mail-lf0-f67.google.com with SMTP id x23so6762596lfi.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 05:38:49 -0700 (PDT)
Date: Thu, 13 Oct 2016 14:38:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: MPOL_BIND on memory only nodes
Message-ID: <20161013123846.GM21678@dhcp22.suse.cz>
References: <57FE0184.6030008@linux.vnet.ibm.com>
 <20161012094337.GH17128@dhcp22.suse.cz>
 <20161012131626.GL17128@dhcp22.suse.cz>
 <20161013102459.GE20573@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161013102459.GE20573@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

On Thu 13-10-16 11:24:59, Mel Gorman wrote:
> On Wed, Oct 12, 2016 at 03:16:27PM +0200, Michal Hocko wrote:
> > On Wed 12-10-16 11:43:37, Michal Hocko wrote:
> > > On Wed 12-10-16 14:55:24, Anshuman Khandual wrote:
> > [...]
> > > > Why we insist on __GFP_THISNODE ?
> > > 
> > > AFAIU __GFP_THISNODE just overrides the given node to the policy
> > > nodemask in case the current node is not part of that node mask. In
> > > other words we are ignoring the given node and use what the policy says. 
> > > I can see how this can be confusing especially when confronting the
> > > documentation:
> > > 
> > >  * __GFP_THISNODE forces the allocation to be satisified from the requested
> > >  *   node with no fallbacks or placement policy enforcements.
> > 
> > You made me think and look into this deeper. I came to the conclusion
> > that this is actually a relict from the past. policy_zonelist is called
> > only from 3 places:
> > - huge_zonelist - never should do __GFP_THISNODE when going this path
> > - alloc_pages_vma - which shouldn't depend on __GFP_THISNODE either
> > - alloc_pages_current - which uses default_policy id __GFP_THISNODE is
> >   used
> > 
> > So AFAICS this is essentially a dead code or I am missing something. Mel
> > do you remember why we needed it in the past?
> 
> I don't recall a specific reason. It was likely due to confusion on my
> part at the time on the exact use of __GFP_THISNODE. The expectation is
> that flag is not used in fault paths or with policies. It's meant to
> enforce node-locality for kernel internal decisions such as the locality
> of slab pages and ensuring that a THP collapse from khugepaged is on the
> same node.

This is my understanding as well. Thanks for double checking. I will
send a proper patch (it will even compile as a bonus point ;).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
