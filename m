Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2828D8E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 17:45:23 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c8-v6so13340908pfn.2
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 14:45:23 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x9-v6sor379326pgj.120.2018.09.25.14.45.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 14:45:21 -0700 (PDT)
Date: Tue, 25 Sep 2018 14:45:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, thp: always specify ineligible vmas as nh in
 smaps
In-Reply-To: <20180925202959.GY18685@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com> <e2f159f3-5373-dda4-5904-ed24d029de3c@suse.cz> <alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com> <alpine.DEB.2.21.1809241227370.241621@chino.kir.corp.google.com>
 <20180924195603.GJ18685@dhcp22.suse.cz> <20180924200258.GK18685@dhcp22.suse.cz> <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz> <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com> <20180925202959.GY18685@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue, 25 Sep 2018, Michal Hocko wrote:

> > This is used to identify heap mappings that should be able to fault thp 
> > but do not, and they normally point to a low-on-memory or fragmentation 
> > issue.  After commit 1860033237d4, our users of PR_SET_THP_DISABLE no 
> > longer show "nh" for their heap mappings so they get reported as having a 
> > low thp ratio when in reality it is disabled.  
> 
> I am still not sure I understand the issue completely. How are PR_SET_THP_DISABLE
> users any different from the global THP disabled case? Is this only
> about the scope? E.g the one who checks for the state cannot check the
> PR_SET_THP_DISABLE state? Besides that what are consequences of the
> low ratio? Is this an example of somebody using the prctl and still
> complaining or an external observer trying to do something useful which
> ends up doing contrary?
> 

Yes, that is how I found out about this.  The system-wide policy can be 
determined from /sys/kernel/mm/transparent_hugepage/enabled.  If it is 
"always" and heap mappings are not being backed by hugepages and lack the 
"nh" flag, it was considered as a likely fragmentation issue before commit 
1860033237d4.  After commit 1860033237d4, the heap mapping for 
PR_SET_THP_DISABLE users was not showing it actually is prevented from 
faulting thp because of policy, not because of fragmentation.

> > It is also used in 
> > automated testing to ensure that vmas get disabled for thp appropriately 
> > and we used "nh" since that is how PR_SET_THP_DISABLE previously enforced 
> > this, and those tests now break.
> 
> This sounds like a bit of an abuse to me. It shows how an internal
> implementation detail leaks out to the userspace which is something we
> should try to avoid.
> 

Well, it's already how this has worked for years before commit 
1860033237d4 broke it.  Changing the implementation in the kernel is fine 
as long as you don't break userspace who relies on what is exported to it 
and is the only way to determine if MADV_NOHUGEPAGE is preventing it from 
being backed by hugepages.

> > I'll reword this to explicitly state that "hg" and "nh" mappings either 
> > allow or disallow thp backing.
> 
> How are you going to distinguish a regular THP-able mapping then? I am
> still not sure how this is supposed to work. Could you be more specific.

You look for "[heap]" in smaps to determine where the heap mapping is.
