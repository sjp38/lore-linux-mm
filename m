Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6D86B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 15:32:15 -0400 (EDT)
Received: by mail-bk0-f47.google.com with SMTP id w10so1363525bkz.20
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 12:32:14 -0700 (PDT)
Received: from mail-bk0-x230.google.com (mail-bk0-x230.google.com [2a00:1450:4008:c01::230])
        by mx.google.com with ESMTPS id nw1si9657609bkb.190.2014.04.01.12.32.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 12:32:14 -0700 (PDT)
Received: by mail-bk0-f48.google.com with SMTP id mx12so1333291bkb.21
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 12:32:13 -0700 (PDT)
Message-ID: <533B1439.3010403@gmail.com>
Date: Tue, 01 Apr 2014 21:32:09 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
References: <533B04A9.6090405@bbn.com>
In-Reply-To: <533B04A9.6090405@bbn.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Hansen <rhansen@bbn.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mtk.manpages@gmail.com, linux-api@vger.kernel.org, Greg Troxel <gdt@ir.bbn.com>

Richard,

On 04/01/2014 08:25 PM, Richard Hansen wrote:
> For the flags parameter, POSIX says "Either MS_ASYNC or MS_SYNC shall
> be specified, but not both." [1]  There was already a test for the
> "both" condition.  Add a test to ensure that the caller specified one
> of the flags; fail with EINVAL if neither are specified.
> 
> Without this change, specifying neither is the same as specifying
> flags=MS_ASYNC because nothing in msync() is conditioned on the
> MS_ASYNC flag.  This has not always been true, 

I am curious (since such things should be documented)--when was
it not true?

> and there's no good
> reason to believe that this behavior would have persisted
> indefinitely.
> 
> The msync(2) man page (as currently written in man-pages.git) is
> silent on the behavior if both flags are unset, so this change should
> not break an application written by somone who carefully reads the
> Linux man pages or the POSIX spec.

Sadly, people do not always carefully read man pages, so there
remains the chance that a change like this will break applications.
Aside from standards conformance, what do you see as the benefit
of the change?

Thanks,

Michael


> [1] http://pubs.opengroup.org/onlinepubs/9699919799/functions/msync.html
> 
> Signed-off-by: Richard Hansen <rhansen@bbn.com>
> Reported-by: Greg Troxel <gdt@ir.bbn.com>
> Reviewed-by: Greg Troxel <gdt@ir.bbn.com>
> ---
> 
> This is a resend of:
> http://article.gmane.org/gmane.linux.kernel/1554416
> I didn't get any feedback from that submission, so I'm resending it
> without changes.
> 
>  mm/msync.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/msync.c b/mm/msync.c
> index 632df45..472ad3e 100644
> --- a/mm/msync.c
> +++ b/mm/msync.c
> @@ -42,6 +42,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t,
> len, int, flags)
>  		goto out;
>  	if ((flags & MS_ASYNC) && (flags & MS_SYNC))
>  		goto out;
> +	if (!(flags & (MS_ASYNC | MS_SYNC)))
> +		goto out;
>  	error = -ENOMEM;
>  	len = (len + ~PAGE_MASK) & PAGE_MASK;
>  	end = start + len;
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
