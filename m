Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9F6686B01AC
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 07:24:58 -0400 (EDT)
Received: by iwn2 with SMTP id 2so5660712iwn.14
        for <linux-mm@kvack.org>; Tue, 06 Jul 2010 04:24:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100706101235.GE13780@csn.ul.ie>
References: <20100702125155.69c02f85.akpm@linux-foundation.org>
	<20100705134949.GC13780@csn.ul.ie>
	<20100706093529.CCD1.A69D9226@jp.fujitsu.com>
	<20100706101235.GE13780@csn.ul.ie>
Date: Tue, 6 Jul 2010 20:24:57 +0900
Message-ID: <AANLkTin8FotAC1GvjuoYU9XA2eiSr6FWWh6bwypTdhq3@mail.gmail.com>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi, Mel.

On Tue, Jul 6, 2010 at 7:12 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Tue, Jul 06, 2010 at 09:36:41AM +0900, KOSAKI Motohiro wrote:
>> Hello,
>>
>> > Ok, that's reasonable as I'm still working on that patch. For example,=
 the
>> > patch disabled anonymous page writeback which is unnecessary as the st=
ack
>> > usage for anon writeback is less than file writeback.
>>
>> How do we examine swap-on-file?
>>
>
> Anything in particular wrong with the following?
>
> /*
> =C2=A0* For now, only kswapd can writeback filesystem pages as otherwise
> =C2=A0* there is a stack overflow risk
> =C2=A0*/
> static inline bool reclaim_can_writeback(struct scan_control *sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pa=
ge *page)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return !page_is_file_cache(page) || current_is=
_kswapd();
> }
>
> Even if it is a swapfile, I didn't spot a case where the filesystems
> writepage would be called. Did I miss something?


As I understand Kosaki's opinion, He said that if we make swapout in
pageout, it isn't a problem in case of swap device since swapout of
block device is light but it is still problem in case of swap file.
That's because swapout on swapfile cause file system writepage which
makes kernel stack overflow.

Do I misunderstand kosaki's point?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
