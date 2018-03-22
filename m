Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4076B0260
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 13:08:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v17so4941076pff.9
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 10:08:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g3-v6si6020298plo.189.2018.03.22.10.08.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 10:08:45 -0700 (PDT)
Date: Thu, 22 Mar 2018 10:08:42 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 1/8] page_frag_cache: Remove pfmemalloc bool
Message-ID: <20180322170842.GG28468@bombadil.infradead.org>
References: <20180322153157.10447-1-willy@infradead.org>
 <20180322153157.10447-2-willy@infradead.org>
 <CAKgT0Ud7CcKcbwjwDU0RrUNwDaJWwZoG0k2VYANeqq679X_9Hg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0Ud7CcKcbwjwDU0RrUNwDaJWwZoG0k2VYANeqq679X_9Hg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Thu, Mar 22, 2018 at 09:39:40AM -0700, Alexander Duyck wrote:
> So I was just thinking about this and it would probably make more
> sense to look at addressing this after you take care of your
> conversion from size/offset to a mask. One thing with the mask is that
> it should never reach 64K since that is the largest page size if I
> recall. With that being the case we could look at dropping mask to a
> u16 value and then add a u16 flags field where you could store things
> like this. Then you could avoid having to do the masking and math you
> are having to do below.

With the bit being in the top bit, it's actually no maths at all in the
caller; it only looks like it in C.  Here's what GCC ends up doing:

     e66:       e8 00 00 00 00          callq  e6b <__netdev_alloc_skb+0x7b>
                        e67: R_X86_64_PC32      page_frag_alloc-0x4
     e6b:       44 8b 3d 00 00 00 00    mov    0x0(%rip),%r15d
...
     e8c:       45 85 ff                test   %r15d,%r15d
     e8f:       79 04                   jns    e95 <__netdev_alloc_skb+0xa5>
     e91:       80 48 78 08             orb    $0x8,0x78(%rax)
     e95:       80 48 76 20             orb    $0x20,0x76(%rax)

ie it's testing the top bit by looking at the sign bit.  If I move it to
the second-top bit (1 << 30), it does this instead:

     e66:       e8 00 00 00 00          callq  e6b <__netdev_alloc_skb+0x7b>
                        e67: R_X86_64_PC32      page_frag_alloc-0x4
     e6b:       44 8b 2d 00 00 00 00    mov    0x0(%rip),%r13d
...
     e75:       41 81 e5 00 00 00 40    and    $0x40000000,%r13d
...
     e93:       45 85 ed                test   %r13d,%r13d
     e96:       74 04                   je     e9c <__netdev_alloc_skb+0xac>
     e98:       80 48 78 08             orb    $0x8,0x78(%rax)
     e9c:       80 48 76 20             orb    $0x20,0x76(%rax)

Changing mask to an unsigned short and adding a bool pfmemalloc to the
struct, I get:

     e66:       e8 00 00 00 00          callq  e6b <__netdev_alloc_skb+0x7b>
                        e67: R_X86_64_PC32      page_frag_alloc-0x4
     e6b:       44 0f b6 3d 00 00 00    movzbl 0x0(%rip),%r15d
     e72:       00 
...
     e8d:       45 84 ff                test   %r15b,%r15b
     e90:       74 04                   je     e96 <__netdev_alloc_skb+0xa6>
     e92:       80 48 78 08             orb    $0x8,0x78(%rax)
     e96:       80 48 76 20             orb    $0x20,0x76(%rax)

actually one byte less efficient code due to movzbl being one byte longer.
