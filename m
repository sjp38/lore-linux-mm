Date: Thu, 14 Oct 2004 21:35:45 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RESEND][PATCH 4/6] Add page becoming writable notification
Message-ID: <20041014203545.GA13639@infradead.org>
References: <24449.1097780701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24449.1097780701@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> +
> +	/* notification that a page is about to become writable */
> +	int (*page_mkwrite)(struct page *page);

This doesn't fit into address_space operations at all.  The vm_operation
below is enough.

> --- linux-2.6.9-rc1-mm2/mm/memory.c	2004-08-31 16:52:40.000000000 +0100
> +++ linux-2.6.9-rc1-mm2-cachefs/mm/memory.c	2004-09-02 15:40:26.000000000 +0100
> @@ -1030,6 +1030,54 @@ static inline void break_cow(struct vm_a
>  }
>  
>  /*
> + * Make a PTE writeable for do_wp_page() on a shared-writable page
> + */
> +static inline int do_wp_page_mk_pte_writable(struct mm_struct *mm,
> +					     struct vm_area_struct *vma,
> +					     unsigned long address,
> +					     pte_t *page_table,
> +					     struct page *old_page,
> +					     pte_t pte)

This prototype shows pretty much that splitting it out doesn't make much sense.
Why not add a goto reuse_page; where you call it currently and append it
at the end of do_wp_page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
