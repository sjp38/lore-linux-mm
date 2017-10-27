Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3546B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 16:59:36 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h70so15251346ioi.5
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 13:59:36 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n145si1884655ita.23.2017.10.27.13.59.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Oct 2017 13:59:35 -0700 (PDT)
Subject: Re: [PATCH] mm: Simplify and batch working set shadow pages LRU
 isolation locking
References: <20171026234854.25764-1-andi@firstfloor.org>
 <20171027170156.GA1743@cmpxchg.org>
 <20171027172205.GA22894@tassilo.jf.intel.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <cf74ed09-7478-7047-ccb1-d2847499585e@oracle.com>
Date: Fri, 27 Oct 2017 16:59:16 -0400
MIME-Version: 1.0
In-Reply-To: <20171027172205.GA22894@tassilo.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org

On 10/27/2017 01:22 PM, Andi Kleen wrote:
>> The nlru->lock in list_lru_shrink_walk() is the only thing that keeps
>> truncation blocked on workingset_update_node() -> list_lru_del() and
>> so ultimately keeping it from freeing the radix tree node.
>>
>> It's not safe to access the nodes on the private list after that.
> True.
>
>> Batching mapping->tree_lock is possible, but you have to keep the
>> lock-handoff scheme. Pass a &mapping to list_lru_shrink_walk() and
>> only unlock and spin_trylock(&mapping->tree_lock) if it changes?
> Yes something like that could work. Thanks.

My mistake, I didn't see this other thread and clearly missed this issue.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
