Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 06E506B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 05:36:03 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so372qwf.44
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 02:37:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090630092235.GA17561@csn.ul.ie>
References: <20090628142239.GA20986@localhost>
	 <20090628151026.GB25076@localhost>
	 <20090629091741.ab815ae7.minchan.kim@barrios-desktop>
	 <17678.1246270219@redhat.com> <20090629125549.GA22932@localhost>
	 <29432.1246285300@redhat.com>
	 <28c262360906290800v37f91d7av3642b1ad8b5f0477@mail.gmail.com>
	 <20090629160725.GF5065@csn.ul.ie>
	 <20090630130741.c191d042.minchan.kim@barrios-desktop>
	 <20090630092235.GA17561@csn.ul.ie>
Date: Tue, 30 Jun 2009 18:30:16 +0900
Message-ID: <28c262360906300230r627bd553m2d02979f0d3c0a8@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Howells <dhowells@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 6:22 PM, Mel Gorman<mel@csn.ul.ie> wrote:
> On Tue, Jun 30, 2009 at 01:07:41PM +0900, Minchan Kim wrote:
>> On Mon, 29 Jun 2009 17:07:25 +0100
>> Mel Gorman <mel@csn.ul.ie> wrote:
>>
>> > On Tue, Jun 30, 2009 at 12:00:26AM +0900, Minchan Kim wrote:
>> > > On Mon, Jun 29, 2009 at 11:21 PM, David Howells<dhowells@redhat.com>=
 wrote:
>> > > > Wu Fengguang <fengguang.wu@intel.com> wrote:
>> > > >
>> > > >> Sorry! This one compiles OK:
>> > > >
>> > > > Sadly that doesn't seem to work either:
>> > > >
>> > > > msgctl11 invoked oom-killer: gfp_mask=3D0x200da, order=3D0, oom_ad=
j=3D0
>> > > > msgctl11 cpuset=3D/ mems_allowed=3D0
>> > > > Pid: 30858, comm: msgctl11 Not tainted 2.6.31-rc1-cachefs #146
>> > > > Call Trace:
>> > > > =C2=A0[<ffffffff8107207e>] ? oom_kill_process.clone.0+0xa9/0x245
>> > > > =C2=A0[<ffffffff81072345>] ? __out_of_memory+0x12b/0x142
>> > > > =C2=A0[<ffffffff810723c6>] ? out_of_memory+0x6a/0x94
>> > > > =C2=A0[<ffffffff81074a90>] ? __alloc_pages_nodemask+0x42e/0x51d
>> > > > =C2=A0[<ffffffff81080843>] ? do_wp_page+0x2c6/0x5f5
>> > > > =C2=A0[<ffffffff810820c1>] ? handle_mm_fault+0x5dd/0x62f
>> > > > =C2=A0[<ffffffff81022c32>] ? do_page_fault+0x1f8/0x20d
>> > > > =C2=A0[<ffffffff812e069f>] ? page_fault+0x1f/0x30
>> > > > Mem-Info:
>> > > > DMA per-cpu:
>> > > > CPU =C2=A0 =C2=A00: hi: =C2=A0 =C2=A00, btch: =C2=A0 1 usd: =C2=A0=
 0
>> > > > CPU =C2=A0 =C2=A01: hi: =C2=A0 =C2=A00, btch: =C2=A0 1 usd: =C2=A0=
 0
