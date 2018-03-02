Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 874DA6B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 19:01:09 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 96so2844941wrk.12
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 16:01:09 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q37si3646753wrb.536.2018.03.01.16.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 16:01:08 -0800 (PST)
Date: Thu, 1 Mar 2018 16:01:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/3] mm/free_pcppages_bulk: do not hold lock when
 picking pages to free
Message-Id: <20180301160105.aca958fac871998d582307d4@linux-foundation.org>
In-Reply-To: <20180301062845.26038-3-aaron.lu@intel.com>
References: <20180301062845.26038-1-aaron.lu@intel.com>
	<20180301062845.26038-3-aaron.lu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On Thu,  1 Mar 2018 14:28:44 +0800 Aaron Lu <aaron.lu@intel.com> wrote:

> When freeing a batch of pages from Per-CPU-Pages(PCP) back to buddy,
> the zone->lock is held and then pages are chosen from PCP's migratetype
> list. While there is actually no need to do this 'choose part' under
> lock since it's PCP pages, the only CPU that can touch them is us and
> irq is also disabled.
> 
> Moving this part outside could reduce lock held time and improve
> performance. Test with will-it-scale/page_fault1 full load:
> 
> kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
> v4.16-rc2+  9034215        7971818       13667135       15677465
> this patch  9536374 +5.6%  8314710 +4.3% 14070408 +3.0% 16675866 +6.4%
> 
> What the test does is: starts $nr_cpu processes and each will repeatedly
> do the following for 5 minutes:
> 1 mmap 128M anonymouse space;
> 2 write access to that space;
> 3 munmap.
> The score is the aggregated iteration.

But it's a loss for uniprocessor systems: it adds more code and adds an
additional pass across a list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
