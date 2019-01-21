Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 257F88E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 06:10:52 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id z68so18971617qkb.14
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:10:52 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v21si11897840qth.252.2019.01.21.03.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 03:10:51 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0LB0h0L140117
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 06:10:50 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q5bdmc2v7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 06:10:50 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 21 Jan 2019 11:10:48 -0000
Date: Mon, 21 Jan 2019 13:10:39 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH RFC 20/24] userfaultfd: wp: don't wake up when doing
 write protect
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-21-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121075722.7945-21-peterx@redhat.com>
Message-Id: <20190121111039.GB26461@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Mon, Jan 21, 2019 at 03:57:18PM +0800, Peter Xu wrote:
> It does not make sense to try to wake up any waiting thread when we're
> write-protecting a memory region.  Only wake up when resolving a write
> protected page fault.

Probably it would be better to make it default to wake up only when
requested explicitly?
Then we can simply disallow _DONTWAKE for uffd_wp and only use
UFFDIO_WRITEPROTECT_MODE_WP as possible mode.
 
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
>  fs/userfaultfd.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 455b87c0596f..e54ab6076e13 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1771,6 +1771,7 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
>  	struct uffdio_writeprotect uffdio_wp;
>  	struct uffdio_writeprotect __user *user_uffdio_wp;
>  	struct userfaultfd_wake_range range;
> +	bool mode_wp, mode_dontwake;
> 
>  	user_uffdio_wp = (struct uffdio_writeprotect __user *) arg;
> 
> @@ -1786,17 +1787,19 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
>  	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
>  			       UFFDIO_WRITEPROTECT_MODE_WP))
>  		return -EINVAL;
> -	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
> -	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
> +
> +	mode_wp = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP;
> +	mode_dontwake = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE;
> +
> +	if (mode_wp && mode_dontwake)
>  		return -EINVAL;
> 
>  	ret = mwriteprotect_range(ctx->mm, uffdio_wp.range.start,
> -				  uffdio_wp.range.len, uffdio_wp.mode &
> -				  UFFDIO_WRITEPROTECT_MODE_WP);
> +				  uffdio_wp.range.len, mode_wp);
>  	if (ret)
>  		return ret;
> 
> -	if (!(uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE)) {
> +	if (!mode_wp && !mode_dontwake) {
>  		range.start = uffdio_wp.range.start;
>  		range.len = uffdio_wp.range.len;
>  		wake_userfault(ctx, &range);
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.
