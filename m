Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4926B0005
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 17:06:09 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so427661925pad.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 14:06:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ik5si16357786pac.111.2016.08.04.14.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 14:06:08 -0700 (PDT)
Date: Thu, 4 Aug 2016 14:06:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/slab: Improve performance of gathering slabinfo
 stats
Message-Id: <20160804140607.49e84fd1e24f5e03bc151538@linux-foundation.org>
In-Reply-To: <1470337273-6700-1-git-send-email-aruna.ramakrishna@oracle.com>
References: <1470337273-6700-1-git-send-email-aruna.ramakrishna@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu,  4 Aug 2016 12:01:13 -0700 Aruna Ramakrishna <aruna.ramakrishna@oracle.com> wrote:

> On large systems, when some slab caches grow to millions of objects (and
> many gigabytes), running 'cat /proc/slabinfo' can take up to 1-2 seconds.
> During this time, interrupts are disabled while walking the slab lists
> (slabs_full, slabs_partial, and slabs_free) for each node, and this
> sometimes causes timeouts in other drivers (for instance, Infiniband).
> 
> This patch optimizes 'cat /proc/slabinfo' by maintaining a counter for
> total number of allocated slabs per node, per cache. This counter is
> updated when a slab is created or destroyed. This enables us to skip
> traversing the slabs_full list while gathering slabinfo statistics, and
> since slabs_full tends to be the biggest list when the cache is large, it
> results in a dramatic performance improvement. Getting slabinfo statistics
> now only requires walking the slabs_free and slabs_partial lists, and
> those lists are usually much smaller than slabs_full. We tested this after
> growing the dentry cache to 70GB, and the performance improved from 2s to
> 5ms.

I assume this is tested on both slab and slub?

It isn't the smallest of patches but given the seriousness of the
problem I think I'll tag it for -stable backporting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
