Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5DEC56B0071
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 04:41:43 -0400 (EDT)
Received: by wyf23 with SMTP id 23so575736wyf.14
        for <linux-mm@kvack.org>; Fri, 22 Oct 2010 01:41:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101022032244.GA13018@localhost>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
	<1287667701-8081-2-git-send-email-lliubbo@gmail.com>
	<20101021142534.GB9709@localhost>
	<AANLkTi=zJV52imMNHEhftsBdyL1-8W30+tpZpY_yaj_s@mail.gmail.com>
	<20101022032244.GA13018@localhost>
Date: Fri, 22 Oct 2010 16:41:40 +0800
Message-ID: <AANLkTinbKadf9FL1y86yUSzJeLN-M2mAqapGUNuC4gaJ@mail.gmail.com>
Subject: Re: [PATCH 2/3] do_migrate_range: exit loop if not_managed is true.
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2010 at 11:22 AM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> On Fri, Oct 22, 2010 at 10:48:51AM +0800, Bob Liu wrote:
>> On Thu, Oct 21, 2010 at 10:25 PM, Wu Fengguang <fengguang.wu@intel.com> =
wrote:
>> > On Thu, Oct 21, 2010 at 09:28:20PM +0800, Bob Liu wrote:
>> >> If not_managed is true all pages will be putback to lru, so
>> >> break the loop earlier to skip other pages isolate.
>> >
>> > It's good fix in itself. However it's normal for isolate_lru_page() to
>> > fail at times (when there are active reclaimers). The failures are
>> > typically temporal and may well go away when offline_pages() retries
>> > the call. So it seems more reasonable to migrate as much as possible
>> > to increase the chance of complete success in next retry.
>> >
>>
>> Hi, Wu
>>
>> The original code will try to migrate pages as much as possible except
>> page_count(page) is true.
>> If page_count(page) is true, isolate more pages is mean-less, because
>> all of them will
>> be put back after the loop.
>>
>> Or maybe we can skip the page_count() check? =C2=A0It seems unreasonable=
,
>> if isolate one page failed and
>> that page was in use why it needs to put back the whole isolated list?
>
> My suggestion was to keep the page_count() check and remove
> putback_lru_pages() and call migrate_pages() regardless of
> not_managed.
>

If not_managed is no more used, page_count() will also meanless.
You mean patch like this:
=3D=3D
@@ -687,7 +687,6 @@
 	unsigned long pfn;
 	struct page *page;
 	int move_pages =3D NR_OFFLINE_AT_ONCE_PAGES;
-	int not_managed =3D 0;
 	int ret =3D 0;
 	LIST_HEAD(source);

@@ -709,10 +708,6 @@
 					    page_is_file_cache(page));

 		} else {
-			/* Becasue we don't have big zone->lock. we should
-			   check this again here. */
-			if (page_count(page))
-				not_managed++;
 #ifdef CONFIG_DEBUG_VM
 			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
 			       pfn);
@@ -720,12 +715,6 @@
 #endif
 		}
 	}
-	ret =3D -EBUSY;
-	if (not_managed) {
-		if (!list_empty(&source))
-			putback_lru_pages(&source);
-		goto out;
-	}
 	ret =3D 0;
 	if (list_empty(&source))
 		goto out;
=3D=3D
Thanks,

> Does that make sense for typical memory hot remove scenarios?
> That will increase the possibility of success at the cost of some more
> migrated pages in case memory offline fails.
>
> Thanks,
> Fengguang
>
>> >> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> >> ---
>> >> =C2=A0mm/memory_hotplug.c | =C2=A0 10 ++++++----
>> >> =C2=A01 files changed, 6 insertions(+), 4 deletions(-)
>> >>
>> >> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> >> index d4e940a..4f72184 100644
>> >> --- a/mm/memory_hotplug.c
>> >> +++ b/mm/memory_hotplug.c
>> >> @@ -709,15 +709,17 @@ do_migrate_range(unsigned long start_pfn, unsig=
ned long end_pfn)
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 page_is_file_cache(page));
>> >>
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else {
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* Becasue we don't have big zone->lock. we should
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0check this again here. */
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (page_count(page))
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 not_managed++;
>> >> =C2=A0#ifdef CONFIG_DEBUG_VM
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pfn);
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 dump_page(page);
>> >> =C2=A0#endif
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* Becasue we don't have big zone->lock. we should
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0check this again here. */
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (page_count(page)) {
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 not_managed++;
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 }
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> >> =C2=A0 =C2=A0 =C2=A0 }
>> >> =C2=A0 =C2=A0 =C2=A0 ret =3D -EBUSY;
>> >> --
--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
