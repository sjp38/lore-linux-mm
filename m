Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C70126B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 02:08:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g71so3238620wmg.13
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 23:08:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r129si581144wma.40.2017.08.07.23.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 23:08:25 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7863phY060819
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 02:08:24 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c728rbf45-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 02:08:23 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 07:08:22 +0100
Date: Tue, 8 Aug 2017 09:08:17 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] userfaultfd: replace ENOSPC with ESRCH in case mm has
 gone during copy/zeropage
References: <1502111545-32305-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502111545-32305-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <20170808060816.GA31648@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@suse.com>

(adding Michal)

On Mon, Aug 07, 2017 at 04:12:25PM +0300, Mike Rapoport wrote:
> When the process exit races with outstanding mcopy_atomic, it would be
> better to return ESRCH error. When such race occurs the process and it's mm
> are going away and returning "no such process" to the uffd monitor seems
> better fit than ENOSPC.
> 
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
> Cc: Pavel Emelyanov <xemul@virtuozzo.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
> The man-pages update is ready and I'll send it out once the patch is
> merged.
> 
>  fs/userfaultfd.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 06ea26b8c996..b0d5897bc4e6 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1600,7 +1600,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
>  				   uffdio_copy.len);
>  		mmput(ctx->mm);
>  	} else {
> -		return -ENOSPC;
> +		return -ESRCH;
>  	}
>  	if (unlikely(put_user(ret, &user_uffdio_copy->copy)))
>  		return -EFAULT;
> @@ -1647,7 +1647,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
>  				     uffdio_zeropage.range.len);
>  		mmput(ctx->mm);
>  	} else {
> -		return -ENOSPC;
> +		return -ESRCH;
>  	}
>  	if (unlikely(put_user(ret, &user_uffdio_zeropage->zeropage)))
>  		return -EFAULT;
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
