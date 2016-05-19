Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 55B7A6B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 16:20:09 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v128so187041725qkh.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 13:20:09 -0700 (PDT)
Received: from mail-yw0-x233.google.com (mail-yw0-x233.google.com. [2607:f8b0:4002:c05::233])
        by mx.google.com with ESMTPS id t63si7011558ywd.173.2016.05.19.13.20.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 13:20:08 -0700 (PDT)
Received: by mail-yw0-x233.google.com with SMTP id x194so89876594ywd.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 13:20:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160519020722.GC10245@js1304-P5Q-DELUXE>
References: <1463594175-111929-1-git-send-email-thgarnie@google.com>
 <1463594175-111929-3-git-send-email-thgarnie@google.com> <alpine.DEB.2.20.1605181323260.14349@east.gentwo.org>
 <CAJcbSZFhsZheqdZ5FD8auhiu8ozCyq-0xY1wjYu3j+Wc2R8nGg@mail.gmail.com>
 <alpine.DEB.2.20.1605181401560.29313@east.gentwo.org> <CAJcbSZHwZxH=NN+xk7N+O-47QQHmRchgqMS5==_HzH1no5ho9g@mail.gmail.com>
 <20160519020722.GC10245@js1304-P5Q-DELUXE>
From: Thomas Garnier <thgarnie@google.com>
Date: Thu, 19 May 2016 13:20:07 -0700
Message-ID: <CAJcbSZGUTJdzRDno=+V+F4Yu_gaU_k0UJq5xhF5PPwgKGi3O7A@mail.gmail.com>
Subject: Re: [RFC v1 2/2] mm: SLUB Freelist randomization
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Pranith Kumar <bobby.prani@gmail.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Woodhouse <David.Woodhouse@intel.com>, Petr Mladek <pmladek@suse.com>, Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, kernel-hardening@lists.openwall.com

I ran the test given by Joonsoo and it gave me these minimum cycles
per size across 20 usage:

size,before,after
8,63.00,64.50 (102.38%)
16,64.50,65.00 (100.78%)
32,65.00,65.00 (100.00%)
64,66.00,65.00 (98.48%)
128,66.00,65.00 (98.48%)
256,64.00,64.00 (100.00%)
512,65.00,66.00 (101.54%)
1024,68.00,64.00 (94.12%)
2048,66.00,65.00 (98.48%)
4096,66.00,66.00 (100.00%)

I assume the difference is bigger if you don't have RDRAND support.

Christoph, Joonsoo: Do you think it would be valuable to add a CONFIG
to disable additional randomization per new page? It will remove
additional entropy but increase performance for machines without arch
specific randomization instructions.

Thanks,
Thomas


On Wed, May 18, 2016 at 7:07 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Wed, May 18, 2016 at 12:12:13PM -0700, Thomas Garnier wrote:
>> I thought the mix of slab_test & kernbench would show a diverse
>> picture on perf data. Is there another test that you think would be
>> useful?
>
> Single thread testing on slab_test would be meaningful because it also
> touch the slowpath. Problem is just unstable result of slab_test.
>
> You can get more stable result of slab_test if you repeat same test
> sometimes and get average result.
>
> Please use following slab_test. It will do each operations 100000
> times and repeat it 50 times.
>
> https://github.com/JoonsooKim/linux/blob/slab_test_robust-next-20160509/mm/slab_test.c
>
> I did a quick test for this patchset and get following result.
>
> - Before (With patch and randomization is disabled by config)
>
> Single thread testing
> =====================
> 1. Kmalloc: Repeatedly allocate then free test
> 100000 times kmalloc(8) -> 42 cycles kfree -> 67 cycles
> 100000 times kmalloc(16) -> 43 cycles kfree -> 68 cycles
> 100000 times kmalloc(32) -> 47 cycles kfree -> 72 cycles
> 100000 times kmalloc(64) -> 54 cycles kfree -> 78 cycles
> 100000 times kmalloc(128) -> 75 cycles kfree -> 87 cycles
> 100000 times kmalloc(256) -> 84 cycles kfree -> 111 cycles
> 100000 times kmalloc(512) -> 82 cycles kfree -> 112 cycles
> 100000 times kmalloc(1024) -> 86 cycles kfree -> 113 cycles
> 100000 times kmalloc(2048) -> 113 cycles kfree -> 127 cycles
> 100000 times kmalloc(4096) -> 151 cycles kfree -> 154 cycles
>
> - After (With patch and randomization is enabled by config)
>
> Single thread testing
> =====================
> 1. Kmalloc: Repeatedly allocate then free test
> 100000 times kmalloc(8) -> 51 cycles kfree -> 68 cycles
> 100000 times kmalloc(16) -> 57 cycles kfree -> 70 cycles
> 100000 times kmalloc(32) -> 70 cycles kfree -> 75 cycles
> 100000 times kmalloc(64) -> 95 cycles kfree -> 84 cycles
> 100000 times kmalloc(128) -> 142 cycles kfree -> 97 cycles
> 100000 times kmalloc(256) -> 150 cycles kfree -> 107 cycles
> 100000 times kmalloc(512) -> 151 cycles kfree -> 107 cycles
> 100000 times kmalloc(1024) -> 154 cycles kfree -> 110 cycles
> 100000 times kmalloc(2048) -> 230 cycles kfree -> 124 cycles
> 100000 times kmalloc(4096) -> 423 cycles kfree -> 165 cycles
>
> It seems that performance decreases a lot but I don't care about it
> because it is a security feature and I don't have a better idea.
>
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
