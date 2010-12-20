Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B58BB6B00B5
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 22:31:57 -0500 (EST)
Received: by iwn40 with SMTP id 40so2825222iwn.14
        for <linux-mm@kvack.org>; Sun, 19 Dec 2010 19:31:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101220120218.E56F.A69D9226@jp.fujitsu.com>
References: <20101220113239.E56C.A69D9226@jp.fujitsu.com>
	<AANLkTikOu6xUs3e_gEubidwSc_kQVuTKask+1WcCjzFs@mail.gmail.com>
	<20101220120218.E56F.A69D9226@jp.fujitsu.com>
Date: Mon, 20 Dec 2010 12:31:55 +0900
Message-ID: <AANLkTikaTAsU9yVpdDriJ9LmUhGQoNp06f6ZMF+wJKcX@mail.gmail.com>
Subject: Re: [RFC 5/5] truncate: Remove unnecessary page release
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 20, 2010 at 12:03 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Mon, Dec 20, 2010 at 11:32 AM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> On Mon, Dec 20, 2010 at 11:21 AM, KOSAKI Motohiro
>> >> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> >> This patch series changes remove_from_page_cache's page ref counti=
ng
>> >> >> rule. page cache ref count is decreased in remove_from_page_cache.
>> >> >> So we don't need call again in caller context.
>> >> >>
>> >> >> Cc: Nick Piggin <npiggin@suse.de>
>> >> >> Cc: Al Viro <viro@zeniv.linux.org.uk>
>> >> >> Cc: linux-mm@kvack.org
>> >> >> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> >> >> ---
>> >> >> =A0mm/truncate.c | =A0 =A01 -
>> >> >> =A01 files changed, 0 insertions(+), 1 deletions(-)
>> >> >>
>> >> >> diff --git a/mm/truncate.c b/mm/truncate.c
>> >> >> index 9ee5673..8decb93 100644
>> >> >> --- a/mm/truncate.c
>> >> >> +++ b/mm/truncate.c
>> >> >> @@ -114,7 +114,6 @@ truncate_complete_page(struct address_space *m=
apping, struct page *page)
>> >> >> =A0 =A0 =A0 =A0* calls cleancache_put_page (and note page->mapping=
 is now NULL)
>> >> >> =A0 =A0 =A0 =A0*/
>> >> >> =A0 =A0 =A0 cleancache_flush_page(mapping, page);
>> >> >> - =A0 =A0 page_cache_release(page); =A0 =A0 =A0 /* pagecache ref *=
/
>> >> >> =A0 =A0 =A0 return 0;
>> >> >
>> >> > Do we _always_ have stable page reference here? IOW, I can assume
>> >>
>> >> I think so.
>> >> Because the page is locked so caller have to hold a ref to unlock it.
>> >
>> > Hmm...
>> >
>> > Perhaps, I'm missing something. But I think =A0__memory_failure() only=
 lock
>> > compaund_head page. not all. example.
>>
>> The page passed truncate_complete_page is only head page?
>> Is it possible to pass the page which isn't head of compound in
>> truncate_complete_page?
>
> I dunno, really. My five miniture grep found following logic. therefore I=
 asked you.
>
>
>
> __memory_failure()
> {
> =A0 =A0 =A0 =A0p =3D pfn_to_page(pfn);
> =A0 =A0 =A0 =A0hpage =3D compound_head(p);
> (snip)
> =A0 =A0 =A0 =A0res =3D -EBUSY;
> =A0 =A0 =A0 =A0for (ps =3D error_states;; ps++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((p->flags & ps->mask) =3D=3D ps->res) =
{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res =3D page_action(ps, p,=
 pfn); =A0// call truncate here
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> out:
> =A0 =A0 =A0 =A0unlock_page(hpage);
> }
>
>

AFAIK, We have to handle head page when we handle compound page.
Internal page handling logic about tail pages is hidden by compound
page internal.

So I think memory_failure also don't have a problem.
For needing double check, Cced Andi.

Thanks for the review, KOSAKI.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
