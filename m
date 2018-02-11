Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DD2436B000E
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 08:22:25 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e74so1593314wmg.0
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 05:22:25 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id 10si276222eds.499.2018.02.11.05.22.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Feb 2018 05:22:24 -0800 (PST)
Date: Sun, 11 Feb 2018 13:21:29 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: The usage of page_mapping() in architecture code
Message-ID: <20180211132128.GN9418@n2100.armlinux.org.uk>
References: <87vaf4xbz8.fsf@yhuang-dev.intel.com>
 <20180211081707.GM9418@n2100.armlinux.org.uk>
 <87fu67yl78.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87fu67yl78.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Dave Hansen <dave.hansen@intel.com>, Chen Liqin <liqin.linux@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Vineet Gupta <vgupta@synopsys.com>, Ley Foon Tan <lftan@altera.com>, Ralf Baechle <ralf@linux-mips.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

On Sun, Feb 11, 2018 at 04:39:07PM +0800, Huang, Ying wrote:
> Hi, Russell,
> 
> Russell King - ARM Linux <linux@armlinux.org.uk> writes:
> 
> > On Sun, Feb 11, 2018 at 02:43:39PM +0800, Huang, Ying wrote:
> [snip]
> >> 
> >> 
> >> if page is an anonymous page in swap cache, "mapping &&
> >> !mapping_mapped()" will be true, so we will delay flushing.  But if my
> >> understanding of the code were correct, we should call
> >> flush_kernel_dcache() because the kernel may access the page during
> >> swapping in/out.
> >> 
> >> The code in other architectures follow the similar logic.  Would it be
> >> better for page_mapping() here to return NULL for anonymous pages even
> >> if they are in swap cache?  Of course we need to change the function
> >> name.  page_file_mapping() appears a good name, but that has been used
> >> already.  Any suggestion?
> >
> > flush_dcache_page() does nothing for anonymous pages (see cachetlb.txt,
> > it's only defined to do anything for page cache pages.)
> >
> > flush_anon_page() deals with anonymous pages.
> 
> Thanks for your information!  But I found this isn't followed exactly in
> the code.  For example, in get_mergeable_page() in mm/ksm.c,
> 
> 	if (PageAnon(page)) {
> 		flush_anon_page(vma, page, addr);
> 		flush_dcache_page(page);
> 	} else {
> 		put_page(page);
> 
> flush_dcache_page() is called for anonymous pages too.

... and flush_dcache_page() will be a no-op here, as per its
documentation.  Any flushing required here will have been taken care of
with flush_anon_page().

If flush_dcache_page() were to do flushing here, it would repeat the
flushing that flush_anon_page() has just done, so its pointless.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
