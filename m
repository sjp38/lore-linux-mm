Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85DE8440460
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 23:28:19 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v78so4868583pgb.18
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 20:28:19 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f9si5288491pgt.760.2017.11.08.20.28.17
        for <linux-mm@kvack.org>;
        Wed, 08 Nov 2017 20:28:18 -0800 (PST)
Date: Thu, 9 Nov 2017 13:33:09 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm: page_ext: allocate page extension though first PFN
 is invalid
Message-ID: <20171109043308.GB24383@js1304-P5Q-DELUXE>
References: <CGME20171107094311epcas1p4a5dd975d6e9f3618a26a0a5d68c68b55@epcas1p4.samsung.com>
 <20171107094447.14763-1-jaewon31.kim@samsung.com>
 <20171108075242.GB18747@js1304-P5Q-DELUXE>
 <CAJrd-UtqWQiqgtfZQDxt18BnqYFgOZOw9pqNJY6UUp71POLOpQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJrd-UtqWQiqgtfZQDxt18BnqYFgOZOw9pqNJY6UUp71POLOpQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@gmail.com>
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 08, 2017 at 10:33:51PM +0900, Jaewon Kim wrote:
> 2017-11-08 16:52 GMT+09:00 Joonsoo Kim <iamjoonsoo.kim@lge.com>:
> > On Tue, Nov 07, 2017 at 06:44:47PM +0900, Jaewon Kim wrote:
> >> online_page_ext and page_ext_init allocate page_ext for each section, but
> >> they do not allocate if the first PFN is !pfn_present(pfn) or
> >> !pfn_valid(pfn).
> >>
> >> Though the first page is not valid, page_ext could be useful for other
> >> pages in the section. But checking all PFNs in a section may be time
> >> consuming job. Let's check each (section count / 16) PFN, then prepare
> >> page_ext if any PFN is present or valid.
> >
> > I guess that this kind of section is not so many. And, this is for
> > debugging so completeness would be important. It's better to check
> > all pfn in the section.
> Thank you for your comment.
> 
> AFAIK physical memory address depends on HW SoC.
> Sometimes a SoC remains few GB address region hole between few GB DRAM
> and other few GB DRAM
> such as 2GB under 4GB address and 2GB beyond 4GB address and holes between them.
> If SoC designs so big hole between actual mapping, I thought too much
> time will be spent on just checking all the PFNs.

I don't think that it is painful because it is done just once at
initialization step. However, if you worry about it, we can use
pfn_present() to skip the whole section at once. !pfn_present()
guarantees that there is no valid pfn in the section. If pfn_present()
returns true, we need to search the whole pages in the section in
order to find valid pfn.

And, I think that we don't need to change online_page_ext(). AFAIK,
hotplug always adds section aligned memory so pfn_present() check
should be enough.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