>> > > > DMA32 per-cpu:
>> > > > CPU =C2=A0 =C2=A00: hi: =C2=A0186, btch: =C2=A031 usd: =C2=A038
>> > > > CPU =C2=A0 =C2=A01: hi: =C2=A0186, btch: =C2=A031 usd: 106
>> > > > Active_anon:75040 active_file:0 inactive_anon:2031
>> > > > =C2=A0inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
>> > > > =C2=A0free:1951 slab:41499 mapped:301 pagetables:60674 bounce:0
>> > > > DMA free:3932kB min:60kB low:72kB high:88kB active_anon:2868kB ina=
ctive_anon:384kB active_file:0kB inactive_file:0kB unevictable:0kB present:=
15364kB pages_scanned:0 all_unreclaimable? no
>> > > > lowmem_reserve[]: 0 968 968 968
>> > > > DMA32 free:3872kB min:3948kB low:4932kB high:5920kB active_anon:29=
7292kB inactive_anon:7740kB active_file:0kB inactive_file:0kB unevictable:0=
kB present:992032kB pages_scanned:0 all_unreclaimable? no
>> > > > lowmem_reserve[]: 0 0 0 0
>> > > > DMA: 7*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*10=
24kB 1*2048kB 0*4096kB =3D 3932kB
>> > > > DMA32: 500*4kB 2*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB =
1*1024kB 0*2048kB 0*4096kB =3D 3872kB
>> > > > 1928 total pagecache pages
>> > > > 0 pages in swap cache
>> > > > Swap cache stats: add 0, delete 0, find 0/0
>> > > > Free swap =C2=A0=3D 0kB
>> > > > Total swap =3D 0kB
>> > > > 255744 pages RAM
>> > > > 5589 pages reserved
>> > > > 238251 pages shared
>> > > > 216210 pages non-shared
>> > > > Out of memory: kill process 25221 (msgctl11) score 130560 or a chi=
ld
>> > > > Killed process 26379 (msgctl11)
>> > >
>> > > Totally, I can't understand this situation.
>> > > Now, this page allocation is order zero and It is just likely GFP_HI=
GHUSER.
>> > > So it's unlikely interrupt context.
>> >
>> > The GFP flags that are set are
>> >
>> > #define __GFP_HIGHMEM =C2=A0 =C2=A0 =C2=A0 (0x02)
>> > #define __GFP_MOVABLE =C2=A0 =C2=A0 =C2=A0 (0x08) =C2=A0/* Page is mov=
able */
>> > #define __GFP_WAIT =C2=A0(0x10) =C2=A0/* Can wait and reschedule? */
>> > #define __GFP_IO =C2=A0 =C2=A0(0x40) =C2=A0/* Can start physical IO? *=
/
>> > #define __GFP_FS =C2=A0 =C2=A0(0x80) =C2=A0/* Can call down to low-lev=
el FS? */
>> > #define __GFP_HARDWALL =C2=A0 (0x20000) /* Enforce hardwall cpuset mem=
ory allocs */
>> >
>> > which are fairly permissive in terms of what action can be taken.
>> >
>> > > Buddy already has enough fallback DMA32, I think.
>> >
>> > It doesn't really. We are below the minimum watermark. It wouldn't be
>> > able to grant the allocation until a few pages had been freed.
>>
>> Yes. I missed that.
>>
>> > > Why kernel can't allocate page for order 0 ?
>> > > Is it allocator bug ?
>> > >
>> >
>> > If it is, it is not because the allocation failed as the watermarks we=
re not
>> > being met. For this situation to be occuring, it has to be scanning th=
e LRU
>> > lists and making no forward progress. Odd things to note;
>> >
>> > o active_anon is very large in comparison to inactive_anon. Is this
>> > =C2=A0 because there is no swap and they are no longer being rotated?
>>
>> Yes. My patch's intention was that.
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0commit 69c854817566db82c362797b4a6521d0b00fe1=
d8
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0Author: MinChan Kim <minchan.kim@gmail.com>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0Date: =C2=A0 Tue Jun 16 15:32:44 2009 -0700
>>
>> > o Slab and pagetables are very large. Is slab genuinely unshrinkable?
>> >
>> > I think this system might be genuinely OOM. It can't reclaim memory an=
d
>> > we are below the minimum watermarks.
>> >
>> > Is it possible there are pages that are counted as active_anon that in
>> > fact are reclaimable because they are on the wrong LRU list? If that w=
as
>> > the case, the lack of rotation to inactive list would prevent them
>> > getting discovered.
>>
>> I agree.
>> One of them is that "[BUGFIX][PATCH] fix lumpy reclaim lru handiling at
>> isolate_lru_pages v2" as Kosaki already said.
>>
>> Unfortunately, David said it's not.
>> But I think your guessing make sense.
>>
>> David. Doesn't it happen OOM if you revert my patch, still?
>>
>
> In the event the OOM does not happen with the patch reverted, I suggest
> you put together a debugging patch that prints out details of all pages
> on the active_anon LRU list in the event of an OOM. The intention is to
> figure out what pages are on the active_anon list that shouldn't be.

Okay. But unfortunately, I will do it after the day after tomorrow. ;-(

> --
> Mel Gorman
> Part-time Phd Student =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linux Technology Center
> University of Limerick =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IBM Dublin Software Lab
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
