Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 726036B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 21:34:07 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o33-v6so9990092plb.16
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 18:34:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 101-v6sor1603040ple.72.2018.04.03.18.34.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 18:34:06 -0700 (PDT)
Date: Wed, 4 Apr 2018 09:33:57 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/memblock: fix potential issue in
 memblock_search_pfn_nid()
Message-ID: <20180404013357.GB1841@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180330033055.22340-1-richard.weiyang@gmail.com>
 <20180330135727.67251c7ea8c2db28b404e0e1@linux-foundation.org>
 <20180402015026.GA32938@WeideMacBook-Pro.local>
 <20180403113041.GP5501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180403113041.GP5501@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, yinghai@kernel.org, linux-mm@kvack.org, hejianet@gmail.com, "3 . 12+" <stable@vger.kernel.org>

On Tue, Apr 03, 2018 at 01:30:41PM +0200, Michal Hocko wrote:
>On Mon 02-04-18 09:50:26, Wei Yang wrote:
>> On Fri, Mar 30, 2018 at 01:57:27PM -0700, Andrew Morton wrote:
>> >On Fri, 30 Mar 2018 11:30:55 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
>> >
>> >> memblock_search_pfn_nid() returns the nid and the [start|end]_pfn of the
>> >> memory region where pfn sits in. While the calculation of start_pfn has
>> >> potential issue when the regions base is not page aligned.
>> >> 
>> >> For example, we assume PAGE_SHIFT is 12 and base is 0x1234. Current
>> >> implementation would return 1 while this is not correct.
>> >
>> >Why is this not correct?  The caller might want the pfn of the page
>> >which covers the base?
>> >
>> 
>> Hmm... the only caller of memblock_search_pfn_nid() is __early_pfn_to_nid(),
>> which returns the nid of a pfn and save the [start_pfn, end_pfn] with in the
>> same memory region to a cache. So this looks not a good practice to store
>> un-exact pfn in the cache.
>> 
>> >> This patch fixes this by using PFN_UP().
>> >> 
>> >> The original commit is commit e76b63f80d93 ("memblock, numa: binary search
>> >> node id") and merged in v3.12.
>> >> 
>> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> >> Cc: 3.12+ <stable@vger.kernel.org>
>> >
>> >Please fully describe the runtime effects of a bug when fixing that
>> >bug.  This description doesn't give enough justification for merging
>> >the patch into mainline, let alone -stable.
>> 
>> Since PFN_UP() and PFN_DOWN() differs when the address is not page aligned, in
>> theory we may have two situations like below.
>
>Have you ever seen a HW that would report page unaligned memory ranges?
>Is this even possible?

No, so we don't need to handle this case?

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
