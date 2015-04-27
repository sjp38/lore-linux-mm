Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id C05C16B006C
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 18:43:35 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so143178405pdb.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:43:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z14si31829863pdi.58.2015.04.27.15.43.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 15:43:34 -0700 (PDT)
Date: Mon, 27 Apr 2015 15:43:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 05/13] mm: meminit: Make __early_pfn_to_nid SMP-safe and
 introduce meminit_pfn_in_nid
Message-Id: <20150427154333.85a1fd2dbc38c7c0888fd4f5@linux-foundation.org>
In-Reply-To: <1429785196-7668-6-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
	<1429785196-7668-6-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, 23 Apr 2015 11:33:08 +0100 Mel Gorman <mgorman@suse.de> wrote:

> __early_pfn_to_nid() in the generic and arch-specific implementations
> use static variables to cache recent lookups. Without the cache
> boot times are much higher due to the excessive memblock lookups but
> it assumes that memory initialisation is single-threaded. Parallel
> initialisation of struct pages will break that assumption so this patch
> makes __early_pfn_to_nid() SMP-safe by requiring the caller to cache
> recent search information. early_pfn_to_nid() keeps the same interface
> but is only safe to use early in boot due to the use of a global static
> variable. meminit_pfn_in_nid() is an SMP-safe version that callers must
> maintain their own state for.

Seems a bit awkward.

> +struct __meminitdata mminit_pfnnid_cache global_init_state;
> +
> +/* Only safe to use early in boot when initialisation is single-threaded */
>  int __meminit early_pfn_to_nid(unsigned long pfn)
>  {
>  	int nid;
>  
> -	nid = __early_pfn_to_nid(pfn);
> +	/* The system will behave unpredictably otherwise */
> +	BUG_ON(system_state != SYSTEM_BOOTING);

Because of this.

Providing a cache per cpu:

struct __meminitdata mminit_pfnnid_cache global_init_state[NR_CPUS];

would be simpler?


Also, `global_init_state' is a poor name for a kernel-wide symbol.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
