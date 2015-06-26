Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 445BD6B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 09:56:22 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so46110901wic.1
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 06:56:21 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id v3si3021337wix.97.2015.06.26.06.56.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Jun 2015 06:56:20 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Fri, 26 Jun 2015 14:56:19 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 15FF71B08061
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 14:57:21 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5QDuG2H35586270
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 13:56:16 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5QDuFF2011979
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 07:56:16 -0600
Date: Fri, 26 Jun 2015 15:56:14 +0200
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: Add error check after call to rmap_walk in the
 function page_referenced
Message-ID: <20150626155614.04bffed1@BR9TG4T3.de.ibm.com>
In-Reply-To: <1435282597-21728-1-git-send-email-xerofoify@gmail.com>
References: <1435282597-21728-1-git-send-email-xerofoify@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, riel@redhat.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, dave@stgolabs.net, koct9i@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 25 Jun 2015 21:36:37 -0400
Nicholas Krause <xerofoify@gmail.com> wrote:

> This adds a return check after the call to the function rmap_walk
> in the function page_referenced as this function call can fail
> and thus should signal callers of page_referenced if this happens
> by returning the SWAP macro return value as returned by rmap_walk
> here. In addition also check if have locked the page pointer as
> passed to this particular and unlock it with unlock_page if this
> page is locked before returning our SWAP marco return code from
> rmap_walk.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  mm/rmap.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 171b687..e4df848 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -814,7 +814,9 @@ static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
>   * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
>   *
>   * Quick test_and_clear_referenced for all mappings to a page,
> - * returns the number of ptes which referenced the page.
> + * returns the number of ptes which referenced the page.On
> + * error returns either zero or the error code returned from
> + * the failed call to rmap_walk.
>   */
>  int page_referenced(struct page *page,
>  		    int is_locked,
> @@ -855,7 +857,13 @@ int page_referenced(struct page *page,
>  		rwc.invalid_vma = invalid_page_referenced_vma;
>  	}
> 
> +

unnecessary empty line

>  	ret = rmap_walk(page, &rwc);
> +	if (!ret) {
> +		if (we_locked)
> +			unlock_page(page);
> +		return ret;
> +	}

I don't see why the function should propagate the rmap_walk return value.
rmap_walk will not set pra.referenced, so that both callers just skip.

What is the purpose of the given patch? Do you have any real case introducing such code,
which is imho incomplete as all callers need to take care of the changed return value!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
