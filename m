Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1726B000A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 01:58:46 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g6-v6so6737363plo.0
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 22:58:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s2-v6si4065647plp.144.2018.10.03.22.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 22:58:45 -0700 (PDT)
Date: Thu, 4 Oct 2018 07:58:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
Message-ID: <20181004055842.GA22173@dhcp22.suse.cz>
References: <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
 <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com>
 <20180925202959.GY18685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com>
 <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org>
 <20180926060624.GA18685@dhcp22.suse.cz>
 <20181002112851.GP18290@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com>
 <20181003073640.GF18290@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810031547150.202532@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810031547150.202532@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Wed 03-10-18 15:51:05, David Rientjes wrote:
> On Wed, 3 Oct 2018, Michal Hocko wrote:
> 
> > > > So how about this? (not tested yet but it should be pretty
> > > > straightforward)
> > > 
> > > Umm, prctl(PR_GET_THP_DISABLE)?
> > 
> > /me confused. I thought you want to query for the flag on a
> > _different_ process. 
> 
> Why would we want to check three locations (system wide setting, prctl 
> setting, madvise setting) to determine if a heap can be backed by thp?

Because we simply have 3 different ways to control THP? Is this a real
problem?

> If the nh flag being exported to VmFlag is to be extended beyond what my 
> patch did, I suggest (1) it does it for the system wide setting as well 
> and/or (2) calling a helper function to determine if the vma could be 
> backed by thp in the first place regardless of any setting to determine if 
> nh/hg is important.
> 
> The last thing I suggest is done is adding a third place to check.

But conflating the three ways into a single exported symbol (be it nh
or something else) just makes the api more confusing longterm. I am
pretty sure we have made that mistake in the past already.

What if somebody really wants to check for PR_SET_THP_DISABLE? There is
currently no way to do that on a remote process right now AFAICS. So it
makes sense to export the state in general. Any exported API should be
about consistency. If you want to combine all three checks then
just do that in the userspace or in a library function.
-- 
Michal Hocko
SUSE Labs
