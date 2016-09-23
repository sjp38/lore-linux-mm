Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 874A46B0284
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 08:42:49 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fu14so203517373pad.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:42:49 -0700 (PDT)
Received: from mail-pf0-f196.google.com (mail-pf0-f196.google.com. [209.85.192.196])
        by mx.google.com with ESMTPS id zm10si7527633pac.10.2016.09.23.05.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 05:42:48 -0700 (PDT)
Received: by mail-pf0-f196.google.com with SMTP id n24so5244031pfb.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:42:48 -0700 (PDT)
Date: Fri, 23 Sep 2016 14:42:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping
 page unaligned ranges
Message-ID: <20160923124244.GN4478@dhcp22.suse.cz>
References: <57E20A69.5010206@zoho.com>
 <20160922124735.GB11204@dhcp22.suse.cz>
 <35661a34-c3e0-0ec2-b58f-ee59bef4e4d4@zoho.com>
 <20160923084551.GG4478@dhcp22.suse.cz>
 <f9e708e1-121e-367e-1141-5470e5baffe5@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f9e708e1-121e-367e-1141-5470e5baffe5@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On Fri 23-09-16 20:29:20, zijun_hu wrote:
> On 2016/9/23 16:45, Michal Hocko wrote:
> > On Thu 22-09-16 23:13:17, zijun_hu wrote:
> >> On 2016/9/22 20:47, Michal Hocko wrote:
> >>> On Wed 21-09-16 12:19:53, zijun_hu wrote:
> >>>> From: zijun_hu <zijun_hu@htc.com>
> >>>>
> >>>> endless loop maybe happen if either of parameter addr and end is not
> >>>> page aligned for kernel API function ioremap_page_range()
> >>>
> >>> Does this happen in practise or this you found it by reading the code?
> >>>
> >> i found it by reading the code, this is a kernel API function and there
> >> are no enough hint for parameter requirements, so any parameters
> >> combination maybe be used by user, moreover, it seems appropriate for
> >> many bad parameter combination, for example, provided  PMD_SIZE=2M and
> >> PAGE_SIZE=4K, 0x00 is used for aligned very well address
> >> a user maybe want to map virtual range[0x1ff800, 0x200800) to physical address
> >> 0x300800, it will cause endless loop
> > 
> > Well, we are relying on the kernel to do the sane thing otherwise we
> > would be screwed anyway. If this can be triggered by a userspace then it
> > would be a different story. Just look at how we are doing mmap, we
> > sanitize the page alignment at the high level and the lower level
> > functions just assume sane values.
> > 
> ioremap_page_range() is exported by EXPORT_SYMBOL_GPL() as a kernel interface
> so perhaps it is called by not only any kernel module authors but also other
> kernel parts
> 
> if the bad range is used by a careless kernel user really, it seems a better
> choice to alert the warning message or panic the kernel than hanging the system
> due to endless loop, it can help them locate problem usefully

I absolutely do not want to panic my system just because a crapy module
or whatnot doesn't provide an aligned address. Warning and a fixup
sounds much more sane to me.

[...]

> >> no, it don't work for many special case
> >> for example, provided  PMD_SIZE=2M
> >> mapping [0x1f8800, 0x208800) virtual range will be split to two ranges
> >> [0x1f8800, 0x200000) and [0x200000,0x208800) and map them separately
> >> the first range will cause dead loop
> > 
> > I am not sure I see your point. How can we deadlock if _both_ addresses
> > get aligned to the page boundary and how does PMD_SIZE make any
> > difference.
> > 
> i will take a example to illustrate my considerations
> provided PUD_SIZE == 1G, PMD_SIZE == 2M, PAGE_SIZE == 4K
> it is used by arm64 normally
> 
> we want to map virtual range [0xffffffff_ffc08800, 0xffffffff_fffff800) by
> ioremap_page_range(),ioremap_pmd_range() is called to map the range
> finally, ioremap_pmd_range() will call
> ioremap_pte_range(pmd, 0xffffffff_ffc08800, 0xffffffff_fffe0000) and
> ioremap_pte_range(pmd, 0xffffffff_fffe0000, 0xffffffff fffff800) separately

but those ranges are not aligned and it ioremap_page_range fix them up
to _be_ aligned then there is no problem, right? So either I am missing
something or we are talking past each other.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
