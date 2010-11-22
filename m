Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1C9006B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 19:30:44 -0500 (EST)
Received: by bwz16 with SMTP id 16so5912579bwz.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 16:30:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101119125653.16dd5452.akpm@linux-foundation.org>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20101119125653.16dd5452.akpm@linux-foundation.org>
Date: Mon, 22 Nov 2010 02:30:39 +0200
Message-ID: <AANLkTikyjzyT7EW02gXBV+9vnFnHYBUURKizdx9wetib@mail.gmail.com>
Subject: Re: [PATCH 0/4] big chunk memory allocator v4
From: Felipe Contreras <felipe.contreras@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, minchan.kim@gmail.com, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, m.nazarewicz@samsung.com, pawel@osciak.com, andi.kleen@intel.com, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 10:56 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 19 Nov 2010 17:10:33 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> Hi, this is an updated version.
>>
>> No major changes from the last one except for page allocation function.
>> removed RFC.
>>
>> Order of patches is
>>
>> [1/4] move some functions from memory_hotplug.c to page_isolation.c
>> [2/4] search physically contiguous range suitable for big chunk alloc.
>> [3/4] allocate big chunk memory based on memory hotplug(migration) techn=
ique
>> [4/4] modify page allocation function.
>>
>> For what:
>>
>> =C2=A0 I hear there is requirements to allocate a chunk of page which is=
 larger than
>> =C2=A0 MAX_ORDER. Now, some (embeded) device use a big memory chunk. To =
use memory,
>> =C2=A0 they hide some memory range by boot option (mem=3D) and use hidde=
n memory
>> =C2=A0 for its own purpose. But this seems a lack of feature in memory m=
anagement.

Actually, now that's not needed any more by using memblock:
http://article.gmane.org/gmane.linux.ports.arm.omap/44978

>> =C2=A0 This patch adds
>> =C2=A0 =C2=A0 =C2=A0 alloc_contig_pages(start, end, nr_pages, gfp_mask)
>> =C2=A0 to allocate a chunk of page whose length is nr_pages from [start,=
 end)
>> =C2=A0 phys address. This uses similar logic of memory-unplug, which tri=
es to
>> =C2=A0 offline [start, end) pages. By this, drivers can allocate 30M or =
128M or
>> =C2=A0 much bigger memory chunk on demand. (I allocated 1G chunk in my t=
est).
>>
>> =C2=A0 But yes, because of fragmentation, this cannot guarantee 100% all=
oc.
>> =C2=A0 If alloc_contig_pages() is called in system boot up or movable_zo=
ne is used,
>> =C2=A0 this allocation succeeds at high rate.
>
> So this is an alternatve implementation for the functionality offered
> by Michal's "The Contiguous Memory Allocator framework".
>
>> =C2=A0 I tested this on x86-64, and it seems to work as expected. But fe=
edback from
>> =C2=A0 embeded guys are appreciated because I think they are main user o=
f this
>> =C2=A0 function.
>
> From where I sit, feedback from the embedded guys is *vital*, because
> they are indeed the main users.
>
> Michal, I haven't made a note of all the people who are interested in
> and who are potential users of this code. =C2=A0Your patch series has a
> billion cc's and is up to version 6. =C2=A0Could I ask that you review an=
d
> test this code, and also hunt down other people (probably at other
> organisations) who can do likewise for us? =C2=A0Because until we hear fr=
om
> those people that this work satisfies their needs, we can't really
> proceed much further.

As I've explained before, a contiguous memory allocator would be nice,
but on ARM many drivers not only need contiguous memory, but
non-cacheable, and this requires removing the memory from normal
kernel mapping in early boot.

Cheers.

--=20
Felipe Contreras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
