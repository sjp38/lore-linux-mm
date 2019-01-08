Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0B2308E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 09:53:05 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id 39so1740268edq.13
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 06:53:04 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l13si19134edw.439.2019.01.08.06.53.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 06:53:03 -0800 (PST)
Date: Tue, 8 Jan 2019 15:53:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190108145302.GY31793@dhcp22.suse.cz>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
 <c320b754-b4b2-5b5b-1ed7-7d25ea114229@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c320b754-b4b2-5b5b-1ed7-7d25ea114229@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed 02-01-19 10:12:04, Dave Hansen wrote:
> On 12/28/18 12:41 AM, Michal Hocko wrote:
> >>
> >> It can be done in kernel page reclaim path, near the anonymous page
> >> swap out point. Instead of swapping out, we now have the option to
> >> migrate cold pages to PMEM NUMA nodes.
> > OK, this makes sense to me except I am not sure this is something that
> > should be pmem specific. Is there any reason why we shouldn't migrate
> > pages on memory pressure to other nodes in general? In other words
> > rather than paging out we whould migrate over to the next node that is
> > not under memory pressure. Swapout would be the next level when the
> > memory is (almost_) fully utilized. That wouldn't be pmem specific.
> 
> Yeah, we don't want to make this specific to any particular kind of
> memory.  For instance, with lots of pressure on expensive, small
> high-bandwidth memory (HBM), we might want to migrate some HBM contents
> to DRAM.
> 
> We need to decide on whether we want to cause pressure on the
> destination nodes or not, though.  I think you're suggesting that we try
> to look for things under some pressure and totally avoid them.  That
> sounds sane, but I also like the idea of this being somewhat ordered.
> 
> Think of if we have three nodes, A, B, C.  A is fast, B is medium, C is
> slow.  If A and B are "full" and we want to reclaim some of A, do we:
> 
> 1. Migrate A->B, and put pressure on a later B->C migration, or
> 2. Migrate A->C directly
> 
> ?
> 
> Doing A->C is less resource intensive because there's only one migration
> involved.  But, doing A->B/B->C probably makes the app behave better
> because the "A data" is presumably more valuable and is more
> appropriately placed in B rather than being demoted all the way to C.

This is a good question and I do not have a good answer because I lack
experiences with such "many levels" systems. If we followed CPU caches
model ten you are right that the fallback should be gradual. This is
more complex implementation wise of course. Anyway, I believe that there
is a lot of room for experimentations. If this stays an internal
implementation detail without user API then there is also no promise on
future behavior so nothing gets carved into stone since the day 1 when
our experiences are limited.

-- 
Michal Hocko
SUSE Labs
