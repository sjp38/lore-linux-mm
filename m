Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 162818E0025
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 19:34:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n17-v6so7122943pff.17
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 16:34:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r7-v6si4955122pgf.620.2018.09.21.16.34.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 16:34:14 -0700 (PDT)
Date: Fri, 21 Sep 2018 16:34:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] slub: extend slub debug to handle multiple slabs
Message-Id: <20180921163412.de1b331a639a8031aaf85d4f@linux-foundation.org>
In-Reply-To: <20180920200016.11003-1-atomlin@redhat.com>
References: <20180920200016.11003-1-atomlin@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Tomlin <atomlin@redhat.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 20 Sep 2018 21:00:16 +0100 Aaron Tomlin <atomlin@redhat.com> wrote:

> Extend the slub_debug syntax to "slub_debug=<flags>[,<slub>]*", where <slub>
> may contain an asterisk at the end.  For example, the following would poison
> all kmalloc slabs:
> 
> 	slub_debug=P,kmalloc*
> 
> and the following would apply the default flags to all kmalloc and all block IO
> slabs:
> 
> 	slub_debug=,bio*,kmalloc*
> 
> Please note that a similar patch was posted by Iliyan Malchev some time ago but
> was never merged:
> 
> 	https://marc.info/?l=linux-mm&m=131283905330474&w=2

Fair enough, I guess.

> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1283,9 +1283,37 @@ slab_flags_t kmem_cache_flags(unsigned int object_size,
>  	/*
>  	 * Enable debugging if selected on the kernel commandline.
>  	 */

The above comment is in a strange place.  Can we please move it to
above the function definition in the usual fashion?  And make it
better, if anything seems to be missing.

> -	if (slub_debug && (!slub_debug_slabs || (name &&
> -		!strncmp(slub_debug_slabs, name, strlen(slub_debug_slabs)))))
> -		flags |= slub_debug;
> +
> +	char *end, *n, *glob;

`end' and `glob' could be local to the loop which uses them, which I
find a bit nicer.

`n' is a rotten identifier.  Can't we think of something which
communicates meaning?

> +	int len = strlen(name);
> +
> +	/* If slub_debug = 0, it folds into the if conditional. */
> +	if (!slub_debug_slabs)
> +		return flags | slub_debug;

If we take the above return, the call to strlen() was wasted cycles. 
Presumably gcc is smart enough to prevent that, but why risk it.

> +	n = slub_debug_slabs;
> +	while (*n) {
> +		int cmplen;
> +
> +		end = strchr(n, ',');
> +		if (!end)
> +			end = n + strlen(n);
> +
> +		glob = strnchr(n, end - n, '*');
> +		if (glob)
> +			cmplen = glob - n;
> +		else
> +			cmplen = max(len, (int)(end - n));

max_t() exists for this.  Or maybe make `len' size_t, but I expect that
will still warn - that subtraction returns a ptrdiff_t, yes?

> +
> +		if (!strncmp(name, n, cmplen)) {
> +			flags |= slub_debug;
> +			break;
> +		}
> +
> +		if (!*end)
> +			break;
> +		n = end + 1;
> +	}

The code in this loop hurts my brain a bit. I hope it's correct ;)
