Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4DB36B0033
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 05:36:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 97so1911977wrb.1
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 02:36:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w14si932932edk.421.2017.09.15.02.36.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 02:36:58 -0700 (PDT)
Date: Fri, 15 Sep 2017 11:36:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memory_hotplug: fix wrong casting for
 __remove_section()
Message-ID: <20170915093656.jxnc55qhap3kswew@dhcp22.suse.cz>
References: <51a59ec3-e7ba-2562-1917-036b8181092c@gmail.com>
 <20170912124952.uraxdt5bgl25zhf7@dhcp22.suse.cz>
 <587bdecd-2584-21be-94b8-61b427f1b0e8@gmail.com>
 <20170913055914.3npcxevhdwghcmdd@dhcp22.suse.cz>
 <509197e7-135d-1304-76f1-32ae1fcbf223@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <509197e7-135d-1304-76f1-32ae1fcbf223@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, qiuxishi@huawei.com, arbab@linux.vnet.ibm.com, Vlastimil Babka <vbabka@suse.cz>

On Thu 14-09-17 11:43:10, YASUAKI ISHIMATSU wrote:
> Hi Michal,
> 
> On 09/13/2017 01:59 AM, Michal Hocko wrote:
> > On Tue 12-09-17 13:05:39, YASUAKI ISHIMATSU wrote:
> >> Hi Michal,
> >>
> >> Thanks you for reviewing my patch.
> >>
> >> On 09/12/2017 08:49 AM, Michal Hocko wrote:
> >>> On Fri 08-09-17 16:43:04, YASUAKI ISHIMATSU wrote:
> >>>> __remove_section() calls __remove_zone() to shrink zone and pgdat.
> >>>> But due to wrong castings, __remvoe_zone() cannot shrink zone
> >>>> and pgdat correctly if pfn is over 0xffffffff.
> >>>>
> >>>> So the patch fixes the following 3 wrong castings.
> >>>>
> >>>>   1. find_smallest_section_pfn() returns 0 or start_pfn which defined
> >>>>      as unsigned long. But the function always returns 32bit value
> >>>>      since the function is defined as int.
> >>>>
> >>>>   2. find_biggest_section_pfn() returns 0 or pfn which defined as
> >>>>      unsigned long. the function always returns 32bit value
> >>>>      since the function is defined as int.
> >>>
> >>> this is indeed wrong. Pfns over would be really broken 15TB. Not that
> >>> unrealistic these days
> >>
> >> Why 15TB?
> > 
> > 0xffffffff>>28
> > 
> 
> Even thought I see your explanation, I cannot understand.
> 
> In my understanding, find_{smallest|biggest}_section_pfn() return integer.
> So the functions always return 0x00000000 - 0xffffffff. Therefore if pfn is over
> 0xffffffff (under 16TB), then the function cannot work correctly.
> 
> What am I wrong?

You are not wrong. We are talking about the same thing AFAICS. I was
just less precise...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
