Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0D7E76B0087
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 10:08:00 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so129381ywm.26
        for <linux-mm@kvack.org>; Wed, 17 Jun 2009 07:08:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090617140334.GB8079@localhost>
References: <20090615031253.530308256@intel.com>
	 <20090615152612.GA11700@localhost>
	 <20090616090308.bac3b1f7.minchan.kim@barrios-desktop>
	 <20090616134944.GB7524@localhost>
	 <20090617092826.56730a10.minchan.kim@barrios-desktop>
	 <20090617072319.GA5841@localhost>
	 <28c262360906170627p2e57f907y2f8bbdc9fd5804f2@mail.gmail.com>
	 <20090617133708.GA7839@localhost>
	 <28c262360906170643o3783b0a4k8fbc1001baa8e2e1@mail.gmail.com>
	 <20090617140334.GB8079@localhost>
Date: Wed, 17 Jun 2009 23:08:13 +0900
Message-ID: <28c262360906170708u467f9324qf218c0c6f5fa434f@mail.gmail.com>
Subject: Re: [PATCH 09/22] HWPOISON: Handle hardware poisoned pages in
	try_to_unmap
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 17, 2009 at 11:03 PM, Wu Fengguang<fengguang.wu@intel.com> wrot=
e:
> On Wed, Jun 17, 2009 at 09:43:29PM +0800, Minchan Kim wrote:
>> On Wed, Jun 17, 2009 at 10:37 PM, Wu Fengguang<fengguang.wu@intel.com> w=
rote:
>> > On Wed, Jun 17, 2009 at 09:27:36PM +0800, Minchan Kim wrote:
>> >> On Wed, Jun 17, 2009 at 4:23 PM, Wu Fengguang<fengguang.wu@intel.com>=
 wrote:
>> >> > On Wed, Jun 17, 2009 at 08:28:26AM +0800, Minchan Kim wrote:
>> >> >> On Tue, 16 Jun 2009 21:49:44 +0800
>> >> >> Wu Fengguang <fengguang.wu@intel.com> wrote:
>> >> >>
>> >> >> > On Tue, Jun 16, 2009 at 08:03:08AM +0800, Minchan Kim wrote:
>> >> >> > > On Mon, 15 Jun 2009 23:26:12 +0800
>> >> >> > > Wu Fengguang <fengguang.wu@intel.com> wrote:
>> >> >> > >
>> >> >> > > > On Mon, Jun 15, 2009 at 09:09:03PM +0800, Minchan Kim wrote:
>> >> >> > > > > On Mon, Jun 15, 2009 at 11:45 AM, Wu Fengguang<fengguang.w=
u@intel.com> wrote:
>> >> >> > > > > > From: Andi Kleen <ak@linux.intel.com>
>> >> >> > > > > >
>> >> >> > > > > > When a page has the poison bit set replace the PTE with =
a poison entry.
>> >> >> > > > > > This causes the right error handling to be done later wh=
en a process runs
>> >> >> > > > > > into it.
>> >> >> > > > > >
>> >> >> > > > > > Also add a new flag to not do that (needed for the memor=
y-failure handler
>> >> >> > > > > > later)
>> >> >> > > > > >
>> >> >> > > > > > Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
>> >> >> > > > > > Signed-off-by: Andi Kleen <ak@linux.intel.com>
>> >> >> > > > > >
>> >> >> > > > > > ---
>> >> >> > > > > > =C2=A0include/linux/rmap.h | =C2=A0 =C2=A01 +
>> >> >> > > > > > =C2=A0mm/rmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| =C2=A0 =C2=A09 ++++++++-
>> >> >> > > > > > =C2=A02 files changed, 9 insertions(+), 1 deletion(-)
>> >> >> > > > > >
>> >> >> > > > > > --- sound-2.6.orig/mm/rmap.c
>> >> >> > > > > > +++ sound-2.6/mm/rmap.c
>> >> >> > > > > > @@ -958,7 +958,14 @@ static int try_to_unmap_one(struct =
page
>> >> >> > > > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Update high watermark befo=
re we lower rss */
>> >> >> > > > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0update_hiwater_rss(mm);
>> >> >> > > > > >
>> >> >> > > > > > - =C2=A0 =C2=A0 =C2=A0 if (PageAnon(page)) {
>> >> >> > > > > > + =C2=A0 =C2=A0 =C2=A0 if (PageHWPoison(page) && !(flags=
 & TTU_IGNORE_HWPOISON)) {
>> >> >> > > > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (P=
ageAnon(page))
>> >> >> > > > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 dec_mm_counter(mm, anon_rss);
>> >> >> > > > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else =
if (!is_migration_entry(pte_to_swp_entry(*pte)))
>> >> >> > > > >
>> >> >> > > > > Isn't it straightforward to use !is_hwpoison_entry ?
>> >> >> > > >
>> >> >> > > > Good catch! =C2=A0It looks like a redundant check: the
>> >> >> > > > page_check_address() at the beginning of the function guaran=
tees that
>> >> >> > > > !is_migration_entry() or !is_migration_entry() tests will al=
l be TRUE.
>> >> >> > > > So let's do this?
>> >> >> > > It seems you expand my sight :)
>> >> >> > >
>> >> >> > > I don't know migration well.
>> >> >> > > How page_check_address guarantee it's not migration entry ?
>> >> >> >
>> >> >> > page_check_address() calls pte_present() which returns the
>> >> >> > (_PAGE_PRESENT | _PAGE_PROTNONE) bits. While x86-64 defines
>> >> >> >
>> >> >> > #define __swp_entry(type, offset) =C2=A0 =C2=A0 =C2=A0 ((swp_ent=
ry_t) { \
>> >> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0((type) << (_PAGE_BIT_PRESENT + 1)) \
>> >> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0| ((offset) << SWP_OFFSET_SHIFT) })
>> >> >> >
>> >> >> > where SWP_OFFSET_SHIFT is defined to the bigger one of
>> >> >> > max(_PAGE_BIT_PROTNONE + 1, _PAGE_BIT_FILE + 1) =3D max(8+1, 6+1=
) =3D 9.
>> >> >> >
>> >> >> > So __swp_entry(type, offset) :=3D (type << 1) | (offset << 9)
>> >> >> >
>> >> >> > We know that the swap type is 5 bits. So the bit 0 _PAGE_PRESENT=
 and bit 8
