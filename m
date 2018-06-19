Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DE1D16B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 18:21:52 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t5-v6so353216pgt.18
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 15:21:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c18-v6si780538pls.407.2018.06.19.15.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 15:21:51 -0700 (PDT)
Date: Tue, 19 Jun 2018 15:21:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] slub: fix __kmem_cache_empty for !CONFIG_SLUB_DEBUG
Message-Id: <20180619152150.ad3c245bc0e0b2ea4cce8154@linux-foundation.org>
In-Reply-To: <20180619213352.71740-1-shakeelb@google.com>
References: <20180619213352.71740-1-shakeelb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: "Jason A . Donenfeld" <Jason@zx2c4.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

On Tue, 19 Jun 2018 14:33:52 -0700 Shakeel Butt <shakeelb@google.com> wrote:

> For !CONFIG_SLUB_DEBUG, SLUB does not maintain the number of slabs
> allocated per node for a kmem_cache. Thus, slabs_node() in
> __kmem_cache_empty() will always return 0. So, in such situation, it is
> required to check per-cpu slabs to make sure if a kmem_cache is empty or
> not.
> 
> Please note that __kmem_cache_shutdown() and __kmem_cache_shrink() are
> not affected by !CONFIG_SLUB_DEBUG as they call flush_all() to clear
> per-cpu slabs.

Thanks guys.  I'll beef up this changelog a bit by adding

f9e13c0a5a33 ("slab, slub: skip unnecessary kasan_cache_shutdown()")
causes crashes when using slub, as described at
http://lkml.kernel.org/r/CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com

So that a) Greg knows why we're sending it at him and b) other people
who are seeing the same sorts of crashes in their various kernels will
know that this patch will probably fix them.
