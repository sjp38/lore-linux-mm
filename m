Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC3296B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 12:12:09 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g15-v6so700883plo.11
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 09:12:09 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y2-v6si9215698pga.141.2018.07.23.09.12.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 09:12:08 -0700 (PDT)
Subject: Re: [PATCH v6 06/13] mm, dev_pagemap: Do not clear ->mapping on final
 put
References: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153154380137.34503.3754023882460956800.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Dave Jiang <dave.jiang@intel.com>
Message-ID: <3fcb3c8a-2a41-7c78-edde-066c10110d34@intel.com>
Date: Mon, 23 Jul 2018 09:12:06 -0700
MIME-Version: 1.0
In-Reply-To: <153154380137.34503.3754023882460956800.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de

Jerome,
Is it possible to get an ack for this? Thanks!

On 07/13/2018 09:50 PM, Dan Williams wrote:
> MEMORY_DEVICE_FS_DAX relies on typical page semantics whereby ->mapping
> is only ever cleared by truncation, not final put.
> 
> Without this fix dax pages may forget their mapping association at the
> end of every page pin event.
> 
> Move this atypical behavior that HMM wants into the HMM ->page_free()
> callback.
> 
> Cc: <stable@vger.kernel.org>
> Cc: Jan Kara <jack@suse.cz>
> Cc: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Fixes: d2c997c0f145 ("fs, dax: use page->mapping...")
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  kernel/memremap.c |    1 -
>  mm/hmm.c          |    2 ++
>  2 files changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 5857267a4af5..62603634a1d2 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -339,7 +339,6 @@ void __put_devmap_managed_page(struct page *page)
>  		__ClearPageActive(page);
>  		__ClearPageWaiters(page);
>  
> -		page->mapping = NULL;
>  		mem_cgroup_uncharge(page);
>  
>  		page->pgmap->page_free(page, page->pgmap->data);
> diff --git a/mm/hmm.c b/mm/hmm.c
> index de7b6bf77201..f9d1d89dec4d 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -963,6 +963,8 @@ static void hmm_devmem_free(struct page *page, void *data)
>  {
>  	struct hmm_devmem *devmem = data;
>  
> +	page->mapping = NULL;
> +
>  	devmem->ops->free(devmem, page);
>  }
>  
> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm
> 
