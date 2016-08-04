Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7D5C6B0005
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 17:49:37 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e139so527003069oib.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 14:49:37 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b70si8591502oih.170.2016.08.04.14.49.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 14:49:37 -0700 (PDT)
Subject: Re: [PATCH v2] mm/slab: Improve performance of gathering slabinfo
 stats
References: <1470337273-6700-1-git-send-email-aruna.ramakrishna@oracle.com>
 <20160804140607.49e84fd1e24f5e03bc151538@linux-foundation.org>
From: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Message-ID: <ae512e3e-201a-4176-fa03-22aa2edad41b@oracle.com>
Date: Thu, 4 Aug 2016 14:49:29 -0700
MIME-Version: 1.0
In-Reply-To: <20160804140607.49e84fd1e24f5e03bc151538@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>



On 08/04/2016 02:06 PM, Andrew Morton wrote:
> On Thu,  4 Aug 2016 12:01:13 -0700 Aruna Ramakrishna <aruna.ramakrishna@oracle.com> wrote:
>
>> On large systems, when some slab caches grow to millions of objects (and
>> many gigabytes), running 'cat /proc/slabinfo' can take up to 1-2 seconds.
>> During this time, interrupts are disabled while walking the slab lists
>> (slabs_full, slabs_partial, and slabs_free) for each node, and this
>> sometimes causes timeouts in other drivers (for instance, Infiniband).
>>
>> This patch optimizes 'cat /proc/slabinfo' by maintaining a counter for
>> total number of allocated slabs per node, per cache. This counter is
>> updated when a slab is created or destroyed. This enables us to skip
>> traversing the slabs_full list while gathering slabinfo statistics, and
>> since slabs_full tends to be the biggest list when the cache is large, it
>> results in a dramatic performance improvement. Getting slabinfo statistics
>> now only requires walking the slabs_free and slabs_partial lists, and
>> those lists are usually much smaller than slabs_full. We tested this after
>> growing the dentry cache to 70GB, and the performance improved from 2s to
>> 5ms.
>
> I assume this is tested on both slab and slub?
>
> It isn't the smallest of patches but given the seriousness of the
> problem I think I'll tag it for -stable backporting.
>

This was only sanity-checked on slub. The performance tests were only 
run on slab.

Thanks,
Aruna

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
