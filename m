Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id C00226B0062
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 22:28:59 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so10014773obb.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 19:28:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120611143808.GA30668@cmpxchg.org>
References: <1339411335-23326-1-git-send-email-hao.bigrat@gmail.com>
	<4FD5CC71.4060002@gmail.com>
	<20120611143808.GA30668@cmpxchg.org>
Date: Tue, 12 Jun 2012 10:28:58 +0800
Message-ID: <CAFZ0FUUUdE710e9WT7=Uv1EJgKxAXEBeEzKvShreuwbd-L5aqw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: fix ununiform page status when writing new file
 with small buffer
From: Robin Dong <hao.bigrat@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Robin Dong <sanbai@taobao.com>

2012/6/11 Johannes Weiner <hannes@cmpxchg.org>:
> On Mon, Jun 11, 2012 at 06:46:09AM -0400, KOSAKI Motohiro wrote:
>> (6/11/12 6:42 AM), Robin Dong wrote:
>> > From: Robin Dong<sanbai@taobao.com>
>> >
>> > When writing a new file with 2048 bytes buffer, such as write(fd, buff=
er, 2048), it will
>> > call generic_perform_write() twice for every page:
>> >
>> > =A0 =A0 write_begin
>> > =A0 =A0 mark_page_accessed(page)
>> > =A0 =A0 write_end
>> >
>> > =A0 =A0 write_begin
>> > =A0 =A0 mark_page_accessed(page)
>> > =A0 =A0 write_end
>> >
>> > The page 1~13th will be added to lru-pvecs in write_begin() and will *=
NOT* be added to
>> > active_list even they have be accessed twice because they are not Page=
LRU(page).
>> > But when page 14th comes, all pages in lru-pvecs will be moved to inac=
tive_list
>> > (by __lru_cache_add() ) in first write_begin(), now page 14th *is* Pag=
eLRU(page).
>> > And after second write_end() only page 14th =A0will be in active_list.
>> >
>> > In Hadoop environment, we do comes to this situation: after writing a =
file, we find
>> > out that only 14th, 28th, 42th... page are in active_list and others i=
n inactive_list. Now
>> > kswapd works, shrinks the inactive_list, the file only have 14th, 28th=
...pages in memory,
>> > the readahead request size will be broken to only 52k (13*4k), system'=
s performance falls
>> > dramatically.
>> >
>> > This problem can also replay by below steps (the machine has 8G memory=
):
>> >
>> > =A0 =A0 1. dd if=3D/dev/zero of=3D/test/file.out bs=3D1024 count=3D104=
8576
>> > =A0 =A0 2. cat another 7.5G file to /dev/null
>> > =A0 =A0 3. vmtouch -m 1G -v /test/file.out, it will show:
>> >
>> > =A0 =A0 /test/file.out
>> > =A0 =A0 [oooooooooooooooooooOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO]=
 187847/262144
>> >
>> > =A0 =A0 the 'o' means same pages are in memory but same are not.
>> >
>> >
>> > The solution for this problem is simple: the 14th page should be added=
 to lru_add_pvecs
>> > before mark_page_accessed() just as other pages.
>> >
>> > Signed-off-by: Robin Dong<sanbai@taobao.com>
>> > Reviewed-by: Minchan Kim<minchan@kernel.org>
>> > ---
>> > =A0 mm/swap.c | =A0 =A08 +++++++-
>> > =A0 1 file changed, 7 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/mm/swap.c b/mm/swap.c
>> > index 4e7e2ec..08e83ad 100644
>> > --- a/mm/swap.c
>> > +++ b/mm/swap.c
>> > @@ -394,13 +394,19 @@ void mark_page_accessed(struct page *page)
>> > =A0 }
>> > =A0 EXPORT_SYMBOL(mark_page_accessed);
>> >
>> > +/*
>> > + * Check pagevec space before adding new page into as
>> > + * it will prevent ununiform page status in
>> > + * mark_page_accessed() after __lru_cache_add()
>> > + */
>> > =A0 void __lru_cache_add(struct page *page, enum lru_list lru)
>> > =A0 {
>> > =A0 =A0 struct pagevec *pvec =3D&get_cpu_var(lru_add_pvecs)[lru];
>> >
>> > =A0 =A0 page_cache_get(page);
>> > - =A0 if (!pagevec_add(pvec, page))
>> > + =A0 if (!pagevec_space(pvec))
>> > =A0 =A0 =A0 =A0 =A0 =A0 __pagevec_lru_add(pvec, lru);
>> > + =A0 pagevec_add(pvec, page);
>> > =A0 =A0 put_cpu_var(lru_add_pvecs);
>> > =A0 }
>> > =A0 EXPORT_SYMBOL(__lru_cache_add);
>
> I agree with the patch, but I'm not too fond of the comment. =A0Would
> this be better perhaps?
>
> "Order of operation is important: flush the pagevec when it's already
> full, not when adding the last page, to make sure that last page is
> not added to the LRU directly when passed to this function. =A0Because
> mark_page_accessed() (called after this when writing) only activates
> pages that are on the LRU, linear writes in subpage chunks would see
> every PAGEVEC_SIZE page activated, which is unexpected."

Good suggestion.
Many thanks!

--=20
--
Best Regard
Robin Dong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
