Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9580F6B0032
	for <linux-mm@kvack.org>; Wed,  6 May 2015 15:38:42 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so18170728pac.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 12:38:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k4si30328105pdb.126.2015.05.06.12.38.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 12:38:41 -0700 (PDT)
Date: Wed, 6 May 2015 12:38:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [net-next PATCH 1/6] net: Add skb_free_frag to replace use of
 put_page in freeing skb->head
Message-Id: <20150506123840.312f41000e8d46f1ef9ce046@linux-foundation.org>
In-Reply-To: <20150504231448.1538.84164.stgit@ahduyck-vm-fedora22>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
	<20150504231448.1538.84164.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, davem@davemloft.net

On Mon, 04 May 2015 16:14:48 -0700 Alexander Duyck <alexander.h.duyck@redhat.com> wrote:

> +/**
> + * skb_free_frag - free a page fragment
> + * @head: virtual address of page fragment
> + *
> + * Frees a page fragment allocated out of either a compound or order 0 page.
> + * The function itself is a hybrid between free_pages and free_compound_page
> + * which can be found in mm/page_alloc.c
> + */
> +void skb_free_frag(void *head)
> +{
> +	struct page *page = virt_to_head_page(head);
> +
> +	if (unlikely(put_page_testzero(page))) {
> +		if (likely(PageHead(page)))
> +			__free_pages_ok(page, compound_order(page));
> +		else
> +			free_hot_cold_page(page, false);
> +	}
> +}

Why are we testing for PageHead in here?  If the code were to simply do

	if (unlikely(put_page_testzero(page)))
		__free_pages_ok(page, compound_order(page));

that would still work?


There's nothing networking-specific in here.  I suggest the function be
renamed and moved to page_alloc.c.  Add an inlined skb_free_frag() in a
net header which calls it.  This way the mm developers know about it
and will hopefully maintain it.  It would need a comment explaining
when and why people should and shouldn't use it.

The term "page fragment" is a net thing and isn't something we know
about.  What is it?  From context I'm thinking a definition would look
something like

  An arbitrary-length arbitrary-offset area of memory which resides
  within a 0 or higher order page.  Multiple fragments within that page
  are individually refcounted, in the page's reference counter.

Is that correct and complete?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
