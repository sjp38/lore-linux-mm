Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5D166B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:46:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e3so157985380pfc.4
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 23:46:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t5si12587757plj.397.2017.07.16.23.46.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 23:46:30 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6H6hjnO113340
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:46:30 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2brqy90mr3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:46:29 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 17 Jul 2017 07:46:27 +0100
Date: Mon, 17 Jul 2017 09:46:21 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] userfaultfd: non-cooperative: notify about unmap of
 destination during mremap
References: <1500272293-17174-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500272293-17174-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <20170717064620.GB6815@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, stable@vger.kernel.org

On Mon, Jul 17, 2017 at 09:18:13AM +0300, Mike Rapoport wrote:
> When mremap is called with MREMAP_FIXED it unmaps memory at the destination
> address without notifying userfaultfd monitor. If the destination were
> registered with userfaultfd, the monitor has no way to distinguish between
> the old and new ranges and to properly relate the page faults that would
> occur in the destination region.
> 
> Cc: stable@vger.kernel.org
> Fixes: 897ab3e0c49e ("userfaultfd: non-cooperative: add event for memory
> unmaps")
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---

Please discard this patch. I completely missed that
userfaultfd_unmap_complete releases mmap_sem :(

>  mm/mremap.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index cd8a1b199ef9..eb36ef9410e4 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -446,9 +446,14 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
>  	if (addr + old_len > new_addr && new_addr + new_len > addr)
>  		goto out;
> 
> -	ret = do_munmap(mm, new_addr, new_len, NULL);
> +	/*
> +	 * We presume the uf_unmap list is empty by this point and it
> +	 * will be cleared again in userfaultfd_unmap_complete.
> +	 */
> +	ret = do_munmap(mm, new_addr, new_len, uf_unmap);
>  	if (ret)
>  		goto out;
> +	userfaultfd_unmap_complete(mm, uf_unmap);
> 
>  	if (old_len >= new_len) {
>  		ret = do_munmap(mm, addr+new_len, old_len - new_len, uf_unmap);
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
