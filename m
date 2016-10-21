Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB9F6B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 20:32:23 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b75so40680210lfg.3
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 17:32:23 -0700 (PDT)
Received: from mail-lf0-x231.google.com (mail-lf0-x231.google.com. [2a00:1450:4010:c07::231])
        by mx.google.com with ESMTPS id r185si1612583lfe.74.2016.10.20.17.32.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 17:32:21 -0700 (PDT)
Received: by mail-lf0-x231.google.com with SMTP id b81so108940826lfe.1
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 17:32:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161019163112.GA31091@lst.de>
References: <1476773771-11470-1-git-send-email-hch@lst.de> <1476773771-11470-3-git-send-email-hch@lst.de>
 <20161019111541.GQ29358@nuc-i3427.alporthouse.com> <20161019130552.GB5876@lst.de>
 <CALCETrVqjejgpQVUdem8RK3uxdEgfOZy4cOJqJQjCLtBDnJfyQ@mail.gmail.com> <20161019163112.GA31091@lst.de>
From: Joel Fernandes <joelaf@google.com>
Date: Thu, 20 Oct 2016 17:32:19 -0700
Message-ID: <CAJWu+oric2eq1WOrx9fKHxiMhyq490av-1TbRPDfTptOydfM+A@mail.gmail.com>
Subject: Re: [PATCH 2/6] mm: mark all calls into the vmalloc subsystem as
 potentially sleeping
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andy Lutomirski <luto@amacapital.net>, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Jisheng Zhang <jszhang@marvell.com>, John Dias <joaodias@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Christoph,

On Wed, Oct 19, 2016 at 9:31 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Wed, Oct 19, 2016 at 08:34:40AM -0700, Andy Lutomirski wrote:
>>
>> It would be quite awkward for a task stack to get freed from a
>> sleepable context, because the obvious sleepable context is the task
>> itself, and it still needs its stack.  This was true even in the old
>> regime when task stacks were freed from RCU context.
>>
>> But vfree has a magic automatic deferral mechanism.  Couldn't you make
>> the non-deferred case might_sleep()?
>
> But it's only magic from interrupt context..
>
> Chris, does this patch make virtually mapped stack work for you again?
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index f2481cb..942e02d 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1533,7 +1533,7 @@ void vfree(const void *addr)
>
>         if (!addr)
>                 return;
> -       if (unlikely(in_interrupt())) {
> +       if (in_interrupt() || in_atomic()) {

in_atomic() also checks in_interrupt() cases so only in_atomic() should suffice.

Thanks,

Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
