Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2636B0038
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 01:29:36 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x202so18248531pgx.1
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 22:29:36 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id d30si15322021pld.747.2017.11.22.22.29.34
        for <linux-mm@kvack.org>;
        Wed, 22 Nov 2017 22:29:35 -0800 (PST)
Date: Thu, 23 Nov 2017 15:35:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
Message-ID: <20171123063514.GD31720@js1304-P5Q-DELUXE>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <CACT4Y+ZkC8R1vL+=j4Ordr2-4BWAc8Um+hdxPPWS6_DFi58ZJA@mail.gmail.com>
 <20171120015000.GA13507@js1304-P5Q-DELUXE>
 <8bdd114f-4bf1-e60d-eb78-af67f6c74abc@oracle.com>
 <20171122043027.GA24912@js1304-P5Q-DELUXE>
 <bc1b210e-8a95-39ac-fafb-852409bdebd4@oracle.com>
 <20171123062317.GC31720@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123062317.GC31720@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wengang Wang <wen.gang.wang@oracle.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Linux-MM <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>

On Thu, Nov 23, 2017 at 03:23:17PM +0900, Joonsoo Kim wrote:
> On Wed, Nov 22, 2017 at 11:43:00AM -0800, Wengang Wang wrote:
> > >
> > >
> > >>There do is the case you pointed out here. In this case, the
> > >>debugger can make slight change to the calling path. And as I
> > >>understand,
> > >>most of the overwritten are happening in quite different call paths,
> > >>they are not calling the (owning) caller.
> > >Agreed.
> > >
> > >>>FYI, I attach some commit descriptions of the vchecker.
> > >>>
> > >>>     vchecker: store/report callstack of value writer
> > >>>     The purpose of the value checker is finding invalid user writing
> > >>>     invalid value at the moment that the value is written. However, there is
> > >>>     a missing infrastructure that passes writing value to the checker
> > >>>     since we temporarilly piggyback on the KASAN. So, we cannot easily
> > >>>     detect this case in time.
> > >>>     However, by following way, we can emulate similar effect.
> > >>>     1. Store callstack when memory is written.
> > >>Oh, seems you are storing the callstack for each write. -- I am not
> > >>sure if that would too heavy.
> > >Unlike KASAN that checks all type of the objects, this debugging
> > >feature is only enabled on the specific type of the objects so
> > >overhead would not be too heavy in terms of system overall
> > >performance.
> > Yes, only specific type of objects do the extra stuff, but I am not
> > sure if the overall
> > performance to be affected. Actually I was thinking of tracking last
> > write stack.
> > At that time, I had two concerns: one is the performance affect; the
> > other is if it's safe
> > since memory access can happen in any context -- process context,
> > soft irq and irq..

Oops. I missed this question. vchecker works well on all contexts
however there is a possibilty to miss the callstack due to memory
allocation failure in stackdepot. It would be rare case since
stackdepot has some protection to this problem. Note that KASAN has
the same problem and it works well until now.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
