Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f53.google.com (mail-vk0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id C12436B007E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 18:15:26 -0400 (EDT)
Received: by mail-vk0-f53.google.com with SMTP id e6so120251468vkh.2
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 15:15:26 -0700 (PDT)
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com. [209.85.220.170])
        by mx.google.com with ESMTPS id b2si4808204vka.102.2016.04.01.15.15.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Apr 2016 15:15:25 -0700 (PDT)
Received: by mail-qk0-f170.google.com with SMTP id s5so43900145qkd.0
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 15:15:24 -0700 (PDT)
Subject: Re: [RFC][PATCH] mm/slub: Skip CPU slab activation when debugging
References: <1459205581-4605-1-git-send-email-labbott@fedoraproject.org>
 <20160401023533.GB13179@js1304-P5Q-DELUXE>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56FEF2F8.7010508@redhat.com>
Date: Fri, 1 Apr 2016 15:15:20 -0700
MIME-Version: 1.0
In-Reply-To: <20160401023533.GB13179@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On 03/31/2016 07:35 PM, Joonsoo Kim wrote:
> On Mon, Mar 28, 2016 at 03:53:01PM -0700, Laura Abbott wrote:
>> The per-cpu slab is designed to be the primary path for allocation in SLUB
>> since it assumed allocations will go through the fast path if possible.
>> When debugging is enabled, the fast path is disabled and per-cpu
>> allocations are not used. The current debugging code path still activates
>> the cpu slab for allocations and then immediately deactivates it. This
>> is useless work. When a slab is enabled for debugging, skip cpu
>> activation.
>>
>> Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
>> ---
>> This is a follow on to the optimization of the debug paths for poisoning
>> With this I get ~2 second drop on hackbench -g 20 -l 1000 with slub_debug=P
>> and no noticable change with slub_debug=- .
>
> I'd like to know the performance difference between slub_debug=P and
> slub_debug=- with this change.
>

with the hackbench benchmark

slub_debug=- 6.834

slub_debug=P 8.059


so ~1.2 second difference.

> Although this patch increases hackbench performance, I'm not sure it's
> sufficient for the production system. Concurrent slab allocation request
> will contend the node lock in every allocation attempt. So, there would be
> other ues-cases that performance drop due to slub_debug=P cannot be
> accepted even if it is security feature.
>

Hmmm, I hadn't considered that :-/

> How about allowing cpu partial list for debug cases?
> It will not hurt fast path and will make less contention on the node
> lock.
>

That helps more than this patch! It brings slub_debug=P down to 7.535
with the same relaxing of restrictions of CMPXCHG (allow the partials
with poison or redzoning, restrict otherwise).

It still seems unfortunate that deactive_slab takes up so much time
of __slab_alloc. I'll give some more thought about trying to skip
the CPU slab activation with the cpu partial list.

> Thanks.
>

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
