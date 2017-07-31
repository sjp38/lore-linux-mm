Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B482D6B05E9
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:22:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m80so17421678wmd.4
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 05:22:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s77si431397wme.161.2017.07.31.05.22.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 05:22:06 -0700 (PDT)
Date: Mon, 31 Jul 2017 14:22:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] userfaultfd_zeropage: return -ENOSPC in case mm has gone
Message-ID: <20170731122204.GB4878@dhcp22.suse.cz>
References: <1501136819-21857-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501136819-21857-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Thu 27-07-17 09:26:59, Mike Rapoport wrote:
> In the non-cooperative userfaultfd case, the process exit may race with
> outstanding mcopy_atomic called by the uffd monitor.  Returning -ENOSPC
> instead of -EINVAL when mm is already gone will allow uffd monitor to
> distinguish this case from other error conditions.

Normally we tend to return ESRCH in such case. ENOSPC sounds rather
confusing...
 
> Cc: stable@vger.kernel.org
> Fixes: 96333187ab162 ("userfaultfd_copy: return -ENOSPC in case mm has gone")
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
> 
> Unfortunately, I've overlooked userfaultfd_zeropage when I updated
> userfaultd_copy :(
> 
>  fs/userfaultfd.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index cadcd12a3d35..2d8c2d848668 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1643,6 +1643,8 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
>  		ret = mfill_zeropage(ctx->mm, uffdio_zeropage.range.start,
>  				     uffdio_zeropage.range.len);
>  		mmput(ctx->mm);
> +	} else {
> +		return -ENOSPC;
>  	}
>  	if (unlikely(put_user(ret, &user_uffdio_zeropage->zeropage)))
>  		return -EFAULT;
> -- 
> 2.7.4
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
