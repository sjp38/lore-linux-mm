Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 14CCA6B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 09:21:24 -0400 (EDT)
Received: by yenm8 with SMTP id m8so2155604yen.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2012 06:21:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120321140019.9ca39a31.akpm@linux-foundation.org>
References: <CAJd=RBALNtedfq+PLPnGKd4i4D0mLiVPdW_7pWWopnSZNC_vqA@mail.gmail.com>
	<20120222130659.d75b6f69.akpm@linux-foundation.org>
	<CAJd=RBA53nS70Q7GEeskKFas-hfg4GKmUf=Zut5anSN0P+d1KA@mail.gmail.com>
	<20120223121238.b597e7e4.akpm@linux-foundation.org>
	<20120321140019.9ca39a31.akpm@linux-foundation.org>
Date: Thu, 22 Mar 2012 21:21:22 +0800
Message-ID: <CAJd=RBC9wN_M6T=vxmw+HxwxJF8Me1pq+UwZGEGoxto+HmG-3Q@mail.gmail.com>
Subject: Re: [PATCH] mm: hugetlb: bail out unmapping after serving reference page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

On Thu, Mar 22, 2012 at 5:00 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 23 Feb 2012 12:12:38 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Thu, 23 Feb 2012 21:05:41 +0800
>> Hillf Danton <dhillf@gmail.com> wrote:
>>
>> > and a follow-up cleanup also attached.
>>
>> Please, never put more than one patches in an email - it is rather a
>> pain to manually unpick everything.
>>
>> > When unmapping given VM range, a couple of code duplicate, such as pte=
_page()
>> > and huge_pte_none(), so a cleanup needed to compact them together.
>> >
>> > Signed-off-by: Hillf Danton <dhillf@gmail.com>
>> > ---
>> >
>> > --- a/mm/hugetlb.c =C2=A0Thu Feb 23 20:13:06 2012
>> > +++ b/mm/hugetlb.c =C2=A0Thu Feb 23 20:30:16 2012
>> > @@ -2245,16 +2245,23 @@ void __unmap_hugepage_range(struct vm_ar
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (huge_pmd_unshare(mm, &ad=
dress, ptep))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
continue;
>> >
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pte =3D huge_ptep_get(ptep);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (huge_pte_none(pte))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* HWPoisoned hugepage is al=
ready unmapped and dropped reference
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(is_hugetlb_entry_hwp=
oisoned(pte)))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D pte_page(pte);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If a reference page =
is supplied, it is because a specific
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* page is being unmapp=
ed, not a range. Ensure the page we
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* are about to unmap i=
s the actual page of interest.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ref_page) {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pte =
=3D huge_ptep_get(ptep);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (h=
uge_pte_none(pte))
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 continue;
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =
=3D pte_page(pte);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (page !=3D ref_page)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;
>> >
>> > @@ -2267,16 +2274,6 @@ void __unmap_hugepage_range(struct vm_ar
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pte =3D huge_ptep_get_and_cl=
ear(mm, address, ptep);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (huge_pte_none(pte))
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>> > -
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* HWPoisoned hugepage is al=
ready unmapped and dropped reference
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(is_hugetlb_entry_hwp=
oisoned(pte)))
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>> > -
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D pte_page(pte);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pte_dirty(pte))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
set_page_dirty(page);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_add(&page->lru, &page_l=
ist);
>>
>> This changes behaviour when ref_page refers to a hwpoisoned page.
>
> Respond, please?

First say sorry to you, Andrew.

The comment says, HWPoisoned hugepage is already unmapped;
and even if ref_page =3D=3D HWPoisoned page, it is not added onto
page_list and no page_remove_rmap() is issued for it, so we end
up with no behavior change.

Thanks
-hd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
