Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB9E48E0001
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 20:55:56 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 191-v6so11056007pgb.23
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 17:55:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o8-v6sor828851pls.134.2018.09.25.17.55.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 17:55:55 -0700 (PDT)
Date: Tue, 25 Sep 2018 17:55:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, thp: always specify ineligible vmas as nh in
 smaps
In-Reply-To: <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org>
Message-ID: <alpine.DEB.2.21.1809251750300.28960@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com> <e2f159f3-5373-dda4-5904-ed24d029de3c@suse.cz> <alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com> <alpine.DEB.2.21.1809241227370.241621@chino.kir.corp.google.com>
 <20180924195603.GJ18685@dhcp22.suse.cz> <20180924200258.GK18685@dhcp22.suse.cz> <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz> <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com> <20180925202959.GY18685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com> <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue, 25 Sep 2018, Andrew Morton wrote:

> > > > It is also used in 
> > > > automated testing to ensure that vmas get disabled for thp appropriately 
> > > > and we used "nh" since that is how PR_SET_THP_DISABLE previously enforced 
> > > > this, and those tests now break.
> > > 
> > > This sounds like a bit of an abuse to me. It shows how an internal
> > > implementation detail leaks out to the userspace which is something we
> > > should try to avoid.
> > > 
> > 
> > Well, it's already how this has worked for years before commit 
> > 1860033237d4 broke it.  Changing the implementation in the kernel is fine 
> > as long as you don't break userspace who relies on what is exported to it 
> > and is the only way to determine if MADV_NOHUGEPAGE is preventing it from 
> > being backed by hugepages.
> 
> 1860033237d4 was over a year ago so perhaps we don't need to be
> too worried about restoring the old interface.  In which case
> we have an opportunity to make improvements such as that suggested
> by Michal?
> 

The only way to determine if a vma was thp disabled prior to this commit 
was parsing VmFlags from /proc/pid/smaps.  That was possible either 
through MADV_NOHUGEPAGE or PR_SET_THP_DISABLE.  It is perfectly legitimate 
for a test case to check if either are being set correctly through 
userspace libraries or through the kernel itself in the manner in which 
the kernel exports this information.  It is also perfectly legitimate for 
userspace to cull through information in the only way it is exported by 
the kernel to identify reasons for why applications are not having their 
heap backed by transparent hugepages: the mapping is disabled, the 
application is hitting the limit for its mem cgroup, we are low on memory, 
or there are fragmentation issues.  Differentiating between those is 
something our userspace does, and was broken by 1860033237d4.
