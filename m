Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id C3A1C6B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 08:11:25 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so350399vcb.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 05:11:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344324343-3817-3-git-send-email-walken@google.com>
References: <1344324343-3817-1-git-send-email-walken@google.com>
	<1344324343-3817-3-git-send-email-walken@google.com>
Date: Tue, 14 Aug 2012 20:11:24 +0800
Message-ID: <CAJd=RBDnwDJzWACwW-z-1CZ-VEkpiHbCSfskapW+_+=ErWVVGw@mail.gmail.com>
Subject: Re: [PATCH 2/5] mm: replace vma prio_tree with an interval tree
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, peterz@infradead.org, vrajesh@umich.edu, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Tue, Aug 7, 2012 at 3:25 PM, Michel Lespinasse <walken@google.com> wrote:

> +#define ITSTRUCT   struct vm_area_struct
> +#define ITSTART(n) ((n)->vm_pgoff)
> +#define ITLAST(n)  ((n)->vm_pgoff + \
> +                   (((n)->vm_end - (n)->vm_start) >> PAGE_SHIFT) - 1)

[...]

> @@ -1547,7 +1545,6 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
>         struct address_space *mapping = page->mapping;
>         pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>         struct vm_area_struct *vma;
> -       struct prio_tree_iter iter;
>         int ret = SWAP_AGAIN;
>         unsigned long cursor;
>         unsigned long max_nl_cursor = 0;
> @@ -1555,7 +1552,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
>         unsigned int mapcount;
>
>         mutex_lock(&mapping->i_mmap_mutex);
> -       vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
> +       vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {

Given the above defines for ITSTART and ITLAST, page index perhaps could not
be used directly in scanning interval tree for vma when ttum hugetlb page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
