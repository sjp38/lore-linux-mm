Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBAA16B026B
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 07:38:52 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v69so2039629wrb.3
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 04:38:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o63si1647289edb.23.2017.12.06.04.38.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 04:38:43 -0800 (PST)
Date: Wed, 6 Dec 2017 13:38:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Get 7% more pages in a pagevec
Message-ID: <20171206123842.GB7515@dhcp22.suse.cz>
References: <20171206022521.GM26021@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206022521.GM26021@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org

On Tue 05-12-17 18:25:21, Matthew Wilcox wrote:
[...]
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> We don't have to use an entire 'long' for the number of elements in the
> pagevec; we know it's a number between 0 and 14 (now 15).  So we can
> store it in a char, and then the bool packs next to it and we still have
> two or six bytes of padding for more elements in the header.  That gives
> us space to cram in an extra page.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> 
> diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
> index 5fb6580f7f23..6dc456ac6136 100644
> --- a/include/linux/pagevec.h
> +++ b/include/linux/pagevec.h
> @@ -9,14 +9,14 @@
>  #ifndef _LINUX_PAGEVEC_H
>  #define _LINUX_PAGEVEC_H
>  
> -/* 14 pointers + two long's align the pagevec structure to a power of two */
> -#define PAGEVEC_SIZE	14
> +/* 15 pointers + header align the pagevec structure to a power of two */
> +#define PAGEVEC_SIZE	15

And now you have ruined the ultimate constant of the whole MM :p
But seriously, I have completely missed that pagevec has such a bad
layout.

>  struct page;
>  struct address_space;
>  
>  struct pagevec {
> -	unsigned long nr;
> +	unsigned char nr;
>  	bool percpu_pvec_drained;
>  	struct page *pages[PAGEVEC_SIZE];
>  };

Anyway the change looks good to me.

Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
