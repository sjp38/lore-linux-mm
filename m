Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id ACE636B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 07:13:50 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id y205so203739703qkb.4
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 04:13:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t44si2783775qtc.169.2016.12.02.04.13.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 04:13:49 -0800 (PST)
Date: Fri, 2 Dec 2016 13:13:44 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Initial thoughts on TXDP
Message-ID: <20161202131344.12ce594c@redhat.com>
In-Reply-To: <CALx6S36ywu3ruY7AFKYk=N4Ekr5zjY33ivx92EgNNT36XoXhFA@mail.gmail.com>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
	<20161201024407.GE26507@breakpoint.cc>
	<CALx6S36ywu3ruY7AFKYk=N4Ekr5zjY33ivx92EgNNT36XoXhFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Herbert <tom@herbertland.com>
Cc: brouer@redhat.com, Florian Westphal <fw@strlen.de>, Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>


On Thu, 1 Dec 2016 11:51:42 -0800 Tom Herbert <tom@herbertland.com> wrote:
> On Wed, Nov 30, 2016 at 6:44 PM, Florian Westphal <fw@strlen.de> wrote:
> > Tom Herbert <tom@herbertland.com> wrote:  
[...]
> >>   - Call into TCP/IP stack with page data directly from driver-- no
> >> skbuff allocation or interface. This is essentially provided by the
> >> XDP API although we would need to generalize the interface to call
> >> stack functions (I previously posted patches for that). We will also
> >> need a new action, XDP_HELD?, that indicates the XDP function held the
> >> packet (put on a socket for instance).  
> >
> > Seems this will not work at all with the planned page pool thing when
> > pages start to be held indefinitely.

It is quite the opposite, the page pool support pages are being held
for longer times, than drivers today.  The current driver page recycle
tricks cannot, as they depend on page refcnt being decremented quickly
(while pages are still mapped in their recycle queue).

> > You can also never get even close to userspace offload stacks once you
> > need/do this; allocations in hotpath are too expensive.

Yes. It is important to understand that once the number of outstanding
pages get large, the driver recycle stops working.  Meaning the pages
allocations start to go through the page allocator.  I've documented[1]
that the bare alloc+free cost[2] (231 cycles order-0/4K) is higher than
the 10G wirespeed budget (201 cycles).

Thus, the driver recycle tricks are nice for benchmarking, as it hides
the page allocator overhead. But this optimization might disappear for
Tom's and Eric's more real-world use-cases e.g. like 10.000 sockets.
The page pool don't these issues.

[1] http://people.netfilter.org/hawk/presentations/MM-summit2016/generic_page_pool_mm_summit2016.pdf
[2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/page_bench01.c

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
