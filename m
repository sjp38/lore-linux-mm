Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 864396B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 04:20:00 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b1so1745922209pgc.5
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 01:20:00 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id s137si87993518pfs.170.2017.01.09.01.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 01:19:59 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id b22so7829876pfd.3
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 01:19:59 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 9 Jan 2017 14:49:52 +0530
Subject: Re: [HMM v15 01/16] mm/free_hot_cold_page: catch ZONE_DEVICE pages
Message-ID: <20170109091952.GA9655@localhost.localdomain>
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
 <1483721203-1678-2-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1483721203-1678-2-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri, Jan 06, 2017 at 11:46:28AM -0500, Jerome Glisse wrote:
> Catch page from ZONE_DEVICE in free_hot_cold_page(). This should never
> happen as ZONE_DEVICE page must always have an elevated refcount.
> 
> This is safety-net to catch any refcounting issues in a sane way for any
> ZONE_DEVICE pages.
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  mm/page_alloc.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1c24112..355beb4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2445,6 +2445,16 @@ void free_hot_cold_page(struct page *page, bool cold)
>  	unsigned long pfn = page_to_pfn(page);
>  	int migratetype;
>  
> +	/*
> +	 * This should never happen ! Page from ZONE_DEVICE always must have an
> +	 * active refcount. Complain about it and try to restore the refcount.
> +	 */
> +	if (is_zone_device_page(page)) {
> +		VM_BUG_ON_PAGE(is_zone_device_page(page), page);

This can be VM_BUG_ON_PAGE(1, page), hopefully the compiler does the right thing
here. I suspect this should be a BUG_ON, independent of CONFIG_DEBUG_VM

> +		page_ref_inc(page);
> +		return;
> +	}
> +

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
