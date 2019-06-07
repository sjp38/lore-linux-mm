Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FAA5C468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 15:35:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CF7F208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 15:35:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Qr2bXb/r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CF7F208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 978E96B0266; Fri,  7 Jun 2019 11:35:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 928456B0269; Fri,  7 Jun 2019 11:35:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C86D6B026A; Fri,  7 Jun 2019 11:35:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4372D6B0266
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 11:35:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so1630283pgo.14
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 08:35:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=rMn+KK/+/vKIITpmVYk3t/A5lzW1s3V3VN8uxsCf9bI=;
        b=fOTipgRoceBV98poBkTFsBMKriZECIRjpgjnXRViT3AdrymShFN1wr30XpJGN+OU5t
         SnE6F6g/AKyyCZvAA7w5lUTjQp6B1zwboy5RBKPLHPRW+P7dg+jtSzf/ZZs79jMe4fmZ
         0cV1NWF7IBmdnFTkLTypDJktTMS+lQ/b90nUvM8Q1EZ7gXrWYp/1vj10G99drYMxCmiy
         dHclNqOknynwnsWCjavmCZm1x2/tbuLzCCOcQzb/6wx2gKcEzYMpye3O2AezZ69B44+k
         rSpt/QVKDvuc6WhckZWl3HvWuEOuse/e78hfvxi47Kn4yqqZHTsHcxQxMdYlzPzaNk3r
         yCvA==
X-Gm-Message-State: APjAAAXnVs8q5hibYbui5eWMIvhKDwoK0B7PaItl4IHzUG5HShnhhnOZ
	0QXuAuLbacAfnsCrlJtKEDnPqnB6LjyNch9OLOB0geg9ME/QHl4oCMmdfmaYeF/J6QTQB9VRfRx
	dXwa+PLRJUrPjxeoJD7ou+jou1EK5t+beZYmx6cjFkP5+DL4Z4lp2X0tYHBvnkwmpUg==
X-Received: by 2002:a63:b1d:: with SMTP id 29mr3327088pgl.103.1559921745602;
        Fri, 07 Jun 2019 08:35:45 -0700 (PDT)
X-Received: by 2002:a63:b1d:: with SMTP id 29mr3326981pgl.103.1559921744561;
        Fri, 07 Jun 2019 08:35:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559921744; cv=none;
        d=google.com; s=arc-20160816;
        b=SNYH+fnxUv+Czn1vjjiS+NXZdMmvnszGM0pDZrtC5AiWLhisuPGaPKlvnP4mjHYSdo
         vHNSkthfNt4eZqbxDjCOvt6VNl3mVs8FLNkZmRzI5CzutCeQaygdBbjmCR+HWbJ/R8No
         BkDX8eII1Np6cWIsU9hjY0JhAr0hu/4PkJrRuMKwT0Gzxgj/vuk+FBFcdusVJHjhiDqq
         PXBegI6DBxepkz0rgdubklWJDmjuHBueacbT/LJVKUdbehP2IzN0P6Myf7O2ehNWUWiE
         Us5GqyHP+7WKJplPZN8nDZ68xGx59wrBjOa39t2QwCPtWvJtv1YDhlTDMlR47k4caLHf
         taaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=rMn+KK/+/vKIITpmVYk3t/A5lzW1s3V3VN8uxsCf9bI=;
        b=g7e3c3x63a5NBh9+X/2ytwTvzykiTfPnvdD0hdEpU9VbS6YilyIgzLJT+pzTqja0dT
         WesbeVduHacWMZpD6n9wRdLx5pBVFkjDiJFygVvXbKLOgN8noQy+oeyJYGvpxNiWbRAb
         xOsEGqcecB89vrDyFb2yIOLn9hafsFCh9zG3BhT/jvg7dtnUYLRbci2CkDflqF5doxvJ
         2Ox1yHhdWQLZZTCH4JGfBQLqETADo9Z+VTbNtXQCujMoco56LZ2E7+41wI9XdiWjiTM8
         LmCZawX/vpProdp7mfLON3bygZBzs64ILxByoQ+VU2V1yXMvZXLGt9JDWT49eIpKerwg
         WTWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="Qr2bXb/r";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x9sor2907016plv.3.2019.06.07.08.35.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 08:35:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="Qr2bXb/r";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=rMn+KK/+/vKIITpmVYk3t/A5lzW1s3V3VN8uxsCf9bI=;
        b=Qr2bXb/rPbjHR5W24GxZg0GFCgx/nV17NNjk335upAGobJW/NPtxnYjlQ7o8FcSmT7
         cj6/uqPsjn93KfrpGj9wOuAIfl+KRKxQbT+xW39oxM/HP+LOHlBDaTzJUPo8Z3B55G/K
         Od0bSrpc40XNpkJXQh0Z7BbRG2t4kZKR8kPU0=
