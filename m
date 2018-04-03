Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 823736B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 07:30:46 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id u16-v6so7309594plq.7
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 04:30:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m1-v6si2752491plt.363.2018.04.03.04.30.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 04:30:45 -0700 (PDT)
Date: Tue, 3 Apr 2018 13:30:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memblock: fix potential issue in
 memblock_search_pfn_nid()
Message-ID: <20180403113041.GP5501@dhcp22.suse.cz>
References: <20180330033055.22340-1-richard.weiyang@gmail.com>
 <20180330135727.67251c7ea8c2db28b404e0e1@linux-foundation.org>
 <20180402015026.GA32938@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180402015026.GA32938@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, yinghai@kernel.org, linux-mm@kvack.org, hejianet@gmail.com, "3 . 12+" <stable@vger.kernel.org>

On Mon 02-04-18 09:50:26, Wei Yang wrote:
> On Fri, Mar 30, 2018 at 01:57:27PM -0700, Andrew Morton wrote:
> >On Fri, 30 Mar 2018 11:30:55 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
> >
> >> memblock_search_pfn_nid() returns the nid and the [start|end]_pfn of the
> >> memory region where pfn sits in. While the calculation of start_pfn has
> >> potential issue when the regions base is not page aligned.
> >> 
> >> For example, we assume PAGE_SHIFT is 12 and base is 0x1234. Current
> >> implementation would return 1 while this is not correct.
> >
> >Why is this not correct?  The caller might want the pfn of the page
> >which covers the base?
> >
> 
> Hmm... the only caller of memblock_search_pfn_nid() is __early_pfn_to_nid(),
> which returns the nid of a pfn and save the [start_pfn, end_pfn] with in the
> same memory region to a cache. So this looks not a good practice to store
> un-exact pfn in the cache.
> 
> >> This patch fixes this by using PFN_UP().
> >> 
> >> The original commit is commit e76b63f80d93 ("memblock, numa: binary search
> >> node id") and merged in v3.12.
> >> 
> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> >> Cc: 3.12+ <stable@vger.kernel.org>
> >
> >Please fully describe the runtime effects of a bug when fixing that
> >bug.  This description doesn't give enough justification for merging
> >the patch into mainline, let alone -stable.
> 
> Since PFN_UP() and PFN_DOWN() differs when the address is not page aligned, in
> theory we may have two situations like below.

Have you ever seen a HW that would report page unaligned memory ranges?
Is this even possible?
-- 
Michal Hocko
SUSE Labs
