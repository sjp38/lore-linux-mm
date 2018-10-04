Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 57BFB6B0006
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 05:46:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e5-v6so5143273eda.4
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 02:46:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f18si608504edx.146.2018.10.04.02.46.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 02:46:39 -0700 (PDT)
Date: Thu, 4 Oct 2018 11:46:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
Message-ID: <20181004094637.GG22173@dhcp22.suse.cz>
References: <20180925202959.GY18685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com>
 <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org>
 <20180926060624.GA18685@dhcp22.suse.cz>
 <20181002112851.GP18290@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com>
 <20181003073640.GF18290@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810031547150.202532@chino.kir.corp.google.com>
 <20181004055842.GA22173@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810040209130.113459@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810040209130.113459@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Thu 04-10-18 02:15:38, David Rientjes wrote:
> On Thu, 4 Oct 2018, Michal Hocko wrote:
> 
> > > > > > So how about this? (not tested yet but it should be pretty
> > > > > > straightforward)
> > > > > 
> > > > > Umm, prctl(PR_GET_THP_DISABLE)?
> > > > 
> > > > /me confused. I thought you want to query for the flag on a
> > > > _different_ process. 
> > > 
> > > Why would we want to check three locations (system wide setting, prctl 
> > > setting, madvise setting) to determine if a heap can be backed by thp?
> > 
> > Because we simply have 3 different ways to control THP? Is this a real
> > problem?
> > 
> 
> And prior to the offending commit, there were three ways to control thp 
> but two ways to determine if a mapping was eligible for thp based on the 
> implementation detail of one of those ways.

Yes, it is really unfortunate that we have ever allowed to leak such an
internal stuff like VMA flags to userspace.

> If there are three ways to 
> control thp, userspace is still in the dark wrt which takes precedence 
> over the other: we have PR_SET_THP_DISABLE but globally sysfs has it set 
> to "always", or we have MADV_HUGEPAGE set per smaps but PR_SET_THP_DISABLE 
> shown in /proc/pid/status, etc.
> 
> Which one is the ultimate authority?

Isn't our documentation good enough? If not then we should document it
properly.

> There's one way to specify it: in a 
> single per-mapping location that reveals whether that mapping is eligible 
> for thp or not.  So I think it would be a very sane extension so that 
> smaps reveals if a mapping can be backed by hugepages or not depending on 
> the helper function thp uses itself to determine if it can fault 
> hugepages.  I don't think we should have three locations to check and then 
> try to resolve which one takes precedence over the other for each 
> userspace implementation (and perhaps how the kernel implementation 
> evolves).

But we really have three different ways to disable thp. Which one has
caused the end result might be interesting/important because different
entities might be under control. You either have to contact your admin
for the global one, or whomever has launched you for the prctl thing. So
the distinction might be important.

Checking 3 different places and the precedence rules is not really
trivial but I do not see any reason why this couldn't be implemented in
a library so the user doesn't really have to scratch head.

If you really insist to have per-vma thing then all right but do not
conflate vma flags and the higher level logic and make it its own line
in the smaps output and make sure it reports only THP able VMAs.
-- 
Michal Hocko
SUSE Labs
