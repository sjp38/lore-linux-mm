Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED596B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 10:31:50 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n85so51724188pfi.4
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 07:31:50 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00104.outbound.protection.outlook.com. [40.107.0.104])
        by mx.google.com with ESMTPS id o69si31714306pfi.265.2016.11.07.07.01.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 07 Nov 2016 07:01:32 -0800 (PST)
Subject: Re: [PATCH 4/7] mm: defer vmalloc from atomic context
References: <1477149440-12478-1-git-send-email-hch@lst.de>
 <1477149440-12478-5-git-send-email-hch@lst.de>
 <25c117ae-6d06-9846-6a88-ae6221ad6bfe@virtuozzo.com>
 <CAJWu+oppRL5kD9qPcdCbFAbEkE7bN+kmrvTuaueVZnY+WtK_tg@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <a40cccff-3a6e-b0be-5d06-bac6cdb0e1e6@virtuozzo.com>
Date: Mon, 7 Nov 2016 18:01:45 +0300
MIME-Version: 1.0
In-Reply-To: <CAJWu+oppRL5kD9qPcdCbFAbEkE7bN+kmrvTuaueVZnY+WtK_tg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jisheng Zhang <jszhang@marvell.com>, Chris Wilson <chris@chris-wilson.co.uk>, John Dias <joaodias@google.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>

On 11/05/2016 06:43 AM, Joel Fernandes wrote:
> On Mon, Oct 24, 2016 at 8:44 AM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>>
>>
>> On 10/22/2016 06:17 PM, Christoph Hellwig wrote:
>>> We want to be able to use a sleeping lock for freeing vmap to keep
>>> latency down.  For this we need to use the deferred vfree mechanisms
>>> no only from interrupt, but from any atomic context.
>>>
>>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>>> ---
>>>  mm/vmalloc.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>>> index a4e2cec..bcc1a64 100644
>>> --- a/mm/vmalloc.c
>>> +++ b/mm/vmalloc.c
>>> @@ -1509,7 +1509,7 @@ void vfree(const void *addr)
>>>
>>>       if (!addr)
>>>               return;
>>> -     if (unlikely(in_interrupt())) {
>>> +     if (unlikely(in_atomic())) {
>>
>> in_atomic() cannot always detect atomic context, thus it shouldn't be used here.
>> You can add something like vfree_in_atomic() and use it in atomic call sites.
>>
> 
> So because in_atomic doesn't work for !CONFIG_PREEMPT kernels, can we
> always defer the work in these cases?
> 
> So for non-preemptible kernels, we always defer:
> 
> if (!IS_ENABLED(CONFIG_PREEMPT) || in_atomic()) {
>   // defer
> }
> 
> Is this fine? Or any other ideas?
> 

What's wrong with my idea?
We can add vfree_in_atomic() and use it to free vmapped stacks
and for any other places where vfree() used 'in_atomict() && !in_interrupt()' context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
