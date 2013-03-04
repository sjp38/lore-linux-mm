Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 3E80D6B0002
	for <linux-mm@kvack.org>; Sun,  3 Mar 2013 20:54:28 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id x8so4078437wey.6
        for <linux-mm@kvack.org>; Sun, 03 Mar 2013 17:54:26 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 4 Mar 2013 09:54:26 +0800
Message-ID: <CAFNq8R7tq9kvD9LyhZJ-Cj0kexQfDsPhB4iQYyZ9s9+8Jo82QA@mail.gmail.com>
Subject: [PATCH] mm: Fixup the condition whether the page cache is free
From: Li Haifeng <omycle@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, Johannes Weiner <hannes@cmpxchg.org>

When a page cache is to reclaim, we should to decide whether the page
cache is free.
IMO, the condition whether a page cache is free should be 3 in page
frame reclaiming. The reason lists as below.

When page is allocated, the page->_count is 1(code fragment is code-1 ).
And when the page is allocated for reading files from extern disk, the
page->_count will increment 1 by page_cache_get() in
add_to_page_cache_locked()(code fragment is code-2). When the page is to
reclaim, the isolated LRU list also increase the page->_count(code
fragment is code-3).

According above reasons, when the file page is freeable, the
page->_count should be 3 instead of 2.

<code-1>
buffered_rmqueue ->prep_new_page->set_page_refcounted:
24 /*
25  * Turn a non-refcounted page (->_count =3D=3D 0) into refcounted with
26  * a count of one.
27  */
28 static inline void set_page_refcounted(struct page *page)
29 {
30         VM_BUG_ON(PageTail(page));
31         VM_BUG_ON(atomic_read(&page->_count));
32         set_page_count(page, 1);
33 }

<code-2>
do_generic_file_read ->add_to_page_cache_lru-> add_to_page_cache->
add_to_page_cache_locked:
int add_to_page_cache_locked(struct page *page, struct address_space
*mapping,
                pgoff_t offset, gfp_t gfp_mask)
{
=85
           page_cache_get(page);
                page->mapping =3D mapping;
                page->index =3D offset;

                spin_lock_irq(&mapping->tree_lock);
                error =3D radix_tree_insert(&mapping->page_tree, offset,
page);
                if (likely(!error)) {
                        mapping->nrpages++;
                        __inc_zone_page_state(page, NR_FILE_PAGES);
                        spin_unlock_irq(&mapping->tree_lock);
=85
}
<code-3>
static noinline_for_stack unsigned long
shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone
*mz,
                     struct scan_control *sc, int priority, int file)
{
=85
       nr_taken =3D isolate_lru_pages(nr_to_scan, mz, &page_list,
&nr_scanned,
                                     sc, isolate_mode, 0, file);
=85
	   nr_reclaimed =3D shrink_page_list(&page_list, mz, sc, priority,
                                                &nr_dirty,
&nr_writeback);
}
Remarks for code-3:
isolate_lru_pages() will call get_page_unless_zero() ultimately to
increase the page->_count by 1.
And shrink_page_list() will call is_page_cache_freeable() finally to
check whether the page cache is free.
