Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id AB1306B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 06:47:02 -0400 (EDT)
Received: by wiar9 with SMTP id r9so31774609wia.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 03:47:02 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id bn1si18668348wib.38.2015.06.30.03.47.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 03:47:01 -0700 (PDT)
Received: by wiar9 with SMTP id r9so31773805wia.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 03:47:00 -0700 (PDT)
Date: Tue, 30 Jun 2015 12:46:54 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC v2 PATCH 0/8] mm: mirrored memory support for page buddy
 allocations
Message-ID: <20150630104654.GA24932@gmail.com>
References: <558E084A.60900@huawei.com>
 <20150630094149.GA6812@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150630094149.GA6812@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> [...]
> 
> Basically, overall I feel this series is the wrong approach but not knowing who 
> the users are making is much harder to judge. I strongly suspect that if 
> mirrored memory is to be properly used then it needs to be available before the 
> page allocator is even active. Once active, there needs to be controlled access 
> for allocation requests that are really critical to mirror and not just all 
> kernel allocations. None of that would use a MIGRATE_TYPE approach. It would be 
> alterations to the bootmem allocator and access to an explicit reserve that is 
> not accounted for as "free memory" and accessed via an explicit GFP flag.

So I think the main goal is to avoid kernel crashes when a #MC memory fault 
arrives on a piece of memory that is owned by the kernel.

In that sense 'protecting' all kernel allocations is natural: we don't know how to 
recover from faults that affect kernel memory.

We do know how to recover from faults that affect user-space memory alone.

So if a mechanism is in place that prioritizes 3 groups of allocators:

  - non-recoverable memory (kernel allocations mostly)

  - high priority user memory (critical apps that must never fail)

  - recoverable user memory (non-dirty caches that can simply be dropped,
    non-critical apps, etc.)

then we can make use of this hardware feature. I suspect this series tries to move 
in that direction.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
