Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 0A7216B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 07:02:21 -0500 (EST)
Received: by wera13 with SMTP id a13so1465670wer.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 04:02:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120209113606.GA8054@sig21.net>
References: <201202041109.53003.toralf.foerster@gmx.de>
	<201202051107.26634.toralf.foerster@gmx.de>
	<CAJd=RBCvvVgWqfSkoEaWVG=2mwKhyXarDOthHt9uwOb2fuDE9g@mail.gmail.com>
	<201202080956.18727.toralf.foerster@gmx.de>
	<20120208115244.GA24959@sig21.net>
	<CAJd=RBDbYA4xZRikGtHJvKESdiSE-B4OucZ6vQ+tHCi+hG2+aw@mail.gmail.com>
	<20120209113606.GA8054@sig21.net>
Date: Thu, 9 Feb 2012 20:02:20 +0800
Message-ID: <CAJd=RBDzUpUgZLVU+WSfb8grzMAbi3fcyyZkpX8qpaxu6zYe1g@mail.gmail.com>
Subject: Re: swap storm since kernel 3.2.x
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Stezenbach <js@sig21.net>
Cc: =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Thu, Feb 9, 2012 at 7:36 PM, Johannes Stezenbach <js@sig21.net> wrote:
> On Wed, Feb 08, 2012 at 08:34:14PM +0800, Hillf Danton wrote:
>> And I want to ask kswapd to do less work, the attached diff is
>> based on 3.2.5, mind to test it with CONFIG_DEBUG_OBJECTS enabled?
>
> Sorry, for slow reply. =C2=A0The patch does not apply to 3.2.4
> (3.2.5 only has the ASPM change which I don't want to
> try atm). =C2=A0Is the patch below correct?
>

It is fine;)

Thanks
Hillf

> I'll let this run for a while and will report back.
>
> Thanks
> Johannes
>
>
> --- mm/vmscan.c.orig =C2=A0 =C2=A02012-02-03 21:39:51.000000000 +0100
> +++ mm/vmscan.c 2012-02-09 12:30:42.000000000 +0100
> @@ -2067,8 +2067,11 @@ restart:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * with multiple p=
rocesses reclaiming pages, the total
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * freeing target =
can get unreasonably large.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (nr_reclaimed >=3D =
nr_to_reclaim && priority < DEF_PRIORITY)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (nr_reclaimed >=3D =
nr_to_reclaim) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 nr_to_reclaim =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0break;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_to_reclaim -=3D nr_=
reclaimed;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0blk_finish_plug(&plug);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sc->nr_reclaimed +=3D nr_reclaimed;
> @@ -2535,12 +2538,12 @@ static unsigned long balance_pgdat(pg_da
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * we want to put =
equal scanning pressure on each zone.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.nr_to_reclaim =3D=
 ULONG_MAX,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .order =3D order,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.mem_cgroup =3D NU=
LL,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0};
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct shrink_control shrink =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.gfp_mask =3D sc.g=
fp_mask,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0};
> + =C2=A0 =C2=A0 =C2=A0 sc.order =3D order =3D 0;
> =C2=A0loop_again:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0total_scanned =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sc.nr_reclaimed =3D 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
