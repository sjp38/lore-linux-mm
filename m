Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6558E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 15:52:21 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id o27-v6so13200302pfj.6
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 12:52:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g11-v6sor699931plp.62.2018.09.25.12.52.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 12:52:20 -0700 (PDT)
Date: Tue, 25 Sep 2018 12:52:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, thp: always specify ineligible vmas as nh in
 smaps
In-Reply-To: <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
Message-ID: <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com> <e2f159f3-5373-dda4-5904-ed24d029de3c@suse.cz> <alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com> <alpine.DEB.2.21.1809241227370.241621@chino.kir.corp.google.com>
 <20180924195603.GJ18685@dhcp22.suse.cz> <20180924200258.GK18685@dhcp22.suse.cz> <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Mon, 24 Sep 2018, Vlastimil Babka wrote:

> On 9/24/18 10:02 PM, Michal Hocko wrote:
> > On Mon 24-09-18 21:56:03, Michal Hocko wrote:
> >> On Mon 24-09-18 12:30:07, David Rientjes wrote:
> >>> Commit 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
> >>> introduced a regression in that userspace cannot always determine the set
> >>> of vmas where thp is ineligible.
> >>>
> >>> Userspace relies on the "nh" flag being emitted as part of /proc/pid/smaps
> >>> to determine if a vma is eligible to be backed by hugepages.
> >>
> >> I was under impression that nh resp hg flags only tell about the madvise
> >> status. How do you exactly use these flags in an application?
> >>

This is used to identify heap mappings that should be able to fault thp 
but do not, and they normally point to a low-on-memory or fragmentation 
issue.  After commit 1860033237d4, our users of PR_SET_THP_DISABLE no 
longer show "nh" for their heap mappings so they get reported as having a 
low thp ratio when in reality it is disabled.  It is also used in 
automated testing to ensure that vmas get disabled for thp appropriately 
and we used "nh" since that is how PR_SET_THP_DISABLE previously enforced 
this, and those tests now break.

> >> Your eligible rules as defined here:
> >>
> >>> + [*] A process mapping is eligible to be backed by transparent hugepages (thp)
> >>> +     depending on system-wide settings and the mapping itself.  See
> >>> +     Documentation/admin-guide/mm/transhuge.rst for default behavior.  If a
> >>> +     mapping has a flag of "nh", it is not eligible to be backed by hugepages
> >>> +     in any condition, either because of prctl(PR_SET_THP_DISABLE) or
> >>> +     madvise(MADV_NOHUGEPAGE).  PR_SET_THP_DISABLE takes precedence over any
> >>> +     MADV_HUGEPAGE.
> >>
> >> doesn't seem to match the reality. I do not see all the file backed
> >> mappings to be nh marked. So is this really about eligibility rather
> >> than the madvise status? Maybe it is just the above documentation that
> >> needs to be updated.
> 
> Yeah the change from madvise to eligibility in the doc seems to go too far.
> 

I'll reword this to explicitly state that "hg" and "nh" mappings either 
allow or disallow thp backing.
