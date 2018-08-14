Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB93D6B0007
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 09:09:30 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id c21-v6so8612329pgw.0
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 06:09:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r84-v6si22124707pfj.355.2018.08.14.06.09.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 Aug 2018 06:09:29 -0700 (PDT)
Date: Tue, 14 Aug 2018 06:09:28 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH RFC] usercopy: optimize stack check flow when the
 page-spanning test is disabled
Message-ID: <20180814130928.GB25328@bombadil.infradead.org>
References: <1534249051-56879-1-git-send-email-yuanxiaofeng1@huawei.com>
 <20180814123454.GA25328@bombadil.infradead.org>
 <494CFD22286B8448AF161132C5FE9A985B624E05@dggema521-mbx.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <494CFD22286B8448AF161132C5FE9A985B624E05@dggema521-mbx.china.huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Yuanxiaofeng (XiAn)" <yuanxiaofeng1@huawei.com>
Cc: "keescook@chromium.org" <keescook@chromium.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Aug 14, 2018 at 01:02:55PM +0000, Yuanxiaofeng (XiAn) wrote:
> 1, When the THREAD_SIZE is less than PAGE_SIZE, the stack will allocate memory by kmem_cache_alloc_node(), it's slab memory and will execute __check_heap_object().
> 2, When CONFIG_HARDENED_USERCOPY_PAGESPAN is enabled, the multiple-pages stacks will do some check in check_page_span().

I understand the checks will still do something useful, but I do not see the
scenario in which an object would satisfy the stack checks but fail the heap
checks.

> So, I set some restrictions to make sure the useful check will not be skipped.
> 
> -----Original Message-----
> From: Matthew Wilcox [mailto:willy@infradead.org] 
> Sent: Tuesday, August 14, 2018 8:35 PM
> To: Yuanxiaofeng (XiAn)
> Cc: keescook@chromium.org; linux-mm@kvack.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH RFC] usercopy: optimize stack check flow when the
> 
> On Tue, Aug 14, 2018 at 08:17:31PM +0800, Xiaofeng Yuan wrote:
> > The check_heap_object() checks the spanning multiple pages and slab.
> > When the page-spanning test is disabled, the check_heap_object() is
> > redundant for spanning multiple pages. However, the kernel stacks are
> > multiple pages under certain conditions: CONFIG_ARCH_THREAD_STACK_ALLOCATOR
> > is not defined and (THREAD_SIZE >= PAGE_SIZE). At this point, We can skip
> > the check_heap_object() for kernel stacks to improve performance.
> > Similarly, the virtually-mapped stack can skip check_heap_object() also,
> > beacause virt_addr_valid() will return.
> 
> Why not just check_stack_object() first, then check_heap_object() second?
> 
