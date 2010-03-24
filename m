Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 63DE06B01B4
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 20:16:10 -0400 (EDT)
Received: by pwi2 with SMTP id 2so169708pwi.14
        for <linux-mm@kvack.org>; Tue, 23 Mar 2010 17:16:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100324090312.4e1cc725.kamezawa.hiroyu@jp.fujitsu.com>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	 <1269347146-7461-6-git-send-email-mel@csn.ul.ie>
	 <20100324090312.4e1cc725.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 24 Mar 2010 09:16:07 +0900
Message-ID: <28c262361003231716k54ca1ae8u92793be7f2fdf374@mail.gmail.com>
Subject: Re: [PATCH 05/11] Export unusable free space index via
	/proc/unusable_index
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Kame.

On Wed, Mar 24, 2010 at 9:03 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 23 Mar 2010 12:25:40 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
>
>> Unusable free space index is a measure of external fragmentation that
>> takes the allocation size into account. For the most part, the huge page
>> size will be the size of interest but not necessarily so it is exported
>> on a per-order and per-zone basis via /proc/unusable_index.
>>
>> The index is a value between 0 and 1. It can be expressed as a
>> percentage by multiplying by 100 as documented in
>> Documentation/filesystems/proc.txt.
>>
>> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Acked-by: Rik van Riel <riel@redhat.com>
>> ---
>> =C2=A0Documentation/filesystems/proc.txt | =C2=A0 13 ++++-
>> =C2=A0mm/vmstat.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0120 ++++++++++++++++++++++++++++++++=
+
>> =C2=A02 files changed, 132 insertions(+), 1 deletions(-)
>>
>> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesyst=
ems/proc.txt
>> index 5e132b5..5c4b0fb 100644
>> --- a/Documentation/filesystems/proc.txt
>> +++ b/Documentation/filesystems/proc.txt
>> @@ -452,6 +452,7 @@ Table 1-5: Kernel info in /proc
>> =C2=A0 sys =C2=A0 =C2=A0 =C2=A0 =C2=A0 See chapter 2
>> =C2=A0 sysvipc =C2=A0 =C2=A0 Info of SysVIPC Resources (msg, sem, shm) =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (2.4)
>> =C2=A0 tty =C2=A0 =C2=A0 =C2=A0Info of tty drivers
>> + unusable_index Additional page allocator information (see text)(2.5)
>> =C2=A0 uptime =C2=A0 =C2=A0 =C2=A0System uptime
>> =C2=A0 version =C2=A0 =C2=A0 Kernel version
>> =C2=A0 video =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bttv info of video=
 resources =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 (2.4)
>> @@ -609,7 +610,7 @@ ZONE_DMA, 4 chunks of 2^1*PAGE_SIZE in ZONE_DMA, 101=
 chunks of 2^4*PAGE_SIZE
>> =C2=A0available in ZONE_NORMAL, etc...
>>
>> =C2=A0More information relevant to external fragmentation can be found i=
n
>> -pagetypeinfo.
>> +pagetypeinfo and unusable_index
>>
>> =C2=A0> cat /proc/pagetypeinfo
>> =C2=A0Page block order: 9
>> @@ -650,6 +651,16 @@ unless memory has been mlock()'d. Some of the Recla=
imable blocks should
>> =C2=A0also be allocatable although a lot of filesystem metadata may have=
 to be
>> =C2=A0reclaimed to achieve this.
>>
>> +> cat /proc/unusable_index
>> +Node 0, zone =C2=A0 =C2=A0 =C2=A0DMA 0.000 0.000 0.000 0.001 0.005 0.01=
3 0.021 0.037 0.037 0.101 0.230
>> +Node 0, zone =C2=A0 Normal 0.000 0.000 0.000 0.001 0.002 0.002 0.005 0.=
015 0.028 0.028 0.054
>> +
>> +The unusable free space index measures how much of the available free
>> +memory cannot be used to satisfy an allocation of a given size and is a
>> +value between 0 and 1. The higher the value, the more of free memory is
>> +unusable and by implication, the worse the external fragmentation is. T=
his
>> +can be expressed as a percentage by multiplying by 100.
>> +
>> =C2=A0..................................................................=
............
>>
>> =C2=A0meminfo:
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 7f760cb..ca42e10 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -453,6 +453,106 @@ static int frag_show(struct seq_file *m, void *arg=
)
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0}
>>
>> +
>> +struct contig_page_info {
>> + =C2=A0 =C2=A0 unsigned long free_pages;
>> + =C2=A0 =C2=A0 unsigned long free_blocks_total;
>> + =C2=A0 =C2=A0 unsigned long free_blocks_suitable;
>> +};
>> +
>> +/*
>> + * Calculate the number of free pages in a zone, how many contiguous
>> + * pages are free and how many are large enough to satisfy an allocatio=
n of
>> + * the target size. Note that this function makes to attempt to estimat=
e
>> + * how many suitable free blocks there *might* be if MOVABLE pages were
>> + * migrated. Calculating that is possible, but expensive and can be
>> + * figured out from userspace
>> + */
>> +static void fill_contig_page_info(struct zone *zone,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int suitable_order,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct contig_page_info *info)
>> +{
>> + =C2=A0 =C2=A0 unsigned int order;
>> +
>> + =C2=A0 =C2=A0 info->free_pages =3D 0;
>> + =C2=A0 =C2=A0 info->free_blocks_total =3D 0;
>> + =C2=A0 =C2=A0 info->free_blocks_suitable =3D 0;
>> +
>> + =C2=A0 =C2=A0 for (order =3D 0; order < MAX_ORDER; order++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long blocks;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Count number of free bloc=
ks */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 blocks =3D zone->free_area[o=
rder].nr_free;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 info->free_blocks_total +=3D=
 blocks;
>
> ....for what this free_blocks_total is ?

It's used by fragmentation_index in [06/11].

>
> Thanks,
> -Kame
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
