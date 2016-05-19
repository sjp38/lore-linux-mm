Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06AE26B0005
	for <linux-mm@kvack.org>; Wed, 18 May 2016 22:06:58 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id i5so129662418ige.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 19:06:58 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 199si21987515itx.64.2016.05.18.19.06.56
        for <linux-mm@kvack.org>;
        Wed, 18 May 2016 19:06:57 -0700 (PDT)
Date: Thu, 19 May 2016 11:07:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC v1 2/2] mm: SLUB Freelist randomization
Message-ID: <20160519020722.GC10245@js1304-P5Q-DELUXE>
References: <1463594175-111929-1-git-send-email-thgarnie@google.com>
 <1463594175-111929-3-git-send-email-thgarnie@google.com>
 <alpine.DEB.2.20.1605181323260.14349@east.gentwo.org>
 <CAJcbSZFhsZheqdZ5FD8auhiu8ozCyq-0xY1wjYu3j+Wc2R8nGg@mail.gmail.com>
 <alpine.DEB.2.20.1605181401560.29313@east.gentwo.org>
 <CAJcbSZHwZxH=NN+xk7N+O-47QQHmRchgqMS5==_HzH1no5ho9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJcbSZHwZxH=NN+xk7N+O-47QQHmRchgqMS5==_HzH1no5ho9g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Pranith Kumar <bobby.prani@gmail.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Woodhouse <David.Woodhouse@intel.com>, Petr Mladek <pmladek@suse.com>, Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, kernel-hardening@lists.openwall.com

On Wed, May 18, 2016 at 12:12:13PM -0700, Thomas Garnier wrote:
> I thought the mix of slab_test & kernbench would show a diverse
> picture on perf data. Is there another test that you think would be
> useful?

Single thread testing on slab_test would be meaningful because it also
touch the slowpath. Problem is just unstable result of slab_test.

You can get more stable result of slab_test if you repeat same test
sometimes and get average result.

Please use following slab_test. It will do each operations 100000
times and repeat it 50 times.

https://github.com/JoonsooKim/linux/blob/slab_test_robust-next-20160509/mm/slab_test.c

I did a quick test for this patchset and get following result.

- Before (With patch and randomization is disabled by config)

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate then free test
100000 times kmalloc(8) -> 42 cycles kfree -> 67 cycles
100000 times kmalloc(16) -> 43 cycles kfree -> 68 cycles
100000 times kmalloc(32) -> 47 cycles kfree -> 72 cycles
100000 times kmalloc(64) -> 54 cycles kfree -> 78 cycles
100000 times kmalloc(128) -> 75 cycles kfree -> 87 cycles
100000 times kmalloc(256) -> 84 cycles kfree -> 111 cycles
100000 times kmalloc(512) -> 82 cycles kfree -> 112 cycles
100000 times kmalloc(1024) -> 86 cycles kfree -> 113 cycles
100000 times kmalloc(2048) -> 113 cycles kfree -> 127 cycles
100000 times kmalloc(4096) -> 151 cycles kfree -> 154 cycles

- After (With patch and randomization is enabled by config)

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate then free test
100000 times kmalloc(8) -> 51 cycles kfree -> 68 cycles
100000 times kmalloc(16) -> 57 cycles kfree -> 70 cycles
100000 times kmalloc(32) -> 70 cycles kfree -> 75 cycles
100000 times kmalloc(64) -> 95 cycles kfree -> 84 cycles
100000 times kmalloc(128) -> 142 cycles kfree -> 97 cycles
100000 times kmalloc(256) -> 150 cycles kfree -> 107 cycles
100000 times kmalloc(512) -> 151 cycles kfree -> 107 cycles
100000 times kmalloc(1024) -> 154 cycles kfree -> 110 cycles
100000 times kmalloc(2048) -> 230 cycles kfree -> 124 cycles
100000 times kmalloc(4096) -> 423 cycles kfree -> 165 cycles

It seems that performance decreases a lot but I don't care about it
because it is a security feature and I don't have a better idea.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
