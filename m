Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 417AD6B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 03:16:03 -0500 (EST)
Received: by iwn9 with SMTP id 9so707011iwn.14
        for <linux-mm@kvack.org>; Mon, 29 Nov 2010 00:16:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101129072951.GA22803@localhost>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
	<c3b1c78f0e2eba5dfebda7c363c4274e649ab36a.1290956059.git.minchan.kim@gmail.com>
	<20101129072951.GA22803@localhost>
Date: Mon, 29 Nov 2010 17:16:01 +0900
Message-ID: <AANLkTikuriwJr-UZg9=WXXwLt-u3sywkzkpZFBV1C4Db@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] move ClearPageReclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 4:29 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Sun, Nov 28, 2010 at 11:02:56PM +0800, Minchan Kim wrote:
>> fe3cba17 added ClearPageReclaim into clear_page_dirty_for_io for
>> preventing fast reclaiming readahead marker page.
>>
>> In this series, PG_reclaim is used by invalidated page, too.
>> If VM find the page is invalidated and it's dirty, it sets PG_reclaim
>> to reclaim asap. Then, when the dirty page will be writeback,
>> clear_page_dirty_for_io will clear PG_reclaim unconditionally.
>> It disturbs this serie's goal.
>>
>> I think it's okay to clear PG_readahead when the page is dirty, not
>> writeback time. So this patch moves ClearPageReadahead.
>> This patch needs Wu's opinion.
>
> It's a safe change. The possibility and consequence of races are both
> small enough. However the patch could be simplified as follows?

If all of file systems use it, I don't mind it.
Do all of filesystems use it when the page is dirtied?
I was not sure it.(It's why I added Cc. :)
If it doesn't have a problem, I hope so.

Thanks, Wu.

>
> Thanks,
> Fengguang
> ---
>
> --- linux-next.orig/mm/page-writeback.c 2010-11-29 15:14:54.000000000 +08=
00
> +++ linux-next/mm/page-writeback.c =A0 =A0 =A02010-11-29 15:15:02.0000000=
00 +0800
> @@ -1330,6 +1330,7 @@ int set_page_dirty(struct page *page)
> =A0{
> =A0 =A0 =A0 =A0struct address_space *mapping =3D page_mapping(page);
>
> + =A0 =A0 =A0 ClearPageReclaim(page);
> =A0 =A0 =A0 =A0if (likely(mapping)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int (*spd)(struct page *) =3D mapping->a_o=
ps->set_page_dirty;
> =A0#ifdef CONFIG_BLOCK
> @@ -1387,7 +1388,6 @@ int clear_page_dirty_for_io(struct page
>
> =A0 =A0 =A0 =A0BUG_ON(!PageLocked(page));
>
> - =A0 =A0 =A0 ClearPageReclaim(page);
> =A0 =A0 =A0 =A0if (mapping && mapping_cap_account_dirty(mapping)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Yes, Virginia, this is indeed insane.
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
