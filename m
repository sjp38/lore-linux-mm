Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 781AC6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:01:43 -0400 (EDT)
Received: by oier21 with SMTP id r21so36080927oie.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:01:43 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id yg17si2611727obb.92.2015.03.25.17.01.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 17:01:42 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/memory-failure.c: define page types for
 action_result() in one place
Date: Wed, 25 Mar 2015 23:56:03 +0000
Message-ID: <20150325235603.GA14825@hori1.linux.bs1.fc.nec.co.jp>
References: <1426746272-24306-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.10.1503242058300.20696@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503242058300.20696@chino.kir.corp.google.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <101EA0CF4854064EB9B7D68873A83C56@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Xie XiuQi <xiexiuqi@huawei.com>, Steven Rostedt <rostedt@goodmis.org>, Chen Gong <gong.chen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Mar 24, 2015 at 09:02:13PM -0700, David Rientjes wrote:
> On Thu, 19 Mar 2015, Naoya Horiguchi wrote:
>=20
> > This cleanup patch moves all strings passed to action_result() into a s=
ingle
> > array action_page_type so that a reader can easily find which kind of a=
ction
> > results are possible. And this patch also fixes the odd lines to be pri=
nted
> > out, like "unknown page state page" or "free buddy, 2nd try page".
> >=20
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  mm/memory-failure.c | 107 +++++++++++++++++++++++++++++++++++++-------=
--------
> >  1 file changed, 76 insertions(+), 31 deletions(-)
> >=20
> > diff --git v3.19.orig/mm/memory-failure.c v3.19/mm/memory-failure.c
> > index d487f8dc6d39..afb740e1c8b0 100644
> > --- v3.19.orig/mm/memory-failure.c
> > +++ v3.19/mm/memory-failure.c
> > @@ -521,6 +521,52 @@ static const char *action_name[] =3D {
> >  	[RECOVERED] =3D "Recovered",
> >  };
> > =20
> > +enum page_type {
> > +	KERNEL,
> > +	KERNEL_HIGH_ORDER,
> > +	SLAB,
> > +	DIFFERENT_COMPOUND,
> > +	POISONED_HUGE,
> > +	HUGE,
> > +	FREE_HUGE,
> > +	UNMAP_FAILED,
> > +	DIRTY_SWAPCACHE,
> > +	CLEAN_SWAPCACHE,
> > +	DIRTY_MLOCKED_LRU,
> > +	CLEAN_MLOCKED_LRU,
> > +	DIRTY_UNEVICTABLE_LRU,
> > +	CLEAN_UNEVICTABLE_LRU,
> > +	DIRTY_LRU,
> > +	CLEAN_LRU,
> > +	TRUNCATED_LRU,
> > +	BUDDY,
> > +	BUDDY_2ND,
> > +	UNKNOWN,
> > +};
> > +
>=20
> I like the patch because of the consistency in output and think it's wort=
h=20
> the extra 1% .text size.
>=20
> My only concern is the generic naming of the enum members. =20
> memory-failure.c is already an offender with "enum outcome" and the namin=
g=20
> of its members.
>
> Would you mind renaming these to be prefixed with "MSG_"?

no, your naming is clearer and represents better what it is, so I agree wit=
h it.

> These enums should be anonymous, too, nothing is referencing enum outcome=
=20
> or your new enum page_type.
>=20

Or the type of action_result()'s 2nd parameter can be "enum page_type".

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
