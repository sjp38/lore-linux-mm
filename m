Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBAFE6B0389
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 10:18:16 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g10so3249566wrg.5
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 07:18:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g29si630183wmi.145.2017.03.15.07.18.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 07:18:15 -0700 (PDT)
Date: Wed, 15 Mar 2017 15:18:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170315141813.GB32626@dhcp22.suse.cz>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Wed 15-03-17 16:59:59, Aaron Lu wrote:
[...]
> The proposed parallel free did this: if the process has many pages to be
> freed, accumulate them in these struct mmu_gather_batch(es) one after
> another till 256K pages are accumulated. Then take this singly linked
> list starting from tlb->local.next off struct mmu_gather *tlb and free
> them in a worker thread. The main thread can return to continue zap
> other pages(after freeing pages pointed by tlb->local.pages).

I didn't have a look at the implementation yet but there are two
concerns that raise up from this description. Firstly how are we going
to tune the number of workers. I assume there will be some upper bound
(one of the patch subject mentions debugfs for tuning) and secondly
if we offload the page freeing to the worker then the original context
can consume much more cpu cycles than it was configured via cpu
controller. How are we going to handle that? Or is this considered
acceptable?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
