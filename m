Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0326B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 19:21:42 -0400 (EDT)
Received: by ykax123 with SMTP id x123so31390501yka.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:21:42 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id c140si7160667ywa.56.2015.07.24.16.21.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 16:21:41 -0700 (PDT)
Message-ID: <55B2C882.8050903@citrix.com>
Date: Sat, 25 Jul 2015 00:21:38 +0100
From: Julien Grall <julien.grall@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCHv2 10/10] xen/balloon: pre-allocate p2m entries
 for ballooned pages
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
 <1437738468-24110-11-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1437738468-24110-11-git-send-email-david.vrabel@citrix.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xenproject.org
Cc: Daniel Kiper <daniel.kiper@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>

Hi David,

On 24/07/2015 12:47, David Vrabel wrote:
> Pages returned by alloc_xenballooned_pages() will be used for grant
> mapping which will call set_phys_to_machine() (in PV guests).
>
> Ballooned pages are set as INVALID_P2M_ENTRY in the p2m and thus may
> be using the (shared) missing tables and a subsequent
> set_phys_to_machine() will need to allocate new tables.
>
> Since the grant mapping may be done from a context that cannot sleep,
> the p2m entries must already be allocated.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
>   drivers/xen/balloon.c | 8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index fd6970f3..8932d10 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -541,6 +541,7 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
>   {
>   	int pgno = 0;
>   	struct page *page;
> +	int ret = -ENOMEM;
>
>   	mutex_lock(&balloon_mutex);
>
> @@ -550,6 +551,11 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
>   		page = balloon_retrieve(true);
>   		if (page) {
>   			pages[pgno++] = page;
> +#ifdef CONFIG_XEN_HAVE_PVMMU
> +			ret = xen_alloc_p2m_entry(page_to_pfn(page));

Don't you want to call this function only when the guest is not using 
auto-translated physmap?

> +			if (ret < 0)
> +				goto out_undo;
> +#endif
>   		} else {
>   			enum bp_state st;
>
> @@ -576,7 +582,7 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
>    out_undo:
>   	mutex_unlock(&balloon_mutex);
>   	free_xenballooned_pages(pgno, pages);
> -	return -ENOMEM;
> +	return ret;
>   }
>   EXPORT_SYMBOL(alloc_xenballooned_pages);
>
>

Regards,

-- 
Julien Grall

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
