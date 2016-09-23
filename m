Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 22AA428024C
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 10:27:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l138so19377371wmg.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 07:27:03 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ey9si7789959wjb.265.2016.09.23.07.27.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 07:27:02 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id 133so3089362wmq.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 07:27:01 -0700 (PDT)
Date: Fri, 23 Sep 2016 16:27:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping
 page unaligned ranges
Message-ID: <20160923142700.GS4478@dhcp22.suse.cz>
References: <57E20A69.5010206@zoho.com>
 <20160922124735.GB11204@dhcp22.suse.cz>
 <35661a34-c3e0-0ec2-b58f-ee59bef4e4d4@zoho.com>
 <20160923084551.GG4478@dhcp22.suse.cz>
 <f9e708e1-121e-367e-1141-5470e5baffe5@zoho.com>
 <20160923124244.GN4478@dhcp22.suse.cz>
 <57E52762.9000702@zoho.com>
 <20160923133330.GO4478@dhcp22.suse.cz>
 <d7408c4e-6fe1-f51c-0388-8636f4761ccd@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d7408c4e-6fe1-f51c-0388-8636f4761ccd@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On Fri 23-09-16 22:14:40, zijun_hu wrote:
> On 2016/9/23 21:33, Michal Hocko wrote:
> > On Fri 23-09-16 21:00:18, zijun_hu wrote:
> >> On 09/23/2016 08:42 PM, Michal Hocko wrote:
> >>>>>> no, it don't work for many special case
> >>>>>> for example, provided  PMD_SIZE=2M
> >>>>>> mapping [0x1f8800, 0x208800) virtual range will be split to two ranges
> >>>>>> [0x1f8800, 0x200000) and [0x200000,0x208800) and map them separately
> >>>>>> the first range will cause dead loop
> >>>>>
> >>>>> I am not sure I see your point. How can we deadlock if _both_ addresses
> >>>>> get aligned to the page boundary and how does PMD_SIZE make any
> >>>>> difference.
> >>>>>
> >>>> i will take a example to illustrate my considerations
> >>>> provided PUD_SIZE == 1G, PMD_SIZE == 2M, PAGE_SIZE == 4K
> >>>> it is used by arm64 normally
> >>>>
> >>>> we want to map virtual range [0xffffffff_ffc08800, 0xffffffff_fffff800) by
> >>>> ioremap_page_range(),ioremap_pmd_range() is called to map the range
> >>>> finally, ioremap_pmd_range() will call
> >>>> ioremap_pte_range(pmd, 0xffffffff_ffc08800, 0xffffffff_fffe0000) and
> >>>> ioremap_pte_range(pmd, 0xffffffff_fffe0000, 0xffffffff fffff800) separately
> >>>
> >>> but those ranges are not aligned and it ioremap_page_range fix them up
> >>> to _be_ aligned then there is no problem, right? So either I am missing
> >>> something or we are talking past each other.
> >>>
> >> my complementary considerations are show below
> >>
> >> why not to round up the range start boundary to page aligned?
> >> 1, it don't remain consistent with the original logic
> >>    take map [0x1800, 0x4800) as example
> >>    the original logic map range [0x1000, 0x2000), but rounding up start boundary
> >>    don't mapping the range [0x1000, 0x2000)
> > 
> > just look at how we do that for the mmap...
>
> okay
> i don't familiar with mmap code very well now

mmap basically does addr &= PAGE_MASK (modulo mmap_min_addr) and
len = PAGE_ALIGN(len).

this is [star, end) raher than [start, start+len) but you should get the
point I guess.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
