Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9C56B026B
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 08:07:33 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id x13-v6so13197608iog.16
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 05:07:33 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k11-v6si10017345jam.31.2018.07.02.05.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 05:07:31 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w62C3ZcW099054
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 12:07:30 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2jx2gpv59g-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 12:07:30 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w62C7R5F026208
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 12:07:27 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w62C7RN0002493
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 12:07:27 GMT
Received: by mail-oi0-f50.google.com with SMTP id r16-v6so15386858oie.3
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 05:07:27 -0700 (PDT)
MIME-Version: 1.0
References: <1530239363-2356-1-git-send-email-hejianet@gmail.com> <20180702114037.GJ19043@dhcp22.suse.cz>
In-Reply-To: <20180702114037.GJ19043@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 2 Jul 2018 08:06:50 -0400
Message-ID: <CAGM2reaPhcWNhNW+i7kCysUr2tEMBour-GO_hkr4N-SrEvcx0w@mail.gmail.com>
Subject: Re: [PATCH v9 0/6] optimize memblock_next_valid_pfn and
 early_pfn_valid on arm and arm64
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Jia He <hejianet@gmail.com>, linux@armlinux.org.uk, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, will.deacon@arm.com, mark.rutland@arm.com, hpa@zytor.com, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, neelx@redhat.com, erosca@de.adit-jv.com, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, james.morse@arm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>, steve.capper@arm.com, tglx@linutronix.de, mingo@redhat.com, gregkh@linuxfoundation.org, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, kemi.wang@intel.com, =?UTF-8?B?UGV0ciBUZXNhxZnDrWs=?= <ptesarik@suse.com>, yasu.isimatu@gmail.com, aryabinin@virtuozzo.com, nborisov@suse.com, Wei Yang <richard.weiyang@gmail.com>

On Mon, Jul 2, 2018 at 7:40 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 29-06-18 10:29:17, Jia He wrote:
> > Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> > where possible") tried to optimize the loop in memmap_init_zone(). But
> > there is still some room for improvement.
>
> It would be great to shortly describe those optimization from high level
> POV.
>
> >
> > Patch 1 introduce new config to make codes more generic
> > Patch 2 remain the memblock_next_valid_pfn on arm and arm64
> > Patch 3 optimizes the memblock_next_valid_pfn()
> > Patch 4~6 optimizes the early_pfn_valid()
> >
> > As for the performance improvement, after this set, I can see the time
> > overhead of memmap_init() is reduced from 27956us to 13537us in my
> > armv8a server(QDF2400 with 96G memory, pagesize 64k).
>
> So this is 13ms saving when booting 96G machine. Is this really worth
> the additional code? Are there any other benefits?

While 0.0144s for 96G is definitely small, I think the time is
proportional to the number of pages since memmap_init() loops through
all the pages. If base pages were changed to 4K, I bet the time would
increase 16 times: 0.23s on given machine, in other words around 2s
per 1T of memory.

I agree, a high level description of optimization is needed, and also
an explanation of why it would not work on other arches that support
memblock.

Pavel
