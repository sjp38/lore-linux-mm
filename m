Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id F243E6B0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 23:36:14 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id rr4so547300pbb.13
        for <linux-mm@kvack.org>; Tue, 12 Mar 2013 20:36:14 -0700 (PDT)
Message-ID: <513FF3F3.2000509@gmail.com>
Date: Wed, 13 Mar 2013 11:35:15 +0800
From: Shuge <shugelinux@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] bounce:fix bug, avoid to flush dcache on slab page from
 jbd2.
References: <5139DB90.5090302@gmail.com> <20130312153221.0d26fe5599d4885e51bb0c7c@linux-foundation.org> <20130313011020.GA5313@blackbox.djwong.org>
In-Reply-To: <20130313011020.GA5313@blackbox.djwong.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Kevin <kevin@allwinnertech.com>, Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Jens Axboe <axboe@kernel.dk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org

Hi all
>>> The bounce accept slab pages from jbd2, and flush dcache on them.
>>> When enabling VM_DEBUG, it will tigger VM_BUG_ON in page_mapping().
>>> So, check PageSlab to avoid it in __blk_queue_bounce().
>>>
>>> Bug URL: http://lkml.org/lkml/2013/3/7/56
>>>
>>> ...
>>>
>> ......
>>
> That sure is strange.  I didn't see any obvious reasons why we'd end up with a
>
......

     Well, this problem not only appear in arm64, but also arm32. And my 
kernel version is 3.3.0, arch is arm32.
Following the newest kernel, the problem shoulde be exist.
     I agree with Darrick's modification. Hum, if 
CONFIG_NEED_BOUNCE_POOL is not set, it also flush dcahce on
the pages of b_frozen_data, some of them are allocated by kmem_cache_alloc.
     As we know, jbd2_alloc allocate a buffer from jbd2_xk slab pool, 
when the size is smaller than PAGE_SIZE.
The b_frozen_data  is not mapped to usrspace, not aliasing cache. It cat 
be lazy flush or other. Is it right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
