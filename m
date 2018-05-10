Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D5E766B05D1
	for <linux-mm@kvack.org>; Thu, 10 May 2018 04:41:23 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f23-v6so915002wra.20
        for <linux-mm@kvack.org>; Thu, 10 May 2018 01:41:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u19-v6si601013edi.253.2018.05.10.01.41.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 May 2018 01:41:22 -0700 (PDT)
Date: Thu, 10 May 2018 10:41:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v1 0/6] use mm to manage NVDIMM (pmem) zone
Message-ID: <20180510084119.GJ32366@dhcp22.suse.cz>
References: <1525746628-114136-1-git-send-email-yehs1@lenovo.com>
 <20180510075759.GF32366@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180510075759.GF32366@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng Ye <yehs1@lenovo.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, pasha.tatashin@oracle.com, alexander.levin@verizon.com, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org

I have only now noticed that you have posted this few days ago
http://lkml.kernel.org/r/1525704627-30114-1-git-send-email-yehs1@lenovo.com
There were some good questions asked there and I have many that are
common yet they are not covered in the cover letter. Please _always_
make sure to answer review comments before reposting. Otherwise some
important parts gets lost on the way.

On Thu 10-05-18 09:57:59, Michal Hocko wrote:
> On Tue 08-05-18 10:30:22, Huaisheng Ye wrote:
> > Traditionally, NVDIMMs are treated by mm(memory management) subsystem as
> > DEVICE zone, which is a virtual zone and both its start and end of pfn
> > are equal to 0, mm wouldna??t manage NVDIMM directly as DRAM, kernel uses
> > corresponding drivers, which locate at \drivers\nvdimm\ and
> > \drivers\acpi\nfit and fs, to realize NVDIMM memory alloc and free with
> > memory hot plug implementation.
> > 
> > With current kernel, many mma??s classical features like the buddy
> > system, swap mechanism and page cache couldna??t be supported to NVDIMM.
> > What we are doing is to expand kernel mma??s capacity to make it to handle
> > NVDIMM like DRAM. Furthermore we make mm could treat DRAM and NVDIMM
> > separately, that means mm can only put the critical pages to NVDIMM
> > zone, here we created a new zone type as NVM zone.
> 
> How do you define critical pages? Who is allowed to allocate from them?
> You do not seem to add _any_ user of GFP_NVM.
> 
> > That is to say for
> > traditional(or normal) pages which would be stored at DRAM scope like
> > Normal, DMA32 and DMA zones. But for the critical pages, which we hope
> > them could be recovered from power fail or system crash, we make them
> > to be persistent by storing them to NVM zone.
> 
> This brings more questions than it answers. First of all is this going
> to be any guarantee? Let's say I want GFP_NVM, can I get memory from
> other zones? In other words is such a request allowed to fallback to
> succeed? Are we allowed to reclaim memory from the new zone? What should
> happen on the OOM? How is the user expected to restore the previous
> content after reboot/crash?
> 
> I am sorry if these questions are answered in the respective patches but
> it would be great to have this in the cover letter to have a good
> overview of the whole design. From my quick glance over patches my
> previous concerns about an additional zone still hold, though.
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs
