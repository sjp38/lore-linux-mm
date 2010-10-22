Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DBF8C6B004A
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 22:48:52 -0400 (EDT)
Received: by gxk4 with SMTP id 4so246640gxk.14
        for <linux-mm@kvack.org>; Thu, 21 Oct 2010 19:48:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101021142534.GB9709@localhost>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
	<1287667701-8081-2-git-send-email-lliubbo@gmail.com>
	<20101021142534.GB9709@localhost>
Date: Fri, 22 Oct 2010 10:48:51 +0800
Message-ID: <AANLkTi=zJV52imMNHEhftsBdyL1-8W30+tpZpY_yaj_s@mail.gmail.com>
Subject: Re: [PATCH 2/3] do_migrate_range: exit loop if not_managed is true.
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 10:25 PM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> On Thu, Oct 21, 2010 at 09:28:20PM +0800, Bob Liu wrote:
>> If not_managed is true all pages will be putback to lru, so
>> break the loop earlier to skip other pages isolate.
>
> It's good fix in itself. However it's normal for isolate_lru_page() to
> fail at times (when there are active reclaimers). The failures are
> typically temporal and may well go away when offline_pages() retries
> the call. So it seems more reasonable to migrate as much as possible
> to increase the chance of complete success in next retry.
>

Hi, Wu

The original code will try to migrate pages as much as possible except
page_count(page) is true.
If page_count(page) is true, isolate more pages is mean-less, because
all of them will
be put back after the loop.

Or maybe we can skip the page_count() check?  It seems unreasonable,
if isolate one page failed and
that page was in use why it needs to put back the whole isolated list?

Thanks

>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>> =C2=A0mm/memory_hotplug.c | =C2=A0 10 ++++++----
>> =C2=A01 files changed, 6 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index d4e940a..4f72184 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -709,15 +709,17 @@ do_migrate_range(unsigned long start_pfn, unsigned=
 long end_pfn)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 page_is_file_cache(page));
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
/* Becasue we don't have big zone->lock. we should
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0check this again here. */
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (page_count(page))
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 not_managed++;
>> =C2=A0#ifdef CONFIG_DEBUG_VM
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pfn);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 dump_page(page);
>> =C2=A0#endif
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
/* Becasue we don't have big zone->lock. we should
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0check this again here. */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (page_count(page)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 not_managed++;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
}
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 ret =3D -EBUSY;
>> --
>> 1.5.6.3
>
--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
