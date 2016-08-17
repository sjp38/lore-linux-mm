Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D7E756B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 13:20:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so16141725wme.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 10:20:24 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id f9si26424614wmg.96.2016.08.17.10.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 10:20:23 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o80so26333436wme.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 10:20:23 -0700 (PDT)
Date: Wed, 17 Aug 2016 19:20:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] do_generic_file_read(): Fail immediately if killed
Message-ID: <20160817172021.GD20719@dhcp22.suse.cz>
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

If not anything else it makes code more readable because the real error
is hidden in page_not_up_to_date: currently...

Acked-by: Michal Hocko <mhocko@suse.com>

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
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
