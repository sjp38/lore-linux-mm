Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id CAD6D6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 12:48:49 -0400 (EDT)
Received: by igbud6 with SMTP id ud6so59265564igb.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:48:49 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id ke13si5076692icb.101.2015.03.20.09.48.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 09:48:49 -0700 (PDT)
Received: by igbud6 with SMTP id ud6so59265329igb.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:48:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <550C37C9.2060200@oracle.com>
References: <550C37C9.2060200@oracle.com>
Date: Fri, 20 Mar 2015 09:48:48 -0700
Message-ID: <CA+55aFxhNphSMrNvwqj0AQRzuqRdPG11J6DaazKWMb2U+H7wKg@mail.gmail.com>
Subject: Re: 4.0.0-rc4: panic in free_block
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Ahern <david.ahern@oracle.com>, "David S. Miller" <davem@davemloft.net>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org

[ Added Davem and the sparc mailing list, since it happens on sparc
and that just makes me suspicious ]

On Fri, Mar 20, 2015 at 8:07 AM, David Ahern <david.ahern@oracle.com> wrote:
> I can easily reproduce the panic below doing a kernel build with make -j N,
> N=128, 256, etc. This is a 1024 cpu system running 4.0.0-rc4.

3.19 is fine? Because I dont' think I've seen any reports like this
for others, and what stands out is sparc (and to a lesser degree "1024
cpus", which obviously gets a lot less testing)

> The top 3 frames are consistently:
>     free_block+0x60
>     cache_flusharray+0xac
>     kmem_cache_free+0xfc
>
> After that one path has been from __mmdrop and the others are like below,
> from remove_vma.
>
> Unable to handle kernel paging request at virtual address 0006100000000000

One thing you *might* check is if the problem goes away if you select
CONFIG_SLUB instead of CONFIG_SLAB. I'd really like to just get rid of
SLAB. The whole "we have multiple different allocators" is a mess and
causes test coverage issues.

Apart from testing with CONFIG_SLUB, if 3.19 is ok and you seem to be
able to "easily reproduce" this, the obvious thing to do is to try to
bisect it.

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
