Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 930A36B0047
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 03:09:44 -0500 (EST)
Received: by pzk3 with SMTP id 3so49813pzk.11
        for <linux-mm@kvack.org>; Thu, 28 Jan 2010 00:09:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.00.1001272300120.2909@abydos.NerdBox.Net>
References: <20100120215536.GN27212@frostnet.net>
	 <20100121054734.GC24236@localhost>
	 <28c262361001262309x332a895aoa906dda0bc040859@mail.gmail.com>
	 <alpine.DEB.1.00.1001272300120.2909@abydos.NerdBox.Net>
Date: Thu, 28 Jan 2010 17:09:43 +0900
Message-ID: <28c262361001280009u509f169dnc558d013150ca00b@mail.gmail.com>
Subject: Re: [PATCH] mm/readahead.c: update the LRU positions of in-core
	pages, too
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Steve VanDeBogart <vandebo-lkml@nerdbox.net>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Chris Frost <frost@cs.ucla.edu>, Andrew Morton <akpm@linux-foundation.org>, Steve Dickson <steved@redhat.com>, David Howells <dhowells@redhat.com>, Xu Chenfeng <xcf@ustc.edu.cn>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 4:16 PM, Steve VanDeBogart
<vandebo-lkml@nerdbox.net> wrote:
> On Wed, 27 Jan 2010, Minchan Kim wrote:
>
>> This patch effect happens when inactive file list is small, I think.
>> It means it's high memory pressure. so if we move ra pages into
>
> This patch does the same thing regardless of memory pressure - it
> doesn't just apply in high memory pressure situations. =C2=A0Is your conc=
ern
> that in high memory pressure situations this patch with make things worse=
?

Yes.

>
>> head of inactive list, other application which require free page urgentl=
y
>> suffer from latency or are killed.
>
> I don't think this patch will affect the number of pages reclaimed, only
> which pages are reclaimed. =C2=A0In extreme cases it could increase the t=
ime

Most likely.
But it can affect the number of pages reclaimed at sometime.

For example,

scanning window size for reclaim =3D 5.
P : hard reclaimable page
R : readaheaded page(easily reclaimable page)

without this patch
HEAD-P - P - P - P ................ - P - R -R -R -R -R- TAIL

reclaimed pages : 5

with this patch
HEAD-R-R-R-R-R .................... - P -P -P -P -P -P -TAIL

reclaimed pages : 0 =3D> might be OOMed.

Yes. It's very extreme example.
it is just for explanation. :)

> needed to reclaim that many pages, but the inactive list would have to be
> very short.

I think short inactive list means now we are suffering from shortage of
free memory. So I think it would be better to discard ra pages rather than
OOMed.

>
>> If VM don't have this patch, of course ra pages are discarded and
>> then I/O performance would be bad. but as I mentioned, it's time
>> high memory pressure. so I/O performance low makes system
>> natural throttling. It can help out of =C2=A0system memory pressure.
>
> Even in low memory situations, improving I/O performance can help the
> overall system performance. =C2=A0For example if most of the inactive lis=
t is
> dirty, needlessly discarding pages, just to refetch them will clog
> I/O and increase the time needed to write out the dirty pages.

Yes. That's what I said.
But my point is that it makes system I/O throttling by clogging I/O natural=
ly.
It can prevent fast consumption of memory.
Actually I think mm don't have to consider I/O throttling as far as possibl=
e.
It's role of I/O subsystem. but it's not real.
There are some codes for I/O throttling in mm.

>
>> In summary I think it's good about viewpoint of I/O but I am not sure
>> it's good about viewpoint of system.
>
> In this case, I think what's good for I/O is good for the system.
> Please help me understand if I am missing something. =C2=A0Thanks

You didn't missed anything. :)
I don't know how this patch affect in low memory situation.
What we just need is experiment which is valuable.

Wu have a catch in my concern and are making new version.
I am looking forward to that.

>
> --
> Steve
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
