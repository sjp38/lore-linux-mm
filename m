Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 351456B027F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 17:32:26 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id 78so117654198pfw.2
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 14:32:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e84si38887433pfb.83.2015.12.28.14.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Dec 2015 14:32:25 -0800 (PST)
Date: Mon, 28 Dec 2015 14:32:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
Message-Id: <20151228143224.86787a0ee1c343e1b2db36dc@linux-foundation.org>
In-Reply-To: <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, dave.hansen@intel.com, matt@codeblueprint.co.uk

On Wed,  9 Dec 2015 12:19:37 +0900 Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:

> This patch extends existing "kernelcore" option and
> introduces kernelcore=mirror option. By specifying
> "mirror" instead of specifying the amount of memory,
> non-mirrored (non-reliable) region will be arranged
> into ZONE_MOVABLE.
> 
> v1 -> v2:
>  - Refine so that the following case also can be
>    handled properly:
> 
>  Node X:  |MMMMMM------MMMMMM--------|
>    (legend) M: mirrored  -: not mirrrored
> 
>  In this case, ZONE_NORMAL and ZONE_MOVABLE are
>  arranged like bellow:
> 
>  Node X:  |MMMMMM------MMMMMM--------|
>           |ooooooxxxxxxooooooxxxxxxxx| ZONE_NORMAL
>                 |ooooooxxxxxxoooooooo| ZONE_MOVABLE
>    (legend) o: present  x: absent
> 
> ...
>
>
> @@ -5507,6 +5569,36 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>  	}
>  
>  	/*
> +	 * If kernelcore=mirror is specified, ignore movablecore option
> +	 */
> +	if (mirrored_kernelcore) {
> +		bool mem_below_4gb_not_mirrored = false;
> +
> +		for_each_memblock(memory, r) {
> +			if (memblock_is_mirror(r))
> +				continue;
> +
> +			nid = r->nid;
> +
> +			usable_startpfn = memblock_region_memory_base_pfn(r);
> +
> +			if (usable_startpfn < 0x100000) {
> +				mem_below_4gb_not_mirrored = true;
> +				continue;
> +			}
> +
> +			zone_movable_pfn[nid] = zone_movable_pfn[nid] ?
> +				min(usable_startpfn, zone_movable_pfn[nid]) :
> +				usable_startpfn;
> +		}
> +
> +		if (mem_below_4gb_not_mirrored)
> +			pr_warn("This configuration results in unmirrored kernel memory.");

This looks a bit strange.

What's the code actually doing?  Checking to see that all memory at
physical addresses < 0x100000000 is mirrored, I think?

If so, what's up with that hard-wired 0x100000?  That's not going to
work on PAGE_SIZE>4k machines, and this is generic code.

Also, I don't think the magical 0x100000000 is necessarily going to be
relevant for other architectures (presumably powerpc will be next...)

I guess this is all OK as an "initial implementation for x86_64 only"
for now, and this stuff will be changed later if/when another
architecture comes along.  However it would be nice to make things more
generic from the outset, to provide a guide for how things should be
implemented by other architectures.



Separately, what feedback does the user get about the success of the
kernelcore=mirror comment?  We didn't include an explicit printk which
displays the outcome, so how is the user to find out that it all worked
OK and that the kernel is now using mirrored memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
