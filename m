Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A483C8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 07:56:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id q29-v6so8565297edd.0
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 04:56:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s58-v6si247737edm.70.2018.09.11.04.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 04:56:17 -0700 (PDT)
Date: Tue, 11 Sep 2018 13:56:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180911115613.GR10951@dhcp22.suse.cz>
References: <20180907130550.11885-1-mhocko@kernel.org>
 <alpine.DEB.2.21.1809101253080.177111@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1809101253080.177111@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stefan Priebe <s.priebe@profihost.ag>

On Mon 10-09-18 13:08:34, David Rientjes wrote:
> On Fri, 7 Sep 2018, Michal Hocko wrote:
[...]
> > Fix this by removing __GFP_THISNODE handling from alloc_pages_vma where
> > it doesn't belong and move it to alloc_hugepage_direct_gfpmask where we
> > juggle gfp flags for different allocation modes. The rationale is that
> > __GFP_THISNODE is helpful in relaxed defrag modes because falling back
> > to a different node might be more harmful than the benefit of a large page.
> > If the user really requires THP (e.g. by MADV_HUGEPAGE) then the THP has
> > a higher priority than local NUMA placement.
> > 
> 
> That's not entirely true, the remote access latency for remote thp on all 
> of our platforms is greater than local small pages, this is especially 
> true for remote thp that is allocated intersocket and must be accessed 
> through the interconnect.
> 
> Our users of MADV_HUGEPAGE are ok with assuming the burden of increased 
> allocation latency, but certainly not remote access latency.  There are 
> users who remap their text segment onto transparent hugepages are fine 
> with startup delay if they are access all of their text from local thp.  
> Remote thp would be a significant performance degradation.

Well, it seems that expectations differ for users. It seems that kvm
users do not really agree with your interpretation.

> When Andrea brought this up, I suggested that the full solution would be a 
> MPOL_F_HUGEPAGE flag that could define thp allocation policy -- the added 
> benefit is that we could replace the thp "defrag" mode default by setting 
> this as part of default_policy.  Right now, MADV_HUGEPAGE users are 
> concerned about (1) getting thp when system-wide it is not default and (2) 
> additional fault latency when direct compaction is not default.  They are 
> not anticipating the degradation of remote access latency, so overloading 
> the meaning of the mode is probably not a good idea.

hugepage specific MPOL flags sounds like yet another step into even more
cluttered API and semantic, I am afraid. Why should this be any
different from regular page allocations? You are getting off-node memory
once your local node is full. You have to use an explicit binding to
disallow that. THP should be similar in that regards. Once you have said
that you _really_ want THP then you are closer to what we do for regular
pages IMHO.

I do realize that this is a gray zone because nobody bothered to define
the semantic since the MADV_HUGEPAGE has been introduced (a826e422420b4
is exceptionaly short of information). So we are left with more or less
undefined behavior and define it properly now. As we can see this might
regress in some workloads but I strongly suspect that an explicit
binding sounds more logical approach than a thp specific mpol mode. If
anything this should be a more generic memory policy basically saying
that a zone/node reclaim mode should be enabled for the particular
allocation.
-- 
Michal Hocko
SUSE Labs
