Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83CCA6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 06:09:36 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u62so111972606pfk.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 03:09:36 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l3si10302058pln.137.2017.03.03.03.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 03:09:35 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v23B4Zed029051
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 06:09:35 -0500
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28xs8da713-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Mar 2017 06:09:34 -0500
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 3 Mar 2017 11:09:32 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] userfaultfd: non-cooperative: fix fork fctx->new memleak
Date: Fri,  3 Mar 2017 13:09:26 +0200
In-Reply-To: <20170302173738.18994-2-aarcange@redhat.com>
References: <20170302173738.18994-2-aarcange@redhat.com>
Message-Id: <1488539366-22846-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

> From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> We have a memleak in the ->new ctx if the uffd of the parent is closed
> before the fork event is read, nothing frees the new context.
> 
> Reported-by: Andrea Arcangeli <aarcange@redhat.com>

I think
Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
would be appropriate here.

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  fs/userfaultfd.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index d2f15a6..5087a69 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -548,6 +548,15 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
>  		if (ACCESS_ONCE(ctx->released) ||
>  		    fatal_signal_pending(current)) {
>  			__remove_wait_queue(&ctx->event_wqh, &ewq->wq);
> +			if (ewq->msg.event == UFFD_EVENT_FORK) {
> +				struct userfaultfd_ctx *new;
> +
> +				new = (struct userfaultfd_ctx *)
> +					(unsigned long)
> +					ewq->msg.arg.reserved.reserved1;
> +
> +				userfaultfd_ctx_put(new);
> +			}
>  			break;
>  		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
