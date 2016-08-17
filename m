Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57FC16B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 09:48:07 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id j12so218310515ywb.3
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 06:48:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z88si21100042qtc.23.2016.08.17.06.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 06:48:06 -0700 (PDT)
Date: Wed, 17 Aug 2016 15:48:02 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] do_generic_file_read(): Fail immediately if killed
Message-ID: <20160817134802.GA20161@redhat.com>
References: <63068e8e-8bee-b208-8441-a3c39a9d9eb6@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <63068e8e-8bee-b208-8441-a3c39a9d9eb6@sandisk.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 08/16, Bart Van Assche wrote:
>
> If a fatal signal has been received, fail immediately instead of
> trying to read more data.

This looks a bit misleading to me.

If wait_on_page_locked_killable() was interrupted then this page is most
likely is not PageUptodate() and in this case do_generic_file_read() will
fail after lock_page_killable().

But as I already said, I belive the change itself is fine,

> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1721,7 +1721,9 @@ find_page:
>  			 * wait_on_page_locked is used to avoid unnecessarily
>  			 * serialisations and why it's safe.
>  			 */
> -			wait_on_page_locked_killable(page);
> +			error = wait_on_page_locked_killable(page);
> +			if (unlikely(error))
> +				goto readpage_error;
>  			if (PageUptodate(page))
>  				goto page_ok;

Acked-by: Oleg Nesterov <oleg@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
