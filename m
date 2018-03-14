Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0D46B0024
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 09:04:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u68so1572907pfk.8
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 06:04:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 30-v6si1921814plc.446.2018.03.14.06.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Mar 2018 06:04:24 -0700 (PDT)
Date: Wed, 14 Mar 2018 06:04:18 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH v19 0/8] mm: security: ro protection for dynamic data
Message-ID: <20180314130418.GG29631@bombadil.infradead.org>
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
 <a9bfc57f-1591-21b6-1676-b60341a2fadd@huawei.com>
 <20180314115653.GD29631@bombadil.infradead.org>
 <8623382b-cdbe-8862-8c2f-fa5bc6a1213a@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8623382b-cdbe-8862-8c2f-fa5bc6a1213a@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: keescook@chromium.org, david@fromorbit.com, rppt@linux.vnet.ibm.com, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Mar 14, 2018 at 02:55:10PM +0200, Igor Stoppa wrote:
> >  The page_frag allocator seems like a much better place to
> > start than genalloc.  It has a significantly lower overhead and is
> > much more suited to the kind of probably-identical-lifespan that the
> > pmalloc API is going to persuade its users to have.
> 
> Could you please provide me a pointer?
> I did a quick search on 4.16-rc5 and found the definition of page_frag
> and sk_page_frag(). Is this what you are referring to?

It's a blink-and-you'll-miss-it allocator buried deep in mm/page_alloc.c:
void *page_frag_alloc(struct page_frag_cache *nc,
                      unsigned int fragsz, gfp_t gfp_mask)
void page_frag_free(void *addr)

I don't necessarily think you should use it as-is, but the principle it uses
seems like a better match to me than the rather complex genalloc.  Just
allocate some pages and track the offset within those pages that is the
current allocation point.  It's less than 100 lines of code!
