Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C218D6B0003
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 09:02:59 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id c21-v6so8604208pgw.0
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 06:02:59 -0700 (PDT)
Received: from huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id o21-v6si19705503pgk.337.2018.08.14.06.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 06:02:58 -0700 (PDT)
From: "Yuanxiaofeng (XiAn)" <yuanxiaofeng1@huawei.com>
Subject: RE: [PATCH RFC] usercopy: optimize stack check flow when the
 page-spanning test is disabled
Date: Tue, 14 Aug 2018 13:02:55 +0000
Message-ID: <494CFD22286B8448AF161132C5FE9A985B624E05@dggema521-mbx.china.huawei.com>
References: <1534249051-56879-1-git-send-email-yuanxiaofeng1@huawei.com>
 <20180814123454.GA25328@bombadil.infradead.org>
In-Reply-To: <20180814123454.GA25328@bombadil.infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "keescook@chromium.org" <keescook@chromium.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

1, When the THREAD_SIZE is less than PAGE_SIZE, the stack will allocate mem=
ory by kmem_cache_alloc_node(), it's slab memory and will execute __check_h=
eap_object().
2, When CONFIG_HARDENED_USERCOPY_PAGESPAN is enabled, the multiple-pages st=
acks will do some check in check_page_span().

So, I set some restrictions to make sure the useful check will not be skipp=
ed.

-----Original Message-----
From: Matthew Wilcox [mailto:willy@infradead.org]=20
Sent: Tuesday, August 14, 2018 8:35 PM
To: Yuanxiaofeng (XiAn)
Cc: keescook@chromium.org; linux-mm@kvack.org; linux-kernel@vger.kernel.org
Subject: Re: [PATCH RFC] usercopy: optimize stack check flow when the

On Tue, Aug 14, 2018 at 08:17:31PM +0800, Xiaofeng Yuan wrote:
> The check_heap_object() checks the spanning multiple pages and slab.
> When the page-spanning test is disabled, the check_heap_object() is
> redundant for spanning multiple pages. However, the kernel stacks are
> multiple pages under certain conditions: CONFIG_ARCH_THREAD_STACK_ALLOCAT=
OR
> is not defined and (THREAD_SIZE >=3D PAGE_SIZE). At this point, We can sk=
ip
> the check_heap_object() for kernel stacks to improve performance.
> Similarly, the virtually-mapped stack can skip check_heap_object() also,
> beacause virt_addr_valid() will return.

Why not just check_stack_object() first, then check_heap_object() second?
