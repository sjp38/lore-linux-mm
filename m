Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 058576B0005
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 00:36:20 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o9so7350857pgv.19
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 21:36:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r2-v6si17607039pgj.139.2018.11.12.21.36.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 21:36:18 -0800 (PST)
Date: Mon, 12 Nov 2018 21:36:15 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] vmscan: return NODE_RECLAIM_NOSCAN in node_reclaim()
 when CONFIG_NUMA is n
Message-ID: <20181113053615.GJ21824@bombadil.infradead.org>
References: <20181113041750.20784-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113041750.20784-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 13, 2018 at 12:17:50PM +0800, Wei Yang wrote:
> Commit fa5e084e43eb ("vmscan: do not unconditionally treat zones that
> fail zone_reclaim() as full") changed the return value of node_reclaim().
> The original return value 0 means NODE_RECLAIM_SOME after this commit.
> 
> While the return value of node_reclaim() when CONFIG_NUMA is n is not
> changed. This will leads to call zone_watermark_ok() again.
> 
> This patch fix the return value by adjusting to NODE_RECLAIM_NOSCAN. Since
> it is not proper to include "mm/internal.h", just hard coded it.

Since the return value is defined in mm/internal.h that means no code
outside mm/ can call node_reclaim (nor should it).  So let's move both
of node_reclaim's declarations to mm/internal.h instead of keeping them
in linux/swap.h.
