Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0D2BD6B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 22:12:47 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id xk3so156227996obc.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 19:12:47 -0800 (PST)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id v5si15128485oei.13.2016.02.21.19.12.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 19:12:46 -0800 (PST)
Received: by mail-ob0-x22b.google.com with SMTP id xk3so156227897obc.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 19:12:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56CA78F7.9010201@huawei.com>
References: <56CA78F7.9010201@huawei.com>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Mon, 22 Feb 2016 11:12:06 +0800
Message-ID: <CAHz2CGUDM5qHKBFjkDnEvRt1TrohuETtFzNhknxkVZEUASeVCQ@mail.gmail.com>
Subject: Re: [RFC] mm: why we should clear page when do anonymous page fault
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Feb 22, 2016 at 10:56 AM, Xishi Qiu <qiuxishi@huawei.com> wrote:
> handle_pte_fault()
>         do_anonymous_page()
>                 alloc_zeroed_user_highpage_movable()
>
> We will alloc a zeroed page when do anonymous page fault, I don't know
> why should clear it? just for safe?
>
> If user space program do like the following, there are two memset 0, right?
> kernel alloc zeroed page, and user memset 0 it again, this will waste a
> lot of time.
>
> main()
> {
>         ...
>         vaddr = malloc(size)
>         if (vaddr)
>                 memset(vaddr, 0, size);
>         ...
> }
>
>
> Thanks,
> Xishi Qiu
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

I believe this is mainly for security reason.

To zero a highmem page, we could avoid another process peeking into the page
that is (highly likely) just released by another process, who might
well have put its confidential
data in that very page.

IIRC, Windows zeros the pages at freeing time. Linux instead does it lazily.

And for the userspace zeroing action,  it is another problem - user
just wants a clean, definitive
context to act on ( and we can be sure he/she is a self-disciplined
guy who does not peek into
other's secret,  but we can not assume that for all).


Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
