Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E1FE86B0390
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 16:08:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l37so23192571wrc.7
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 13:08:43 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id f72si12111426wmh.18.2017.03.19.13.08.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 13:08:42 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 3AEFF1C3185
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 20:08:42 +0000 (GMT)
Date: Sun, 19 Mar 2017 20:08:36 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [HMM 02/16] mm/put_page: move ref decrement to
 put_zone_device_page()
Message-ID: <20170319200836.GC2774@techsingularity.net>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-3-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1489680335-6594-3-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J?r?me Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Mar 16, 2017 at 12:05:21PM -0400, J?r?me Glisse wrote:
> This does not affect non ZONE_DEVICE page. In order to allow
> ZONE_DEVICE page to be tracked we need to detect when refcount
> of a ZONE_DEVICE page reach 1 (not 0 as non ZONE_DEVICE page).
> 
> This patch just move put_page_testzero() from put_page() to
> put_zone_device_page() and only for ZONE_DEVICE. It does not
> add any overhead compare to existing code.
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  include/linux/mm.h | 8 +++++---
>  kernel/memremap.c  | 2 ++
>  2 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5f01c88..28e8b28 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -793,11 +793,13 @@ static inline void put_page(struct page *page)
>  {
>  	page = compound_head(page);
>  
> +	if (unlikely(is_zone_device_page(page))) {
> +		put_zone_device_page(page);
> +		return;
> +	}
> +
>  	if (put_page_testzero(page))
>  		__put_page(page);
> -
> -	if (unlikely(is_zone_device_page(page)))
> -		put_zone_device_page(page);
>  }
>  
>  #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 40d4af8..c821946 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -190,6 +190,8 @@ EXPORT_SYMBOL(get_zone_device_page);
>  
>  void put_zone_device_page(struct page *page)
>  {
> +	page_ref_dec(page);
> +
>  	put_dev_pagemap(page->pgmap);
>  }
>  EXPORT_SYMBOL(put_zone_device_page);

So the page refcount goes to zero but where did the __put_page call go? I
haven't read the full series yet but I do note the next patch introduces
a callback. Maybe callbacks free the page but it looks optional. Maybe
it gets fixed later in the series but the changelog should at least say
this is not bisect safe and as this looks like a memory leak.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
