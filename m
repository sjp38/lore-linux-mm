Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 01B976B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:34:30 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fn2so97096903pad.7
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 17:34:29 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id v143si12940747pgb.176.2016.10.13.17.34.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 17:34:29 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id s8so6014149pfj.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 17:34:29 -0700 (PDT)
Date: Thu, 13 Oct 2016 20:34:26 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix several trivial issues
Message-ID: <20161014003426.GJ32534@mtj.duckdns.org>
References: <e9cf3570-2c35-42f6-4bb1-f60734651e6c@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e9cf3570-2c35-42f6-4bb1-f60734651e6c@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: akpm@linux-foundation.org, zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

On Tue, Oct 11, 2016 at 09:29:27PM +0800, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> as shown by pcpu_setup_first_chunk(), the first chunk is same as the
> reserved chunk if the reserved size is nonzero but the dynamic is zero
> this special scenario is referred as the special case by below content
> 
> fix several trivial issues:
> 
> 1) correct or fix several comments
> the LSB of a chunk->map element is used as free/in-use flag and is cleared
> for free area and set for in-use, rather than use positive/negative number
> to mark area state.
> 
> 2) change atomic size to PAGE_SIZE for consistency when CONFIG_SMP == n
> both default setup_per_cpu_areas() and pcpu_page_first_chunk()
> use PAGE_SIZE as atomic size when CONFIG_SMP == y; however
> setup_per_cpu_areas() allocates memory for the only unit with alignment
> PAGE_SIZE but assigns unit size to atomic size when CONFIG_SMP == n, so the
> atomic size isn't consistent with either the alignment or the SMP ones.
> fix it by changing atomic size to PAGE_SIZE when CONFIG_SMP == n
> 
> 3) correct empty and populated pages statistic error
> in order to service dynamic atomic memory allocation, the number of empty
> and populated pages of chunks is counted to maintain above a low threshold.
> however, for the special case, the first chunk is took into account by
> pcpu_setup_first_chunk(), it is meaningless since the chunk don't include
> any dynamic areas.
> fix it by excluding the reserved chunk before statistic as the other
> contexts do.
> 
> 4) fix potential memory leakage for percpu_init_late()
> in order to manage chunk->map memory uniformly, for the first and reserved
> chunks, percpu_init_late() will allocate memory to replace the static
> chunk->map array within section .init.data after slab is brought up
> however, for the special case, memory are allocated for the same chunk->map
> twice since the first chunk reference is same as the reserved, so the
> memory allocated at the first time are leaked obviously.
> fix it by eliminating the second memory allocation under the special case
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>

Can you please break the changes into separate patches?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
