Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9103E6B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 20:39:46 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va2so7797155obc.0
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 17:39:46 -0700 (PDT)
Received: from g5t1627.atlanta.hp.com (g5t1627.atlanta.hp.com. [15.192.137.10])
        by mx.google.com with ESMTPS id f4si18942488oel.1.2014.03.10.17.39.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Mar 2014 17:39:45 -0700 (PDT)
Message-ID: <1394497958.6784.204.camel@misato.fc.hp.com>
Subject: Re: [PATCH v6 06/22] Replace XIP read and write with DAX I/O
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 10 Mar 2014 18:32:38 -0600
In-Reply-To: <1393337918-28265-7-git-send-email-matthew.r.wilcox@intel.com>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
	 <1393337918-28265-7-git-send-email-matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com

On Tue, 2014-02-25 at 09:18 -0500, Matthew Wilcox wrote:
> Use the generic AIO infrastructure instead of custom read and write
> methods.  In addition to giving us support for AIO, this adds the missing
> locking between read() and truncate().
> 
 :
> +static void dax_new_buf(void *addr, unsigned size, unsigned first,
> +					loff_t offset, loff_t end, int rw)
> +{
> +	loff_t final = end - offset;	/* The final byte in this buffer */

I may be missing something, but shouldn't it take first into account?

	loff_t final = end - offset + first;

Thanks,
-Toshi


> +	if (rw != WRITE) {
> +		memset(addr, 0, size);
> +		return;
> +	}
> +
> +	if (first > 0)
> +		memset(addr, 0, first);
> +	if (final < size)
> +		memset(addr + final, 0, size - final);
> +}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
