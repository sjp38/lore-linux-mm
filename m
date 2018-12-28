Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9EBA58E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 03:41:11 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id h10so17934793plk.12
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 00:41:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q18si36142023pls.30.2018.12.28.00.41.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 00:41:10 -0800 (PST)
Date: Fri, 28 Dec 2018 09:41:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20181228084105.GQ16738@dhcp22.suse.cz>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Fri 28-12-18 13:08:06, Wu Fengguang wrote:
[...]
> Optimization: do hot/cold page tracking and migration
> =====================================================
> 
> Since PMEM is slower than DRAM, we need to make sure hot pages go to
> DRAM and cold pages stay in PMEM, to get the best out of PMEM and DRAM.
> 
> - DRAM=>PMEM cold page migration
> 
> It can be done in kernel page reclaim path, near the anonymous page
> swap out point. Instead of swapping out, we now have the option to
> migrate cold pages to PMEM NUMA nodes.

OK, this makes sense to me except I am not sure this is something that
should be pmem specific. Is there any reason why we shouldn't migrate
pages on memory pressure to other nodes in general? In other words
rather than paging out we whould migrate over to the next node that is
not under memory pressure. Swapout would be the next level when the
memory is (almost_) fully utilized. That wouldn't be pmem specific.

> User space may also do it, however cannot act on-demand, when there
> are memory pressure in DRAM nodes.
> 
> - PMEM=>DRAM hot page migration
> 
> While LRU can be good enough for identifying cold pages, frequency
> based accounting can be more suitable for identifying hot pages.
> 
> Our design choice is to create a flexible user space daemon to drive
> the accounting and migration, with necessary kernel supports by this
> patchset.

We do have numa balancing, why cannot we rely on it? This along with the
above would allow to have pmem numa nodes (cpuless nodes in fact)
without any special casing and a natural part of the MM. It would be
only the matter of the configuration to set the appropriate distance to
allow reasonable allocation fallback strategy.

I haven't looked at the implementation yet but if you are proposing a
special cased zone lists then this is something CDM (Coherent Device
Memory) was trying to do two years ago and there was quite some
skepticism in the approach.
-- 
Michal Hocko
SUSE Labs
