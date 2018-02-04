Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7B86B0005
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 17:19:27 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id q5so7368930pll.17
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 14:19:27 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z7si5849141pfa.360.2018.02.04.14.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 04 Feb 2018 14:19:25 -0800 (PST)
Subject: Re: [PATCH 2/6] genalloc: selftest
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
 <20180204164732.28241-3-igor.stoppa@huawei.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <e05598c1-3c7c-15c6-7278-ed52ceff0acf@infradead.org>
Date: Sun, 4 Feb 2018 14:19:22 -0800
MIME-Version: 1.0
In-Reply-To: <20180204164732.28241-3-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 02/04/2018 08:47 AM, Igor Stoppa wrote:
> Introduce a set of macros for writing concise test cases for genalloc.
> 
> The test cases are meant to provide regression testing, when working on
> new functionality for genalloc.
> 
> Primarily they are meant to confirm that the various allocation strategy
> will continue to work as expected.
> 
> The execution of the self testing is controlled through a Kconfig option.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>  include/linux/genalloc-selftest.h |  30 +++
>  init/main.c                       |   2 +
>  lib/Kconfig                       |  15 ++
>  lib/Makefile                      |   1 +
>  lib/genalloc-selftest.c           | 402 ++++++++++++++++++++++++++++++++++++++
>  5 files changed, 450 insertions(+)
>  create mode 100644 include/linux/genalloc-selftest.h
>  create mode 100644 lib/genalloc-selftest.c
> 
> diff --git a/include/linux/genalloc-selftest.h b/include/linux/genalloc-selftest.h
> new file mode 100644
> index 000000000000..7af1901e57dc
> --- /dev/null
> +++ b/include/linux/genalloc-selftest.h
> @@ -0,0 +1,30 @@
> +/*
> + * genalloc-selftest.h
> + *
> + * (C) Copyright 2017 Huawei Technologies Co. Ltd.
> + * Author: Igor Stoppa <igor.stoppa@huawei.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; version 2
> + * of the License.
> + */
> +
> +
> +#ifndef __GENALLOC_SELFTEST_H__
> +#define __GENALLOC_SELFTEST_H__

Please use _LINUX_GENALLOC_SELFTEST_H_

> +
> +
> +#ifdef CONFIG_GENERIC_ALLOCATOR_SELFTEST
> +
> +#include <linux/genalloc.h>
> +
> +void genalloc_selftest(void);
> +
> +#else
> +
> +static inline void genalloc_selftest(void){};
> +
> +#endif
> +
> +#endif


> diff --git a/lib/genalloc-selftest.c b/lib/genalloc-selftest.c
> new file mode 100644
> index 000000000000..007a0cfb3d77
> --- /dev/null
> +++ b/lib/genalloc-selftest.c
> @@ -0,0 +1,402 @@
> +/*
> + * genalloc-selftest.c
> + *
> + * (C) Copyright 2017 Huawei Technologies Co. Ltd.
> + * Author: Igor Stoppa <igor.stoppa@huawei.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; version 2
> + * of the License.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/printk.h>
> +#include <linux/init.h>
> +#include <linux/vmalloc.h>
> +#include <asm/set_memory.h>
> +#include <linux/string.h>
> +#include <linux/debugfs.h>
> +#include <linux/atomic.h>
> +#include <linux/genalloc.h>
> +
> +
> +
> +/* Keep the bitmap small, while including case of cross-ulong mapping.
> + * For simplicity, the test cases use only 1 chunk of memory.
> + */
> +#define BITMAP_SIZE_C 16
> +#define ALLOC_ORDER 0
> +
> +#define ULONG_SIZE (sizeof(unsigned long))
> +#define BITMAP_SIZE_UL (BITMAP_SIZE_C / ULONG_SIZE)
> +#define MIN_ALLOC_SIZE (1 << ALLOC_ORDER)
> +#define ENTRIES (BITMAP_SIZE_C * 8)
> +#define CHUNK_SIZE  (MIN_ALLOC_SIZE * ENTRIES)
> +
> +#ifndef CONFIG_GENERIC_ALLOCATOR_SELFTEST_VERBOSE
> +
> +static inline void print_first_chunk_bitmap(struct gen_pool *pool) {}
> +
> +#else
> +
> +static void print_first_chunk_bitmap(struct gen_pool *pool)
> +{
> +	struct gen_pool_chunk *chunk;
> +	char bitmap[BITMAP_SIZE_C * 2 + 1];
> +	unsigned long i;
> +	char *bm = bitmap;
> +	char *entry;
> +
> +	if (unlikely(pool == NULL || pool->chunks.next == NULL))
> +		return;
> +
> +	chunk = container_of(pool->chunks.next, struct gen_pool_chunk,
> +			     next_chunk);
> +	entry = (void *)chunk->entries;
> +	for (i = 1; i <= BITMAP_SIZE_C; i++)
> +		bm += snprintf(bm, 3, "%02hhx", entry[BITMAP_SIZE_C - i]);
> +	*bm = '\0';
> +	pr_notice("chunk: %p    bitmap: 0x%s\n", chunk, bitmap);
> +
> +}
> +
> +#endif
> +
> +enum test_commands {
> +	CMD_ALLOCATOR,
> +	CMD_ALLOCATE,
> +	CMD_FLUSH,
> +	CMD_FREE,
> +	CMD_NUMBER,
> +	CMD_END = CMD_NUMBER,
> +};
> +
> +struct null_struct {
> +	void *null;
> +};
> +
> +struct test_allocator {
> +	genpool_algo_t algo;
> +	union {
> +		struct genpool_data_align align;
> +		struct genpool_data_fixed offset;
> +		struct null_struct null;
> +	} data;
> +};
> +
> +struct test_action {
> +	unsigned int location;
> +	char pattern[BITMAP_SIZE_C];
> +	unsigned int size;
> +};
> +
> +
> +struct test_command {
> +	enum test_commands command;
> +	union {
> +		struct test_allocator allocator;
> +		struct test_action action;
> +	};
> +};
> +
> +
> +/* To pass an array literal as parameter to a macro, it must go through
> + * this one, first.
> + */

