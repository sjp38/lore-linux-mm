Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B90166B0007
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 10:03:51 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id j3so11725528pld.0
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 07:03:51 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id n13si1179200pfh.81.2018.02.05.07.03.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Feb 2018 07:03:49 -0800 (PST)
Date: Mon, 05 Feb 2018 10:03:47 -0500 (EST)
Message-Id: <20180205.100347.176614123780866781.davem@davemloft.net>
Subject: Re: [PATCH v2] socket: Provide put_cmsg_whitelist() for constant
 size copies
From: David Miller <davem@davemloft.net>
In-Reply-To: <20180202102749.GA34019@beast>
References: <20180202102749.GA34019@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org
Cc: syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, ebiggers3@gmail.com, james.morse@arm.com, keun-o.park@darkmatter.ae, labbott@redhat.com, linux-mm@kvack.org, mingo@kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Fri, 2 Feb 2018 02:27:49 -0800

> @@ -343,6 +343,14 @@ struct ucred {
>  
>  extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr_storage *kaddr);
>  extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
> +/*
> + * Provide a bounce buffer for copying cmsg data to userspace when the
> + * target memory isn't already whitelisted for hardened usercopy.
> + */
> +#define put_cmsg_whitelist(_msg, _level, _type, _ptr) ({		\
> +		typeof(*(_ptr)) _val = *(_ptr);				\
> +		put_cmsg(_msg, _level, _type, sizeof(_val), &_val);	\
> +	})

I understand what you are trying to achieve, but it's at a real cost
here.  Some of these objects are structures, for example the struct
sock_extended_err is 16 bytes.

And now we're going to copy it twice, once into the on-stack copy,
and then once again into the CMSG blob.

Please find a way to make hardened user copy happy without adding
new overhead.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
