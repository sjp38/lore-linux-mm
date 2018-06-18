Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3CF6B0008
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 19:36:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j7-v6so3551895pff.16
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 16:36:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q17-v6si12896051pgc.270.2018.06.18.16.36.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 16:36:18 -0700 (PDT)
Date: Mon, 18 Jun 2018 16:36:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] x86/e820: put !E820_TYPE_RAM regions into
 memblock.reserved
Message-Id: <20180618163616.52645949a8e4a0f73819fd62@linux-foundation.org>
In-Reply-To: <20180615140000.44tht4f3ek3lh2u2@xakep.localdomain>
References: <20180607100256.GA9129@hori1.linux.bs1.fc.nec.co.jp>
	<20180613054107.GA5329@hori1.linux.bs1.fc.nec.co.jp>
	<20180613090700.GG13364@dhcp22.suse.cz>
	<20180614051618.GB17860@hori1.linux.bs1.fc.nec.co.jp>
	<20180614053859.GA9863@techadventures.net>
	<20180614063454.GA32419@hori1.linux.bs1.fc.nec.co.jp>
	<20180614213033.GA19374@techadventures.net>
	<20180615010927.GC1196@hori1.linux.bs1.fc.nec.co.jp>
	<20180615072947.GB23273@hori1.linux.bs1.fc.nec.co.jp>
	<20180615084142.GE24039@dhcp22.suse.cz>
	<20180615140000.44tht4f3ek3lh2u2@xakep.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oscar Salvador <osalvador@techadventures.net>, Oscar Salvador <osalvador@suse.de>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Matthew Wilcox <willy@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@kernel.org" <mingo@kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>

On Fri, 15 Jun 2018 10:00:00 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Tested-by: Oscar Salvador <osalvador@suse.de>
> > 
> > OK, this makes sense to me. It is definitely much better than the
> > original attempt.
> > 
> > Unless I am missing something this should be correct
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> First of all thank you Naoya for finding and root causing this issue.
> 
> So, with this fix we reserve any hole and !E820_TYPE_RAM or
> !E820_TYPE_RESERVED_KERN in e820.  I think, this will work because we
> do pfn_valid() check in zero_resv_unavail(), so the ranges that do not have
> backing struct pages will be skipped. But, I am worried on the performance
> implications of when the holes of invalid memory are rather large. We would
> have to loop through it in zero_resv_unavail() one pfn at a time.
> 
> Therefore, we might also need to optimize zero_resv_unavail() a little like
> this:
> 
> 6407			if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
> 6408				continue;
> 
> Add before "continue":
> 	pfn = ALIGN_DOWN(pfn, pageblock_nr_pages) + pageblock_nr_pageas - 1.
> At least, this way, we would skip a section of invalid memory at a time.
> 
> For the patch above:
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> 
> But, I think the 2nd patch with the optimization above should go along this
> this fix.

So I expect this patch needs a cc:stable, which I'll add.

The optimiation patch seems less important and I'd like to hold that
off for 4.19-rc1?
