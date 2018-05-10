Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 795626B05CE
	for <linux-mm@kvack.org>; Thu, 10 May 2018 03:58:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x23-v6so761439pfm.7
        for <linux-mm@kvack.org>; Thu, 10 May 2018 00:58:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h14-v6si239792plk.535.2018.05.10.00.58.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 May 2018 00:58:05 -0700 (PDT)
Date: Thu, 10 May 2018 09:57:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v1 0/6] use mm to manage NVDIMM (pmem) zone
Message-ID: <20180510075759.GF32366@dhcp22.suse.cz>
References: <1525746628-114136-1-git-send-email-yehs1@lenovo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1525746628-114136-1-git-send-email-yehs1@lenovo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng Ye <yehs1@lenovo.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, pasha.tatashin@oracle.com, alexander.levin@verizon.com, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org

On Tue 08-05-18 10:30:22, Huaisheng Ye wrote:
> Traditionally, NVDIMMs are treated by mm(memory management) subsystem as
> DEVICE zone, which is a virtual zone and both its start and end of pfn
> are equal to 0, mm wouldna??t manage NVDIMM directly as DRAM, kernel uses
> corresponding drivers, which locate at \drivers\nvdimm\ and
> \drivers\acpi\nfit and fs, to realize NVDIMM memory alloc and free with
> memory hot plug implementation.
> 
> With current kernel, many mma??s classical features like the buddy
> system, swap mechanism and page cache couldna??t be supported to NVDIMM.
> What we are doing is to expand kernel mma??s capacity to make it to handle
> NVDIMM like DRAM. Furthermore we make mm could treat DRAM and NVDIMM
> separately, that means mm can only put the critical pages to NVDIMM
> zone, here we created a new zone type as NVM zone.

How do you define critical pages? Who is allowed to allocate from them?
You do not seem to add _any_ user of GFP_NVM.

> That is to say for
> traditional(or normal) pages which would be stored at DRAM scope like
> Normal, DMA32 and DMA zones. But for the critical pages, which we hope
> them could be recovered from power fail or system crash, we make them
> to be persistent by storing them to NVM zone.

This brings more questions than it answers. First of all is this going
to be any guarantee? Let's say I want GFP_NVM, can I get memory from
other zones? In other words is such a request allowed to fallback to
succeed? Are we allowed to reclaim memory from the new zone? What should
happen on the OOM? How is the user expected to restore the previous
content after reboot/crash?

I am sorry if these questions are answered in the respective patches but
it would be great to have this in the cover letter to have a good
overview of the whole design. From my quick glance over patches my
previous concerns about an additional zone still hold, though.
-- 
Michal Hocko
SUSE Labs
