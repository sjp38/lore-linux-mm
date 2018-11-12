Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 956AC6B026A
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 01:13:45 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a26-v6so7049393pfo.17
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 22:13:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d66-v6si17700752pfc.92.2018.11.11.22.13.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 11 Nov 2018 22:13:44 -0800 (PST)
Date: Sun, 11 Nov 2018 22:13:37 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 1/4] mm: reference totalram_pages and managed_pages
 once per function
Message-ID: <20181112061337.GG21824@bombadil.infradead.org>
References: <1542002869-16704-1-git-send-email-arunks@codeaurora.org>
 <1542002869-16704-2-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542002869-16704-2-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vatsa@codeaurora.org

On Mon, Nov 12, 2018 at 11:37:46AM +0530, Arun KS wrote:
> +++ b/arch/um/kernel/mem.c
> @@ -51,8 +51,7 @@ void __init mem_init(void)
>  
>  	/* this will put all low memory onto the freelists */
>  	memblock_free_all();
> -	max_low_pfn = totalram_pages;
> -	max_pfn = totalram_pages;
> +	max_pfn = max_low_pfn = totalram_pages;

We don't normally do "a = b = c".  How about:

 	max_low_pfn = totalram_pages;
-	max_pfn = totalram_pages;
+	max_pfn = max_low_pfn;

> +++ b/arch/x86/kernel/cpu/microcode/core.c
> @@ -434,9 +434,10 @@ static ssize_t microcode_write(struct file *file, const char __user *buf,
>  			       size_t len, loff_t *ppos)
>  {
>  	ssize_t ret = -EINVAL;
> +	unsigned long totalram_pgs = totalram_pages;

Can't we use a better variable name here?  Even nr_pages would look
better to me.

> +++ b/drivers/hv/hv_balloon.c
> +	unsigned long totalram_pgs = totalram_pages;

Ditto

> +++ b/fs/file_table.c
> +	unsigned long totalram_pgs = totalram_pages;

... throughout, I guess.
