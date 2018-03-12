Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D48506B0028
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 15:13:22 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id az5-v6so8991692plb.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 12:13:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d14si6259247pfk.29.2018.03.12.12.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Mar 2018 12:13:21 -0700 (PDT)
Date: Mon, 12 Mar 2018 12:13:15 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 4/7] Protectable Memory
Message-ID: <20180312191314.GA29191@bombadil.infradead.org>
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-5-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180228200620.30026-5-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: david@fromorbit.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Feb 28, 2018 at 10:06:17PM +0200, Igor Stoppa wrote:
> struct gen_pool *pmalloc_create_pool(const char *name,
> 					 int min_alloc_order);
> int is_pmalloc_object(const void *ptr, const unsigned long n);
> bool pmalloc_prealloc(struct gen_pool *pool, size_t size);
> void *pmalloc(struct gen_pool *pool, size_t size, gfp_t gfp);
> static inline void *pzalloc(struct gen_pool *pool, size_t size, gfp_t gfp)
> static inline void *pmalloc_array(struct gen_pool *pool, size_t n,
> 				  size_t size, gfp_t flags)
> static inline void *pcalloc(struct gen_pool *pool, size_t n,
> 			    size_t size, gfp_t flags)
> static inline char *pstrdup(struct gen_pool *pool, const char *s, gfp_t gfp)
> int pmalloc_protect_pool(struct gen_pool *pool);
> static inline void pfree(struct gen_pool *pool, const void *addr)
> int pmalloc_destroy_pool(struct gen_pool *pool);

Do you have users for all these functions?  I'm particularly sceptical of
pfree().  To my mind, a user wants to:

pmalloc_create();
pmalloc(); * N
pmalloc_protect();
...
pmalloc_destroy();

I don't mind the pstrdup, pcalloc, pmalloc_array, pzalloc variations, but
I don't know why you need is_pmalloc_object().
