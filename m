Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 655076B0032
	for <linux-mm@kvack.org>; Sun, 19 Apr 2015 20:03:19 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so119454550ied.1
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 17:03:19 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id n14si7098139igx.1.2015.04.19.17.03.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 19 Apr 2015 17:03:18 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
Date: Mon, 20 Apr 2015 00:02:00 +0000
Message-ID: <20150420000200.GC10725@hori1.linux.bs1.fc.nec.co.jp>
References: <20150418205656.GA7972@pd.tnic>
 <CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
 <20150418215656.GA13928@node.dhcp.inet.fi>
 <CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
 <CA+55aFxLjBFUPYFJDGo236Ubdxy9s32gZ9VU43PA3RCkxJxdbw@mail.gmail.com>
In-Reply-To: <CA+55aFxLjBFUPYFJDGo236Ubdxy9s32gZ9VU43PA3RCkxJxdbw@mail.gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <D1019B867B3BB644B01964329077308B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Borislav Petkov <bp@alien8.de>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

On Sat, Apr 18, 2015 at 06:12:56PM -0400, Linus Torvalds wrote:
> On Sat, Apr 18, 2015 at 5:59 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> > On Sat, Apr 18, 2015 at 5:56 PM, Kirill A. Shutemov
> > <kirill@shutemov.name> wrote:
> >>
> >> Andrea has already seen the bug and pointed to 8d63d99a5dfb as possibl=
e
> >> cause. I don't see why the commit could broke anything, but it worth
> >> trying to revert and test.
> >
> > Ahh, yes, that does look like a more likely culprit.
>=20
> That said, I do think we should likely also do that
>=20
>         WARN_ON_ONCE(PageHuge(page));
>=20
> in __put_compound_page() rather than just silently saying "no refcount
> changes for this magical case that shouldn't even happen".  If it
> shouldn't happen, then we should warn about it, not try to ":handle"
> some case that shouldn't happen and shouldn't matter.

__put_compound_page() can be called for PageHuge, so I don't think that add=
ing
WARN_ON_ONCE(PageHuge) is good (, which makes every hugetlb user see the wa=
rning
once in every boot.)

What I thought when I suggested this code was that __page_cache_release() s=
eems
not to be intended for hugetlb, but I'm not sure.
__put_compound_page() does work without this !PageHuge check which is only =
for
potential change in __put_compound_page().
So if everyone thinks that __put_compound_page() is stable and will never c=
hange
in the future, this !PageHuge check is totally unnecessary.

> Let's not play games in this area. This code has been stable for many
> years, why are we suddenly doing random things here? There's something
> to be said for "if it ain't broke..", and there's *definitely* a lot
> to be said for "let's not complicate this even more".

OK, so could you please try simply reverting 822fc61367f0 ?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
