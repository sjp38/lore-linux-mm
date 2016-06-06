Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 738406B025E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 09:56:07 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id zc6so7654038lbb.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 06:56:07 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id v184si14320317wmv.34.2016.06.06.06.56.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 06:56:06 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id r5so2909474wmr.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 06:56:06 -0700 (PDT)
Date: Mon, 6 Jun 2016 15:56:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 6/7] mm/page_owner: use stackdepot to store stacktrace
Message-ID: <20160606135604.GJ11895@dhcp22.suse.cz>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464230275-25791-6-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464230275-25791-6-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu 26-05-16 11:37:54, Joonsoo Kim wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Currently, we store each page's allocation stacktrace on corresponding
> page_ext structure and it requires a lot of memory. This causes the problem
> that memory tight system doesn't work well if page_owner is enabled.
> Moreover, even with this large memory consumption, we cannot get full
> stacktrace because we allocate memory at boot time and just maintain
> 8 stacktrace slots to balance memory consumption. We could increase it
> to more but it would make system unusable or change system behaviour.
> 
> To solve the problem, this patch uses stackdepot to store stacktrace.
> It obviously provides memory saving but there is a drawback that
> stackdepot could fail.
> 
> stackdepot allocates memory at runtime so it could fail if system has
> not enough memory. But, most of allocation stack are generated at very
> early time and there are much memory at this time. So, failure would not
> happen easily. And, one failure means that we miss just one page's
> allocation stacktrace so it would not be a big problem. In this patch,
> when memory allocation failure happens, we store special stracktrace
> handle to the page that is failed to save stacktrace. With it, user
> can guess memory usage properly even if failure happens.
> 
> Memory saving looks as following. (4GB memory system with page_owner)

I still have troubles to understand your numbers

> static allocation:
> 92274688 bytes -> 25165824 bytes

I assume that the first numbers refers to the static allocation for the
given amount of memory while the second one is the dynamic after the
boot, right?

> dynamic allocation after kernel build:
> 0 bytes -> 327680 bytes

And this is the additional dynamic allocation after the kernel build.

> total:
> 92274688 bytes -> 25493504 bytes
> 
> 72% reduction in total.
> 
> Note that implementation looks complex than someone would imagine because
> there is recursion issue. stackdepot uses page allocator and page_owner
> is called at page allocation. Using stackdepot in page_owner could re-call
> page allcator and then page_owner. That is a recursion. To detect and
> avoid it, whenever we obtain stacktrace, recursion is checked and
> page_owner is set to dummy information if found. Dummy information means
> that this page is allocated for page_owner feature itself
> (such as stackdepot) and it's understandable behavior for user.
> 
> v2:
> o calculate memory saving with including dynamic allocation
> after kernel build
> o change maximum stacktrace entry size due to possible stack overflow
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Other than the small remark below I haven't spotted anything wrong and
I like the approach.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/page_ext.h |   4 +-
>  lib/Kconfig.debug        |   1 +
>  mm/page_owner.c          | 138 ++++++++++++++++++++++++++++++++++++++++-------
>  3 files changed, 122 insertions(+), 21 deletions(-)
> 
[...]
> @@ -7,11 +7,18 @@
>  #include <linux/page_owner.h>
>  #include <linux/jump_label.h>
>  #include <linux/migrate.h>
> +#include <linux/stackdepot.h>
> +
>  #include "internal.h"
>  

This is still 128B of the stack which is a lot in the allocation paths
so can we add something like

/*
 * TODO: teach PAGE_OWNER_STACK_DEPTH (__dump_page_owner and save_stack)
 * to use off stack temporal storage
 */
> +#define PAGE_OWNER_STACK_DEPTH (16)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
