Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5406B0388
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 11:44:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t143so39231090pgb.5
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 08:44:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a125si2444286pgc.9.2017.03.15.08.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 08:44:00 -0700 (PDT)
Date: Wed, 15 Mar 2017 23:44:07 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170315154406.GF2442@aaronlu.sh.intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170315141813.GB32626@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Wed, Mar 15, 2017 at 03:18:14PM +0100, Michal Hocko wrote:
> On Wed 15-03-17 16:59:59, Aaron Lu wrote:
> [...]
> > The proposed parallel free did this: if the process has many pages to be
> > freed, accumulate them in these struct mmu_gather_batch(es) one after
> > another till 256K pages are accumulated. Then take this singly linked
> > list starting from tlb->local.next off struct mmu_gather *tlb and free
> > them in a worker thread. The main thread can return to continue zap
> > other pages(after freeing pages pointed by tlb->local.pages).
> 
> I didn't have a look at the implementation yet but there are two
> concerns that raise up from this description. Firstly how are we going
> to tune the number of workers. I assume there will be some upper bound
> (one of the patch subject mentions debugfs for tuning) and secondly

The workers are put in a dedicated workqueue which is introduced in
patch 3/5 and the number of workers can be tuned through that workqueue's
sysfs interface: max_active.

> if we offload the page freeing to the worker then the original context
> can consume much more cpu cycles than it was configured via cpu
> controller. How are we going to handle that? Or is this considered
> acceptable?

I'll need to think about and take a look at this subject(not familiar
with cpu controller).

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
