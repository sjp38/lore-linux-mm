Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 889D96B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 10:35:30 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 10so47977379qkh.1
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 07:35:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g190si12051694qkf.118.2017.04.03.07.35.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 07:35:29 -0700 (PDT)
Date: Mon, 3 Apr 2017 16:35:23 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH for 4.11] userfaultfd: report actual registered features
 in fdinfo
Message-ID: <20170403143523.GC5107@redhat.com>
References: <1491140181-22121-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1491140181-22121-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org

On Sun, Apr 02, 2017 at 04:36:21PM +0300, Mike Rapoport wrote:
> fdinfo for userfault file descriptor reports UFFD_API_FEATURES. Up until
> recently, the UFFD_API_FEATURES was defined as 0, therefore corresponding
> field in fdinfo always contained zero. Now, with introduction of several
> additional features, UFFD_API_FEATURES is not longer 0 and it seems better
> to report actual features requested for the userfaultfd object described by
> the fdinfo. First, the applications that were using userfault will still
> see zero at the features field in fdinfo. Next, reporting actual features
> rather than available features, gives clear indication of what userfault
> features are used by an application.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  fs/userfaultfd.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 1d227b0..f7555fc 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1756,7 +1756,7 @@ static void userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
>  	 *	protocols: aa:... bb:...
>  	 */
>  	seq_printf(m, "pending:\t%lu\ntotal:\t%lu\nAPI:\t%Lx:%x:%Lx\n",
> -		   pending, total, UFFD_API, UFFD_API_FEATURES,
> +		   pending, total, UFFD_API, ctx->features,
>  		   UFFD_API_IOCTLS|UFFD_API_RANGE_IOCTLS);
>  }
>  #endif

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

I wonder if we've been a bit overkill in showing these details in
/proc as this innocent change is technically an ABI visible change
now. It's intended only for informational/debug purposes, no software
should attempt to decode it, so it'd be better in debugfs, but the
per-thread fds aren't anywhere in debugfs so it's shown there where
it's all already in place to provide it with a few liner function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
