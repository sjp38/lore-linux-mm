Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id B65436B0260
	for <linux-mm@kvack.org>; Wed, 18 May 2016 06:18:14 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x67so74697731oix.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 03:18:14 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id 67si3125681otl.76.2016.05.18.03.18.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 03:18:14 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: bad_page() checks bad_flags instead of
 page->flags for hwpoison page
Date: Wed, 18 May 2016 10:17:09 +0000
Message-ID: <20160518101709.GA25087@hori1.linux.bs1.fc.nec.co.jp>
References: <1463470975-29972-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160518092100.GB2527@techsingularity.net> <573C365B.6020807@suse.cz>
 <20160518095251.GD2527@techsingularity.net>
In-Reply-To: <20160518095251.GD2527@techsingularity.net>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <67C80B6B3C4D1E4EBF4F687D4A11C405@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, May 18, 2016 at 10:52:51AM +0100, Mel Gorman wrote:
> On Wed, May 18, 2016 at 11:31:07AM +0200, Vlastimil Babka wrote:
> > On 05/18/2016 11:21 AM, Mel Gorman wrote:
> > >On Tue, May 17, 2016 at 04:42:55PM +0900, Naoya Horiguchi wrote:
> > >>There's a race window between checking page->flags and unpoisoning, w=
hich
> > >>taints kernel with "BUG: Bad page state". That's overkill. It's safer=
 to
> > >>use bad_flags to detect hwpoisoned page.
> > >>
> > >
> > >I'm not quite getting this one. Minimally, instead of =3D __PG_HWPOISO=
N, it
> > >should have been (bad_flags & __PG_POISON). As Vlastimil already point=
ed
> > >out, __PG_HWPOISON can be 0. What I'm not getting is why this fixes th=
e
> > >race. The current race is
> > >
> > >1. Check poison, set bad_flags
> > >2. poison clears in parallel
> > >3. Check page->flag state in bad_page and trigger warning
> > >
> > >The code changes it to
> > >
> > >1. Check poison, set bad_flags
> > >2. poison clears in parallel
> > >3. Check bad_flags and trigger warning
> >=20
> > I think you got step 3 here wrong. It's "skip the warning since we have=
 set
> > bad_flags to hwpoison and bad_flags didn't change due to parallel unpoi=
son".
> >=20
>=20
> I think the benefit is marginal. The race means that the patch will trigg=
er
> a warning that might have been missed before due to a parallel unpoison
> but that's not necessary a Good Thing. It's inherently race-prone.
>=20
> Naoya, if you fix the check to (bad_flags & __PG_POISON) then I'll add my
> ack but I'm not convinced it's a real problem.

This v1 had the wrong operator issue as you mentioned. I posted v2 a while =
ago,
which has no such issue and is a better fix hopefully.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
