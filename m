Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 23EDD6B0008
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 14:05:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t123so4563757wmt.2
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 11:05:31 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id g15si563083wmi.109.2018.03.19.11.05.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 11:05:29 -0700 (PDT)
Subject: Re: [RFC PATCH v19 0/8] mm: security: ro protection for dynamic data
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
 <a9bfc57f-1591-21b6-1676-b60341a2fadd@huawei.com>
 <20180314115653.GD29631@bombadil.infradead.org>
 <8623382b-cdbe-8862-8c2f-fa5bc6a1213a@huawei.com>
 <20180314130418.GG29631@bombadil.infradead.org>
 <9623b0d1-4ace-b3e7-b861-edba03b8a8cd@huawei.com>
 <20180314173343.GJ29631@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <242fd8a2-2b80-3aa3-4b11-27f49c021a1d@huawei.com>
Date: Mon, 19 Mar 2018 20:04:35 +0200
MIME-Version: 1.0
In-Reply-To: <20180314173343.GJ29631@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: keescook@chromium.org, david@fromorbit.com, rppt@linux.vnet.ibm.com, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 14/03/18 19:33, Matthew Wilcox wrote:
> I think an implementation of
> pmalloc which used a page_frag-style allocator would be larger than
> 100 lines, but I don't think it would have to be significantly larger
> than that.

I have some doubt about what is the best way to implement it using
vmalloced memory.

1. Since I can allocate an arbitrary number of pages, I think allocating
a rounded up amount of memory, so that it's multiple of PAGE_SIZE should
be enough.

But maybe I could do better than that:
a) support pre-allocation of x pages

b) define, as pool parameter, the minimum number of pages to allocate
every time there is a refill

c) both a and b


----


2. the flavor of page_frag from page_alloc relies on page->_refcount,
however neither vmap_area, nor vm_struct seem to have anything like
that. (My reasoning is that I should do the accounting not on page
level, but based on the virtual area that I get when I allocate new
memory) What would be the best way to do refcounting for the area?

a) use the the page->_refcount from the first page that belongs to the area

b) add the _refcount to either vm_struct or vmap_area (I am not really
sure of why these two structures exist as separate entities, rather than
a single one - cache optimization?)


----

3. I will have to add a list of chunks (in genalloc lingo, or areas, if
we refer to the new implementation), because I will still need to
iterate over all the memory that belongs to a pool, for either write
protecting it or for destroying the pool. I have two options:

a) handle the chunks within the pmalloc pool

b) create an intermediate type of pool (vfrag_pool?) and then include it
in the pmalloc pool structure.

I'd lean toward option a, but I thought I might as well ask for advice
before I implement the less desirable option (whatever it might be).

--
thanks, igor
