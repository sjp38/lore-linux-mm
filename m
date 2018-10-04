Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 79F896B000A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 05:15:41 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v9-v6so5572156pff.4
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 02:15:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n18-v6sor3533990pfb.17.2018.10.04.02.15.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 02:15:40 -0700 (PDT)
Date: Thu, 4 Oct 2018 02:15:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
In-Reply-To: <20181004055842.GA22173@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1810040209130.113459@chino.kir.corp.google.com>
References: <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz> <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com> <20180925202959.GY18685@dhcp22.suse.cz> <alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com>
 <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org> <20180926060624.GA18685@dhcp22.suse.cz> <20181002112851.GP18290@dhcp22.suse.cz> <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com> <20181003073640.GF18290@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810031547150.202532@chino.kir.corp.google.com> <20181004055842.GA22173@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Thu, 4 Oct 2018, Michal Hocko wrote:

> > > > > So how about this? (not tested yet but it should be pretty
> > > > > straightforward)
> > > > 
> > > > Umm, prctl(PR_GET_THP_DISABLE)?
> > > 
> > > /me confused. I thought you want to query for the flag on a
> > > _different_ process. 
> > 
> > Why would we want to check three locations (system wide setting, prctl 
> > setting, madvise setting) to determine if a heap can be backed by thp?
> 
> Because we simply have 3 different ways to control THP? Is this a real
> problem?
> 

And prior to the offending commit, there were three ways to control thp 
but two ways to determine if a mapping was eligible for thp based on the 
implementation detail of one of those ways.  If there are three ways to 
control thp, userspace is still in the dark wrt which takes precedence 
over the other: we have PR_SET_THP_DISABLE but globally sysfs has it set 
to "always", or we have MADV_HUGEPAGE set per smaps but PR_SET_THP_DISABLE 
shown in /proc/pid/status, etc.

Which one is the ultimate authority?  There's one way to specify it: in a 
single per-mapping location that reveals whether that mapping is eligible 
for thp or not.  So I think it would be a very sane extension so that 
smaps reveals if a mapping can be backed by hugepages or not depending on 
the helper function thp uses itself to determine if it can fault 
hugepages.  I don't think we should have three locations to check and then 
try to resolve which one takes precedence over the other for each 
userspace implementation (and perhaps how the kernel implementation 
evolves).
