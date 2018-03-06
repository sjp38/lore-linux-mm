Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91FAC6B0005
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 19:47:43 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id h193so10585858pfe.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 16:47:43 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id y7si8079481pgy.161.2018.03.05.16.47.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 16:47:42 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V2 -mm] mm: Fix races between swapoff and flush dcache
References: <20180305083634.15174-1-ying.huang@intel.com>
Date: Tue, 06 Mar 2018 08:47:37 +0800
In-Reply-To: <20180305083634.15174-1-ying.huang@intel.com> (Ying Huang's
	message of "Mon, 5 Mar 2018 16:36:34 +0800")
Message-ID: <871sgy2fo6.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Dave Hansen <dave.hansen@intel.com>, Chen Liqin <liqin.linux@gmail.com>, Russell King <linux@armlinux.org.uk>, Yoshinori Sato <ysato@users.sourceforge.jp>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Vineet Gupta <vgupta@synopsys.com>, Ley Foon Tan <lftan@altera.com>, Ralf Baechle <ralf@linux-mips.org>, Andi Kleen <ak@linux.intel.com>

"Huang, Ying" <ying.huang@intel.com> writes:

> From: Huang Ying <ying.huang@intel.com>
>
> From commit 4b3ef9daa4fc ("mm/swap: split swap cache into 64MB
> trunks") on, after swapoff, the address_space associated with the swap
> device will be freed.  So page_mapping() users which may touch the
> address_space need some kind of mechanism to prevent the address_space
> from being freed during accessing.
>
> The dcache flushing functions (flush_dcache_page(), etc) in
> architecture specific code may access the address_space of swap device
> for anonymous pages in swap cache via page_mapping() function.  But in
> some cases there are no mechanisms to prevent the swap device from
> being swapoff, for example,
>
> CPU1					CPU2
> __get_user_pages()			swapoff()
>   flush_dcache_page()
>     mapping = page_mapping()
>       ...				  exit_swap_address_space()
>       ...				    kvfree(spaces)
>       mapping_mapped(mapping)
>
> The address space may be accessed after being freed.
>
> But from cachetlb.txt and Russell King, flush_dcache_page() only care
> about file cache pages, for anonymous pages, flush_anon_page() should
> be used.  The implementation of flush_dcache_page() in all
> architectures follows this too.  They will check whether
> page_mapping() is NULL and whether mapping_mapped() is true to
> determine whether to flush the dcache immediately.  And they will use
> interval tree (mapping->i_mmap) to find all user space mappings.
> While mapping_mapped() and mapping->i_mmap isn't used by anonymous
> pages in swap cache at all.
>
> So, to fix the race between swapoff and flush dcache, __page_mapping()
> is add to return the address_space for file cache pages and NULL
> otherwise.  All page_mapping() invoking in flush dcache functions are
> replaced with __page_mapping().

Sorry, I just found I forgot replacing __page_mapping() to
page_mapping_file() in the above paragraph.  Could you help me to change
it in place?  Or I should resend the patch with the updated description?

Best Regards,
Huang, Ying

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
