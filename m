Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 791AF6B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 11:40:13 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id pp5so10187494pac.3
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 08:40:13 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id zq10si3717799pab.103.2016.08.11.08.40.12
        for <linux-mm@kvack.org>;
        Thu, 11 Aug 2016 08:40:12 -0700 (PDT)
Subject: Re: [PATCH] mm: Add the ram_latent_entropy kernel parameter
References: <20160810222805.GA13733@www.outflux.net>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57AC9C43.5080106@intel.com>
Date: Thu, 11 Aug 2016 08:39:47 -0700
MIME-Version: 1.0
In-Reply-To: <20160810222805.GA13733@www.outflux.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Emese Revfy <re.emese@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On 08/10/2016 03:28 PM, Kees Cook wrote:
> +	if (ram_latent_entropy && !PageHighMem(page) &&
> +		page_to_pfn(page) < 0x100000) {
> +		u64 hash = 0;
> +		size_t index, end = PAGE_SIZE * nr_pages / sizeof(hash);
> +		const u64 *data = lowmem_page_address(page);
> +
> +		for (index = 0; index < end; index++)
> +			hash ^= hash + data[index];
> +		add_device_randomness((const void *)&hash, sizeof(hash));
> +	}

When I was first reading this, I thought it was using the _addresses_ of
the freed memory for entropy.  But it's actually using the _contents_.
The description could probably use a wee bit of sprucing up.

It might also be nice to say in the patch description (and the
Documentation/) what you expect to be in this memory.  It will obviously
be zeros for the vast majority of the space, but I do wonder what else
ends up in there in practice.

Why is it limited to 4GB?  Just so it doesn't go and try to XOR the
contents of a multi-TB system if it got turned on there? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
