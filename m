Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6DA4E6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 19:01:46 -0400 (EDT)
Received: by qwa26 with SMTP id 26so828162qwa.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 16:01:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110602223201.GH2802@random.random>
References: <20110531121620.GA3490@barrios-laptop>
	<20110531122437.GJ19505@random.random>
	<20110531133340.GB3490@barrios-laptop>
	<20110531141402.GK19505@random.random>
	<20110531143734.GB13418@barrios-laptop>
	<20110531143830.GC13418@barrios-laptop>
	<20110602182302.GA2802@random.random>
	<20110602202156.GA23486@barrios-laptop>
	<20110602214041.GF2802@random.random>
	<BANLkTim1WjdHWOQp7bMg5pFFKp1SSFoLKw@mail.gmail.com>
	<20110602223201.GH2802@random.random>
Date: Fri, 3 Jun 2011 08:01:44 +0900
Message-ID: <BANLkTikA+ugFNS95Zs_o6QqG2u4r2g93=Q@mail.gmail.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 3, 2011 at 7:32 AM, Andrea Arcangeli <aarcange@redhat.com> wrot=
e:
> On Fri, Jun 03, 2011 at 07:23:48AM +0900, Minchan Kim wrote:
>> I mean we have more tail pages than head pages. So I think we are likely=
 to
>> meet tail pages. Of course, compared to all pages(page cache, anon and
>> so on), compound pages would be very small percentage.
>
> Yes that's my point, that being a small percentage it's no big deal to
> break the loop early.

Indeed.

>
>> > isolated the head and it's useless to insist on more tail pages (at
>> > least for large page size like on x86). Plus we've compaction so
>>
>> I can't understand your point. Could you elaborate it?
>
> What I meant is that if we already isolated the head page of the THP,
> we don't need to try to free the tail pages and breaking the loop
> early, will still give us a chance to free a whole 2m because we
> isolated the head page (it'll involve some work and swapping but if it
> was a compoundtranspage we're ok to break the loop and we're not
> making the logic any worse). Provided the PMD_SIZE is quite large like
> 2/4m...

Do you want this? (it's almost pseudo-code)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7a4469b..9d7609f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1017,7 +1017,7 @@ static unsigned long isolate_lru_pages(unsigned
long nr_to_scan,
        for (scan =3D 0; scan < nr_to_scan && !list_empty(src); scan++) {
                struct page *page;
                unsigned long pfn;
-               unsigned long end_pfn;
+               unsigned long start_pfn, end_pfn;
                unsigned long page_pfn;
                int zone_id;

@@ -1057,9 +1057,9 @@ static unsigned long isolate_lru_pages(unsigned
long nr_to_scan,
                 */
                zone_id =3D page_zone_id(page);
                page_pfn =3D page_to_pfn(page);
-               pfn =3D page_pfn & ~((1 << order) - 1);
+               start_pfn =3D pfn =3D page_pfn & ~((1 << order) - 1);
                end_pfn =3D pfn + (1 << order);
-               for (; pfn < end_pfn; pfn++) {
+               while (pfn < end_pfn) {
                        struct page *cursor_page;

                        /* The target page is in the block, ignore it. */
@@ -1086,17 +1086,25 @@ static unsigned long
isolate_lru_pages(unsigned long nr_to_scan,
                                break;

                        if (__isolate_lru_page(cursor_page, mode, file) =3D=
=3D 0) {
+                               int isolated_pages;
                                list_move(&cursor_page->lru, dst);
                                mem_cgroup_del_lru(cursor_page);
-                               nr_taken +=3D hpage_nr_pages(page);
+                               isolated_pages =3D hpage_nr_pages(page);
+                               nr_taken +=3D isolated_pages;
+                               /* if we isolated pages enough, let's
break early */
+                               if (nr_taken > end_pfn - start_pfn)
+                                       break;
+                               pfn +=3D isolated_pages;
                                nr_lumpy_taken++;
                                if (PageDirty(cursor_page))
                                        nr_lumpy_dirty++;
                                scan++;
                        } else {
                                /* the page is freed already. */
-                               if (!page_count(cursor_page))
+                               if (!page_count(cursor_page)) {
+                                       pfn++;
                                        continue;
+                               }
                                break;
                        }
                }

>
> The only way this patch makes things worse is for slub order 3 in the
> process of being freed. But tail pages aren't generally free anyway so
> I doubt this really makes any difference plus the tail is getting
> cleared as soon as the page reaches the buddy so it's probably

Okay. Considering getting clear PG_tail as soon as slub order 3 is
freed, it would be very rare case.

> unnoticeable as this then makes a difference only during a race (plus
> the tail page can't be isolated, only head page can be part of lrus
> and only if they're THP).
>
>> > insisting and screwing lru ordering isn't worth it, better to be
>> > permissive and abort... in fact I wouldn't dislike to remove the
>> > entire lumpy logic when COMPACTION_BUILD is true, but that alters the
>> > trace too...
>>
>> AFAIK, it's final destination to go as compaction will not break lru
>> ordering if my patch(inorder-putback) is merged.
>
> Agreed. I like your patchset, sorry for not having reviewed it in
> detail yet but there were other issues popping up in the last few
> days.

No problem. it's urgent than mine. :)

>
>> >> get_page(cursor_page)
>> >> /* The page is freed already */
>> >> if (1 =3D=3D page_count(cursor_page)) {
>> >> =C2=A0 =C2=A0 =C2=A0 put_page(cursor_page)
>> >> =C2=A0 =C2=A0 =C2=A0 continue;
>> >> }
>> >> put_page(cursor_page);
>> >
>> > We can't call get_page on an tail page or we break split_huge_page,
>>
>> Why don't we call get_page on tail page if tail page isn't free?
>> Maybe I need investigating split_huge_page.
>
> Yes it's split_huge_page, only gup is allowed to increase the tail
> page because we're guaranteed while gup_fast does it,
> split_huge_page_refcount isn't running yet, because the pmd wasn't
> set as splitting and the irqs were disabled (or we'd be holding the
> page_table_lock for gup slow version after checking again the pmd
> wasn't splitting and so __split_huge_page_refcount will wait).

Thanks. I will have a time to understand your point with reviewing
split_huge_page and your this comment.

You convinced me and made me think thing I didn't think about which
are good points.
Thanks, Andrea.

>
> Thanks,
> Andrea
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
