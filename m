Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 426C36B01F3
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 04:31:25 -0400 (EDT)
Received: by ywh26 with SMTP id 26so3126859ywh.12
        for <linux-mm@kvack.org>; Tue, 20 Apr 2010 01:32:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100420082057.GC19264@csn.ul.ie>
References: <201004152210.o3FMA7KV001909@imap1.linux-foundation.org>
	 <20100419190133.50a13021.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100419181442.GA19264@csn.ul.ie> <20100419193919.GB19264@csn.ul.ie>
	 <s2v28c262361004191939we64e5490ld59b21dc4fa5bc8d@mail.gmail.com>
	 <20100420082057.GC19264@csn.ul.ie>
Date: Tue, 20 Apr 2010 17:32:13 +0900
Message-ID: <x2h28c262361004200132q39fe5d5ex79251643a80d28b3@mail.gmail.com>
Subject: Re: error at compaction (Re: mmotm 2010-04-15-14-42 uploaded
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 5:20 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Tue, Apr 20, 2010 at 11:39:46AM +0900, Minchan Kim wrote:
>> On Tue, Apr 20, 2010 at 4:39 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>> > On Mon, Apr 19, 2010 at 07:14:42PM +0100, Mel Gorman wrote:
>> >> On Mon, Apr 19, 2010 at 07:01:33PM +0900, KAMEZAWA Hiroyuki wrote:
>> >> >
>> >> > mmotm 2010-04-15-14-42
>> >> >
>> >> > When I tried
>> >> > =C2=A0# echo 0 > /proc/sys/vm/compaction
>> >> >
>> >> > I see following.
>> >> >
>> >> > My enviroment was
>> >> > =C2=A0 2.6.34-rc4-mm1+ (2010-04-15-14-42) (x86-64) CPUx8
>> >> > =C2=A0 allocating tons of hugepages and reduce free memory.
>> >> >
>> >> > What I did was:
>> >> > =C2=A0 # echo 0 > /proc/sys/vm/compact_memory
>> >> >
>> >> > Hmm, I see this kind of error at migation for the 1st time..
>> >> > my.config is attached. Hmm... ?
>> >> >
>> >> > (I'm sorry I'll be offline soon.)
>> >>
>> >> That's ok, thanks you for the report. I'm afraid I made little progre=
ss
>> >> as I spent most of the day on other bugs but I do have something for
>> >> you.
>> >>
>> >> First, I reproduced the problem using your .config. However, the prob=
lem does
>> >> not manifest with the .config I normally use which is derived from th=
e distro
>> >> kernel configuration (Debian Lenny). So, there is something in your .=
config
>> >> that triggers the problem. I very strongly suspect this is an interac=
tion
>> >> between migration, compaction and page allocation debug.
>> >
>> > I unexpecedly had the time to dig into this. Does the following patch =
fix
>> > your problem? It Worked For Me.
>>
>> Nice catch during shot time. Below is comment.
>>
>> >
>> > =3D=3D=3D=3D CUT HERE =3D=3D=3D=3D
>> > mm,compaction: Map free pages in the address space after they get spli=
t for compaction
>> >
>> > split_free_page() is a helper function which takes a free page from th=
e
>> > buddy lists and splits it into order-0 pages. It is used by memory
>> > compaction to build a list of destination pages. If
>> > CONFIG_DEBUG_PAGEALLOC is set, a kernel paging request bug is triggere=
d
>> > because split_free_page() did not call the arch-allocation hooks or ma=
p
>> > the page into the kernel address space.
>> >
>> > This patch does not update split_free_page() as it is called with
>> > interrupts held. Instead it documents that callers of split_free_page(=
)
>> > are responsible for calling the arch hooks and to map the page and fix=
es
>> > compaction.
>>
>> Dumb question. Why can't we call arch_alloc_page and kernel_map_pages
>> as interrupt disabled?
>
> In theory, it isn't known what arch_alloc_page is going to do but more
> practically kernel_map_pages() is updating mappings and should be
> flushing all the TLBs. It can't do that with interrupts disabled.
>
> I checked X86 and it should be fine but only because it flushes the
> local CPU and appears to just hope for the best that this doesn't cause
> problems.

Okay.

>> And now compaction only uses split_free_page and it is exposed by mm.h.
>> I think it would be better to map pages inside split_free_page to
>> export others.(ie, making generic function).
>
> I considered that and it would not be ideal. It would have to disable and
> reenable interrupts as each page is taken from the list or alternatively
> require that the caller not have the zone lock taken. The latter of these
> options is more reasonable but would still result in more interrupt enabl=
ing
> and disabling.
>
> split_free_page() is extremely specialised and requires knowledge of the
> page allocator internals to call properly. There is little pressure to
> make this easier to use at the cost of increased locking.
>
>> If we can't do, how about making split_free_page static as static functi=
on?
>> And only uses it in compaction.
>>
>
> It pretty much has to be in page_alloc.c because it uses internal
> functions of the page allocator - e.g. rmv_page_order. I could move it
> to mm/internal.h because whatever about split_page, I can't imagine why
> anyone else would need to call split_free_page.

Yes. Then, Let's add comment like split_page. :)
 /*
 * Note: this is probably too low level an operation for use in drivers.
 * Please consult with lkml before using this in your driver.
 */


>
> --
> Mel Gorman
> Part-time Phd Student =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linux Technology Center
> University of Limerick =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IBM Dublin Software Lab
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
