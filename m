Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1ED6B0253
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 16:51:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y83so3680038wmc.8
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 13:51:25 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id t25si5864427edi.551.2017.10.27.13.51.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Oct 2017 13:51:24 -0700 (PDT)
Subject: Re: [PATCH] mm: Simplify and batch working set shadow pages LRU
 isolation locking
References: <20171026234854.25764-1-andi@firstfloor.org>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <66fbc72d-e3e9-ccb1-1a16-cd7150d7e36e@oracle.com>
Date: Fri, 27 Oct 2017 16:51:01 -0400
MIME-Version: 1.0
In-Reply-To: <20171026234854.25764-1-andi@firstfloor.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On 10/26/2017 07:48 PM, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
>
> When shrinking the working set shadow pages LRU we currently
> use a complicated hand-over locking scheme. The isolation
> function runs under the local lru lock for the list, but
> it also needs to take the tree_lock for the address space.
>
> This is done by releasing the lru lock, and then trying
> to get the tree_lock and retrying on failure.

The lru lock is dropped after trying for the tree_lock, so maybe instead:

This is done by trying to get the tree_lock and then either retrying the 
operation if we don't get it or releasing the lru lock.


Otherwise the patch looks good, it's a lot simpler.

Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
