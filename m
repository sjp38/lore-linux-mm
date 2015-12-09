Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id C0D236B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 14:44:17 -0500 (EST)
Received: by qgeb1 with SMTP id b1so97161560qge.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 11:44:17 -0800 (PST)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id 200si10406563qhd.46.2015.12.09.11.44.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 11:44:16 -0800 (PST)
Received: by qgeb1 with SMTP id b1so97160903qge.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 11:44:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1449602325-20572-4-git-send-email-ross.zwisler@linux.intel.com>
References: <1449602325-20572-1-git-send-email-ross.zwisler@linux.intel.com>
	<1449602325-20572-4-git-send-email-ross.zwisler@linux.intel.com>
Date: Wed, 9 Dec 2015 11:44:16 -0800
Message-ID: <CAA9_cmeVYinm4mMiDU4oz8fW4HQ3n1RqEbPHBW7A3OGmi9eXtw@mail.gmail.com>
Subject: Re: [PATCH v3 3/7] mm: add find_get_entries_tag()
From: Dan Williams <dan.j.williams@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm <linux-mm@kvack.org>, Andreas Dilger <adilger.kernel@dilger.ca>, "H. Peter Anvin" <hpa@zytor.com>, Jeff Layton <jlayton@poochiereds.net>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, the arch/x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, ext4 hackers <linux-ext4@vger.kernel.org>, xfs@oss.sgi.com, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Tue, Dec 8, 2015 at 11:18 AM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> Add find_get_entries_tag() to the family of functions that include
> find_get_entries(), find_get_pages() and find_get_pages_tag().  This is
> needed for DAX dirty page handling because we need a list of both page
> offsets and radix tree entries ('indices' and 'entries' in this function)
> that are marked with the PAGECACHE_TAG_TOWRITE tag.
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  include/linux/pagemap.h |  3 +++
>  mm/filemap.c            | 68 +++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 71 insertions(+)
>
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 26eabf5..4db0425 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -361,6 +361,9 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
>                                unsigned int nr_pages, struct page **pages);
>  unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
>                         int tag, unsigned int nr_pages, struct page **pages);
> +unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
> +                       int tag, unsigned int nr_entries,
> +                       struct page **entries, pgoff_t *indices);
>
>  struct page *grab_cache_page_write_begin(struct address_space *mapping,
>                         pgoff_t index, unsigned flags);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 167a4d9..99dfbc9 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1498,6 +1498,74 @@ repeat:
>  }
>  EXPORT_SYMBOL(find_get_pages_tag);
>
> +/**
> + * find_get_entries_tag - find and return entries that match @tag
> + * @mapping:   the address_space to search
> + * @start:     the starting page cache index
> + * @tag:       the tag index
> + * @nr_entries:        the maximum number of entries
> + * @entries:   where the resulting entries are placed
> + * @indices:   the cache indices corresponding to the entries in @entries
> + *
> + * Like find_get_entries, except we only return entries which are tagged with
> + * @tag.
> + */
> +unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
> +                       int tag, unsigned int nr_entries,
> +                       struct page **entries, pgoff_t *indices)
> +{
> +       void **slot;
> +       unsigned int ret = 0;
> +       struct radix_tree_iter iter;
> +
> +       if (!nr_entries)
> +               return 0;
> +
> +       rcu_read_lock();
> +restart:
> +       radix_tree_for_each_tagged(slot, &mapping->page_tree,
> +                                  &iter, start, tag) {
> +               struct page *page;
> +repeat:
> +               page = radix_tree_deref_slot(slot);
> +               if (unlikely(!page))
> +                       continue;
> +               if (radix_tree_exception(page)) {
> +                       if (radix_tree_deref_retry(page)) {
> +                               /*
> +                                * Transient condition which can only trigger
> +                                * when entry at index 0 moves out of or back
> +                                * to root: none yet gotten, safe to restart.
> +                                */
> +                               goto restart;
> +                       }
> +
> +                       /*
> +                        * A shadow entry of a recently evicted page, a swap
> +                        * entry from shmem/tmpfs or a DAX entry.  Return it
> +                        * without attempting to raise page count.
> +                        */
> +                       goto export;
> +               }
> +               if (!page_cache_get_speculative(page))
> +                       goto repeat;
> +
> +               /* Has the page moved? */
> +               if (unlikely(page != *slot)) {
> +                       page_cache_release(page);
> +                       goto repeat;
> +               }
> +export:
> +               indices[ret] = iter.index;
> +               entries[ret] = page;
> +               if (++ret == nr_entries)
> +                       break;
> +       }
> +       rcu_read_unlock();
> +       return ret;
> +}
> +EXPORT_SYMBOL(find_get_entries_tag);
> +

Why does this mostly duplicate find_get_entries()?

Surely find_get_entries() can be implemented as a special case of
find_get_entries_tag().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
