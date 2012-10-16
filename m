Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id A5E3A6B005D
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 12:59:37 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so6966214pbb.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:59:37 -0700 (PDT)
Date: Tue, 16 Oct 2012 22:29:31 +0530
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: Re:  Re: Re: [PATCH 5/5] mm/readahead: Use find_get_pages instead of
 radix_tree_lookup.
Message-ID: <20121016165714.GA2826@Archie>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <aae0fd43fc74dff95489de3c2b543ae8a4c7ed7d.1348309711.git.rprabhu@wnohang.net>
 <20120922131507.GC15962@localhost>
 <20120926025820.GA38848@Archie>
 <20120928121850.GC1525@localhost>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wq9mPyueHGvFACwf"
Content-Disposition: inline
In-Reply-To: <20120928121850.GC1525@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org


--wq9mPyueHGvFACwf
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


* On Fri, Sep 28, 2012 at 08:18:50PM +0800, Fengguang Wu <fengguang.wu@inte=
l.com> wrote:
>On Wed, Sep 26, 2012 at 08:28:20AM +0530, Raghavendra D Prabhu wrote:
>> Hi,
>>
>>
>> * On Sat, Sep 22, 2012 at 09:15:07PM +0800, Fengguang Wu <fengguang.wu@i=
ntel.com> wrote:
>> >On Sat, Sep 22, 2012 at 04:03:14PM +0530, raghu.prabhu13@gmail.com wrot=
e:
>> >>From: Raghavendra D Prabhu <rprabhu@wnohang.net>
>> >>
>> >>Instead of running radix_tree_lookup in a loop and lock/unlocking in t=
he
>> >>process, find_get_pages is called once, which returns a page_list, som=
e of which
>> >>are not NULL and are in core.
>> >>
>> >>Also, since find_get_pages returns number of pages, if all pages are a=
lready
>> >>cached, it can return early.
>> >>
>> >>This will be mostly helpful when a higher proportion of nr_to_read pag=
es are
>> >>already in the cache, which will mean less locking for page cache hits.
>> >
>> >Do you mean the rcu_read_lock()? But it's a no-op for most archs.  So
>> >the benefit of this patch is questionable. Will need real performance
>> >numbers to support it.
>>
>> Aside from the rcu lock/unlock, isn't it better to not make separate
>> calls to radix_tree_lookup and merge them into one call? Similar
>> approach is used with pagevec_lookup which is usually used when one
>> needs to deal with a set of pages.
>
>Yeah, batching is generally good, however find_get_pages() is not the
>right tool. It costs:
>- get/release page counts
>- likely a lot more searches in the address space, because it does not
>  limit the end index of the search.
>
>radix_tree_next_hole() will be the right tool, and I have a patch to
>make it actually smarter than the current dumb loop.

Good to know.

