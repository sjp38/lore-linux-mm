Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 53C956B0006
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 17:50:22 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id d21so2115693pll.12
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 14:50:22 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id w13si397320pgq.199.2018.02.01.14.50.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 14:50:21 -0800 (PST)
Subject: Re: [RFC PATCH v1 03/13] mm: add lock array to pgdat and batch fields
 to struct page
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
 <20180131230413.27653-4-daniel.m.jordan@oracle.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <64330116-13ef-af3c-a445-f0c1b5bc1728@linux.intel.com>
Date: Thu, 1 Feb 2018 14:50:19 -0800
MIME-Version: 1.0
In-Reply-To: <20180131230413.27653-4-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: daniel.m.jordan@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

On 01/31/2018 03:04 PM, daniel.m.jordan@oracle.com wrote:
> This patch simply adds the array of locks and struct page fields.
> Ignore for now where the struct page fields are: we need to find a place
> to put them that doesn't enlarge the struct.
> 
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> ---
>  include/linux/mm_types.h | 5 +++++
>  include/linux/mmzone.h   | 7 +++++++
>  mm/page_alloc.c          | 3 +++
>  3 files changed, 15 insertions(+)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index cfd0ac4e5e0e..6e9d26f0cecf 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -190,6 +190,11 @@ struct page {
>  		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
>  	};
>  
> +	struct {
> +		unsigned lru_batch;
> +		bool lru_sentinel;

The above declaration adds at least 5 bytes to struct page.
It adds a lot of extra memory overhead when multiplied
by the number of pages in the system.

We can move sentinel bool to page flag, at least for 64 bit system.
And 8 bit is probably enough for lru_batch id to give a max 
lru_batch number of 256 to break the locks into 256 smaller ones.  
The max used in the patchset is 32 and that is already giving
pretty good spread of the locking.
It will be better if we can find some unused space in struct page
to squeeze it in.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
