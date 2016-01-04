Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id AC4456B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 02:47:28 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id 1so101606867ion.1
        for <linux-mm@kvack.org>; Sun, 03 Jan 2016 23:47:28 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id l136si47118504iol.136.2016.01.03.23.47.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jan 2016 23:47:28 -0800 (PST)
Date: Mon, 4 Jan 2016 18:47:24 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [-mm PATCH] list, perf: fix list_force_poison() build
 regression
Message-ID: <20160104184724.444b879b@canb.auug.org.au>
In-Reply-To: <20160101032348.26352.75121.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20160101032348.26352.75121.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org

Hi Dan,

On Thu, 31 Dec 2015 19:24:21 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
>
>     In file included from
>     /home/sfr/next/next/tools/include/linux/list.h:5:0,
>                      from arch/../util/map.h:6,
>                      from arch/../util/event.h:8,
>                      from arch/../util/debug.h:7,
>                      from arch/common.c:4:
>     include/linux/list.h: In function 'list_force_poison':
>     include/linux/list.h:123:56: error: unused parameter 'entry' [-Werror=unused-parameter]
>      static inline void list_force_poison(struct list_head *entry)
> 
> perf does not like the empty definition of list_force_poison.  For
> simplicity just switch to list_del in the non-debug case.
> 
> Fixes "mm, dax, pmem: introduce {get|put}_dev_pagemap() for dax-gup" in
> -next.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/list.h |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/list.h b/include/linux/list.h
> index d870ba3315f8..ebf5f358e8c3 100644
> --- a/include/linux/list.h
> +++ b/include/linux/list.h
> @@ -120,9 +120,8 @@ extern void list_del(struct list_head *entry);
>   */
>  extern void list_force_poison(struct list_head *entry);
>  #else
> -static inline void list_force_poison(struct list_head *entry)
> -{
> -}
> +/* fallback to the less strict LIST_POISON* definitions */
> +#define list_force_poison list_del
>  #endif
>  
>  /**

I applied this to linux-next today.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