Please use kernel multi-line comment style.

> +#define ARR(...) __VA_ARGS__
> +
> +#define SET_DATA(parameter, value)	\
> +	.parameter = {			\
> +		.parameter = value,	\
> +	}				\
> +
> +#define SET_ALLOCATOR(alloc, parameter, value)		\
> +{							\
> +	.command = CMD_ALLOCATOR,			\
> +	.allocator = {					\
> +		.algo = (alloc),			\
> +		.data = {				\
> +			SET_DATA(parameter, value),	\
> +		},					\
> +	}						\
> +}
> +
> +#define ACTION_MEM(act, mem_size, mem_loc, match)	\
> +{							\
> +	.command = act,					\
> +	.action = {					\
> +		.size = (mem_size),			\
> +		.location = (mem_loc),			\
> +		.pattern = match,			\
> +	},						\
> +}
> +
> +#define ALLOCATE_MEM(mem_size, mem_loc, match)	\
> +	ACTION_MEM(CMD_ALLOCATE, mem_size, mem_loc, ARR(match))
> +
> +#define FREE_MEM(mem_size, mem_loc, match)	\
> +	ACTION_MEM(CMD_FREE, mem_size, mem_loc, ARR(match))
> +
> +#define FLUSH_MEM()		\
> +{				\
> +	.command = CMD_FLUSH,	\
> +}
> +
> +#define END()			\
> +{				\
> +	.command = CMD_END,	\
> +}
> +
> +static inline int compare_bitmaps(const struct gen_pool *pool,
> +				   const char *reference)
> +{
> +	struct gen_pool_chunk *chunk;
> +	char *bitmap;
> +	unsigned int i;
> +
> +	chunk = container_of(pool->chunks.next, struct gen_pool_chunk,
> +			     next_chunk);
> +	bitmap = (char *)chunk->entries;
> +
> +	for (i = 0; i < BITMAP_SIZE_C; i++)
> +		if (bitmap[i] != reference[i])
> +			return -1;
> +	return 0;
> +}
> +
> +static void callback_set_allocator(struct gen_pool *pool,
> +				   const struct test_command *cmd,
> +				   unsigned long *locations)
> +{
> +	gen_pool_set_algo(pool, cmd->allocator.algo,
> +			  (void *)&cmd->allocator.data);
> +}
> +
> +static void callback_allocate(struct gen_pool *pool,
> +			      const struct test_command *cmd,
> +			      unsigned long *locations)
> +{
> +	const struct test_action *action = &cmd->action;
> +
> +	locations[action->location] = gen_pool_alloc(pool, action->size);
> +	BUG_ON(!locations[action->location]);
> +	print_first_chunk_bitmap(pool);
> +	BUG_ON(compare_bitmaps(pool, action->pattern));

BUG_ON() seems harsh to me, but some of the other self-tests also do that.

> +}
> +

[snip]

> +
> +/* To make the test work for both 32bit and 64bit ulong sizes,
> + * allocate (8 / 2 * 4 - 1) = 15 bytes bytes, then 16, then 2.
> + * The first allocation prepares for the crossing of the 32bit ulong
> + * threshold. The following crosses the 32bit threshold and prepares for
> + * crossing the 64bit thresholds. The last is large enough (2 bytes) to
> + * cross the 64bit threshold.
> + * Then free the allocations in the order: 2nd, 1st, 3rd.

Fix multi-line comment style.

> + */
> +const struct test_command test_ulong_span[] = {
> +	SET_ALLOCATOR(gen_pool_first_fit, null, NULL),
> +	ALLOCATE_MEM(15, 0, ARR({0xab, 0xaa, 0xaa, 0x2a})),
> +	ALLOCATE_MEM(16, 1, ARR({0xab, 0xaa, 0xaa, 0xea,
> +				0xaa, 0xaa, 0xaa, 0x2a})),
> +	ALLOCATE_MEM(2, 2, ARR({0xab, 0xaa, 0xaa, 0xea,
> +			       0xaa, 0xaa, 0xaa, 0xea,
> +			       0x02})),
> +	FREE_MEM(0, 1, ARR({0xab, 0xaa, 0xaa, 0x2a,
> +			   0x00, 0x00, 0x00, 0xc0,
> +			   0x02})),
> +	FREE_MEM(0, 0, ARR({0x00, 0x00, 0x00, 0x00,
> +			   0x00, 0x00, 0x00, 0xc0,
> +			   0x02})),
> +	FREE_MEM(0, 2, ARR({0x00})),
> +	END(),
> +};
> +
> +/* Create progressively smaller allocations A B C D E.
> + * then free B and D.
> + * Then create new allocation that would fit in both of the gaps left by
> + * B and D. Verify that it uses the gap from B.

Ditto.

> + */
> +const struct test_command test_first_fit_gaps[] = {


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
