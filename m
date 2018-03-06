Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id CBB836B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 07:53:07 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id l5-v6so9740115pli.8
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 04:53:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l11-v6si11541906pln.323.2018.03.06.04.53.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Mar 2018 04:53:06 -0800 (PST)
Date: Tue, 6 Mar 2018 04:53:04 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 3/3] mm/free_pcppages_bulk: prefetch buddy while not
 holding lock
Message-ID: <20180306125303.GA13722@bombadil.infradead.org>
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-4-aaron.lu@intel.com>
 <20180301140044.GK15057@dhcp22.suse.cz>
 <cb158b3d-c992-6679-24df-b37d2bb170e0@suse.cz>
 <20180305114159.GA32573@intel.com>
 <bdec481f-b402-64b6-75b0-350b370f3eac@suse.cz>
 <20180306122733.GA9664@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180306122733.GA9664@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>

On Tue, Mar 06, 2018 at 08:27:33PM +0800, Aaron Lu wrote:
> On Tue, Mar 06, 2018 at 08:55:57AM +0100, Vlastimil Babka wrote:
> > So the adjacent line prefetch might be disabled? Could you check bios or
> > the MSR mentioned in
> > https://software.intel.com/en-us/articles/disclosure-of-hw-prefetcher-control-on-some-intel-processors
> 
> root@lkp-bdw-ep2 ~# rdmsr 0x1a4
> 0

Technically 0x1a4 is per-core, so you should run rdmsr -a 0x1a4 in order to
check all the cores.  But I can't imagine they're being set differently on
each core.

> > instructions (calculated from itlb misses and insns-per-itlb-miss) shows
> > less than 1% increase, so dunno. And the improvement comes from reduced
> > dTLB-load-misses? That makes no sense for order-0 buddy struct pages
> > which always share a page. And the memmap mapping should use huge pages.
> 
> THP is disabled to stress order 0 pages(should have mentioned this in
> patch's description, sorry about this).

THP isn't related to memmap; the kernel uses huge pages (usually the 1G
pages) in order to map its own memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
