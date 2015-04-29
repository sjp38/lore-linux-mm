Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 809386B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 17:19:03 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so39425993pdb.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 14:19:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id px1si327037pbb.117.2015.04.29.14.19.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 14:19:02 -0700 (PDT)
Date: Wed, 29 Apr 2015 14:19:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 07/13] mm: meminit: Initialise a subset of struct pages
 if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set
Message-Id: <20150429141901.df10d11cc8fa2d5df377922f@linux-foundation.org>
In-Reply-To: <1430231830-7702-8-git-send-email-mgorman@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
	<1430231830-7702-8-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 28 Apr 2015 15:37:04 +0100 Mel Gorman <mgorman@suse.de> wrote:

> +/*
> + * Deferred struct page initialisation requires some early init functions that
> + * are removed before kswapd is up and running. The feature depends on memory
> + * hotplug so put the data and code required by deferred initialisation into
> + * the __meminit section where they are preserved.
> + */
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +#define __defermem_init __meminit
> +#define __defer_init    __meminit
> +#else
> +#define __defermem_init
> +#define __defer_init __init
> +#endif

I still don't get it :(

__defermem_init:

	if (CONFIG_DEFERRED_STRUCT_PAGE_INIT) {
		if (CONFIG_MEMORY_HOTPLUG)
			retain
	} else {
		retain
	}

    but CONFIG_DEFERRED_STRUCT_PAGE_INIT depends on
    CONFIG_MEMORY_HOTPLUG, so this becomes

	if (CONFIG_DEFERRED_STRUCT_PAGE_INIT) {
		retain
	} else {
		retain
	}

    which becomes

	retain

    so why does __defermem_init exist?



__defer_init:

	if (CONFIG_DEFERRED_STRUCT_PAGE_INIT) {
		if (CONFIG_MEMORY_HOTPLUG)
			retain
	} else {
		discard
	}

    becomes

	if (CONFIG_DEFERRED_STRUCT_PAGE_INIT) {
		retain
	} else {
		discard
	}

    this one makes sense, but could be documented much more clearly!


And why does the comment refer to "and data".  There is no
__defer_initdata, etc.  Just not needed yet?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
