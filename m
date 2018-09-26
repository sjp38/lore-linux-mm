Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA5E48E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:12:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g18-v6so1098553edg.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:12:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g8-v6si4426962eds.222.2018.09.26.04.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 04:12:17 -0700 (PDT)
Subject: Re: [v11 PATCH 1/3] mm: mmap: zap pages with read mmap_sem in munmap
References: <1537376621-51150-1-git-send-email-yang.shi@linux.alibaba.com>
 <1537376621-51150-2-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f0d65866-8977-fba9-28fd-90873fc3d606@suse.cz>
Date: Wed, 26 Sep 2018 13:09:36 +0200
MIME-Version: 1.0
In-Reply-To: <1537376621-51150-2-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org
Cc: dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/19/18 7:03 PM, Yang Shi wrote:

...

> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
> Suggested-by: Matthew Wilcox <willy@infradead.org>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

This is indeed much better code structure. Thanks for persisting with
the series and following the suggestions.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Nit:

> @@ -2797,17 +2819,32 @@ int vm_munmap(unsigned long start, size_t len)
>  	if (down_write_killable(&mm->mmap_sem))
>  		return -EINTR;
>  
> -	ret = do_munmap(mm, start, len, &uf);
> -	up_write(&mm->mmap_sem);
> +	ret = __do_munmap(mm, start, len, &uf, downgrade);
> +	/*
> +	 * Returning 1 indicates mmap_sem is downgraded.
> +	 * But 1 is not legal return value of vm_munmap() and munmap(), reset
> +	 * it to 0 before return.
> +	 */
> +	if (ret == 1) {
> +		up_read(&mm->mmap_sem);
> +		ret = 0;
> +	} else
> +		up_write(&mm->mmap_sem);
> +

I think the else part should also have { } per the kernel style?
