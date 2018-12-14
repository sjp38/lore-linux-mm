Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 174D28E01C5
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 05:20:03 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i14so2522905edf.17
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 02:20:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m1si1328287edj.174.2018.12.14.02.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 02:20:01 -0800 (PST)
Date: Fri, 14 Dec 2018 11:19:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/1] mm, memory_hotplug: Initialize struct pages for
 the full memory section
Message-ID: <20181214101651.GE5624@dhcp22.suse.cz>
References: <20181212172712.34019-1-zaslonko@linux.ibm.com>
 <20181212172712.34019-2-zaslonko@linux.ibm.com>
 <20181213034615.4ntpo4cl2oo5mcx4@master>
 <e4cebbae-3fcb-f03c-3d0e-a1a44ff0675a@linux.bm.com>
 <20181213151209.hmrhrr5gvb256bzm@master>
 <674c53e2-e4b3-f21f-4613-b149acef7e53@linux.bm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <674c53e2-e4b3-f21f-4613-b149acef7e53@linux.bm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zaslonko Mikhail <zaslonko@linux.ibm.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

[Your From address seems to have a typo (linux.bm.com) - fixed]

On Fri 14-12-18 10:33:55, Zaslonko Mikhail wrote:
[...]
> Yes, it might still trigger PF_POISONED_CHECK if the first page 
> of the pageblock is left uninitialized (poisoned).
> But in order to cover these exceptional cases we would need to 
> adjust memory_hotplug sysfs handler functions with similar 
> checks (as in the for loop of memmap_init_zone()). And I guess 
> that is what we were trying to avoid (adding special cases to 
> memory_hotplug paths).

is_mem_section_removable should test pfn_valid_within at least.
But that would require some care because next_active_pageblock expects
aligned pages. Ble, this code is just horrible. I would just remove it
altogether. I strongly suspect that nobody is using it for anything
reasonable anyway. The only reliable way to check whether a block is
removable is to remove it. Everything else is just racy.

-- 
Michal Hocko
SUSE Labs
