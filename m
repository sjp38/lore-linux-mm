Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 330BE83116
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 20:48:34 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id o3so19564085ita.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 17:48:34 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 139si17069571itw.60.2016.08.29.17.48.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 17:48:33 -0700 (PDT)
Subject: Re: [PATCH v4 resend] mm/slab: Improve performance of gathering
 slabinfo stats
References: <1472517876-26814-1-git-send-email-aruna.ramakrishna@oracle.com>
From: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Message-ID: <1760d6be-2345-5dc3-240c-3299cb4a1fda@oracle.com>
Date: Mon, 29 Aug 2016 17:48:25 -0700
MIME-Version: 1.0
In-Reply-To: <1472517876-26814-1-git-send-email-aruna.ramakrishna@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On 08/29/2016 05:44 PM, Aruna Ramakrishna wrote:
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
>
> Signed-off-by: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
> Note: this has been tested only on x86_64.
>

This patch has spawned off a very interesting discussion in a older 
thread, and I guess the latest incarnation of this patch got buried. I'm 
resending it for review/approval.

Thanks,
Aruna

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
