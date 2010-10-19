Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7F0526B00CE
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 22:37:31 -0400 (EDT)
Received: by iwn1 with SMTP id 1so2044048iwn.14
        for <linux-mm@kvack.org>; Mon, 18 Oct 2010 19:37:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101019022451.GA8310@localhost>
References: <20100915091118.3dbdc961@notabene>
	<4C90139A.1080809@redhat.com>
	<20100915122334.3fa7b35f@notabene>
	<20100915082843.GA17252@localhost>
	<20100915184434.18e2d933@notabene>
	<20101018151459.2b443221@notabene>
	<20101018161504.GB29500@localhost>
	<20101018145859.eee1ae33.akpm@linux-foundation.org>
	<20101019093142.509d6947@notabene>
	<20101018154137.90f5325f.akpm@linux-foundation.org>
	<20101019022451.GA8310@localhost>
Date: Tue, 19 Oct 2010 11:37:29 +0900
Message-ID: <AANLkTimEjJu6Eo6VmaCyuDNpen66SeZGyV84GOcc9TV1@mail.gmail.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 11:24 AM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> On Tue, Oct 19, 2010 at 06:41:37AM +0800, Andrew Morton wrote:
>> On Tue, 19 Oct 2010 09:31:42 +1100
>> Neil Brown <neilb@suse.de> wrote:
>>
>> > On Mon, 18 Oct 2010 14:58:59 -0700
>> > Andrew Morton <akpm@linux-foundation.org> wrote:
>> >
>> > > On Tue, 19 Oct 2010 00:15:04 +0800
>> > > Wu Fengguang <fengguang.wu@intel.com> wrote:
>> > >
>> > > > Neil find that if too_many_isolated() returns true while performin=
g
>> > > > direct reclaim we can end up waiting for other threads to complete=
 their
>> > > > direct reclaim. =A0If those threads are allowed to enter the FS or=
 IO to
>> > > > free memory, but this thread is not, then it is possible that thos=
e
>> > > > threads will be waiting on this thread and so we get a circular
>> > > > deadlock.
>> > > >
>> > > > some task enters direct reclaim with GFP_KERNEL
>> > > > =A0 =3D> too_many_isolated() false
>> > > > =A0 =A0 =3D> vmscan and run into dirty pages
>> > > > =A0 =A0 =A0 =3D> pageout()
>> > > > =A0 =A0 =A0 =A0 =3D> take some FS lock
>> > > > =A0 =A0 =A0 =A0 =A0 =3D> fs/block code does GFP_NOIO allocation
>> > > > =A0 =A0 =A0 =A0 =A0 =A0 =3D> enter direct reclaim again
>> > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D> too_many_isolated() true
>> > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D> waiting for others to progres=
s, however the other
>> > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tasks may be circular waiti=
ng for the FS lock..
>>
>> I'm assuming that the last four "=3D>"'s here should have been indented
>> another stop.
>
> Yup. I'll fix it in next post.
>
>> > > > The fix is to let !__GFP_IO and !__GFP_FS direct reclaims enjoy hi=
gher
>> > > > priority than normal ones, by honouring them higher throttle thres=
hold.
>> > > >
>> > > > Now !GFP_IOFS reclaims won't be waiting for GFP_IOFS reclaims to
>> > > > progress. They will be blocked only when there are too many concur=
rent
>> > > > !GFP_IOFS reclaims, however that's very unlikely because the IO-le=
ss
>> > > > direct reclaims is able to progress much more faster, and they won=
't
>> > > > deadlock each other. The threshold is raised high enough for them,=
 so
>> > > > that there can be sufficient parallel progress of !GFP_IOFS reclai=
ms.
>> > >
>> > > I'm not sure that this is really a full fix. =A0Torsten's analysis d=
oes
>> > > appear to point at the real bug: raid1 has code paths which allocate
>> > > more than a single element from a mempool without starting IO agains=
t
>> > > previous elements.
>> >
>> > ... point at "a" real bug.
>> >
>> > I think there are two bugs here.
>> > The raid1 bug that Torsten mentions is certainly real (and has been ar=
ound
>> > for an embarrassingly long time).
>> > The bug that I identified in too_many_isolated is also a real bug and =
can be
>> > triggered without md/raid1 in the mix.
>> > So this is not a 'full fix' for every bug in the kernel :-),
>
>> > but it could well be a full fix for this particular bug.
>
> Yeah it aims to be a full fix for one bug.
>
>> Can we just delete the too_many_isolated() logic? =A0(Crappy comment
>
> If the two cond_resched() calls can be removed from
> shrink_page_list(), the major cause of too many pages being
> isolated will be gone. However the writeback-waiting logic after
> should_reclaim_stall() will also block the direct reclaimer for long
> time with pages isolated, which may bite under pathological conditions.
>
>> describes what the code does but not why it does it).
>
> Good point. The comment could be improved as follows.
>
> Thanks,
> Fengguang
>
> ---
> Subject: vmscan: comment too_many_isolated()
> From: Wu Fengguang <fengguang.wu@intel.com>
> Date: Tue Oct 19 09:53:23 CST 2010
>
> Comment "Why it's doing so" rather than "What it does"
> as proposed by Andrew Morton.
>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
