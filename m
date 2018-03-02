Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B0F1D6B0003
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 02:14:36 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k62so3758121pgd.11
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 23:14:36 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 61-v6si4443032plf.640.2018.03.01.23.14.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 23:14:35 -0800 (PST)
Date: Fri, 2 Mar 2018 15:15:34 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v4 2/3] mm/free_pcppages_bulk: do not hold lock when
 picking pages to free
Message-ID: <20180302071533.GA6356@intel.com>
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-3-aaron.lu@intel.com>
 <20180301135518.GJ15057@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180301135518.GJ15057@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On Thu, Mar 01, 2018 at 02:55:18PM +0100, Michal Hocko wrote:
> On Thu 01-03-18 14:28:44, Aaron Lu wrote:
> > When freeing a batch of pages from Per-CPU-Pages(PCP) back to buddy,
> > the zone->lock is held and then pages are chosen from PCP's migratetype
> > list. While there is actually no need to do this 'choose part' under
> > lock since it's PCP pages, the only CPU that can touch them is us and
> > irq is also disabled.
> > 
> > Moving this part outside could reduce lock held time and improve
> > performance. Test with will-it-scale/page_fault1 full load:
> > 
> > kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
> > v4.16-rc2+  9034215        7971818       13667135       15677465
> > this patch  9536374 +5.6%  8314710 +4.3% 14070408 +3.0% 16675866 +6.4%
> > 
> > What the test does is: starts $nr_cpu processes and each will repeatedly
> > do the following for 5 minutes:
> > 1 mmap 128M anonymouse space;
> > 2 write access to that space;
> > 3 munmap.
> > The score is the aggregated iteration.
> 
> Iteration count I assume.

Correct.

> I am still quite surprised that this would have such a large impact.

Most likely due to the cachelines for these page structures are warmed
up outside of zone->lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
