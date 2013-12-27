Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f43.google.com (mail-qe0-f43.google.com [209.85.128.43])
	by kanga.kvack.org (Postfix) with ESMTP id B8BCD6B0031
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 14:13:29 -0500 (EST)
Received: by mail-qe0-f43.google.com with SMTP id jy17so9508802qeb.30
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 11:13:29 -0800 (PST)
Received: from blu0-omc4-s14.blu0.hotmail.com (blu0-omc4-s14.blu0.hotmail.com. [65.55.111.153])
        by mx.google.com with ESMTP id j7si29471888qab.23.2013.12.27.11.13.26
        for <linux-mm@kvack.org>;
        Fri, 27 Dec 2013 11:13:28 -0800 (PST)
Message-ID: <BLU0-SMTP17D26551261DF285A7E6F497CD0@phx.gbl>
From: John David Anglin <dave.anglin@bell.net>
In-Reply-To: <20131227180018.GC4945@linux.intel.com>
Subject: Re: [PATCH] remap_file_pages needs to check for cache coherency
References: <20131227180018.GC4945@linux.intel.com>
Content-Type: text/plain; charset="US-ASCII"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0 (Apple Message framework v936)
Date: Fri, 27 Dec 2013 14:13:16 -0500
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org, linux-mips@linux-mips.org

On 27-Dec-13, at 1:00 PM, Matthew Wilcox wrote:

> +#ifdef __ARCH_FORCE_SHMLBA
> +	/* Is the mapping cache-coherent? */
> +	if ((pgoff ^ linear_page_index(vma, start)) &
> +	    ((SHMLBA-1) >> PAGE_SHIFT))
> +		goto out;
> +#endif


I think this will cause problems on PA-RISC.  The reason is we have an  
additional offset
for mappings.  See get_offset() in sys_parisc.c.

SHMLBA is 4 MB on PA-RISC.  If we limit ourselves to aligned mappings,  
we run out of
memory very quickly.  Even with our current implementation, we fail  
the perl locales test
with locales-all installed.

Dave
--
John David Anglin	dave.anglin@bell.net



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
