Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2958E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 16:30:24 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z18-v6so13404701pfe.19
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 13:30:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g16-v6sor2896037pgg.427.2018.09.11.13.30.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Sep 2018 13:30:22 -0700 (PDT)
Date: Tue, 11 Sep 2018 13:30:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
In-Reply-To: <20180911115613.GR10951@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1809111319060.189563@chino.kir.corp.google.com>
References: <20180907130550.11885-1-mhocko@kernel.org> <alpine.DEB.2.21.1809101253080.177111@chino.kir.corp.google.com> <20180911115613.GR10951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stefan Priebe <s.priebe@profihost.ag>

On Tue, 11 Sep 2018, Michal Hocko wrote:

> > That's not entirely true, the remote access latency for remote thp on all 
> > of our platforms is greater than local small pages, this is especially 
> > true for remote thp that is allocated intersocket and must be accessed 
> > through the interconnect.
> > 
> > Our users of MADV_HUGEPAGE are ok with assuming the burden of increased 
> > allocation latency, but certainly not remote access latency.  There are 
> > users who remap their text segment onto transparent hugepages are fine 
> > with startup delay if they are access all of their text from local thp.  
> > Remote thp would be a significant performance degradation.
> 
> Well, it seems that expectations differ for users. It seems that kvm
> users do not really agree with your interpretation.
> 

If kvm is happy to allocate hugepages remotely, at least on a subset of 
platforms where it doesn't incur such a high remote access latency, then 
we probably shouldn't be adding lumping that together with the current 
semantics of MADV_HUGEPAGE.  Otherwise, we risk it becoming a dumping 
ground where current users may regress because they would be much more 
willing to fault local pages of the native page size and lose the ability 
to require that absent using mbind() -- and in that case they would be 
affected by the policy decision of native page sizes as well.

> > When Andrea brought this up, I suggested that the full solution would be a 
> > MPOL_F_HUGEPAGE flag that could define thp allocation policy -- the added 
> > benefit is that we could replace the thp "defrag" mode default by setting 
> > this as part of default_policy.  Right now, MADV_HUGEPAGE users are 
> > concerned about (1) getting thp when system-wide it is not default and (2) 
> > additional fault latency when direct compaction is not default.  They are 
> > not anticipating the degradation of remote access latency, so overloading 
> > the meaning of the mode is probably not a good idea.
> 
> hugepage specific MPOL flags sounds like yet another step into even more
> cluttered API and semantic, I am afraid. Why should this be any
> different from regular page allocations? You are getting off-node memory
> once your local node is full. You have to use an explicit binding to
> disallow that. THP should be similar in that regards. Once you have said
> that you _really_ want THP then you are closer to what we do for regular
> pages IMHO.
> 

Saying that we really want THP isn't an all-or-nothing decision.  We 
certainly want to try hard to fault hugepages locally especially at task 
startup when remapping our .text segment to thp, and MADV_HUGEPAGE works 
very well for that.  Remote hugepages would be a regression that we now 
have no way to avoid because the kernel doesn't provide for it, if we were 
to remove __GFP_THISNODE that this patch introduces.

On Broadwell, for example, we find 7% slower access to remote hugepages 
than local native pages.  On Naples, that becomes worse: 14% slower access 
latency for intrasocket hugepages compared to local native pages and 39% 
slower for intersocket.

> I do realize that this is a gray zone because nobody bothered to define
> the semantic since the MADV_HUGEPAGE has been introduced (a826e422420b4
> is exceptionaly short of information). So we are left with more or less
> undefined behavior and define it properly now. As we can see this might
> regress in some workloads but I strongly suspect that an explicit
> binding sounds more logical approach than a thp specific mpol mode. If
> anything this should be a more generic memory policy basically saying
> that a zone/node reclaim mode should be enabled for the particular
> allocation.

This would be quite a serious regression with no way to actually define 
that we want local hugepages but allow fallback to remote native pages if 
we cannot allocate local native pages.  So rather than causing userspace 
to regress and give them no alternative, I would suggest either hugepage 
specific mempolicies or another madvise mode to allow remotely allocated 
hugepages.
