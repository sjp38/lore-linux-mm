Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B44206B0273
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 14:34:14 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 43-v6so9137820ple.19
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 11:34:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m6-v6sor3726228pgp.6.2018.10.04.11.34.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 11:34:13 -0700 (PDT)
Date: Thu, 4 Oct 2018 11:34:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
In-Reply-To: <20181004094637.GG22173@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1810041130380.12951@chino.kir.corp.google.com>
References: <20180925202959.GY18685@dhcp22.suse.cz> <alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com> <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org> <20180926060624.GA18685@dhcp22.suse.cz> <20181002112851.GP18290@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com> <20181003073640.GF18290@dhcp22.suse.cz> <alpine.DEB.2.21.1810031547150.202532@chino.kir.corp.google.com> <20181004055842.GA22173@dhcp22.suse.cz> <alpine.DEB.2.21.1810040209130.113459@chino.kir.corp.google.com>
 <20181004094637.GG22173@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Thu, 4 Oct 2018, Michal Hocko wrote:

> > And prior to the offending commit, there were three ways to control thp 
> > but two ways to determine if a mapping was eligible for thp based on the 
> > implementation detail of one of those ways.
> 
> Yes, it is really unfortunate that we have ever allowed to leak such an
> internal stuff like VMA flags to userspace.
> 

Right, I don't like userspace dependencies on VmFlags in smaps myself, but 
it's the only way we have available that shows whether a single mapping is 
eligible to be backed by thp :/

> > If there are three ways to 
> > control thp, userspace is still in the dark wrt which takes precedence 
> > over the other: we have PR_SET_THP_DISABLE but globally sysfs has it set 
> > to "always", or we have MADV_HUGEPAGE set per smaps but PR_SET_THP_DISABLE 
> > shown in /proc/pid/status, etc.
> > 
> > Which one is the ultimate authority?
> 
> Isn't our documentation good enough? If not then we should document it
> properly.
> 

No, because the offending commit actually changed the precedence itself: 
PR_SET_THP_DISABLE used to be honored for future mappings and the commit 
changed that for all current mappings.  So as a result of the commit 
itself we would have had to change the documentation and userspace can't 
be expected to keep up with yet a fourth variable: kernel version.  It 
really needs to be simpler, just a per-mapping specifier.
