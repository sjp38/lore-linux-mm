Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 1988D6B0005
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 16:31:09 -0500 (EST)
Date: Fri, 8 Mar 2013 13:31:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: remove_memory: Fix end_pfn setting
Message-Id: <20130308133106.ec4f9810b69b105b8f70d82a@linux-foundation.org>
In-Reply-To: <1362757301-18550-2-git-send-email-toshi.kani@hp.com>
References: <1362757301-18550-1-git-send-email-toshi.kani@hp.com>
	<1362757301-18550-2-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com

On Fri,  8 Mar 2013 08:41:41 -0700 Toshi Kani <toshi.kani@hp.com> wrote:

> remove_memory() calls walk_memory_range() with [start_pfn, end_pfn),
> where end_pfn is exclusive in this range.  Therefore, end_pfn needs
> to be set to the next page of the end address.
> 
> ...
>
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1801,7 +1801,7 @@ int __ref remove_memory(int nid, u64 start, u64 size)
>  	int retry = 1;
>  
>  	start_pfn = PFN_DOWN(start);
> -	end_pfn = start_pfn + PFN_DOWN(size);
> +	end_pfn = PFN_UP(start + size - 1);
>  
>  	/*
>  	 * When CONFIG_MEMCG is on, one memory block may be used by other

That looks right, although these rounding/boundary things are always
hard.  I wonder if `start' and `size' are ever not multiples of
PAGE_SIZE..

How did you discover this?  Code inspection, or some runtime
malfunction?  Please always include this info when fixing bugs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
