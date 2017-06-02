Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id A64DD6B0397
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 17:32:04 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i206so87077636ita.10
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 14:32:04 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id u5si23762441iou.248.2017.06.02.14.32.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 14:32:03 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id l145so13295944ita.0
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 14:32:03 -0700 (PDT)
Message-ID: <1496439121.13303.1.camel@gmail.com>
Subject: Re: [PATCH v4] add the option of fortified string.h functions
From: Daniel Micay <danielmicay@gmail.com>
Date: Fri, 02 Jun 2017 17:32:01 -0400
In-Reply-To: <20170602140743.274b9babba6118bfd12c7a26@linux-foundation.org>
References: <20170526095404.20439-1-danielmicay@gmail.com>
	 <20170602140743.274b9babba6118bfd12c7a26@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com, linux-kernel <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Daniel Axtens <dja@axtens.net>, Moni Shoua <monis@mellanox.com>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org

On Fri, 2017-06-02 at 14:07 -0700, Andrew Morton wrote:
> On Fri, 26 May 2017 05:54:04 -0400 Daniel Micay <danielmicay@gmail.com
> > wrote:
> 
> > This adds support for compiling with a rough equivalent to the glibc
> > _FORTIFY_SOURCE=1 feature, providing compile-time and runtime buffer
> > overflow checks for string.h functions when the compiler determines
> > the
> > size of the source or destination buffer at compile-time. Unlike
> > glibc,
> > it covers buffer reads in addition to writes.
> 
> Did we find a bug in drivers/infiniband/sw/rxe/rxe_resp.c?
> 
> i386 allmodconfig:
> 
> In file included from ./include/linux/bitmap.h:8:0,
>                  from ./include/linux/cpumask.h:11,
>                  from ./include/linux/mm_types_task.h:13,
>                  from ./include/linux/mm_types.h:4,
>                  from ./include/linux/kmemcheck.h:4,
>                  from ./include/linux/skbuff.h:18,
>                  from drivers/infiniband/sw/rxe/rxe_resp.c:34:
> In function 'memcpy',
>     inlined from 'send_atomic_ack.constprop' at
> drivers/infiniband/sw/rxe/rxe_resp.c:998:2,
>     inlined from 'acknowledge' at
> drivers/infiniband/sw/rxe/rxe_resp.c:1026:3,
>     inlined from 'rxe_responder' at
> drivers/infiniband/sw/rxe/rxe_resp.c:1286:10:
> ./include/linux/string.h:309:4: error: call to '__read_overflow2'
> declared with attribute error: detected read beyond size of object
> passed as 2nd parameter
>     __read_overflow2();
> 
> 
> If so, can you please interpret this for the infiniband developers?

It copies sizeof(skb->cb) bytes with memcpy which is 48 bytes since cb
is a 48 byte char array in `struct sk_buff`. The source buffer is a
`struct rxe_pkt_info`:

struct rxe_pkt_info {
	struct rxe_dev		*rxe;		/* device that owns packet */
	struct rxe_qp		*qp;		/* qp that owns packet */
	struct rxe_send_wqe	*wqe;		/* send wqe */
	u8			*hdr;		/* points to bth */
	u32			mask;		/* useful info about pkt */
	u32			psn;		/* bth psn of packet */
	u16			pkey_index;	/* partition of pkt */
	u16			paylen;		/* length of bth - icrc */
	u8			port_num;	/* port pkt received on */
	u8			opcode;		/* bth opcode of packet */
	u8			offset;		/* bth offset from pkt->hdr */
};

That looks like 32 bytes (1 byte of padding) on 32-bit and 48 bytes on
64-bit (1 byte of padding), so on 32-bit there's a read overflow of 16
bytes from the stack here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
