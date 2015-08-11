Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9366B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 19:24:53 -0400 (EDT)
Received: by qgdd90 with SMTP id d90so451109qgd.3
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 16:24:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e187si6526567qka.109.2015.08.11.16.24.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 16:24:51 -0700 (PDT)
Date: Tue, 11 Aug 2015 16:24:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/5] mm/hwpoison: introduce put_hwpoison_page to put
 refcount for memory error handling
Message-Id: <20150811162449.77212ec2a80258f5aff8a224@linux-foundation.org>
In-Reply-To: <BLU436-SMTP127AFDD347F96AC6BDED54C80700@phx.gbl>
References: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
	<BLU436-SMTP127AFDD347F96AC6BDED54C80700@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 10 Aug 2015 19:28:21 +0800 Wanpeng Li <wanpeng.li@hotmail.com> wrote:

> Introduce put_hwpoison_page to put refcount for memory 
> error handling. 
> 
> ...
>
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -922,6 +922,27 @@ int get_hwpoison_page(struct page *page)
>  }
>  EXPORT_SYMBOL_GPL(get_hwpoison_page);
>  
> +/**
> + * put_hwpoison_page() - Put refcount for memory error handling:
> + * @page:	raw error page (hit by memory error)
> + */
> +void put_hwpoison_page(struct page *page)
> +{
> +	struct page *head = compound_head(page);
> +
> +	if (PageHuge(head)) {
> +		put_page(head);
> +		return;
> +	}
> +
> +	if (PageTransHuge(head))
> +		if (page != head)
> +			put_page(head);
> +
> +	put_page(page);
> +}
> +EXPORT_SYMBOL_GPL(put_hwpoison_page);

I don't believe the export is needed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
