Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FACD6B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 17:38:29 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f144so217914652pfa.3
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 14:38:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t125si16915712pgb.150.2017.01.23.14.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 14:38:28 -0800 (PST)
Date: Mon, 23 Jan 2017 14:38:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix maybe-uninitialized warning in
 section_deactivate()
Message-Id: <20170123143827.9408317a0809de2d17fce8df@linux-foundation.org>
In-Reply-To: <20170123165156.854464-1-arnd@arndb.de>
References: <20170123165156.854464-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Fabian Frederick <fabf@skynet.be>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 23 Jan 2017 17:51:17 +0100 Arnd Bergmann <arnd@arndb.de> wrote:

> gcc cannot track the combined state of the 'mask' variable across the
> barrier in pgdat_resize_unlock() at compile time, so it warns that we
> can run into undefined behavior:
> 
> mm/sparse.c: In function 'section_deactivate':
> mm/sparse.c:802:7: error: 'early_section' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> We know that this can't happen because the spin_unlock() doesn't
> affect the mask variable, so this is a false-postive warning, but
> rearranging the code to bail out earlier here makes it obvious
> to the compiler as well.
> 
> ...
>
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -807,23 +807,24 @@ static void section_deactivate(struct pglist_data *pgdat, unsigned long pfn,
>  	unsigned long mask = section_active_mask(pfn, nr_pages), flags;
>  
>  	pgdat_resize_lock(pgdat, &flags);
> -	if (!ms->usage) {
> -		mask = 0;
> -	} else if ((ms->usage->map_active & mask) != mask) {
> -		WARN(1, "section already deactivated active: %#lx mask: %#lx\n",
> -				ms->usage->map_active, mask);
> -		mask = 0;
> -	} else {
> -		early_section = is_early_section(ms);
> -		ms->usage->map_active ^= mask;
> -		if (ms->usage->map_active == 0) {
> -			usage = ms->usage;
> -			ms->usage = NULL;
> -			memmap = sparse_decode_mem_map(ms->section_mem_map,
> -					section_nr);
> -			ms->section_mem_map = 0;
> -		}
> +	if (!ms->usage ||
> +	    WARN((ms->usage->map_active & mask) != mask,
> +		 "section already deactivated active: %#lx mask: %#lx\n",
> +			ms->usage->map_active, mask)) {
> +		pgdat_resize_unlock(pgdat, &flags);
> +		return;
>  	}
> +
> +	early_section = is_early_section(ms);
> +	ms->usage->map_active ^= mask;
> +	if (ms->usage->map_active == 0) {
> +		usage = ms->usage;
> +		ms->usage = NULL;
> +		memmap = sparse_decode_mem_map(ms->section_mem_map,
> +				section_nr);
> +		ms->section_mem_map = 0;
> +	}
> +

hm, OK, that looks equivalent.

I wonder if we still need the later

	if (!mask)
		return;

I wonder if this code is appropriately handling the `mask == -1' case. 
section_active_mask() can do that.

What does that -1 in section_active_mask() mean anyway?  Was it really
intended to represent the all-ones pattern or is it an error?  If the
latter, was it appropriate for section_active_mask() to return an
unsigned type?

How come section_active_mask() is __init but its caller
section_deactivate() is not? 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
