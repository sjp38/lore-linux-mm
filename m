Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E89B6B0007
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 21:15:32 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p12-v6so1222221qtg.5
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:15:32 -0700 (PDT)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id a25-v6si2306267qtp.285.2018.06.20.18.15.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Jun 2018 18:15:31 -0700 (PDT)
Date: Thu, 21 Jun 2018 01:15:30 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: track number of slabs irrespective of
 CONFIG_SLUB_DEBUG
In-Reply-To: <20180620224147.23777-1-shakeelb@google.com>
Message-ID: <010001641fe92599-9006a895-d1ea-4881-a63c-f3749ff9b7b3-000000@email.amazonses.com>
References: <20180620224147.23777-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: "Jason A . Donenfeld" <Jason@zx2c4.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Wed, 20 Jun 2018, Shakeel Butt wrote:

> For !CONFIG_SLUB_DEBUG, SLUB does not maintain the number of slabs
> allocated per node for a kmem_cache. Thus, slabs_node() in
> __kmem_cache_empty(), __kmem_cache_shrink() and __kmem_cache_destroy()
> will always return 0 for such config. This is wrong and can cause issues
> for all users of these functions.


CONFIG_SLUB_DEBUG is set by default on almost all builds. The only case
where CONFIG_SLUB_DEBUG is switched off is when we absolutely need to use
the minimum amount of memory (embedded or some such thing).

> The right solution is to make slabs_node() work even for
> !CONFIG_SLUB_DEBUG. The commit 0f389ec63077 ("slub: No need for per node
> slab counters if !SLUB_DEBUG") had put the per node slab counter under
> CONFIG_SLUB_DEBUG because it was only read through sysfs API and the
> sysfs API was disabled on !CONFIG_SLUB_DEBUG. However the users of the
> per node slab counter assumed that it will work in the absence of
> CONFIG_SLUB_DEBUG. So, make the counter work for !CONFIG_SLUB_DEBUG.

Please do not do this. Find a way to avoid these checks. The
objective of a !CONFIG_SLUB_DEBUG configuration is to not compile in
debuggin checks etc etc in order to reduce the code/data footprint to the
minimum necessary while sacrificing debuggability etc etc.

Maybe make it impossible to disable CONFIG_SLUB_DEBUG if CGROUPs are in
use?
