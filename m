Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48A0C6B0005
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 12:31:53 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id e71so17858321vkd.4
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 09:31:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q32sor3794452uaq.167.2018.02.05.09.31.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Feb 2018 09:31:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180205.100347.176614123780866781.davem@davemloft.net>
References: <20180202102749.GA34019@beast> <20180205.100347.176614123780866781.davem@davemloft.net>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 6 Feb 2018 04:31:50 +1100
Message-ID: <CAGXu5j+VnhgXFajjxR7HJkN=Z6r3Kfw-+Gg2x37AacOD6C+Wdg@mail.gmail.com>
Subject: Re: [PATCH v2] socket: Provide put_cmsg_whitelist() for constant size copies
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: syzbot <syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com>, LKML <linux-kernel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Eric Biggers <ebiggers3@gmail.com>, James Morse <james.morse@arm.com>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>

On Tue, Feb 6, 2018 at 2:03 AM, David Miller <davem@davemloft.net> wrote:
> From: Kees Cook <keescook@chromium.org>
> Date: Fri, 2 Feb 2018 02:27:49 -0800
>
>> @@ -343,6 +343,14 @@ struct ucred {
>>
>>  extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr_storage *kaddr);
>>  extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
>> +/*
>> + * Provide a bounce buffer for copying cmsg data to userspace when the
>> + * target memory isn't already whitelisted for hardened usercopy.
>> + */
>> +#define put_cmsg_whitelist(_msg, _level, _type, _ptr) ({             \
>> +             typeof(*(_ptr)) _val = *(_ptr);                         \
>> +             put_cmsg(_msg, _level, _type, sizeof(_val), &_val);     \
>> +     })
>
> I understand what you are trying to achieve, but it's at a real cost
> here.  Some of these objects are structures, for example the struct
> sock_extended_err is 16 bytes.

It didn't look like put_cmsg() was on a fast path, so it seemed like a
bounce buffer was the best solution here (and it's not without
precedent).

> And now we're going to copy it twice, once into the on-stack copy,
> and then once again into the CMSG blob.
>
> Please find a way to make hardened user copy happy without adding
> new overhead.

Another idea would be breaking put_cmsg() up into a macro with helper
functions, rearrange the arguments to avoid the math, and leaving the
copy_to_user() inline to see the const-ness, but that seemed way
uglier to me.

I'll think about it some more, but I think having put_cmsg_whitelist()
called only in a few places is reasonable here.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
