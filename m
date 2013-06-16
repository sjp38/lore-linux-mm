Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 9B82F6B0034
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 00:27:11 -0400 (EDT)
Message-ID: <1371356818.21896.114.camel@pasglop>
Subject: Re: [PATCH 2/4] powerpc: Prepare to support kernel handling of
 IOMMU map/unmap
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 16 Jun 2013 14:26:58 +1000
In-Reply-To: <1370412673-1345-3-git-send-email-aik@ozlabs.ru>
References: <1370412673-1345-1-git-send-email-aik@ozlabs.ru>
	 <1370412673-1345-3-git-send-email-aik@ozlabs.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: linuxppc-dev@lists.ozlabs.org, David Gibson <david@gibson.dropbear.id.au>, Alexander Graf <agraf@suse.de>, Paul Mackerras <paulus@samba.org>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

> +#if defined(CONFIG_SPARSEMEM_VMEMMAP) || defined(CONFIG_FLATMEM)
> +int realmode_get_page(struct page *page)
> +{
> +	if (PageCompound(page))
> +		return -EAGAIN;
> +
> +	get_page(page);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(realmode_get_page);
> +
> +int realmode_put_page(struct page *page)
> +{
> +	if (PageCompound(page))
> +		return -EAGAIN;
> +
> +	if (!atomic_add_unless(&page->_count, -1, 1))
> +		return -EAGAIN;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(realmode_put_page);
> +#endif

Several worries here, mostly that if the generic code ever changes
(something gets added to get_page() that makes it no-longer safe for use
in real mode for example, or some other condition gets added to
put_page()), we go out of sync and potentially end up with very hard and
very subtle bugs.

It might be worth making sure that:

 - This is reviewed by some generic VM people (and make sure they
understand why we need to do that)

 - A comment is added to get_page() and put_page() to make sure that if
they are changed in any way, dbl check the impact on our
realmode_get_page() (or "ping" us to make sure things are still ok).

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
