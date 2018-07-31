Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53C646B0007
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 08:49:51 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o18-v6so12821673qtm.11
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 05:49:51 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 47-v6si2385857qtn.80.2018.07.31.05.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 05:49:50 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6VC4nYo137943
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 12:49:49 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2kgh4q0quv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 12:49:49 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6VCnmVu021149
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 12:49:48 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6VCnm2m020766
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 12:49:48 GMT
Received: by mail-oi0-f54.google.com with SMTP id k81-v6so27626222oib.4
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 05:49:48 -0700 (PDT)
MIME-Version: 1.0
References: <20180731124504.27582-1-osalvador@techadventures.net>
In-Reply-To: <20180731124504.27582-1-osalvador@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 31 Jul 2018 08:49:11 -0400
Message-ID: <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

Hi Oscar,

Have you looked into replacing __paginginit via __meminit ? What is
the reason to keep both?

Thank you,
Pavel
On Tue, Jul 31, 2018 at 8:45 AM <osalvador@techadventures.net> wrote:
>
> From: Oscar Salvador <osalvador@suse.de>
>
> __pagininit macro is being used to mark functions for:
>
> a) Functions that we do not need to keep once the system is fully
>    initialized with regard to memory.
> b) Functions that will be needed for the memory-hotplug code,
>    and because of that we need to keep them after initialization.
>
> Right now, the condition to choose between one or the other is based on
> CONFIG_SPARSEMEM, but I think that this should be changed to be based
> on CONFIG_MEMORY_HOTPLUG.
>
> The reason behind this is that it can very well be that we have CONFIG_SPARSEMEM
> enabled, but not CONFIG_MEMORY_HOTPLUG, and thus, we will not need the
> functions marked as __paginginit to stay around, since no
> memory-hotplug code will call them.
>
> Although the amount of freed bytes is not that big, I think it will
> become more clear what __paginginit is used for.
>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/internal.h | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/mm/internal.h b/mm/internal.h
> index 33c22754d282..c9170b4f7699 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -392,10 +392,11 @@ static inline struct page *mem_map_next(struct page *iter,
>  /*
>   * FLATMEM and DISCONTIGMEM configurations use alloc_bootmem_node,
>   * so all functions starting at paging_init should be marked __init
> - * in those cases. SPARSEMEM, however, allows for memory hotplug,
> - * and alloc_bootmem_node is not used.
> + * in those cases.
> + * In case that MEMORY_HOTPLUG is enabled, we need to keep those
> + * functions around since they can be called when hot-adding memory.
>   */
> -#ifdef CONFIG_SPARSEMEM
> +#ifdef CONFIG_MEMORY_HOTPLUG
>  #define __paginginit __meminit
>  #else
>  #define __paginginit __init
> --
> 2.13.6
>
