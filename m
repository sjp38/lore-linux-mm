Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8F63C6B0031
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 13:23:45 -0400 (EDT)
Received: by mail-ve0-f179.google.com with SMTP id sa20so1777439veb.24
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 10:23:45 -0700 (PDT)
Received: from mail-ve0-f180.google.com (mail-ve0-f180.google.com [209.85.128.180])
        by mx.google.com with ESMTPS id x4si1611060ved.52.2014.06.13.10.23.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 10:23:44 -0700 (PDT)
Received: by mail-ve0-f180.google.com with SMTP id jw12so3569444veb.25
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 10:23:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANq1E4TQXKD8jaBcOJsL3h3ZPRXq176fz8Z9yevFbS3P0q1FQg@mail.gmail.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
 <1402655819-14325-8-git-send-email-dh.herrmann@gmail.com> <CALCETrWaUsq_D2Z1PwbbwQQWKrnsWTLOdUR6bqPuedi8ZHgvEQ@mail.gmail.com>
 <CANq1E4TQXKD8jaBcOJsL3h3ZPRXq176fz8Z9yevFbS3P0q1FQg@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 13 Jun 2014 10:23:23 -0700
Message-ID: <CALCETrWsRQpuu2u9W5mcDTZKT9KVZn6TJHiMP7VWpR=6Zc_7Rw@mail.gmail.com>
Subject: Re: [RFC v3 7/7] shm: isolate pinned pages when sealing files
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>

On Fri, Jun 13, 2014 at 8:27 AM, David Herrmann <dh.herrmann@gmail.com> wrote:
> Hi
>
> On Fri, Jun 13, 2014 at 5:06 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Fri, Jun 13, 2014 at 3:36 AM, David Herrmann <dh.herrmann@gmail.com> wrote:
>>> When setting SEAL_WRITE, we must make sure nobody has a writable reference
>>> to the pages (via GUP or similar). We currently check references and wait
>>> some time for them to be dropped. This, however, might fail for several
>>> reasons, including:
>>>  - the page is pinned for longer than we wait
>>>  - while we wait, someone takes an already pinned page for read-access
>>>
>>> Therefore, this patch introduces page-isolation. When sealing a file with
>>> SEAL_WRITE, we copy all pages that have an elevated ref-count. The newpage
>>> is put in place atomically, the old page is detached and left alone. It
>>> will get reclaimed once the last external user dropped it.
>>>
>>> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
>>
>> Won't this have unexpected effects?
>>
>> Thread 1:  start read into mapping backed by fd
>>
>> Thread 2:  SEAL_WRITE
>>
>> Thread 1: read finishes.  now the page doesn't match the sealed page
>
> Just to be clear: you're talking about read() calls that write into
> the memfd? (like my FUSE example does) Your language might be
> ambiguous to others as "read into" actually implies a write.
>
> No, this does not have unexpected effects. But yes, your conclusion is
> right. To be clear, this behavior would be part of the API. Any
> asynchronous write might be cut off by SEAL_WRITE _iff_ you unmap your
> buffer before the write finishes. But you actually have to extend your
> example:
>
> Thread 1: p = mmap(memfd, SIZE);
> Thread 1: h = async_read(some_fd, p, SIZE);
> Thread 1: munmap(p, SIZE);
> Thread 2: SEAL_WRITE
> Thread 1: async_wait(h);
>
> If you don't do the unmap(), then SEAL_WRITE will fail due to an
> elevated i_mmap_writable. I think this is fine. In fact, I remember
> reading that async-IO is not required to resolve user-space addresses
> at the time of the syscall, but might delay it to the time of the
> actual write. But you're right, it would be misleading that the AIO
> operation returns success. This would be part of the memfd-API,
> though. And if you mess with your address space while running an
> async-IO operation on it, you're screwed anyway.

Ok, I missed the part where you had to munmap to trigger the oddity.
That seems fine to me.

>
> Btw., your sealing use-case is really odd. No-one guarantees that the
> SEAL_WRITE happens _after_ you schedule your async-read. In case you
> have some synchronization there, you just have to move it after
> waiting for your async-io to finish.
>
> Does that clear things up?

I think so.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
