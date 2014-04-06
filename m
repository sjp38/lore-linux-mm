Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id EF4F56B0035
	for <linux-mm@kvack.org>; Sun,  6 Apr 2014 13:47:06 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id gf5so4017096lab.35
        for <linux-mm@kvack.org>; Sun, 06 Apr 2014 10:47:06 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y8si10334529lae.28.2014.04.06.10.47.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Apr 2014 10:47:05 -0700 (PDT)
Message-ID: <53419305.7090104@parallels.com>
Date: Sun, 6 Apr 2014 21:46:45 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 0/3] slab: cleanup mem hotplug synchronization
References: <cover.1396779337.git.vdavydov@parallels.com>
In-Reply-To: <cover.1396779337.git.vdavydov@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On 04/06/2014 07:33 PM, Vladimir Davydov wrote:
> kmem_cache_{create,destroy,shrink} need to get a stable value of
> cpu/node online mask, because they init/destroy/access per-cpu/node
> kmem_cache parts, which can be allocated or destroyed on cpu/mem
> hotplug. To protect against cpu hotplug, these functions use
> {get,put}_online_cpus. However, they do nothing to synchronize with
> memory hotplug - taking the slab_mutex does not eliminate the
> possibility of race as described in patch 3.
>
> What we need there is something like get_online_cpus, but for memory. We
> already have lock_memory_hotplug, which serves for the purpose, but it's
> a bit of a hammer right now, because it's backed by a mutex. As a
> result, it imposes some limitations to locking order, which are not
> desirable, and can't be used just like get_online_cpus. I propose to
> turn this mutex into an rw semaphore, which will be taken for reading in
> lock_memory_hotplug and for writing in memory hotplug code (that's what
> patch 1 does).

This is absolutely wrong, because down_read cannot be nested inside
down/up_write critical section. Although it would work now, it could
result in deadlocks in future. Please ignore this set completely.

Actually we need to implement a recursive rw semaphore here, just like
cpu_hotplug_lock.

Sorry for the noise.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
