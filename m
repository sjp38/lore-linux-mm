Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD83C6B0253
	for <linux-mm@kvack.org>; Wed, 18 May 2016 06:11:16 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id i75so95245023ioa.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 03:11:16 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id l19si6949536itb.45.2016.05.18.03.11.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 03:11:15 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2] mm: check_new_page_bad() directly returns in
 __PG_HWPOISON case
Date: Wed, 18 May 2016 10:09:50 +0000
Message-ID: <20160518100949.GA17299@hori1.linux.bs1.fc.nec.co.jp>
References: <1463470975-29972-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160518092100.GB2527@techsingularity.net> <573C365B.6020807@suse.cz>
In-Reply-To: <573C365B.6020807@suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <C369357ECE6B1840A6BDBF4F28CFF687@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, May 18, 2016 at 11:31:07AM +0200, Vlastimil Babka wrote:
> On 05/18/2016 11:21 AM, Mel Gorman wrote:
> > On Tue, May 17, 2016 at 04:42:55PM +0900, Naoya Horiguchi wrote:
> > > There's a race window between checking page->flags and unpoisoning, w=
hich
> > > taints kernel with "BUG: Bad page state". That's overkill. It's safer=
 to
> > > use bad_flags to detect hwpoisoned page.
> > >=20
> >=20
> > I'm not quite getting this one. Minimally, instead of =3D __PG_HWPOISON=
, it
> > should have been (bad_flags & __PG_POISON). As Vlastimil already pointe=
d
> > out, __PG_HWPOISON can be 0. What I'm not getting is why this fixes the
> > race. The current race is
> >=20
> > 1. Check poison, set bad_flags
> > 2. poison clears in parallel
> > 3. Check page->flag state in bad_page and trigger warning
> >=20
> > The code changes it to
> >=20
> > 1. Check poison, set bad_flags
> > 2. poison clears in parallel
> > 3. Check bad_flags and trigger warning
>=20
> I think you got step 3 here wrong. It's "skip the warning since we have s=
et
> bad_flags to hwpoison and bad_flags didn't change due to parallel unpoiso=
n".
>=20
> Perhaps the question is why do we need to split the handling between
> check_new_page_bad() and bad_page() like this? It might have been differe=
nt
> in the past, but seems like at this point we only look for hwpoison from
> check_new_page_bad(). But a cleanup can come later.

Thanks for clarification. check_new_page_bad() is the only function interes=
ted
in hwpoison flag, so we had better move the hwpoison related code in bad_pa=
ge()
to check_new_page_bad().

Thanks,
Naoya Horiguchi
---
