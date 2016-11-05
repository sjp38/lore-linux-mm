Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9ADD96B0262
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 23:43:18 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id 12so72950593uas.5
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 20:43:18 -0700 (PDT)
Received: from mail-vk0-x236.google.com (mail-vk0-x236.google.com. [2607:f8b0:400c:c05::236])
        by mx.google.com with ESMTPS id m26si1488183uab.121.2016.11.04.20.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 20:43:17 -0700 (PDT)
Received: by mail-vk0-x236.google.com with SMTP id x186so82582104vkd.1
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 20:43:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <25c117ae-6d06-9846-6a88-ae6221ad6bfe@virtuozzo.com>
References: <1477149440-12478-1-git-send-email-hch@lst.de> <1477149440-12478-5-git-send-email-hch@lst.de>
 <25c117ae-6d06-9846-6a88-ae6221ad6bfe@virtuozzo.com>
From: Joel Fernandes <joelaf@google.com>
Date: Fri, 4 Nov 2016 20:43:16 -0700
Message-ID: <CAJWu+oppRL5kD9qPcdCbFAbEkE7bN+kmrvTuaueVZnY+WtK_tg@mail.gmail.com>
Subject: Re: [PATCH 4/7] mm: defer vmalloc from atomic context
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jisheng Zhang <jszhang@marvell.com>, Chris Wilson <chris@chris-wilson.co.uk>, John Dias <joaodias@google.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 24, 2016 at 8:44 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 10/22/2016 06:17 PM, Christoph Hellwig wrote:
>> We want to be able to use a sleeping lock for freeing vmap to keep
>> latency down.  For this we need to use the deferred vfree mechanisms
>> no only from interrupt, but from any atomic context.
>>
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>> ---
>>  mm/vmalloc.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index a4e2cec..bcc1a64 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1509,7 +1509,7 @@ void vfree(const void *addr)
>>
>>       if (!addr)
>>               return;
>> -     if (unlikely(in_interrupt())) {
>> +     if (unlikely(in_atomic())) {
>
> in_atomic() cannot always detect atomic context, thus it shouldn't be used here.
> You can add something like vfree_in_atomic() and use it in atomic call sites.
>

So because in_atomic doesn't work for !CONFIG_PREEMPT kernels, can we
always defer the work in these cases?

So for non-preemptible kernels, we always defer:

if (!IS_ENABLED(CONFIG_PREEMPT) || in_atomic()) {
  // defer
}

Is this fine? Or any other ideas?

Thanks,
Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
