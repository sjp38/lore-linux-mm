Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3AED86B02C3
	for <linux-mm@kvack.org>; Tue, 23 May 2017 09:23:21 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id o139so13813949lfe.15
        for <linux-mm@kvack.org>; Tue, 23 May 2017 06:23:21 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id z10si9089500lja.175.2017.05.23.06.23.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 06:23:19 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id h4so8096296lfj.3
        for <linux-mm@kvack.org>; Tue, 23 May 2017 06:23:19 -0700 (PDT)
Date: Tue, 23 May 2017 16:23:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [HMM 08/15] mm/ZONE_DEVICE: special case put_page() for device
 private pages
Message-ID: <20170523132317.rfg33zwfbx3zl6be@node.shutemov.name>
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-9-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170522165206.6284-9-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, May 22, 2017 at 12:51:59PM -0400, Jerome Glisse wrote:
> A ZONE_DEVICE page that reach a refcount of 1 is free ie no longer
> have any user. For device private pages this is important to catch
> and thus we need to special case put_page() for this.
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  include/linux/mm.h | 30 ++++++++++++++++++++++++++++++
>  kernel/memremap.c  |  1 -
>  2 files changed, 30 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a825dab..11f7bac 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -23,6 +23,7 @@
>  #include <linux/page_ext.h>
>  #include <linux/err.h>
>  #include <linux/page_ref.h>
> +#include <linux/memremap.h>
>  
>  struct mempolicy;
>  struct anon_vma;
> @@ -795,6 +796,20 @@ static inline bool is_device_private_page(const struct page *page)
>  	return ((page_zonenum(page) == ZONE_DEVICE) &&
>  		(page->pgmap->type == MEMORY_DEVICE_PRIVATE));
>  }
> +
> +static inline void put_zone_device_private_page(struct page *page)

Could you measure how much bloat this change produce?

I would rather make put_zone_device_private_page() non-inline. put_page()
is inlined everewhere. It's beneficial to keep it skinny.

(And I guess it would help solving 0-day reporeted build issue).

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
