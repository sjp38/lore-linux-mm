Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 5B4D96B004D
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 12:19:51 -0500 (EST)
MIME-Version: 1.0
Message-ID: <b5b5a961-85e5-4ce1-8280-7ca382cb0e0f@default>
Date: Wed, 11 Jan 2012 09:19:35 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
References: <<1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>>
 <<1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com>>
In-Reply-To: <<1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation librar=
y
>=20
> From: Nitin Gupta <ngupta@vflare.org>
>=20
> This patch creates a new memory allocation library named
> zsmalloc.
>=20
> +/*
> + * Allocate a zspage for the given size class
> + */
> +static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
> +{
> +=09int i, error;
> +=09struct page *first_page =3D NULL;
> +
> +=09/*
> +=09 * Allocate individual pages and link them together as:
> +=09 * 1. first page->private =3D first sub-page
> +=09 * 2. all sub-pages are linked together using page->lru
> +=09 * 3. each sub-page is linked to the first page using page->first_pag=
e
> +=09 *
> +=09 * For each size class, First/Head pages are linked together using
> +=09 * page->lru. Also, we set PG_private to identify the first page
> +=09 * (i.e. no other sub-page has this flag set) and PG_private_2 to
> +=09 * identify the last page.
> +=09 */
> +=09error =3D -ENOMEM;
> +=09for (i =3D 0; i < class->zspage_order; i++) {
> +=09=09struct page *page, *prev_page;
> +
> +=09=09page =3D alloc_page(flags);

Hmmm... I thought we agreed offlist that the new allocator API would
provide for either preloads or callbacks (which may differ per pool)
instead of directly allocating raw pages from the kernel.  The caller
(zcache or ramster or ???) needs to be able to somehow manage maximum
memory capacity to avoid OOMs.

Or am I missing the code that handles that?

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
