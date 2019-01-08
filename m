Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 245978E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 04:01:53 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d35so2822282qtd.20
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 01:01:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p184si1188085qkc.42.2019.01.08.01.01.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 01:01:52 -0800 (PST)
Date: Tue, 8 Jan 2019 17:01:38 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCHv5] x86/kdump: bugfix, make the behavior of crashkernel=X
 consistent with kaslr
Message-ID: <20190108090138.GB18718@MiWiFi-R3L-srv>
References: <1546848299-23628-1-git-send-email-kernelfans@gmail.com>
 <20190108080538.GB4396@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190108080538.GB4396@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Pingfan Liu <kernelfans@gmail.com>, linux-mm@kvack.org, kexec@lists.infradead.org, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

Hi Mike,

On 01/08/19 at 10:05am, Mike Rapoport wrote:
> I'm not thrilled by duplicating this code (yet again).
> I liked the v3 of this patch [1] more, assuming we allow bottom-up mode to
> allocate [0, kernel_start) unconditionally. 
> I'd just replace you first patch in v3 [2] with something like:

In initmem_init(), we will restore the top-down allocation style anyway.
While reserve_crashkernel() is called after initmem_init(), it's not
appropriate to adjust memblock_find_in_range_node(), and we really want
to find region bottom up for crashkernel reservation, no matter where
kernel is loaded, better call __memblock_find_range_bottom_up().

Create a wrapper to do the necessary handling, then call
__memblock_find_range_bottom_up() directly, looks better.

Thanks
Baoquan

> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7df468c..d1b30b9 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -274,24 +274,14 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
>  	 * try bottom-up allocation only when bottom-up mode
>  	 * is set and @end is above the kernel image.
>  	 */
> -	if (memblock_bottom_up() && end > kernel_end) {
> -		phys_addr_t bottom_up_start;
> -
> -		/* make sure we will allocate above the kernel */
> -		bottom_up_start = max(start, kernel_end);
> -
> +	if (memblock_bottom_up()) {
>  		/* ok, try bottom-up allocation first */
> -		ret = __memblock_find_range_bottom_up(bottom_up_start, end,
> +		ret = __memblock_find_range_bottom_up(start, end,
>  						      size, align, nid, flags);
>  		if (ret)
>  			return ret;
>  
>  		/*
> -		 * we always limit bottom-up allocation above the kernel,
> -		 * but top-down allocation doesn't have the limit, so
> -		 * retrying top-down allocation may succeed when bottom-up
> -		 * allocation failed.
> -		 *
>  		 * bottom-up allocation is expected to be fail very rarely,
>  		 * so we use WARN_ONCE() here to see the stack trace if
>  		 * fail happens.
> 
> [1] https://lore.kernel.org/lkml/1545966002-3075-3-git-send-email-kernelfans@gmail.com/
> [2] https://lore.kernel.org/lkml/1545966002-3075-2-git-send-email-kernelfans@gmail.com/
> 
> > +
> > +	return ret;
> > +}
> > +
> >  /**
> >   * __memblock_find_range_top_down - find free area utility, in top-down
> >   * @start: start of candidate range
> > -- 
> > 2.7.4
> > 
> 
> -- 
> Sincerely yours,
> Mike.
> 
