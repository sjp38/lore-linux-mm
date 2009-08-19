Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 064CE6B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 09:38:05 -0400 (EDT)
Received: by gxk12 with SMTP id 12so6059238gxk.4
        for <linux-mm@kvack.org>; Wed, 19 Aug 2009 06:38:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090819132420.GA6137@localhost>
References: <20090816051502.GB13740@localhost>
	 <20090816112910.GA3208@localhost>
	 <20090818234310.A64B.A69D9226@jp.fujitsu.com>
	 <20090819120117.GB7306@localhost>
	 <2f11576a0908190505h6da96280xf67c962aa3f5ba07@mail.gmail.com>
	 <20090819121017.GA8226@localhost>
	 <28c262360908190525i6e56ead0mb8dcb01c3d1a69f1@mail.gmail.com>
	 <20090819132420.GA6137@localhost>
Date: Wed, 19 Aug 2009 22:38:05 +0900
Message-ID: <28c262360908190638g521e55bcje14cb321c9a22c51@mail.gmail.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeff Dike <jdike@addtoit.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 10:24 PM, Wu Fengguang<fengguang.wu@intel.com> wrot=
e:
> On Wed, Aug 19, 2009 at 08:25:56PM +0800, Minchan Kim wrote:
>> On Wed, Aug 19, 2009 at 9:10 PM, Wu Fengguang<fengguang.wu@intel.com> wr=
ote:
>> > On Wed, Aug 19, 2009 at 08:05:19PM +0800, KOSAKI Motohiro wrote:
>> >> >> page_referenced_file?
>> >> >> I think we should change page_referenced().
>> >> >
>> >> > Yeah, good catch.
>> >> >
>> >> >>
>> >> >> Instead, How about this?
>> >> >> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> >> >>
>> >> >> Subject: [PATCH] mm: stop circulating of referenced mlocked pages
>> >> >>
>> >> >> Currently, mlock() systemcall doesn't gurantee to mark the page PG=
_Mlocked
>> >> >
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mark PG_mlocked
>> >> >
>> >> >> because some race prevent page grabbing.
>> >> >> In that case, instead vmscan move the page to unevictable lru.
>> >> >>
>> >> >> However, Recently Wu Fengguang pointed out current vmscan logic is=
n't so
>> >> >> efficient.
>> >> >> mlocked page can move circulatly active and inactive list because
>> >> >> vmscan check the page is referenced _before_ cull mlocked page.
>> >> >>
>> >> >> Plus, vmscan should mark PG_Mlocked when cull mlocked page.
>> >> >
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 PG_mlocked
>> >> >
>> >> >> Otherwise vm stastics show strange number.
>> >> >>
>> >> >> This patch does that.
>> >> >
>> >> > Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
>> >>
>> >> Thanks.
>> >>
>> >>
>> >>
>> >> >> Index: b/mm/rmap.c
>> >> >> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> >> >> --- a/mm/rmap.c =C2=A0 =C2=A0 =C2=A0 2009-08-18 19:48:14.000000000=
 +0900
>> >> >> +++ b/mm/rmap.c =C2=A0 =C2=A0 =C2=A0 2009-08-18 23:47:34.000000000=
 +0900
>> >> >> @@ -362,7 +362,9 @@ static int page_referenced_one(struct pa
>> >> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0* unevictable list.
>> >> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> >> >> =C2=A0 =C2=A0 =C2=A0 if (vma->vm_flags & VM_LOCKED) {
>> >> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *mapcount =3D 1; =C2=
=A0/* break early from loop */
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *mapcount =3D 1; =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* break early from loop */
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *vm_flags |=3D VM_LOCK=
ED; /* for prevent to move active list */
>> >> >
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 try_set_page_mlocked(v=
ma, page);
>> >> >
>> >> > That call is not absolutely necessary?
>> >>
>> >> Why? I haven't catch your point.
>> >
>> > Because we'll eventually hit another try_set_page_mlocked() when
>> > trying to unmap the page. Ie. duplicated with another call you added
>> > in this patch.
>>
>> Yes. we don't have to call it and we can make patch simple.
>> I already sent patch on yesterday.
>>
>> http://marc.info/?l=3Dlinux-mm&m=3D125059325722370&w=3D2
>>
>> I think It's more simple than KOSAKI's idea.
>> Is any problem in my patch ?
>
> No, IMHO your patch is simple and good, while KOSAKI's is more
> complete :)
>
> - the try_set_page_mlocked() rename is suitable
> - the call to try_set_page_mlocked() is necessary on try_to_unmap()

We don't need try_set_page_mlocked call in try_to_unmap.
That's because try_to_unmap_xxx will call try_to_mlock_page if the
page is included in any VM_LOCKED vma. Eventually, It can move
unevictable list.

> - the "if (VM_LOCKED) referenced =3D 0" in page_referenced() could
> =C2=A0cover both active/inactive vmscan

ASAP we set PG_mlocked in page, we can save unnecessary vmscan cost from
active list to inactive list. But I think it's rare case so that there
would be few pages.
So I think that will be not big overhead.

As I know, Rescue by vmscan page losing the isolation race was the
Lee's design.
But as you pointed out, it have a bug that vmscan can't rescue the
page due to reach try_to_unmap.

So I think this approach is proper. :)

> I did like your proposed
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sc->order <=3D=
 PAGE_ALLOC_COSTLY_ORDER &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 referenced &=
& page_mapping_inuse(page))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 referenced &=
& page_mapping_inuse(page)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 && !(vm_flag=
s & VM_LOCKED))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto activate_locked;
>
> which looks more intuitive and less confusing.
>
> Thanks,
> Fengguang
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