>
>> >>Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
>> >>---
>> >> mm/readahead.c | 31 +++++++++++++++++++++++--------
>> >> 1 file changed, 23 insertions(+), 8 deletions(-)
>> >>
>> >>diff --git a/mm/readahead.c b/mm/readahead.c
>> >>index 3977455..3a1798d 100644
>> >>--- a/mm/readahead.c
>> >>+++ b/mm/readahead.c
>> >>@@ -157,35 +157,42 @@ __do_page_cache_readahead(struct address_space *=
mapping, struct file *filp,
>> >> {
>> >> 	struct inode *inode =3D mapping->host;
>> >> 	struct page *page;
>> >>+	struct page **page_list =3D NULL;
>> >> 	unsigned long end_index;	/* The last page we want to read */
>> >> 	LIST_HEAD(page_pool);
>> >> 	int page_idx;
>> >> 	int ret =3D 0;
>> >> 	int ret_read =3D 0;
>> >>+	unsigned long num;
>> >>+	pgoff_t page_offset;
>> >> 	loff_t isize =3D i_size_read(inode);
>> >>
>> >> 	if (isize =3D=3D 0)
>> >> 		goto out;
>> >>
>> >>+	page_list =3D kzalloc(nr_to_read * sizeof(struct page *), GFP_KERNEL=
);
>> >>+	if (!page_list)
>> >>+		goto out;
>> >
>> >That cost one more memory allocation and added code to maintain the
>> >page list. The original code also don't have the cost of grabbing the
>> >page count, which eliminate the trouble of page release.
>> >
>> >> 	end_index =3D ((isize - 1) >> PAGE_CACHE_SHIFT);
>> >>+	num =3D find_get_pages(mapping, offset, nr_to_read, page_list);
>> >
>> >Assume we want to readahead pages for indexes [0, 100] and the cached
>> >pages are in [1000, 1100]. find_get_pages() will return the latter.
>> >Which is probably not the your expected results.
>>
>> I thought if I ask for pages in the range [0,100] it will return a
>> sparse array [0,100] but with holes (NULL) for pages not in cache
>> and references to pages in cache. Isn't that the expected behavior?
>
>Nope. The comments above find_get_pages() made it clear, that it's
>limited by the number of pages rather than the end page index.

Yes, I noticed that, however since nr_to_read in this case is=20
equal to nr_pages.

However, I think I understand what you are saying -- ie. if=20
offset +  nr_pages exceeds the end_index then it will return=20
pages not belonging to the file, is that right?

In that case, won't capping nr_pages do, ie. check if offset +=20
nr_pages > end_index  and if that is true, then reduce =20
nr_to_read by end_index. Won't that work?

>
>> >
>> >> 	/*
>> >> 	 * Preallocate as many pages as we will need.
>> >> 	 */
>> >> 	for (page_idx =3D 0; page_idx < nr_to_read; page_idx++) {
>> >>-		pgoff_t page_offset =3D offset + page_idx;
>> >>+		if (page_list[page_idx]) {
>> >>+			page_cache_release(page_list[page_idx]);
>> >>+			continue;
>> >>+		}
>> >>+
>> >>+		page_offset =3D offset + page_idx;
>> >>
>> >> 		if (page_offset > end_index)
>> >> 			break;
>> >>
>> >>-		rcu_read_lock();
>> >>-		page =3D radix_tree_lookup(&mapping->page_tree, page_offset);
>> >>-		rcu_read_unlock();
>> >>-		if (page)
>> >>-			continue;
>> >>-
>> >> 		page =3D page_cache_alloc_readahead(mapping);
>> >>-		if (!page)
>> >>+		if (unlikely(!page))
>> >> 			break;
>> >
>> >That break will leave the remaining pages' page_count lifted and lead
>> >to memory leak.
>>
>> Thanks. Yes, I realized that now.
>> >
>> >> 		page->index =3D page_offset;
>> >> 		list_add(&page->lru, &page_pool);
>> >>@@ -194,6 +201,13 @@ __do_page_cache_readahead(struct address_space *m=
apping, struct file *filp,
>> >> 			lookahead_size =3D 0;
>> >> 		}
>> >> 		ret++;
>> >>+
>> >>+		/*
>> >>+		 * Since num pages are already returned, bail out after
>> >>+		 * nr_to_read - num pages are allocated and added.
>> >>+		 */
>> >>+		if (ret =3D=3D nr_to_read - num)
>> >>+			break;
>> >
>> >Confused. That break seems unnecessary?
>>
>> I fixed that:
>>
>>
>>  -               pgoff_t page_offset =3D offset + page_idx;
>>  -
>>  -               if (page_offset > end_index)
>>  -                       break;
>>  -
>>  -               rcu_read_lock();
>>  -               page =3D radix_tree_lookup(&mapping->page_tree, page_of=
fset);
>>  -               rcu_read_unlock();
>>  -               if (page)
>
>>  +               if (page_list[page_idx]) {
>>  +                       page_cache_release(page_list[page_idx]);
>
>No, you cannot expect:
>
>        page_list[page_idx]->index =3D=3D page_idx
>
>Thanks,
>Fengguang
>
>
>>  +                       num--;
>>                          continue;
>>  +               }
>>  +
>>  +               page_offset =3D offset + page_idx;
>>  +
>>  +               /*
>>  +                * Break only if all the previous
>>  +                * references have been released
>>  +                */
>>  +               if (page_offset > end_index) {
>>  +                       if (!num)
>>  +                               break;
>>  +                       else
>>  +                               continue;
>>  +               }
>>
>>                  page =3D page_cache_alloc_readahead(mapping);
>>  -               if (!page)
>>  -                       break;
>>  +               if (unlikely(!page))
>>  +                       continue;
>>
>> >
>> >Thanks,
>> >Fengguang
>> >
>> >> 	}
>> >>
>> >> 	/*
>> >>@@ -205,6 +219,7 @@ __do_page_cache_readahead(struct address_space *ma=
pping, struct file *filp,
>> >> 		ret_read =3D read_pages(mapping, filp, &page_pool, ret);
>> >> 	BUG_ON(!list_empty(&page_pool));
>> >> out:
>> >>+	kfree(page_list);
>> >> 	return (ret_read < 0 ? ret_read : ret);
>> >> }
>> >>
>> >>--
>> >>1.7.12.1
>> >>
>> >>--
>> >>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> >>the body to majordomo@kvack.org.  For more info on Linux MM,
>> >>see: http://www.linux-mm.org/ .
>> >>Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>> >
>>
>>
>>
>>
>> Regards,
>> --
>> Raghavendra Prabhu
>> GPG Id : 0xD72BE977
>> Fingerprint: B93F EBCB 8E05 7039 CD3C A4B8 A616 DCA1 D72B E977
>> www: wnohang.net
>
>




Regards,
--=20
Raghavendra Prabhu
GPG Id : 0xD72BE977
Fingerprint: B93F EBCB 8E05 7039 CD3C A4B8 A616 DCA1 D72B E977
www: wnohang.net

--wq9mPyueHGvFACwf
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJQfZJzAAoJEKYW3KHXK+l3zwQH/3eFR6XhS8bpH+BN8DuED3x3
SsUQ1/C9rMJHVyU1xwCyLsvdXgUFmt2zyufsoRFZr91OAxwLOVOwZmanRfOLs/+m
KsJvGfxeFTvYev6RB1MpepxmjHhY6IajyvUL31EYNZzhvOlovciXobThLNl9u/N2
a6eQf96ORuO3MX+POko0snfC8EpkIfYn7HifIlJghf5PCoUXTkzWMjRY5FFL1M8X
tUO66Mk0VRfMncTkVTm2e9eQdahLfNrtQTG2Yhnnc1NMD/3uiuYgOPiE508OrATK
tr4lL+qPME6+ZMhSx7K9c8wpHbRaffP2BQYOoSpjX+muVuWp+VEcgMBLQM+oYNo=
=n59K
-----END PGP SIGNATURE-----

--wq9mPyueHGvFACwf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
