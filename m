Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 58DA46B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 22:20:29 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id e66so4686341pfe.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 19:20:29 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id e1si6019594pas.161.2015.12.15.19.20.28
        for <linux-mm@kvack.org>;
        Tue, 15 Dec 2015 19:20:28 -0800 (PST)
Message-ID: <5670D85C.60106@intel.com>
Date: Wed, 16 Dec 2015 11:19:56 +0800
From: Zhi Wang <zhi.a.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mempool: Factor out mempool_refill()
References: <1449978390-10931-1-git-send-email-zhi.a.wang@intel.com> <F3B0350DF4CB6849A642218320DE483D4B866043@SHSMSX101.ccr.corp.intel.com> <20151215212638.GA17162@cmpxchg.org>
In-Reply-To: <20151215212638.GA17162@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>

Hi Johannes:
     Thanks for the reply. In the end of the mempool_resize(), it will 
call the mempool_refill() to do the rest of the work. So this is not one 
of the "no-caller" case. If you insist this is a "no-caller" case, 
perhaps I should change it to a "static" function without exposing a new 
interface?

Personally I think mempool_refill() should be one of the typical 
interfaces in an implementation of a mempool. Currently the mempool will 
not grow only if pool->min_nr > new_min_nr.

So when user wants to refill the mempool immediately, not resize a 
mempool, in the current implementation, it has to do 2x 
mempool_resize(). First one is mempool_resize(pool->min_nr - 1), second 
one is mempool_resize(new_min_nr). So the refill action would truly 
happen. This is ugly and not convenient.

On 12/16/15 05:26, Johannes Weiner wrote:
> On Mon, Dec 14, 2015 at 11:09:43AM +0000, Wang, Zhi A wrote:
>> This patch factors out mempool_refill() from mempool_resize(). It's reasonable
>> that the mempool user wants to refill the pool immdiately when it has chance
>> e.g. inside a sleepible context, so that next time in the IRQ context the pool
>> would have much more available elements to allocate.
>>
>> After the refactor, mempool_refill() can also executes with mempool_resize()
>> /mempool_alloc/mempool_free() or another mempool_refill().
>>
>> Signed-off-by: Zhi Wang <zhi.a.wang@intel.com>
>
> Who is going to call that function? Adding a new interace usually
> comes with a user, or as part of a series that adds users.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
