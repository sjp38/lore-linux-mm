Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA51C6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:35:01 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id 2so23478418vkb.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 08:35:01 -0700 (PDT)
Received: from mail-vk0-x22a.google.com (mail-vk0-x22a.google.com. [2607:f8b0:400c:c05::22a])
        by mx.google.com with ESMTPS id i1si20036776vkh.146.2016.10.19.08.35.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 08:35:01 -0700 (PDT)
Received: by mail-vk0-x22a.google.com with SMTP id 2so31441176vkb.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 08:35:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161019130552.GB5876@lst.de>
References: <1476773771-11470-1-git-send-email-hch@lst.de> <1476773771-11470-3-git-send-email-hch@lst.de>
 <20161019111541.GQ29358@nuc-i3427.alporthouse.com> <20161019130552.GB5876@lst.de>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 19 Oct 2016 08:34:40 -0700
Message-ID: <CALCETrVqjejgpQVUdem8RK3uxdEgfOZy4cOJqJQjCLtBDnJfyQ@mail.gmail.com>
Subject: Re: [PATCH 2/6] mm: mark all calls into the vmalloc subsystem as
 potentially sleeping
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, joelaf@google.com, jszhang@marvell.com, joaodias@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Oct 19, 2016 at 6:05 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Wed, Oct 19, 2016 at 12:15:41PM +0100, Chris Wilson wrote:
>> On Tue, Oct 18, 2016 at 08:56:07AM +0200, Christoph Hellwig wrote:
>> > This is how everyone seems to already use them, but let's make that
>> > explicit.
>>
>> Ah, found an exception, vmapped stacks:
>
> Oh, fun.  So if we can't require vfree to be called from process context
> we also can't use a mutex to wait for the vmap flushing.  Given that we
> free stacks from the scheduler context switch I also fear there is no
> good way to get a sleepable context there.
>
> The only other idea I had was to use vmap_area_lock for the protection
> that purge_lock currently provides, but that would require some serious
> refactoring to avoid recursive locking first.

It would be quite awkward for a task stack to get freed from a
sleepable context, because the obvious sleepable context is the task
itself, and it still needs its stack.  This was true even in the old
regime when task stacks were freed from RCU context.

But vfree has a magic automatic deferral mechanism.  Couldn't you make
the non-deferred case might_sleep()?

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
