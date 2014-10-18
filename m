Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE086B0069
	for <linux-mm@kvack.org>; Sat, 18 Oct 2014 13:59:11 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so2687155pac.0
        for <linux-mm@kvack.org>; Sat, 18 Oct 2014 10:59:10 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id m13si3931832pdj.84.2014.10.18.10.59.09
        for <linux-mm@kvack.org>;
        Sat, 18 Oct 2014 10:59:09 -0700 (PDT)
Date: Sat, 18 Oct 2014 13:59:07 -0400 (EDT)
Message-Id: <20141018.135907.356113264227709132.davem@davemloft.net>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@davemloft.net>
In-Reply-To: <alpine.LRH.2.11.1410171410210.25429@adalberg.ut.ee>
References: <20141016.162001.599580415052560455.davem@redhat.com>
	<20141016.165017.1151349565275102498.davem@davemloft.net>
	<alpine.LRH.2.11.1410171410210.25429@adalberg.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mroos@linux.ee
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

From: Meelis Roos <mroos@linux.ee>
Date: Fri, 17 Oct 2014 14:12:09 +0300 (EEST)

> However, on top of mainline HEAD 3.17.0-09670-g0429fbc it explodes with 
> scheduler BUG - just reported to LKML + sched maintainers.

task_stack_end_corrupted() cannot work properly on sparc64.

It stores the magic value at "task_thread_info(p) + 1", but on
sparc64 that's where we store the nested array of FPU register
saves.

In fact this facility could be corrupting FPU register state in
certain circumstances.

The current sparc64 design is intentional, the CPU stack grows down
toward the thread_info, and the FPU stack saving area grows up from
the end of thread_info.

I don't want to define the array size of the fpregs save area
explicitly and thereby placing an artificial limit there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
