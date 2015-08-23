Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3A18B6B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:59:53 -0400 (EDT)
Received: by pdob1 with SMTP id b1so46202862pdo.2
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 16:59:52 -0700 (PDT)
Received: from mail-pd0-f193.google.com (mail-pd0-f193.google.com. [209.85.192.193])
        by mx.google.com with ESMTPS id q1si12027433pdg.31.2015.08.23.16.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 16:59:51 -0700 (PDT)
Received: by pdbpd5 with SMTP id pd5so4952891pdb.2
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 16:59:51 -0700 (PDT)
Date: Mon, 24 Aug 2015 01:59:45 +0200
From: Jesper Dangaard Brouer <netdev@brouer.com>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150824015945.58b25f3a@brouer.com>
In-Reply-To: <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Wed, 19 Aug 2015 12:21:45 +0300
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Hugh has pointed that compound_head() call can be unsafe in some
> context. There's one example:
> 
[...]

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0735bc0a351a..a4c4b7d07473 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h

[...]
> -/*
> - * If we access compound page synchronously such as access to
> - * allocated page, there is no need to handle tail flag race, so we can
> - * check tail flag directly without any synchronization primitive.
> - */
> -static inline struct page *compound_head_fast(struct page *page)
> -{
> -	if (unlikely(PageTail(page)))
> -		return page->first_page;
> -	return page;
> -}
> -
[...]

> @@ -548,13 +508,7 @@ static inline struct page *virt_to_head_page(const void *x)
>  {
>  	struct page *page = virt_to_page(x);
>  
> -	/*
> -	 * We don't need to worry about synchronization of tail flag
> -	 * when we call virt_to_head_page() since it is only called for
> -	 * already allocated page and this page won't be freed until
> -	 * this virt_to_head_page() is finished. So use _fast variant.
> -	 */
> -	return compound_head_fast(page);
> +	return compound_head(page);
>  }

I hope this does not slow down the SLAB/slub allocator?
(which calls virt_to_head_page() frequently)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
