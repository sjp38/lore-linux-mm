Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5392D6B0003
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 14:54:23 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id q141-v6so27376291ywg.5
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 11:54:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v129-v6sor2640829ybe.26.2018.08.14.11.54.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Aug 2018 11:54:22 -0700 (PDT)
Received: from mail-yw1-f50.google.com (mail-yw1-f50.google.com. [209.85.161.50])
        by smtp.gmail.com with ESMTPSA id h145-v6sm17596691ywc.3.2018.08.14.11.54.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 11:54:19 -0700 (PDT)
Received: by mail-yw1-f50.google.com with SMTP id c135-v6so17015424ywa.0
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 11:54:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <494CFD22286B8448AF161132C5FE9A985B624E05@dggema521-mbx.china.huawei.com>
References: <1534249051-56879-1-git-send-email-yuanxiaofeng1@huawei.com>
 <20180814123454.GA25328@bombadil.infradead.org> <494CFD22286B8448AF161132C5FE9A985B624E05@dggema521-mbx.china.huawei.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 14 Aug 2018 11:54:17 -0700
Message-ID: <CAGXu5jLw1=KB1J3gQRyg66MxfgOoRmZDfeM5KO57djKU_as+Xw@mail.gmail.com>
Subject: Re: [PATCH RFC] usercopy: optimize stack check flow when the
 page-spanning test is disabled
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Yuanxiaofeng (XiAn)" <yuanxiaofeng1@huawei.com>
Cc: Matthew Wilcox <willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

(Please use contextual quoting in replies... mixing contextual with
top-posting becomes very hard to read...)

On Tue, Aug 14, 2018 at 6:02 AM, Yuanxiaofeng (XiAn)
<yuanxiaofeng1@huawei.com> wrote:
> On Tue, Aug 14, 2018 at 8:35PM Matthew Wilcox wrote:
>> On Tue, Aug 14, 2018 at 08:17:31PM +0800, Xiaofeng Yuan wrote:
>>> The check_heap_object() checks the spanning multiple pages and slab.
>>> When the page-spanning test is disabled, the check_heap_object() is
>>> redundant for spanning multiple pages. However, the kernel stacks are
>>> multiple pages under certain conditions: CONFIG_ARCH_THREAD_STACK_ALLOCATOR
>>> is not defined and (THREAD_SIZE >= PAGE_SIZE). At this point, We can skip
>>> the check_heap_object() for kernel stacks to improve performance.
>>> Similarly, the virtually-mapped stack can skip check_heap_object() also,
>>> beacause virt_addr_valid() will return.
>>
>> Why not just check_stack_object() first, then check_heap_object() second?

Most of the dynamically-sized copies (i.e. those that will trigger
__check_object_size being used at all) come out of heap. Stack copies
tend to be a fixed size. That said, the stack check is pretty cheap:
if it's not bounded by task_stack_page(current) ... +THREAD_SIZE, it
kicks out immediately. The frame-walking will only happen if it IS
actually stack (and once finished will short-circuit all remaining
tests).

> 1, When the THREAD_SIZE is less than PAGE_SIZE, the stack will allocate memory by kmem_cache_alloc_node(), it's slab memory and will execute __check_heap_object().

Correct, though if an architecture supports stack frame analysis, this
is a more narrow check than the bulk heap object check. (i.e. it may
have sub-object granularity to determine if a copy spans a stack
frame.) This supports the idea of just doing the stack check first,
though.

> 2, When CONFIG_HARDENED_USERCOPY_PAGESPAN is enabled, the multiple-pages stacks will do some check in check_page_span().

PAGESPAN checking is buggy for a lot of reasons, unfortunately. It
should generally stay disabled unless someone is working on getting
rid of allocations that _should_ have marked themselves as spanning
pages. It's unclear if this is even a solvable problem in the kernel
right now due to how networking code manages skbs.

> So, I set some restrictions to make sure the useful check will not be skipped.

It'd be nice to find some workloads that visibly change by making the
heap/stack order change. I think the known worst-case (small-packet
UDP flooding) wouldn't get worse since both checks will be performed
in either case.

(Maybe we should also short-circuit early in heap checks if it IS a
valid heap object: no reason to go do the kernel text check after
that...)

-Kees

-- 
Kees Cook
Pixel Security
