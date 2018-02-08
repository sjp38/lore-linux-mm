Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id D54046B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 16:01:16 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 1so3376789uas.23
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 13:01:16 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t5sor415552vkc.174.2018.02.08.13.01.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 13:01:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180208.151621.581060088482890871.davem@davemloft.net>
References: <20180208014438.GA12186@beast> <20180208.151621.581060088482890871.davem@davemloft.net>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 9 Feb 2018 08:01:12 +1100
Message-ID: <CAGXu5jJsmECUtyXBJb60o_Ve3PTUw8pkyaH2=SFHSxHy1vjsmA@mail.gmail.com>
Subject: Re: [PATCH] net: Whitelist the skbuff_head_cache "cb" field
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: syzbot <syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com>, LKML <linux-kernel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Eric Biggers <ebiggers3@gmail.com>, James Morse <james.morse@arm.com>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>

On Fri, Feb 9, 2018 at 7:16 AM, David Miller <davem@davemloft.net> wrote:
> From: Kees Cook <keescook@chromium.org>
> Date: Wed, 7 Feb 2018 17:44:38 -0800
>
>> Most callers of put_cmsg() use a "sizeof(foo)" for the length argument.
>> Within put_cmsg(), a copy_to_user() call is made with a dynamic size, as a
>> result of the cmsg header calculations. This means that hardened usercopy
>> will examine the copy, even though it was technically a fixed size and
>> should be implicitly whitelisted. All the put_cmsg() calls being built
>> from values in skbuff_head_cache are coming out of the protocol-defined
>> "cb" field, so whitelist this field entirely instead of creating per-use
>> bounce buffers, for which there are concerns about performance.
>>
>> Original report was:
>  ...
>> Reported-by: syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com
>> Fixes: 6d07d1cd300f ("usercopy: Restrict non-usercopy caches to size 0")
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>> I tried the inlining, it was awful. Splitting put_cmsg() was awful. So,
>> instead, whitelist the "cb" field as the least bad option if bounce
>> buffers are unacceptable. Dave, do you want to take this through net, or
>> should I take it through the usercopy tree?
>
> Thanks Kees, I'll take this through my 'net' tree.

Cool, thanks. And just to be clear, if it's not already obvious, this
patch needs kmem_cache_create_usercopy() which just landed in Linus's
tree last week, in case you've not merged yet.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
