Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD718E00B9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:21:57 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id v64so13755812qka.5
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:21:57 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH] aio: Convert ioctx_table to XArray
References: <20181128183531.5139-1-willy@infradead.org>
	<x49va46e1p0.fsf@segfault.boston.devel.redhat.com>
	<x49pnuee1gm.fsf@segfault.boston.devel.redhat.com>
Date: Tue, 11 Dec 2018 12:21:52 -0500
In-Reply-To: <x49pnuee1gm.fsf@segfault.boston.devel.redhat.com> (Jeff Moyer's
	message of "Thu, 06 Dec 2018 17:26:33 -0500")
Message-ID: <x49mupcm11r.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>

Jeff Moyer <jmoyer@redhat.com> writes:

> Jeff Moyer <jmoyer@redhat.com> writes:
>
>> Matthew Wilcox <willy@infradead.org> writes:
>>
>>> This custom resizing array was vulnerable to a Spectre attack (speculating
>>> off the end of an array to a user-controlled offset).  The XArray is
>>> not vulnerable to Spectre as it always masks its lookups to be within
>>> the bounds of the array.
>>
>> I'm not a big fan of completely re-writing the code to fix this.  Isn't
>> the below patch sufficient?
>
> Too quick on the draw.  Here's a patch that compiles.  ;-)

Hi, Matthew,

I'm going to submit this version formally.  If you're interested in
converting the ioctx_table to xarray, you can do that separately from a
security fix.  I would include a performance analysis with that patch,
though.  The idea of using a radix tree for the ioctx table was
discarded due to performance reasons--see commit db446a08c23d5 ("aio:
convert the ioctx list to table lookup v3").  I suspect using the xarray
will perform similarly.

Cheers,
Jeff

> diff --git a/fs/aio.c b/fs/aio.c
> index 97f983592925..aac9659381d2 100644
> --- a/fs/aio.c
> +++ b/fs/aio.c
> @@ -45,6 +45,7 @@
>  
>  #include <asm/kmap_types.h>
>  #include <linux/uaccess.h>
> +#include <linux/nospec.h>
>  
>  #include "internal.h"
>  
> @@ -1038,6 +1039,7 @@ static struct kioctx *lookup_ioctx(unsigned long ctx_id)
>  	if (!table || id >= table->nr)
>  		goto out;
>  
> +	id = array_index_nospec(id, table->nr);
>  	ctx = rcu_dereference(table->table[id]);
>  	if (ctx && ctx->user_id == ctx_id) {
>  		if (percpu_ref_tryget_live(&ctx->users))
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-aio' in
> the body to majordomo@kvack.org.  For more info on Linux AIO,
> see: http://www.kvack.org/aio/
> Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
