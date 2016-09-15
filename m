Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id F28E06B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 20:05:56 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fu12so59525120pac.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 17:05:56 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b76si35927381pfd.120.2016.09.14.17.05.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 17:05:56 -0700 (PDT)
Subject: Re: [PATCH] sparse: Track the boundaries of memory sections for
 accurate checks
References: <1466244679-23824-1-git-send-email-karahmed@amazon.de>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57D9E5E2.7060405@intel.com>
Date: Wed, 14 Sep 2016 17:05:54 -0700
MIME-Version: 1.0
In-Reply-To: <1466244679-23824-1-git-send-email-karahmed@amazon.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KarimAllah Ahmed <karahmed@amazon.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Dan Williams <dan.j.williams@intel.com>, Joe Perches <joe@perches.com>, Tejun Heo <tj@kernel.org>, Anthony Liguori <aliguori@amazon.com>, "=?UTF-8?Q?Jan_H_._Sch=c3=b6nherr?=" <jschoenh@amazon.de>

On 06/18/2016 03:11 AM, KarimAllah Ahmed wrote:
> @@ -1067,8 +1067,12 @@ struct mem_section {
>  	 * section. (see page_ext.h about this.)
>  	 */
>  	struct page_ext *page_ext;
> -	unsigned long pad;
> +	unsigned long pad[3];
>  #endif
> +
> +	unsigned long first_pfn;
> +	unsigned long last_pfn;

mem_section started out as a single pointer, and it's getting a bit, um,
rotund.  Remember, some architectures have a lot of physical address
space, and thus a ton of mem_sections, but very little actual memory.
This eats valuable RAM if we bloat mem_section too much.

Oh, and with this:

>         /*
>          * WARNING: mem_section must be a power-of-2 in size for the
>          * calculation and use of SECTION_ROOT_MASK to make sense.
>          */

Aren't you making a non-power-of-2 sized 'mem_section" in some cases?

This also doesn't handle if there is a hole in the _middle_ of a section.

What's wrong with using some bits in the existing usemap?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
