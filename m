Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC638E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 16:30:04 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c25-v6so11217943edb.12
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 13:30:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z16-v6si9537057eda.102.2018.09.25.13.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 13:30:02 -0700 (PDT)
Date: Tue, 25 Sep 2018 22:29:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, thp: always specify ineligible vmas as nh in smaps
Message-ID: <20180925202959.GY18685@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com>
 <e2f159f3-5373-dda4-5904-ed24d029de3c@suse.cz>
 <alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1809241227370.241621@chino.kir.corp.google.com>
 <20180924195603.GJ18685@dhcp22.suse.cz>
 <20180924200258.GK18685@dhcp22.suse.cz>
 <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
 <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue 25-09-18 12:52:09, David Rientjes wrote:
> On Mon, 24 Sep 2018, Vlastimil Babka wrote:
> 
> > On 9/24/18 10:02 PM, Michal Hocko wrote:
> > > On Mon 24-09-18 21:56:03, Michal Hocko wrote:
> > >> On Mon 24-09-18 12:30:07, David Rientjes wrote:
> > >>> Commit 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
> > >>> introduced a regression in that userspace cannot always determine the set
> > >>> of vmas where thp is ineligible.
> > >>>
> > >>> Userspace relies on the "nh" flag being emitted as part of /proc/pid/smaps
> > >>> to determine if a vma is eligible to be backed by hugepages.
> > >>
> > >> I was under impression that nh resp hg flags only tell about the madvise
> > >> status. How do you exactly use these flags in an application?
> > >>
> 
> This is used to identify heap mappings that should be able to fault thp 
> but do not, and they normally point to a low-on-memory or fragmentation 
> issue.  After commit 1860033237d4, our users of PR_SET_THP_DISABLE no 
> longer show "nh" for their heap mappings so they get reported as having a 
> low thp ratio when in reality it is disabled.  

I am still not sure I understand the issue completely. How are PR_SET_THP_DISABLE
users any different from the global THP disabled case? Is this only
about the scope? E.g the one who checks for the state cannot check the
PR_SET_THP_DISABLE state? Besides that what are consequences of the
low ratio? Is this an example of somebody using the prctl and still
complaining or an external observer trying to do something useful which
ends up doing contrary?

> It is also used in 
> automated testing to ensure that vmas get disabled for thp appropriately 
> and we used "nh" since that is how PR_SET_THP_DISABLE previously enforced 
> this, and those tests now break.

This sounds like a bit of an abuse to me. It shows how an internal
implementation detail leaks out to the userspace which is something we
should try to avoid.

> > >> Your eligible rules as defined here:
> > >>
> > >>> + [*] A process mapping is eligible to be backed by transparent hugepages (thp)
> > >>> +     depending on system-wide settings and the mapping itself.  See
> > >>> +     Documentation/admin-guide/mm/transhuge.rst for default behavior.  If a
> > >>> +     mapping has a flag of "nh", it is not eligible to be backed by hugepages
> > >>> +     in any condition, either because of prctl(PR_SET_THP_DISABLE) or
> > >>> +     madvise(MADV_NOHUGEPAGE).  PR_SET_THP_DISABLE takes precedence over any
> > >>> +     MADV_HUGEPAGE.
> > >>
> > >> doesn't seem to match the reality. I do not see all the file backed
> > >> mappings to be nh marked. So is this really about eligibility rather
> > >> than the madvise status? Maybe it is just the above documentation that
> > >> needs to be updated.
> > 
> > Yeah the change from madvise to eligibility in the doc seems to go too far.
> > 
> 
> I'll reword this to explicitly state that "hg" and "nh" mappings either 
> allow or disallow thp backing.

How are you going to distinguish a regular THP-able mapping then? I am
still not sure how this is supposed to work. Could you be more specific.
Let's say I have a THP-able mapping (shmem resp. anon for the current
implementation). What is the the matrix for hg/nh wrt. madvice/nomadvise
PR_SET_THP_DISABLE and global THP enabled/disable.

-- 
Michal Hocko
SUSE Labs
