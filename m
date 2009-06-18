Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 543B76B0055
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 09:30:55 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so436680ywm.26
        for <linux-mm@kvack.org>; Thu, 18 Jun 2009 06:31:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090618121430.GA6746@localhost>
References: <20090615031253.530308256@intel.com>
	 <20090615152612.GA11700@localhost>
	 <20090616090308.bac3b1f7.minchan.kim@barrios-desktop>
	 <20090616134944.GB7524@localhost>
	 <20090617092826.56730a10.minchan.kim@barrios-desktop>
	 <20090617072319.GA5841@localhost>
	 <28c262360906170644w65c08a8y2d2805fb08045804@mail.gmail.com>
	 <20090617135543.GA8079@localhost>
	 <28c262360906170703h3363b68dp74471358f647921e@mail.gmail.com>
	 <20090618121430.GA6746@localhost>
Date: Thu, 18 Jun 2009 22:31:52 +0900
Message-ID: <28c262360906180631i25ea6a18mbdc5be31c2346c04@mail.gmail.com>
Subject: Re: [PATCH 09/22] HWPOISON: Handle hardware poisoned pages in
	try_to_unmap
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 18, 2009 at 9:14 PM, Wu Fengguang<fengguang.wu@intel.com> wrote=
:
> On Wed, Jun 17, 2009 at 10:03:37PM +0800, Minchan Kim wrote:
>> On Wed, Jun 17, 2009 at 10:55 PM, Wu Fengguang<fengguang.wu@intel.com> w=
rote:
>> > On Wed, Jun 17, 2009 at 09:44:39PM +0800, Minchan Kim wrote:
>> >> It is private mail for my question.
>> >> I don't want to make noise in LKML.
>> >> And I don't want to disturb your progress to merge HWPoison.
>> >>
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
>> >> I don't know there are intentional small race windows in kernel until=
 you said.
>> >> I thought kernel code is perfect so it wouldn't allow race window
>> >> although it is very small. But you pointed out. Until now, My thought
>> >> is wrong.
>> >>
>> >> Do you know else small race windows by intention ?
>> >> If you know it, tell me, please. It can expand my sight. :)
>> >
>> > The memory failure code does not aim to rescue 100% page corruptions.
>> > That's unreasonable goal - the kernel pages, slab pages (including the
>> > big dcache/icache) are almost impossible to isolate.
>> >
>> > Comparing to the big slab pools, the migration and other race windows =
are
>> > really too small to care about :)
>>
>> Also, If you will mention this contents as annotation, I will add my
>> review sign.
>
> Good suggestion. Here is a patch for comment updates.
>
>> Thanks for kind reply for my boring discussion.
>
> Boring? Not at all :)
>
> Thanks,
> Fengguang
>
> ---
> =C2=A0mm/memory-failure.c | =C2=A0 76 +++++++++++++++++++++++++----------=
-------
> =C2=A01 file changed, 47 insertions(+), 29 deletions(-)
>
> --- sound-2.6.orig/mm/memory-failure.c
> +++ sound-2.6/mm/memory-failure.c
> @@ -1,4 +1,8 @@
> =C2=A0/*
> + * linux/mm/memory-failure.c
> + *
> + * High level machine check handler.
> + *
> =C2=A0* Copyright (C) 2008, 2009 Intel Corporation
> =C2=A0* Authors: Andi Kleen, Fengguang Wu
> =C2=A0*
> @@ -6,29 +10,36 @@
> =C2=A0* the GNU General Public License ("GPL") version 2 only as publishe=
d by the
> =C2=A0* Free Software Foundation.
> =C2=A0*
> - * High level machine check handler. Handles pages reported by the
> - * hardware as being corrupted usually due to a 2bit ECC memory or cache
> - * failure.
> - *
> - * This focuses on pages detected as corrupted in the background.
> - * When the current CPU tries to consume corruption the currently
> - * running process can just be killed directly instead. This implies
> - * that if the error cannot be handled for some reason it's safe to
> - * just ignore it because no corruption has been consumed yet. Instead
> - * when that happens another machine check will happen.
> - *
> - * Handles page cache pages in various states. The tricky part
> - * here is that we can access any page asynchronous to other VM
> - * users, because memory failures could happen anytime and anywhere,
> - * possibly violating some of their assumptions. This is why this code
> - * has to be extremely careful. Generally it tries to use normal locking
> - * rules, as in get the standard locks, even if that means the
> - * error handling takes potentially a long time.
> - *
> - * The operation to map back from RMAP chains to processes has to walk
> - * the complete process list and has non linear complexity with the numb=
er
> - * mappings. In short it can be quite slow. But since memory corruptions
> - * are rare we hope to get away with this.
> + * Pages are reported by the hardware as being corrupted usually due to =
a
> + * 2bit ECC memory or cache failure. Machine check can either be raised =
when
> + * corruption is found in background memory scrubbing, or when someone t=
ries to
> + * consume the corruption. This code focuses on the former case. =C2=A0I=
f it cannot
> + * handle the error for some reason it's safe to just ignore it because =
no
> + * corruption has been consumed yet. Instead when that happens another (=
deadly)
> + * machine check will happen.
> + *
> + * The tricky part here is that we can access any page asynchronous to o=
ther VM
> + * users, because memory failures could happen anytime and anywhere, pos=
sibly
> + * violating some of their assumptions. This is why this code has to be
> + * extremely careful. Generally it tries to use normal locking rules, as=
 in get
> + * the standard locks, even if that means the error handling takes poten=
tially
> + * a long time.
> + *
> + * We don't aim to rescue 100% corruptions. That's unreasonable goal - t=
he
> + * kernel text and slab pages (including the big dcache/icache) are almo=
st
> + * impossible to isolate. We also try to keep the code clean by ignoring=
 the
> + * other thousands of small corruption windows.

other thousands of small corruption windows(ex, migration, ...)
As far as you know , please write down them.

Anyway, I already added my sign.
Thanks for your effort never get exhausted. :)


--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
