Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C30F6B0005
	for <linux-mm@kvack.org>; Tue, 10 May 2016 17:12:01 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id kj7so49161301igb.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 14:12:01 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id o15si1402059oto.135.2016.05.10.14.12.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 14:12:00 -0700 (PDT)
Received: by mail-oi0-x22b.google.com with SMTP id x201so37212064oif.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 14:12:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160510174915.GJ14377@uranus.lan>
References: <CALCETrWWZy0hngPU8MCiQvnH+s0awpFE8wNBrYsf_c+nz6ZsDg@mail.gmail.com>
 <20160510163045.GH14377@uranus.lan> <CALCETrVFJN+ktqjGAMckVpUf3JA4_iJf2R1tXDG=WmwwwLEF-Q@mail.gmail.com>
 <20160510170545.GI14377@uranus.lan> <CALCETrWS5YpRMh00tH3Lx6yUNhzSti3kpema8nwv-d-jUKbGaA@mail.gmail.com>
 <20160510174915.GJ14377@uranus.lan>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 10 May 2016 14:11:41 -0700
Message-ID: <CALCETrXm+zRxfq08PZUQSS7iMdDsqZYwHcNw6Q6J1qkYoJHSvg@mail.gmail.com>
Subject: Re: Getting rid of dynamic TASK_SIZE (on x86, at least)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Dmitry Safonov <0x7f454c46@gmail.com>, Ruslan Kabatsayev <b7.10110111@gmail.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, Pavel Emelyanov <xemul@parallels.com>, Oleg Nesterov <oleg@redhat.com>

On Tue, May 10, 2016 at 10:49 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On Tue, May 10, 2016 at 10:26:05AM -0700, Andy Lutomirski wrote:
> ...
>> >>
>> >> It's annoying and ugly.  It also makes the idea of doing 32-bit CRIU
>> >> restore by starting in 64-bit mode and switching to 32-bit more
>> >> complicated because it requires switching TASK_SIZE.
>> >
>> > Well, you know I'm not sure it's that annoying. It serves as it should
>> > for task limit. Sure we can add one more parameter into get-unmapped-addr
>> > but same time the task-size will be present in say page faulting code
>> > (the helper might be renamed but it will be here still).
>>
>> Why should the page faulting code care at all what type of task it is?
>> If there's a vma there, fault it in.  If there isn't, then don't.
>
> __bad_area_nosemaphore
>   ...
>                 /* Kernel addresses are always protection faults: */
>                 if (address >= TASK_SIZE)
>                         error_code |= PF_PROT;
>
> For sure page faulting must consider what kind of fault is it.
> Or we gonna drop such code at all?

That code was bogus.  (Well, it was correct unless user code had a way
to create a funny high mapping in an otherwise 32-bit task, but it
still should have been TASK_SIZE_MAX.)  Fix sent.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
