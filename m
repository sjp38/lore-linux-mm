Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E854F6B0025
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 05:26:41 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id z11-v6so7299312plo.21
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 02:26:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w127sor2513630pfb.115.2018.03.23.02.26.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Mar 2018 02:26:40 -0700 (PDT)
Date: Fri, 23 Mar 2018 02:26:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg, thp: do not invoke oom killer on thp charges
In-Reply-To: <20180323090704.GK23100@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1803230208100.97541@chino.kir.corp.google.com>
References: <20180321205928.22240-1-mhocko@kernel.org> <alpine.DEB.2.20.1803211418170.107059@chino.kir.corp.google.com> <20180321214104.GT23100@dhcp22.suse.cz> <alpine.DEB.2.20.1803220106010.175961@chino.kir.corp.google.com> <20180322085611.GY23100@dhcp22.suse.cz>
 <alpine.DEB.2.20.1803221304160.3268@chino.kir.corp.google.com> <20180323090704.GK23100@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 23 Mar 2018, Michal Hocko wrote:

> > Examples of where this isn't already done?  It certainly wasn't a problem 
> > before __GFP_NORETRY was dropped in commit 2516035499b9 but you suspect 
> > it's a problem now.
> 
> It is not a problem _right now_ as I've already pointed out few
> times. We do not trigger the OOM killer for anything but #PF path. But
> this is an implementation detail which can change in future and there is
> actually some demand for the change. Once we start triggering the oom
> killer for all charges then we do not really want to have the disparity.
> 

Ok, my patch is only addressing the code as it sits today, not any 
theoretical code in the future.  The fact remains that the 
PAGE_ALLOC_COSTLY_ORDER and high_zoneidx test for lowmem allocations in 
the allocation path are because oom killing is unlikely to free contiguous 
pages and lowmem, respectively.  We wouldn't avoid oom kill in memcg just 
because a charge is __GFP_DMA.  We shouldn't avoid oom kill in memcg just 
because the order is PAGE_ALLOC_COSTLY_ORDER: it's about contiguous 
memory, not about amount of memory.  I believe you understand that and so 
I'm optimistic that we are good in closing this thread out.  Thanks.
