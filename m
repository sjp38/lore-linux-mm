Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1252C6B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 08:15:54 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u3so1348410pgp.13
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 05:15:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s10si2025540pfi.143.2018.03.14.05.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Mar 2018 05:15:51 -0700 (PDT)
Date: Wed, 14 Mar 2018 05:15:47 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 5/8] Protectable Memory
Message-ID: <20180314121547.GE29631@bombadil.infradead.org>
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
 <20180313214554.28521-6-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313214554.28521-6-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, Mar 13, 2018 at 11:45:51PM +0200, Igor Stoppa wrote:
> +static inline void *pmalloc_array(struct gen_pool *pool, size_t n,
> +				  size_t size, gfp_t flags)
> +{
> +	if (unlikely(!(pool && n && size)))
> +		return NULL;

Why not use the same formula as kvmalloc_array here?  You've failed to
protect against integer overflow, which is the whole point of pmalloc_array.

	if (size != 0 && n > SIZE_MAX / size)
		return NULL;

> +static inline char *pstrdup(struct gen_pool *pool, const char *s, gfp_t gfp)
> +{
> +	size_t len;
> +	char *buf;
> +
> +	if (unlikely(pool == NULL || s == NULL))
> +		return NULL;

No, delete these checks.  They'll mask real bugs.

> +static inline void pfree(struct gen_pool *pool, const void *addr)
> +{
> +	gen_pool_free(pool, (unsigned long)addr, 0);
> +}

It's poor form to use a different subsystem's type here.  It ties you
to genpool, so if somebody wants to replace it, you have to go through
all the users and change them.  If you use your own type, it's a much
easier task.

struct pmalloc_pool {
	struct gen_pool g;
}

then:

static inline void pfree(struct pmalloc_pool *pool, const void *addr)
{
	gen_pool_free(&pool->g, (unsigned long)addr, 0);
}

Looking further down, you could (should) move the contents of pmalloc_data
into pmalloc_pool; that's one fewer object to keep track of.

> +struct pmalloc_data {
> +	struct gen_pool *pool;  /* Link back to the associated pool. */
> +	bool protected;     /* Status of the pool: RO or RW. */
> +	struct kobj_attribute attr_protected; /* Sysfs attribute. */
> +	struct kobj_attribute attr_avail;     /* Sysfs attribute. */
> +	struct kobj_attribute attr_size;      /* Sysfs attribute. */
> +	struct kobj_attribute attr_chunks;    /* Sysfs attribute. */
> +	struct kobject *pool_kobject;
> +	struct list_head node; /* list of pools */
> +};

sysfs attributes aren't free, you know.  I appreciate you want something
to help debug / analyse, but having one file for the whole subsystem or
at least one per pool would be a better idea.
