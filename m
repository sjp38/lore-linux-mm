Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3256B025E
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 06:02:05 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so1323577wmz.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 03:02:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y135si24818695wmc.71.2016.08.17.03.01.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Aug 2016 03:01:58 -0700 (PDT)
Date: Wed, 17 Aug 2016 12:01:56 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] do_generic_file_read(): Fail immediately if killed
Message-ID: <20160817100156.GA6254@quack2.suse.cz>
References: <63068e8e-8bee-b208-8441-a3c39a9d9eb6@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <63068e8e-8bee-b208-8441-a3c39a9d9eb6@sandisk.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue 16-08-16 17:00:43, Bart Van Assche wrote:
> If a fatal signal has been received, fail immediately instead of
> trying to read more data.
> 
> See also commit ebded02788b5 ("mm: filemap: avoid unnecessary
> calls to lock_page when waiting for IO to complete during a read")
> 
> Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Oleg Nesterov <oleg@redhat.com>

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

BTW: Did you see some real world impact of the change? If yes, it would be
good to describe in the changelog.

								Honza
> ---
>  mm/filemap.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 2a9e84f6..bd8ab63 100644
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
>  
> -- 
> 2.9.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