X-Google-Smtp-Source: APXvYqw054aTQzsZjBDfzH78jJKXgD1KGE6ib+0E0JaSGrok7MZROstpxgyRZFQTk9BJ6WThQ2BcjQ==
X-Received: by 2002:a17:902:7d8b:: with SMTP id a11mr19850750plm.96.1559921744201;
        Fri, 07 Jun 2019 08:35:44 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id j7sm7340333pjb.26.2019.06.07.08.35.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 08:35:43 -0700 (PDT)
Date: Fri, 7 Jun 2019 08:35:42 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>, Jann Horn <jannh@google.com>,
	Marco Elver <elver@google.com>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com
Subject: Re: [PATCH v6 3/3] lib: introduce test_meminit module
Message-ID: <201906070835.EA9D8C100@keescook>
References: <20190606164845.179427-1-glider@google.com>
 <20190606164845.179427-4-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606164845.179427-4-glider@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 06:48:45PM +0200, Alexander Potapenko wrote:
> Add tests for heap and pagealloc initialization.
> These can be used to check init_on_alloc and init_on_free implementations
> as well as other approaches to initialization.
> 
> Expected test output in the case the kernel provides heap initialization
> (e.g. when running with either init_on_alloc=1 or init_on_free=1):
> 
>   test_meminit: all 10 tests in test_pages passed
>   test_meminit: all 40 tests in test_kvmalloc passed
>   test_meminit: all 60 tests in test_kmemcache passed
>   test_meminit: all 10 tests in test_rcu_persistent passed
>   test_meminit: all 120 tests passed!
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> To: Kees Cook <keescook@chromium.org>
> To: Andrew Morton <akpm@linux-foundation.org>
> To: Christoph Lameter <cl@linux.com>
> Cc: Nick Desaulniers <ndesaulniers@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Sandeep Patil <sspatil@android.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Jann Horn <jannh@google.com>
> Cc: Marco Elver <elver@google.com>
> Cc: linux-mm@kvack.org
> Cc: linux-security-module@vger.kernel.org
> Cc: kernel-hardening@lists.openwall.com
> ---
>  v3:
>   - added example test output to the description
>   - fixed a missing include spotted by kbuild test robot <lkp@intel.com>
>   - added a missing MODULE_LICENSE
>   - call do_kmem_cache_size() with size >= sizeof(void*) to unbreak
>   debug builds
>  v5:
>   - added tests for RCU slabs and __GFP_ZERO
> ---
>  lib/Kconfig.debug  |   8 +
>  lib/Makefile       |   1 +
>  lib/test_meminit.c | 362 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 371 insertions(+)
>  create mode 100644 lib/test_meminit.c
> 
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index cbdfae379896..085711f14abf 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -2040,6 +2040,14 @@ config TEST_STACKINIT
>  
>  	  If unsure, say N.
>  
> +config TEST_MEMINIT
> +	tristate "Test heap/page initialization"
> +	help
> +	  Test if the kernel is zero-initializing heap and page allocations.
> +	  This can be useful to test init_on_alloc and init_on_free features.
> +
> +	  If unsure, say N.
> +
>  endif # RUNTIME_TESTING_MENU
>  
>  config MEMTEST
> diff --git a/lib/Makefile b/lib/Makefile
> index fb7697031a79..05980c802500 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -91,6 +91,7 @@ obj-$(CONFIG_TEST_DEBUG_VIRTUAL) += test_debug_virtual.o
>  obj-$(CONFIG_TEST_MEMCAT_P) += test_memcat_p.o
>  obj-$(CONFIG_TEST_OBJAGG) += test_objagg.o
>  obj-$(CONFIG_TEST_STACKINIT) += test_stackinit.o
> +obj-$(CONFIG_TEST_MEMINIT) += test_meminit.o
>  
>  obj-$(CONFIG_TEST_LIVEPATCH) += livepatch/
>  
> diff --git a/lib/test_meminit.c b/lib/test_meminit.c
> new file mode 100644
> index 000000000000..ed7efec1387b
> --- /dev/null
> +++ b/lib/test_meminit.c
> @@ -0,0 +1,362 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * Test cases for SL[AOU]B/page initialization at alloc/free time.
> + */
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/mm.h>
> +#include <linux/module.h>
> +#include <linux/slab.h>
> +#include <linux/string.h>
> +#include <linux/vmalloc.h>
> +
> +#define GARBAGE_INT (0x09A7BA9E)
> +#define GARBAGE_BYTE (0x9E)
> +
> +#define REPORT_FAILURES_IN_FN() \
> +	do {	\
> +		if (failures)	\
> +			pr_info("%s failed %d out of %d times\n",	\
> +				__func__, failures, num_tests);		\
> +		else		\
> +			pr_info("all %d tests in %s passed\n",		\
> +				num_tests, __func__);			\
> +	} while (0)
> +
> +/* Calculate the number of uninitialized bytes in the buffer. */
> +static int __init count_nonzero_bytes(void *ptr, size_t size)
> +{
> +	int i, ret = 0;
> +	unsigned char *p = (unsigned char *)ptr;
> +
> +	for (i = 0; i < size; i++)
> +		if (p[i])
> +			ret++;
> +	return ret;
> +}
> +
> +/* Fill a buffer with garbage, skipping |skip| first bytes. */
> +static void __init fill_with_garbage_skip(void *ptr, size_t size, size_t skip)
> +{
> +	unsigned int *p = (unsigned int *)ptr;
> +	int i = 0;
> +
> +	if (skip) {
> +		WARN_ON(skip > size);
> +		p += skip;
> +	}
> +	while (size >= sizeof(*p)) {
> +		p[i] = GARBAGE_INT;
> +		i++;
> +		size -= sizeof(*p);
> +	}
> +	if (size)
> +		memset(&p[i], GARBAGE_BYTE, size);
> +}
> +
> +static void __init fill_with_garbage(void *ptr, size_t size)
> +{
> +	fill_with_garbage_skip(ptr, size, 0);
> +}
> +
> +static int __init do_alloc_pages_order(int order, int *total_failures)
> +{
> +	struct page *page;
> +	void *buf;
> +	size_t size = PAGE_SIZE << order;
> +
> +	page = alloc_pages(GFP_KERNEL, order);
> +	buf = page_address(page);
> +	fill_with_garbage(buf, size);
> +	__free_pages(page, order);
> +
> +	page = alloc_pages(GFP_KERNEL, order);
> +	buf = page_address(page);
> +	if (count_nonzero_bytes(buf, size))
> +		(*total_failures)++;
> +	fill_with_garbage(buf, size);
> +	__free_pages(page, order);
> +	return 1;
> +}
> +
> +/* Test the page allocator by calling alloc_pages with different orders. */
> +static int __init test_pages(int *total_failures)
> +{
> +	int failures = 0, num_tests = 0;
> +	int i;
> +
> +	for (i = 0; i < 10; i++)
> +		num_tests += do_alloc_pages_order(i, &failures);
> +
> +	REPORT_FAILURES_IN_FN();
> +	*total_failures += failures;
> +	return num_tests;
> +}
> +
> +/* Test kmalloc() with given parameters. */
> +static int __init do_kmalloc_size(size_t size, int *total_failures)
> +{
> +	void *buf;
> +
> +	buf = kmalloc(size, GFP_KERNEL);
> +	fill_with_garbage(buf, size);
> +	kfree(buf);
> +
> +	buf = kmalloc(size, GFP_KERNEL);
> +	if (count_nonzero_bytes(buf, size))
> +		(*total_failures)++;
> +	fill_with_garbage(buf, size);
> +	kfree(buf);
> +	return 1;
> +}
> +
> +/* Test vmalloc() with given parameters. */
> +static int __init do_vmalloc_size(size_t size, int *total_failures)
> +{
> +	void *buf;
> +
> +	buf = vmalloc(size);
> +	fill_with_garbage(buf, size);
> +	vfree(buf);
> +
> +	buf = vmalloc(size);
> +	if (count_nonzero_bytes(buf, size))
> +		(*total_failures)++;
> +	fill_with_garbage(buf, size);
> +	vfree(buf);
> +	return 1;
> +}
> +
> +/* Test kmalloc()/vmalloc() by allocating objects of different sizes. */
> +static int __init test_kvmalloc(int *total_failures)
> +{
> +	int failures = 0, num_tests = 0;
> +	int i, size;
> +
> +	for (i = 0; i < 20; i++) {
> +		size = 1 << i;
> +		num_tests += do_kmalloc_size(size, &failures);
> +		num_tests += do_vmalloc_size(size, &failures);
> +	}
> +
> +	REPORT_FAILURES_IN_FN();
> +	*total_failures += failures;
> +	return num_tests;
> +}
> +
> +#define CTOR_BYTES (sizeof(unsigned int))
> +#define CTOR_PATTERN (0x41414141)
> +/* Initialize the first 4 bytes of the object. */
> +static void test_ctor(void *obj)
> +{
> +	*(unsigned int *)obj = CTOR_PATTERN;
> +}
> +
> +/*
> + * Check the invariants for the buffer allocated from a slab cache.
> + * If the cache has a test constructor, the first 4 bytes of the object must
> + * always remain equal to CTOR_PATTERN.
> + * If the cache isn't an RCU-typesafe one, or if the allocation is done with
> + * __GFP_ZERO, then the object contents must be zeroed after allocation.
> + * If the cache is an RCU-typesafe one, the object contents must never be
> + * zeroed after the first use. This is checked by memcmp() in
> + * do_kmem_cache_size().
> + */
> +static bool __init check_buf(void *buf, int size, bool want_ctor,
> +			     bool want_rcu, bool want_zero)
> +{
> +	int bytes;
> +	bool fail = false;
> +
> +	bytes = count_nonzero_bytes(buf, size);
> +	WARN_ON(want_ctor && want_zero);
> +	if (want_zero)
> +		return bytes;
> +	if (want_ctor) {
> +		if (*(unsigned int *)buf != CTOR_PATTERN)
> +			fail = 1;
> +	} else {
> +		if (bytes)
> +			fail = !want_rcu;
> +	}
> +	return fail;
> +}
> +
> +/*
> + * Test kmem_cache with given parameters:
> + *  want_ctor - use a constructor;
> + *  want_rcu - use SLAB_TYPESAFE_BY_RCU;
> + *  want_zero - use __GFP_ZERO.
> + */
> +static int __init do_kmem_cache_size(size_t size, bool want_ctor,
> +				     bool want_rcu, bool want_zero,
> +				     int *total_failures)
> +{
> +	struct kmem_cache *c;
> +	int iter;
> +	bool fail = false;
> +	gfp_t alloc_mask = GFP_KERNEL | (want_zero ? __GFP_ZERO : 0);
> +	void *buf, *buf_copy;
> +
> +	c = kmem_cache_create("test_cache", size, 1,
> +			      want_rcu ? SLAB_TYPESAFE_BY_RCU : 0,
> +			      want_ctor ? test_ctor : NULL);
> +	for (iter = 0; iter < 10; iter++) {
> +		buf = kmem_cache_alloc(c, alloc_mask);
> +		/* Check that buf is zeroed, if it must be. */
> +		fail = check_buf(buf, size, want_ctor, want_rcu, want_zero);
> +		fill_with_garbage_skip(buf, size, want_ctor ? CTOR_BYTES : 0);
> +		/*
> +		 * If this is an RCU cache, use a critical section to ensure we
> +		 * can touch objects after they're freed.
> +		 */
> +		if (want_rcu) {
> +			rcu_read_lock();
> +			/*
> +			 * Copy the buffer to check that it's not wiped on
> +			 * free().
> +			 */
> +			buf_copy = kmalloc(size, GFP_KERNEL);
> +			if (buf_copy)
> +				memcpy(buf_copy, buf, size);
> +		}
> +		kmem_cache_free(c, buf);
> +		if (want_rcu) {
> +			/*
> +			 * Check that |buf| is intact after kmem_cache_free().
> +			 * |want_zero| is false, because we wrote garbage to
> +			 * the buffer already.
> +			 */
> +			fail |= check_buf(buf, size, want_ctor, want_rcu,
> +					  false);
> +			if (buf_copy) {
> +				fail |= (bool)memcmp(buf, buf_copy, size);
> +				kfree(buf_copy);
> +			}
> +			rcu_read_unlock();
> +		}
> +	}
> +	kmem_cache_destroy(c);
> +
> +	*total_failures += fail;
> +	return 1;
> +}
> +
> +/*
> + * Check that the data written to an RCU-allocated object survives
> + * reallocation.
> + */
> +static int __init do_kmem_cache_rcu_persistent(int size, int *total_failures)
> +{
> +	struct kmem_cache *c;
> +	void *buf, *buf_contents, *saved_ptr;
> +	void **used_objects;
> +	int i, iter, maxiter = 1024;
> +	bool fail = false;
> +
> +	c = kmem_cache_create("test_cache", size, size, SLAB_TYPESAFE_BY_RCU,
> +			      NULL);
> +	buf = kmem_cache_alloc(c, GFP_KERNEL);
> +	saved_ptr = buf;
> +	fill_with_garbage(buf, size);
> +	buf_contents = kmalloc(size, GFP_KERNEL);
> +	if (!buf_contents)
> +		goto out;
> +	used_objects = kmalloc_array(maxiter, sizeof(void *), GFP_KERNEL);
> +	if (!used_objects) {
> +		kfree(buf_contents);
> +		goto out;
> +	}
> +	memcpy(buf_contents, buf, size);
> +	kmem_cache_free(c, buf);
> +	/*
> +	 * Run for a fixed number of iterations. If we never hit saved_ptr,
> +	 * assume the test passes.
> +	 */
> +	for (iter = 0; iter < maxiter; iter++) {
> +		buf = kmem_cache_alloc(c, GFP_KERNEL);
> +		used_objects[iter] = buf;
> +		if (buf == saved_ptr) {
> +			fail = memcmp(buf_contents, buf, size);
> +			for (i = 0; i <= iter; i++)
> +				kmem_cache_free(c, used_objects[i]);
> +			goto free_out;
> +		}
> +	}
> +
> +free_out:
> +	kmem_cache_destroy(c);
> +	kfree(buf_contents);
> +	kfree(used_objects);
> +out:
> +	*total_failures += fail;
> +	return 1;
> +}
> +
> +/*
> + * Test kmem_cache allocation by creating caches of different sizes, with and
> + * without constructors, with and without SLAB_TYPESAFE_BY_RCU.
> + */
> +static int __init test_kmemcache(int *total_failures)
> +{
> +	int failures = 0, num_tests = 0;
> +	int i, flags, size;
> +	bool ctor, rcu, zero;
> +
> +	for (i = 0; i < 10; i++) {
> +		size = 8 << i;
> +		for (flags = 0; flags < 8; flags++) {
> +			ctor = flags & 1;
> +			rcu = flags & 2;
> +			zero = flags & 4;
> +			if (ctor & zero)
> +				continue;
> +			num_tests += do_kmem_cache_size(size, ctor, rcu, zero,
> +							&failures);
> +		}
> +	}
> +	REPORT_FAILURES_IN_FN();
> +	*total_failures += failures;
> +	return num_tests;
> +}
> +
> +/* Test the behavior of SLAB_TYPESAFE_BY_RCU caches of different sizes. */
> +static int __init test_rcu_persistent(int *total_failures)
> +{
> +	int failures = 0, num_tests = 0;
> +	int i, size;
> +
> +	for (i = 0; i < 10; i++) {
> +		size = 8 << i;
> +		num_tests += do_kmem_cache_rcu_persistent(size, &failures);
> +	}
> +	REPORT_FAILURES_IN_FN();
> +	*total_failures += failures;
> +	return num_tests;
> +}
> +
> +/*
> + * Run the tests. Each test function returns the number of executed tests and
> + * updates |failures| with the number of failed tests.
> + */
> +static int __init test_meminit_init(void)
> +{
> +	int failures = 0, num_tests = 0;
> +
> +	num_tests += test_pages(&failures);
> +	num_tests += test_kvmalloc(&failures);
> +	num_tests += test_kmemcache(&failures);
> +	num_tests += test_rcu_persistent(&failures);
> +
> +	if (failures == 0)
> +		pr_info("all %d tests passed!\n", num_tests);
> +	else
> +		pr_info("failures: %d out of %d\n", failures, num_tests);
> +
> +	return failures ? -EINVAL : 0;
> +}
> +module_init(test_meminit_init);
> +
> +MODULE_LICENSE("GPL");
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

-- 
Kees Cook

