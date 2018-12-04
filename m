Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8627A6B6EB8
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 08:01:34 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id k192so6082785wmd.1
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 05:01:34 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id k11si12076889wrp.39.2018.12.04.05.01.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 05:01:32 -0800 (PST)
Date: Tue, 4 Dec 2018 14:01:24 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 03/25] ACPI / APEI: Switch estatus pool to use vmalloc
 memory
Message-ID: <20181204130124.GE11803@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-4-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-4-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:05:51PM +0000, James Morse wrote:
> The ghes code is careful to parse and round firmware's advertised
> memory requirements for CPER records, up to a maximum of 64K.
> However when ghes_estatus_pool_expand() does its work, it splits
> the requested size into PAGE_SIZE granules.
> 
> This means if firmware generates 5K of CPER records, and correctly
> describes this in the table, __process_error() will silently fail as it
> is unable to allocate more than PAGE_SIZE.
> 
> Switch the estatus pool to vmalloc() memory. On x86 vmalloc() memory
> may fault and be fixed up by vmalloc_fault(). To prevent this call
> vmalloc_sync_all() before an NMI handler could discover the memory.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  drivers/acpi/apei/ghes.c | 30 +++++++++++++++---------------
>  1 file changed, 15 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index e8503c7d721f..c15264f2dc4b 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -170,40 +170,40 @@ static int ghes_estatus_pool_init(void)
>  	return 0;
>  }
>  
> -static void ghes_estatus_pool_free_chunk_page(struct gen_pool *pool,
> +static void ghes_estatus_pool_free_chunk(struct gen_pool *pool,
>  					      struct gen_pool_chunk *chunk,
>  					      void *data)
>  {
> -	free_page(chunk->start_addr);
> +	vfree((void *)chunk->start_addr);
>  }
>  
>  static void ghes_estatus_pool_exit(void)
>  {
>  	gen_pool_for_each_chunk(ghes_estatus_pool,
> -				ghes_estatus_pool_free_chunk_page, NULL);
> +				ghes_estatus_pool_free_chunk, NULL);
>  	gen_pool_destroy(ghes_estatus_pool);
>  }
>  
>  static int ghes_estatus_pool_expand(unsigned long len)
>  {
> -	unsigned long i, pages, size, addr;
> -	int ret;
> +	unsigned long size, addr;
>  
>  	ghes_estatus_pool_size_request += PAGE_ALIGN(len);

So here we increment with page-aligned len...

>  	size = gen_pool_size(ghes_estatus_pool);
>  	if (size >= ghes_estatus_pool_size_request)
>  		return 0;
> -	pages = (ghes_estatus_pool_size_request - size) / PAGE_SIZE;
> -	for (i = 0; i < pages; i++) {
> -		addr = __get_free_page(GFP_KERNEL);
> -		if (!addr)
> -			return -ENOMEM;
> -		ret = gen_pool_add(ghes_estatus_pool, addr, PAGE_SIZE, -1);
> -		if (ret)
> -			return ret;
> -	}
>  
> -	return 0;
> +	addr = (unsigned long)vmalloc(PAGE_ALIGN(len));
> +	if (!addr)
> +		return -ENOMEM;

... and if we return here due to the ENOMEM, that increment above
remains.

I see you're reworking all that stuff in the next patches which is cool,
thx. So I guess we should leave it as is, as the code before was broken
too.

IOW,

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
