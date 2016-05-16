Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0056B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 16:43:43 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id e126so400450840vkb.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 13:43:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f71si24624235qge.127.2016.05.16.13.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 13:43:42 -0700 (PDT)
Date: Mon, 16 May 2016 22:43:39 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: fs/exec.c: fix minor memory leak
Message-ID: <20160516204339.GA26141@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, hujunjie <jj.net@163.com>
Cc: linux-mm@kvack.org

Andrew, Vlastimil,

I found this patch by accident when I was looking at http://marc.info/?l=linux-mm
and I can't resist ;)

> On 04/21/2016 11:15 PM, Andrew Morton wrote:
> >
> > Could someone please double-check this?
>
> Looks OK to me.
>
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Subject: fs/exec.c: fix minor memory leak
> >
> > When the to-be-removed argument's trailing '\0' is the final byte in the
> > page, remove_arg_zero()'s logic will avoid freeing the page, will break
> > from the loop and will then advance bprm->p to point at the first byte in
> > the next page.  Net result: the final page for the zeroeth argument is
> > unfreed.
> >
> > It isn't a very important leak - that page will be freed later by the
> > bprm-wide sweep in free_arg_pages().

And so I think we should just remove this free_arg_page(), it (and the patch)
only adds the unnecessary confusion.

Note that today free_arg_page() is nop if CONFIG_MMU. At the same time, the
only reason for this free_arg_page() was that (until the commit b6a2fea39)
CONFIG_MMU did install_arg_page() for every page != NULL in bprm->page[].

So we simply do not need it today. And note that the caller is going to do
copy_strings_kernel(), so if we do free_arg_page() with CONFIG_MMU=n we will
likely have to re-allocate this page right after free.

And note that this code is actually wrong! remove_arg_zero() assumes that
argv[0] is null-terminated but this is not necessarily true. copy_strings()
does:

	len = strnlen_user(...);
	...
	copy_from_user(..., len);

another thread or debugger can change the memory in between. Fortunately
nothing really bad can happen (afaics) even if CONFIG_MMU=n, bprm->filename
must be always zero-terminated and it was copied by the 1st copy_strings_kernel().
Still perhaps it makes sense to check "bprm->p < bprm->exec" in the main loop.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
