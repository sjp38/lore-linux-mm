Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7FC08E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:27:26 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q11-v6so2464062oih.15
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 07:27:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f127-v6si831285oih.447.2018.09.12.07.27.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 07:27:25 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8CEOQQC114187
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:27:24 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mf47v93tv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:27:24 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 12 Sep 2018 15:27:22 +0100
Date: Wed, 12 Sep 2018 16:27:17 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH] memory_hotplug: fix the panic when memory end is not on
 the section boundary
In-Reply-To: <20180912133933.GI10951@dhcp22.suse.cz>
References: <20180910123527.71209-1-zaslonko@linux.ibm.com>
	<20180910131754.GG10951@dhcp22.suse.cz>
	<20180912150356.642c1dab@thinkpad>
	<20180912133933.GI10951@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20180912162717.5a018bf6@thinkpad>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel.Tatashin@microsoft.com, osalvador@suse.de

On Wed, 12 Sep 2018 15:39:33 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 12-09-18 15:03:56, Gerald Schaefer wrote:
> [...]
> > BTW, those sysfs attributes are world-readable, so anyone can trigger
> > the panic by simply reading them, or just run lsmem (also available for
> > x86 since util-linux 2.32). OK, you need a special not-memory-block-aligned
> > mem= parameter and DEBUG_VM for poison check, but w/o DEBUG_VM you would
> > still access uninitialized struct pages. This sounds very wrong, and I
> > think it really should be fixed.  
> 
> Ohh, absolutely. Nobody is questioning that. The thing is that the
> code has been likely always broken. We just haven't noticed because
> those unitialized parts where zeroed previously. Now that the implicit
> zeroying is gone it is just visible.
> 
> All that I am arguing is that there are many places which assume
> pageblocks to be fully initialized and plugging one place that blows up
> at the time is just whack a mole. We need to address this much earlier.
> E.g. by allowing only full pageblocks when adding a memory range.

Just to make sure we are talking about the same thing: when you say
"pageblocks", do you mean the MAX_ORDER_NR_PAGES / pageblock_nr_pages
unit of pages, or do you mean the memory (hotplug) block unit?

I do not see any issue here with MAX_ORDER_NR_PAGES / pageblock_nr_pages
pageblocks, and if there was such an issue, of course you are right that
this would affect many places. If there was such an issue, I would also
assume that we would see the new page poison warning in many other places.

The bug that Mikhails patch would fix only affects code that operates
on / iterates through memory (hotplug) blocks, and that does not happen
in many places, only in the two functions that his patch fixes.

When you say "address this much earlier", do you mean changing the way
that free_area_init_core()/memmap_init() initialize struct pages, i.e.
have them not use zone->spanned_pages as limit, but rather align that
up to the memory block (not pageblock) boundary?