>> >> >> > _PAGE_PROTNONE will all be zero for swap entries.
>> >> >> >
>> >> >>
>> >> >> Thanks for kind explanation :)
>> >> >
>> >> > You are welcome~
>> >> >
>> >> >> >
>> >> >> > > In addtion, If the page is poison while we are going to
>> >> >> > > migration((PAGE_MIGRATION && migration) =3D=3D TRUE), we shoul=
d decrease
>> >> >> > > file_rss ?
>> >> >> >
>> >> >> > It will die on trying to migrate the poisoned page so we don't c=
are
>> >> >> > the accounting. But normally the poisoned page shall already be
>> >> >>
>> >> >>
>> >> >> Okay. then, how about this ?
>> >> >> We should not increase file_rss on trying to migrate the poisoned =
page
>> >> >>
>> >> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else if (!is_mi=
gration_entry(pte_to_swp_entry(*pte)))
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else if (!(PAGE=
_MIGRATION && migration))
>> >> >
>> >> > This is good if we are going to stop the hwpoison page from being
>> >> > consumed by move_to_new_page(), but I highly doubt we'll ever add
>> >> > PageHWPoison() checks into the migration code.
>> >> >
>> >> > Because this race window is small enough:
>> >> >
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0TestSetPageHWPoison(p);
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lock_page(page);
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 try_to_unmap(page, TTU=
_MIGRATION|...);
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0lock_page_nosync(p);
>> >> >
>> >> > such small race windows can be found all over the kernel, it's just
>> >> > insane to try to fix any of them.
>> >>
>> >> Sorry for too late response.
>> >>
>> >> I see your point.
>> >> My opinion is that at least we must be notified when such situation h=
appen.
>> >> So I think it would be better to add some warning to fix up it when i=
t
>> >> happen even thought =C2=A0it is small race window.
>> >
>> > Notification is also pointless here: we'll die hard on
>> > accessing/consuming the poisoned page anyway :(
>>
>> My intention wasn't to recover it.
>
> Yes, that's not the point.
>
>> It just add something like WARN_ON.
>> You said it is small window enough. but I think it can happen more
>> hight probability in migration-workload.(At a moment, I don't know
>> what kinds of app)
>> For such case, If we can hear reporting of warning, at that time we
>> can consider migration handling for HWPoison.
>
> The point is, any page can go corrupted any time. We don't need to add
> 1000 PageHWPoison() tests in the kernel like this. We don't aim for
> 100% protection, that's impossible. I'd be very contented if ever it
> can reach 80% coverage :)

Okay.
If it is your goal, I also think migration portion of all is very small.
Thanks for kind reply for my boring discussion.

Reviewed-by : Minchan Kim <minchan.kim@gmail.com>

> Thanks,
> Fengguang
>
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
