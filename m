Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 486346B0055
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:08:19 -0400 (EDT)
Received: by vwj42 with SMTP id 42so2435017vwj.12
        for <linux-mm@kvack.org>; Sun, 05 Jul 2009 07:51:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090705211127.0917.A69D9226@jp.fujitsu.com>
References: <20090705182451.08FF.A69D9226@jp.fujitsu.com>
	 <20090705121003.GB5252@localhost>
	 <20090705211127.0917.A69D9226@jp.fujitsu.com>
Date: Sun, 5 Jul 2009 23:51:46 +0900
Message-ID: <28c262360907050751t1fccbf4t4ace572b4e003a13@mail.gmail.com>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 5, 2009 at 9:23 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Sun, Jul 05, 2009 at 05:25:32PM +0800, KOSAKI Motohiro wrote:
>> > Subject: [PATCH] add isolate pages vmstat
>> >
>> > If the system have plenty threads or processes, concurrent reclaim can
>> > isolate very much pages.
>> > Unfortunately, current /proc/meminfo and OOM log can't show it.
>> >
>> > This patch provide the way of showing this information.
>> >
>> >
>> > reproduce way
>> > -----------------------
>> > % ./hackbench 140 process 1000
>> > =C2=A0 =C2=A0=3D> couse OOM
>> >
>> > Active_anon:4419 active_file:120 inactive_anon:1418
>> > =C2=A0inactive_file:61 unevictable:0 isolated:45311
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0^^^^^
>> > =C2=A0dirty:0 writeback:580 unstable:0
>> > =C2=A0free:27 slab_reclaimable:297 slab_unreclaimable:4050
>> > =C2=A0mapped:221 kernel_stack:5758 pagetables:28219 bounce:0
>> >
>> >
>> >
>> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> > ---
>> > =C2=A0drivers/base/node.c =C2=A0 =C2=A0| =C2=A0 =C2=A02 ++
>> > =C2=A0fs/proc/meminfo.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 ++
>> > =C2=A0include/linux/mmzone.h | =C2=A0 =C2=A01 +
>> > =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A06 ++++=
--
>> > =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =
=C2=A04 ++++
>> > =C2=A0mm/vmstat.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =
=C2=A02 +-
>> > =C2=A06 files changed, 14 insertions(+), 3 deletions(-)
>> >
>> > Index: b/fs/proc/meminfo.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- a/fs/proc/meminfo.c
>> > +++ b/fs/proc/meminfo.c
>> > @@ -65,6 +65,7 @@ static int meminfo_proc_show(struct seq_
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "Active(file): =C2=A0 %8lu k=
B\n"
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "Inactive(file): %8lu kB\n"
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "Unevictable: =C2=A0 =C2=A0%=
8lu kB\n"
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "IsolatedPages: =C2=A0%8lu kB\n"
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "Mlocked: =C2=A0 =C2=A0 =C2=
=A0 =C2=A0%8lu kB\n"
>> > =C2=A0#ifdef CONFIG_HIGHMEM
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "HighTotal: =C2=A0 =C2=A0 =
=C2=A0%8lu kB\n"
>> > @@ -109,6 +110,7 @@ static int meminfo_proc_show(struct seq_
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 K(pages[LRU_ACTIVE_FILE]),
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 K(pages[LRU_INACTIVE_FILE]),
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 K(pages[LRU_UNEVICTABLE]),
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 K(global_page_state(NR_ISOLATED))=
,
>>
>> Glad to see you renamed it to NR_ISOLATED :)
>> But for the user visible name, how about IsolatedLRU?
>
> Ah, nice. =C2=A0below is update patch.
>
> Changelog
> ----------------
> =C2=A0since v1
> =C2=A0 =C2=A0- rename "IsolatedPages" to "IsolatedLRU"
>
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Subject: [PATCH] add isolate pages vmstat
>
> If the system have plenty threads or processes, concurrent reclaim can
> isolate very much pages.
> Unfortunately, current /proc/meminfo and OOM log can't show it.
>
> This patch provide the way of showing this information.
>
>
> reproduce way
> -----------------------
> % ./hackbench 140 process 1000
> =C2=A0 =3D> couse OOM
>
> Active_anon:4419 active_file:120 inactive_anon:1418
> =C2=A0inactive_file:61 unevictable:0 isolated:45311
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ^^^^^
> =C2=A0dirty:0 writeback:580 unstable:0
> =C2=A0free:27 slab_reclaimable:297 slab_unreclaimable:4050
> =C2=A0mapped:221 kernel_stack:5758 pagetables:28219 bounce:0
>
>
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> =C2=A0drivers/base/node.c =C2=A0 =C2=A0| =C2=A0 =C2=A02 ++
> =C2=A0fs/proc/meminfo.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 ++
> =C2=A0include/linux/mmzone.h | =C2=A0 =C2=A01 +
> =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A06 ++++--
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=
=A04 ++++
> =C2=A0mm/vmstat.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=
=A02 +-
> =C2=A06 files changed, 14 insertions(+), 3 deletions(-)
>
> Index: b/fs/proc/meminfo.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -65,6 +65,7 @@ static int meminfo_proc_show(struct seq_
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"Active(file): =C2=
=A0 %8lu kB\n"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"Inactive(file): %=
8lu kB\n"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"Unevictable: =C2=
=A0 =C2=A0%8lu kB\n"
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "IsolatedLRU: =C2=A0 =
=C2=A0%8lu kB\n"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"Mlocked: =C2=A0 =
=C2=A0 =C2=A0 =C2=A0%8lu kB\n"
> =C2=A0#ifdef CONFIG_HIGHMEM
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"HighTotal: =C2=A0=
 =C2=A0 =C2=A0%8lu kB\n"
> @@ -109,6 +110,7 @@ static int meminfo_proc_show(struct seq_
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0K(pages[LRU_ACTIVE=
_FILE]),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0K(pages[LRU_INACTI=
VE_FILE]),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0K(pages[LRU_UNEVIC=
TABLE]),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 K(global_page_state(NR=
_ISOLATED)),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0K(global_page_stat=
e(NR_MLOCK)),
> =C2=A0#ifdef CONFIG_HIGHMEM
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0K(i.totalhigh),
> Index: b/include/linux/mmzone.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -100,6 +100,7 @@ enum zone_stat_item {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0NR_BOUNCE,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0NR_VMSCAN_WRITE,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0NR_WRITEBACK_TEMP, =C2=A0 =C2=A0 =C2=A0/* Writ=
eback using temporary buffers */
> + =C2=A0 =C2=A0 =C2=A0 NR_ISOLATED, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0/* Temporary isolated pages from lru */
> =C2=A0#ifdef CONFIG_NUMA
> =C2=A0 =C2=A0 =C2=A0 =C2=A0NUMA_HIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 /* allocated in intended node */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0NUMA_MISS, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0/* allocated in non intended node */
> Index: b/mm/page_alloc.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2116,8 +2116,7 @@ void show_free_areas(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk("Active_anon:%lu active_file:%lu inacti=
ve_anon:%lu\n"
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 " inactive_file:%lu"
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 " unevictable:%lu"
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 " inactive_file:%lu un=
evictable:%lu isolated:%lu\n"

It's good.
I have a one suggestion.

I know this patch came from David's OOM problem a few days ago.

I think total pages isolated of all lru doesn't help us much.
It just represents why [in]active[anon/file] is zero.

How about adding isolate page number per each lru ?

IsolatedPages(file)
IsolatedPages(anon)

It can help knowing exact number of each lru.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
