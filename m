Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A629F6B005C
	for <linux-mm@kvack.org>; Sun, 17 May 2009 23:34:59 -0400 (EDT)
Received: by gxk20 with SMTP id 20so6057657gxk.14
        for <linux-mm@kvack.org>; Sun, 17 May 2009 20:35:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090518031536.GC5869@localhost>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com>
	 <20090513120606.587C.A69D9226@jp.fujitsu.com>
	 <20090518031536.GC5869@localhost>
Date: Mon, 18 May 2009 12:35:31 +0900
Message-ID: <2f11576a0905172035k3f26b8d6r84af555a94b1d70e@mail.gmail.com>
Subject: Re: [PATCH 1/4] vmscan: change the number of the unmapped files in
	zone reclaim
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2397,6 +2397,7 @@ static int __zone_reclaim(struct zone *z
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .isolate_pages =3D isolate_pages_global,
>> =A0 =A0 =A0 };
>> =A0 =A0 =A0 unsigned long slab_reclaimable;
>> + =A0 =A0 long nr_unmapped_file_pages;
>>
>> =A0 =A0 =A0 disable_swap_token();
>> =A0 =A0 =A0 cond_resched();
>> @@ -2409,9 +2410,11 @@ static int __zone_reclaim(struct zone *z
>> =A0 =A0 =A0 reclaim_state.reclaimed_slab =3D 0;
>> =A0 =A0 =A0 p->reclaim_state =3D &reclaim_state;
>>
>> - =A0 =A0 if (zone_page_state(zone, NR_FILE_PAGES) -
>> - =A0 =A0 =A0 =A0 =A0 =A0 zone_page_state(zone, NR_FILE_MAPPED) >
>> - =A0 =A0 =A0 =A0 =A0 =A0 zone->min_unmapped_pages) {
>> + =A0 =A0 nr_unmapped_file_pages =3D zone_page_state(zone, NR_INACTIVE_F=
ILE) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone_page_s=
tate(zone, NR_ACTIVE_FILE) -
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone_page_s=
tate(zone, NR_FILE_MAPPED);
>
> This can possibly go negative.

Is this a problem?
negative value mean almost pages are mapped. Thus

  (nr_unmapped_file_pages > zone->min_unmapped_pages)  =3D> 0

is ok, I think.

>
>> + =A0 =A0 if (nr_unmapped_file_pages > zone->min_unmapped_pages) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Free memory by calling shrink zone with=
 increasing
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* priorities until we have enough memory =
freed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
