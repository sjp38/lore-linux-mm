Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 51CC46B00B4
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 21:58:52 -0500 (EST)
Received: by iyj17 with SMTP id 17so1921754iyj.14
        for <linux-mm@kvack.org>; Sun, 19 Dec 2010 18:58:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101220112733.064f2fe3.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
	<02ab98b3a1450f7a1c31edc48ccc57e887cee900.1292604746.git.minchan.kim@gmail.com>
	<20101220112227.E566.A69D9226@jp.fujitsu.com>
	<20101220112733.064f2fe3.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 20 Dec 2010 11:58:50 +0900
Message-ID: <AANLkTi=UfmZNfKWCisrs6ezzoWqpcwUOT5bs8LGwN7Rv@mail.gmail.com>
Subject: Re: [RFC 5/5] truncate: Remove unnecessary page release
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 20, 2010 at 11:27 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 20 Dec 2010 11:21:52 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>
>> > This patch series changes remove_from_page_cache's page ref counting
>> > rule. page cache ref count is decreased in remove_from_page_cache.
>> > So we don't need call again in caller context.
>> >
>> > Cc: Nick Piggin <npiggin@suse.de>
>> > Cc: Al Viro <viro@zeniv.linux.org.uk>
>> > Cc: linux-mm@kvack.org
>> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> > ---
>> > =A0mm/truncate.c | =A0 =A01 -
>> > =A01 files changed, 0 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/mm/truncate.c b/mm/truncate.c
>> > index 9ee5673..8decb93 100644
>> > --- a/mm/truncate.c
>> > +++ b/mm/truncate.c
>> > @@ -114,7 +114,6 @@ truncate_complete_page(struct address_space *mappi=
ng, struct page *page)
>> > =A0 =A0 =A0* calls cleancache_put_page (and note page->mapping is now =
NULL)
>> > =A0 =A0 =A0*/
>> > =A0 =A0 cleancache_flush_page(mapping, page);
>> > - =A0 page_cache_release(page); =A0 =A0 =A0 /* pagecache ref */
>> > =A0 =A0 return 0;
>>
>> Do we _always_ have stable page reference here? IOW, I can assume
>> cleancache_flush_page() doesn't cause NULL deref?
>>
> Hmm, my review was bad.
>
> I think cleancache_flush_page() here should eat (mapping, index) as argum=
ent
> rather than "page".
>
> BTW, =A0I can't understand
> =3D=3D
> void __cleancache_flush_page(struct address_space *mapping, struct page *=
page)
> {
> =A0 =A0 =A0 =A0/* careful... page->mapping is NULL sometimes when this is=
 called */
> =A0 =A0 =A0 =A0int pool_id =3D mapping->host->i_sb->cleancache_poolid;
> =A0 =A0 =A0 =A0struct cleancache_filekey key =3D { .u.key =3D { 0 } };
> =3D=3D
>
> Why above is safe...
> I think (mapping,index) should be passed instead of page.

I don't think current code isn't safe.

void __cleancache_flush_page(struct address_space *mapping, struct page *pa=
ge)
{
        /* careful... page->mapping is NULL sometimes when this is called *=
/
        int pool_id =3D mapping->host->i_sb->cleancache_poolid;
        struct cleancache_filekey key =3D { .u.key =3D { 0 } };

        if (pool_id >=3D 0) {
                VM_BUG_ON(!PageLocked(page));

it does check PageLocked. So caller should hold a page reference to
prevent freeing ramined PG_locked
If the caller doesn't hold a ref of page, I think it's BUG of caller.

In our case, caller calls truncate_complete_page have to make sure it, I th=
ink.

>
>
> -Kame
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
