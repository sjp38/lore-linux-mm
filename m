Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BB5266B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 17:36:29 -0400 (EDT)
Date: Tue, 28 Apr 2009 14:32:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-Id: <20090428143244.4e424d36.akpm@linux-foundation.org>
In-Reply-To: <20090428014920.769723618@intel.com>
References: <20090428010907.912554629@intel.com>
	<20090428014920.769723618@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, mpm@selenic.com, adobriyan@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Apr 2009 09:09:12 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> +/*
> + * Kernel flags are exported faithfully to Linus and his fellow hackers.
> + * Otherwise some details are masked to avoid confusing the end user:
> + * - some kernel flags are completely invisible
> + * - some kernel flags are conditionally invisible on their odd usages
> + */
> +#ifdef CONFIG_DEBUG_KERNEL
> +static inline int genuine_linus(void) { return 1; }

Although he's a fine chap, the use of the "_linus" tag isn't terribly
clear (to me).  I think what you're saying here is that this enables
kernel-developer-only features, yes?

If so, perhaps we could come up with an identifier which expresses that
more clearly.

But I'd expect that everyone and all distros enable CONFIG_DEBUG_KERNEL
for _some_ reason, so what's the point?

It is preferable that we always implement the same interface for all
Kconfig settings.  If this exposes information which is confusing or
not useful to end-users then so be it - we should be able to cover that
in supporting documentation.

Also, as mentioned in the other email, it would be good if we were to
publish a little userspace app which people can use to access this raw
data.  We could give that application an `--i-am-a-kernel-developer'
option!

> +#else
> +static inline int genuine_linus(void) { return 0; }
> +#endif

This isn't an appropriate use of CONFIG_DEBUG_KERNEL.

DEBUG_KERNEL is a Kconfig-only construct which is use to enable _other_
debugging features.  The way you've used it here, if the person who is
configuring the kernel wants to enable any other completely-unrelated
debug feature, they have to enable DEBUG_KERNEL first.  But when they
do that, they unexpectedly alter the behaviour of pagemap!

There are two other places where CONFIG_DEBUG_KERNEL affects code
generation in .c files: arch/parisc/mm/init.c and
arch/powerpc/kernel/sysfs.c.  These are both wrong, and need slapping ;)

> +#define kpf_copy_bit(uflags, kflags, visible, ubit, kbit)		\
> +	do {								\
> +		if (visible || genuine_linus())				\
> +			uflags |= ((kflags >> kbit) & 1) << ubit;	\
> +	} while (0);

Did this have to be implemented as a macro?

It's bad, because it might or might not reference its argument, so if
someone passes it an expression-with-side-effects, the end result is
unpredictable.  A C function is almost always preferable if possible.

> +/* a helper function _not_ intended for more general uses */
> +static inline int page_cap_writeback_dirty(struct page *page)
> +{
> +	struct address_space *mapping;
> +
> +	if (!PageSlab(page))
> +		mapping = page_mapping(page);
> +	else
> +		mapping = NULL;
> +
> +	return mapping && mapping_cap_writeback_dirty(mapping);
> +}

If the page isn't locked then page->mapping can be concurrently removed
and freed.  This actually happened to me in real-life testing several
years ago.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
