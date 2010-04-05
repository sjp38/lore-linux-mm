Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 85AC06B020D
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 04:27:00 -0400 (EDT)
Received: by pwi2 with SMTP id 2so2617828pwi.14
        for <linux-mm@kvack.org>; Mon, 05 Apr 2010 01:26:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100405071344.GC23515@logfs.org>
References: <alpine.LFD.2.00.1004041125350.5617@localhost>
	 <1270396784.1814.92.camel@barrios-desktop>
	 <20100404160328.GA30540@ioremap.net>
	 <1270398112.1814.114.camel@barrios-desktop>
	 <20100404195533.GA8836@logfs.org>
	 <p2g28c262361004041759n52f5063dhb182663321d918bb@mail.gmail.com>
	 <20100405053026.GA23515@logfs.org>
	 <x2w28c262361004042320x52dda2d1l30789cac28fbef6@mail.gmail.com>
	 <20100405071344.GC23515@logfs.org>
Date: Mon, 5 Apr 2010 17:26:58 +0900
Message-ID: <m2w28c262361004050126mbcbed77cha6f1085394802cb2@mail.gmail.com>
Subject: Re: why are some low-level MM routines being exported?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@logfs.org>
Cc: Evgeniy Polyakov <zbr@ioremap.net>, "Robert P. J. Day" <rpjday@crashcourse.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 5, 2010 at 4:13 PM, J=C3=B6rn Engel <joern@logfs.org> wrote:
> On Mon, 5 April 2010 15:20:36 +0900, Minchan Kim wrote:
>>
>> Previously I said, what I have a concern is that if file systems or
>> some modules abuses
>> add_to_page_cache_lru, it might system LRU list wrong so then system
>> go to hell.
>> Of course, if we use it carefully, it can be good but how do you make su=
re it?
>
> Having access to the source code means you only have to read all
> callers. =C2=A0This is not java, we don't have to add layers of anti-abus=
e
> wrappers. =C2=A0We can simply flame the first offender to a crisp. :)
>
>> I am not a file system expert but as I read comment of read_cache_pages
>> "Hides the details of the LRU cache etc from the filesystem", I
>> thought it is not good that
>> file system handle LRU list directly. At least, we have been trying for =
years.
>
> Only speaking for logfs, I need some variant of find_or_create_page
> where I can replace lock_page() with a custom function. =C2=A0Whether tha=
t
> function lives in fs/logfs/ or mm/filemap.c doesn't matter much.
>
> What we could do something roughly like the patch below, at least
> semantically. =C2=A0I know the patch is crap in its current form, but it
> illustrates the general idea.
>
> J=C3=B6rn
>
> --
> The key to performance is elegance, not battalions of special cases.
> -- Jon Bentley and Doug McIlroy
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 045b31c..6d452eb 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -646,27 +646,19 @@ repeat:
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(find_get_page);
>
> -/**
> - * find_lock_page - locate, pin and lock a pagecache page
> - * @mapping: the address_space to search
> - * @offset: the page index
> - *
> - * Locates the desired pagecache page, locks it, increments its referenc=
e
> - * count and returns its address.
> - *
> - * Returns zero if the page was not present. find_lock_page() may sleep.
> - */
> -struct page *find_lock_page(struct address_space *mapping, pgoff_t offse=
t)
> +static struct page *__find_lock_page(struct address_space *mapping,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgoff_t offset, void(*=
lock)(struct page *),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void(*unlock)(struct p=
age *))
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;
>
> =C2=A0repeat:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D find_get_page(mapping, offset);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lock_page(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lock(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Has the page be=
en truncated? */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(page-=
>mapping !=3D mapping)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 unlock_page(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 unlock(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0page_cache_release(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto repeat;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> @@ -674,32 +666,31 @@ repeat:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return page;
> =C2=A0}
> -EXPORT_SYMBOL(find_lock_page);
>
> =C2=A0/**
> - * find_or_create_page - locate or add a pagecache page
> - * @mapping: the page's address_space
> - * @index: the page's index into the mapping
> - * @gfp_mask: page allocation mode
> - *
> - * Locates a page in the pagecache. =C2=A0If the page is not present, a =
new page
> - * is allocated using @gfp_mask and is added to the pagecache and to the=
 VM's
> - * LRU list. =C2=A0The returned page is locked and has its reference cou=
nt
> - * incremented.
> + * find_lock_page - locate, pin and lock a pagecache page
> + * @mapping: the address_space to search
> + * @offset: the page index
> =C2=A0*
> - * find_or_create_page() may sleep, even if @gfp_flags specifies an atom=
ic
> - * allocation!
> + * Locates the desired pagecache page, locks it, increments its referenc=
e
> + * count and returns its address.
> =C2=A0*
> - * find_or_create_page() returns the desired page's address, or zero on
> - * memory exhaustion.
> + * Returns zero if the page was not present. find_lock_page() may sleep.
> =C2=A0*/
> -struct page *find_or_create_page(struct address_space *mapping,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgoff_t index, gfp_t g=
fp_mask)
> +struct page *find_lock_page(struct address_space *mapping, pgoff_t offse=
t)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return __find_lock_page(mapping, offset, lock_page=
, unlock_page);
> +}
> +EXPORT_SYMBOL(find_lock_page);
> +
> +static struct page *__find_or_create_page(struct address_space *mapping,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgoff_t index, gfp_t g=
fp_mask, void(*lock)(struct page *),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void(*unlock)(struct p=
age *))
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
> =C2=A0repeat:
> - =C2=A0 =C2=A0 =C2=A0 page =3D find_lock_page(mapping, index);
> + =C2=A0 =C2=A0 =C2=A0 page =3D __find_lock_page(mapping, index, lock, un=
lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D __page_ca=
che_alloc(gfp_mask);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page)
> @@ -721,6 +712,31 @@ repeat:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return page;
> =C2=A0}
> +EXPORT_SYMBOL(__find_or_create_page);
> +
> +/**
> + * find_or_create_page - locate or add a pagecache page
> + * @mapping: the page's address_space
> + * @index: the page's index into the mapping
> + * @gfp_mask: page allocation mode
> + *
> + * Locates a page in the pagecache. =C2=A0If the page is not present, a =
new page
> + * is allocated using @gfp_mask and is added to the pagecache and to the=
 VM's
> + * LRU list. =C2=A0The returned page is locked and has its reference cou=
nt
> + * incremented.
> + *
> + * find_or_create_page() may sleep, even if @gfp_flags specifies an atom=
ic
> + * allocation!
> + *
> + * find_or_create_page() returns the desired page's address, or zero on
> + * memory exhaustion.
> + */
> +struct page *find_or_create_page(struct address_space *mapping,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgoff_t index, gfp_t g=
fp_mask)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return __find_or_create_page(mapping, index, gfp_m=
ask, lock_page,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 unlock_page);
> +}
> =C2=A0EXPORT_SYMBOL(find_or_create_page);
>
> =C2=A0/**
>

Seem to be not bad idea. :)
But we have to justify new interface before. For doing it, we have to say
why we can't do it by current functions(find_get_page,
add_to_page_cache and pagevec_lru_add_xxx)

Pagevec_lru_add_xxx does batch so that it can reduce calling path and
some overhead(ex, page_is_file_cache comparison,
get/put_cpu_var(lru_add_pvecs)).

At least, it would be rather good than old for performance.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
