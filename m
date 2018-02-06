Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DDF1F6B0022
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 11:19:52 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id o128so1285059pfg.6
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 08:19:52 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id t27si2002050pfe.283.2018.02.06.08.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 08:19:51 -0800 (PST)
Date: Tue, 06 Feb 2018 11:19:49 -0500 (EST)
Message-Id: <20180206.111949.1986970583522698316.davem@davemloft.net>
Subject: Re: [PATCH v2] socket: Provide put_cmsg_whitelist() for constant
 size copies
From: David Miller <davem@davemloft.net>
In-Reply-To: <CAGXu5j+VnhgXFajjxR7HJkN=Z6r3Kfw-+Gg2x37AacOD6C+Wdg@mail.gmail.com>
References: <20180202102749.GA34019@beast>
	<20180205.100347.176614123780866781.davem@davemloft.net>
	<CAGXu5j+VnhgXFajjxR7HJkN=Z6r3Kfw-+Gg2x37AacOD6C+Wdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org
Cc: syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, ebiggers3@gmail.com, james.morse@arm.com, keun-o.park@darkmatter.ae, labbott@redhat.com, linux-mm@kvack.org, mingo@kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Tue, 6 Feb 2018 04:31:50 +1100

> On Tue, Feb 6, 2018 at 2:03 AM, David Miller <davem@davemloft.net> wrote:
>> From: Kees Cook <keescook@chromium.org>
>> Date: Fri, 2 Feb 2018 02:27:49 -0800
>>
>>> @@ -343,6 +343,14 @@ struct ucred {
>>>
>>>  extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr_storage *kaddr);
>>>  extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
>>> +/*
>>> + * Provide a bounce buffer for copying cmsg data to userspace when the
>>> + * target memory isn't already whitelisted for hardened usercopy.
>>> + */
>>> +#define put_cmsg_whitelist(_msg, _level, _type, _ptr) ({             \
>>> +             typeof(*(_ptr)) _val = *(_ptr);                         \
>>> +             put_cmsg(_msg, _level, _type, sizeof(_val), &_val);     \
>>> +     })
>>
>> I understand what you are trying to achieve, but it's at a real cost
>> here.  Some of these objects are structures, for example the struct
>> sock_extended_err is 16 bytes.
> 
> It didn't look like put_cmsg() was on a fast path, so it seemed like a
> bounce buffer was the best solution here (and it's not without
> precedent).

For some things like timestamps it can be important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
