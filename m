Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE1D58E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 11:51:04 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id w5so11968416iom.3
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 08:51:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 139sor21909164ity.22.2018.12.10.08.51.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 08:51:03 -0800 (PST)
MIME-Version: 1.0
References: <20181206084604.17167-1-peterx@redhat.com> <20181207033407.GB10726@xz-x1>
In-Reply-To: <20181207033407.GB10726@xz-x1>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Mon, 10 Dec 2018 19:50:52 +0300
Message-ID: <CALYGNiMjWDL6XaOFgfrM1WR6_GnmxfLBXwJ=YYGVNfEKNX0MfQ@mail.gmail.com>
Subject: Re: [PATCH] mm: thp: fix soft dirty for migration when split
Content-Type: multipart/alternative; boundary="00000000000037eb46057cadc521"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterx@redhat.com
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, dave.jiang@intel.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, jrdr.linux@gmail.com, =?UTF-8?B?0JrQvtC90YHRgtCw0L3RgtC40L0g0KXQu9C10LHQvdC40LrQvtCy?= <khlebnikov@yandex-team.ru>, linux-mm@kvack.org

--00000000000037eb46057cadc521
Content-Type: text/plain; charset="UTF-8"

On Fri, Dec 7, 2018 at 6:34 AM Peter Xu <peterx@redhat.com> wrote:
>
> On Thu, Dec 06, 2018 at 04:46:04PM +0800, Peter Xu wrote:
> > When splitting a huge migrating PMD, we'll transfer the soft dirty bit
> > from the huge page to the small pages.  However we're possibly using a
> > wrong data since when fetching the bit we're using pmd_soft_dirty()
> > upon a migration entry.  Fix it up.
>
> Note that if my understanding is correct about the problem then if
> without the patch there is chance to lose some of the dirty bits in
> the migrating pmd pages (on x86_64 we're fetching bit 11 which is part
> of swap offset instead of bit 2) and it could potentially corrupt the
> memory of an userspace program which depends on the dirty bit.

It seems this code is broken in case of pmd_migraion:

old_pmd = pmdp_invalidate(vma, haddr, pmd);

#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
pmd_migration = is_pmd_migration_entry(old_pmd);
if (pmd_migration) {
swp_entry_t entry;

entry = pmd_to_swp_entry(old_pmd);
page = pfn_to_page(swp_offset(entry));
} else
#endif
page = pmd_page(old_pmd);
VM_BUG_ON_PAGE(!page_count(page), page);
page_ref_add(page, HPAGE_PMD_NR - 1);
if (pmd_dirty(old_pmd))
SetPageDirty(page);
write = pmd_write(old_pmd);
young = pmd_young(old_pmd);
soft_dirty = pmd_soft_dirty(old_pmd);

Not just soft_dirt - all bits (dirty, write, young) have diffrent encoding
or not present at all for migration entry.

>
> >
> > CC: Andrea Arcangeli <aarcange@redhat.com>
> > CC: Andrew Morton <akpm@linux-foundation.org>
> > CC: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > CC: Matthew Wilcox <willy@infradead.org>
> > CC: Michal Hocko <mhocko@suse.com>
> > CC: Dave Jiang <dave.jiang@intel.com>
> > CC: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > CC: Souptick Joarder <jrdr.linux@gmail.com>
> > CC: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> > CC: linux-mm@kvack.org
> > CC: linux-kernel@vger.kernel.org
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> > ---
> >
> > I noticed this during code reading.  Only compile tested.  I'm sending
> > a patch directly for review comments since it's relatively
> > straightforward and not easy to test.  Please have a look, thanks.
> > ---
> >  mm/huge_memory.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index f2d19e4fe854..fb0787c3dd3b 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2161,7 +2161,10 @@ static void __split_huge_pmd_locked(struct
vm_area_struct *vma, pmd_t *pmd,
> >               SetPageDirty(page);
> >       write = pmd_write(old_pmd);
> >       young = pmd_young(old_pmd);
> > -     soft_dirty = pmd_soft_dirty(old_pmd);
> > +     if (unlikely(pmd_migration))
> > +             soft_dirty = pmd_swp_soft_dirty(old_pmd);
> > +     else
> > +             soft_dirty = pmd_soft_dirty(old_pmd);
> >
> >       /*
> >        * Withdraw the table only after we mark the pmd entry invalid.
> > --
> > 2.17.1
> >
>
> Regards,
>
> --
> Peter Xu
>

--00000000000037eb46057cadc521
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br>On Fri, Dec 7, 2018 at 6:34 AM Peter =
Xu &lt;<a href=3D"mailto:peterx@redhat.com">peterx@redhat.com</a>&gt; wrote=
:<br>&gt;<br>&gt; On Thu, Dec 06, 2018 at 04:46:04PM +0800, Peter Xu wrote:=
<br>&gt; &gt; When splitting a huge migrating PMD, we&#39;ll transfer the s=
oft dirty bit<br>&gt; &gt; from the huge page to the small pages.=C2=A0 How=
ever we&#39;re possibly using a<br>&gt; &gt; wrong data since when fetching=
 the bit we&#39;re using pmd_soft_dirty()<br>&gt; &gt; upon a migration ent=
ry.=C2=A0 Fix it up.<br>&gt;<br>&gt; Note that if my understanding is corre=
ct about the problem then if<br>&gt; without the patch there is chance to l=
ose some of the dirty bits in<br>&gt; the migrating pmd pages (on x86_64 we=
&#39;re fetching bit 11 which is part<br>&gt; of swap offset instead of bit=
 2) and it could potentially corrupt the<br>&gt; memory of an userspace pro=
gram which depends on the dirty bit.<br><br>It seems this code is broken in=
 case of pmd_migraion:<br><br><div><span style=3D"white-space:pre">	</span>=
old_pmd =3D pmdp_invalidate(vma, haddr, pmd);</div><div><br></div><div>#ifd=
ef CONFIG_ARCH_ENABLE_THP_MIGRATION</div><div><span style=3D"white-space:pr=
e">	</span>pmd_migration =3D is_pmd_migration_entry(old_pmd);</div><div><sp=
an style=3D"white-space:pre">	</span>if (pmd_migration) {</div><div><span s=
tyle=3D"white-space:pre">		</span>swp_entry_t entry;</div><div><br></div><d=
iv><span style=3D"white-space:pre">		</span>entry =3D pmd_to_swp_entry(old_=
pmd);</div><div><span style=3D"white-space:pre">		</span>page =3D pfn_to_pa=
ge(swp_offset(entry));</div><div><span style=3D"white-space:pre">	</span>} =
else</div><div>#endif</div><div><span style=3D"white-space:pre">		</span>pa=
ge =3D pmd_page(old_pmd);</div><div><span style=3D"white-space:pre">	</span=
>VM_BUG_ON_PAGE(!page_count(page), page);</div><div><span style=3D"white-sp=
ace:pre">	</span>page_ref_add(page, HPAGE_PMD_NR - 1);</div><div><span styl=
e=3D"white-space:pre">	</span>if (pmd_dirty(old_pmd))</div><div><span style=
=3D"white-space:pre">		</span>SetPageDirty(page);</div><div><span style=3D"=
white-space:pre">	</span>write =3D pmd_write(old_pmd);</div><div><span styl=
e=3D"white-space:pre">	</span>young =3D pmd_young(old_pmd);</div><div><span=
 style=3D"white-space:pre">	</span>soft_dirty =3D pmd_soft_dirty(old_pmd);<=
/div><div><br></div><div>Not just soft_dirt - all bits (dirty, write, young=
) have diffrent encoding or not present at all for migration entry.</div><b=
r>&gt;<br>&gt; &gt;<br>&gt; &gt; CC: Andrea Arcangeli &lt;<a href=3D"mailto=
:aarcange@redhat.com">aarcange@redhat.com</a>&gt;<br>&gt; &gt; CC: Andrew M=
orton &lt;<a href=3D"mailto:akpm@linux-foundation.org">akpm@linux-foundatio=
n.org</a>&gt;<br>&gt; &gt; CC: &quot;Kirill A. Shutemov&quot; &lt;<a href=
=3D"mailto:kirill.shutemov@linux.intel.com">kirill.shutemov@linux.intel.com=
</a>&gt;<br>&gt; &gt; CC: Matthew Wilcox &lt;<a href=3D"mailto:willy@infrad=
ead.org">willy@infradead.org</a>&gt;<br>&gt; &gt; CC: Michal Hocko &lt;<a h=
ref=3D"mailto:mhocko@suse.com">mhocko@suse.com</a>&gt;<br>&gt; &gt; CC: Dav=
e Jiang &lt;<a href=3D"mailto:dave.jiang@intel.com">dave.jiang@intel.com</a=
>&gt;<br>&gt; &gt; CC: &quot;Aneesh Kumar K.V&quot; &lt;<a href=3D"mailto:a=
neesh.kumar@linux.vnet.ibm.com">aneesh.kumar@linux.vnet.ibm.com</a>&gt;<br>=
&gt; &gt; CC: Souptick Joarder &lt;<a href=3D"mailto:jrdr.linux@gmail.com">=
jrdr.linux@gmail.com</a>&gt;<br>&gt; &gt; CC: Konstantin Khlebnikov &lt;<a =
href=3D"mailto:khlebnikov@yandex-team.ru">khlebnikov@yandex-team.ru</a>&gt;=
<br>&gt; &gt; CC: <a href=3D"mailto:linux-mm@kvack.org">linux-mm@kvack.org<=
/a><br>&gt; &gt; CC: <a href=3D"mailto:linux-kernel@vger.kernel.org">linux-=
kernel@vger.kernel.org</a><br>&gt; &gt; Signed-off-by: Peter Xu &lt;<a href=
=3D"mailto:peterx@redhat.com">peterx@redhat.com</a>&gt;<br>&gt; &gt; ---<br=
>&gt; &gt;<br>&gt; &gt; I noticed this during code reading.=C2=A0 Only comp=
ile tested.=C2=A0 I&#39;m sending<br>&gt; &gt; a patch directly for review =
comments since it&#39;s relatively<br>&gt; &gt; straightforward and not eas=
y to test.=C2=A0 Please have a look, thanks.<br>&gt; &gt; ---<br>&gt; &gt; =
=C2=A0mm/huge_memory.c | 5 ++++-<br>&gt; &gt; =C2=A01 file changed, 4 inser=
tions(+), 1 deletion(-)<br>&gt; &gt;<br>&gt; &gt; diff --git a/mm/huge_memo=
ry.c b/mm/huge_memory.c<br>&gt; &gt; index f2d19e4fe854..fb0787c3dd3b 10064=
4<br>&gt; &gt; --- a/mm/huge_memory.c<br>&gt; &gt; +++ b/mm/huge_memory.c<b=
r>&gt; &gt; @@ -2161,7 +2161,10 @@ static void __split_huge_pmd_locked(stru=
ct vm_area_struct *vma, pmd_t *pmd,<br>&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 SetPageDirty(page);<br>&gt; &gt; =C2=A0 =C2=A0 =C2=
=A0 write =3D pmd_write(old_pmd);<br>&gt; &gt; =C2=A0 =C2=A0 =C2=A0 young =
=3D pmd_young(old_pmd);<br>&gt; &gt; - =C2=A0 =C2=A0 soft_dirty =3D pmd_sof=
t_dirty(old_pmd);<br>&gt; &gt; + =C2=A0 =C2=A0 if (unlikely(pmd_migration))=
<br>&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 soft_dirty =3D pm=
d_swp_soft_dirty(old_pmd);<br>&gt; &gt; + =C2=A0 =C2=A0 else<br>&gt; &gt; +=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 soft_dirty =3D pmd_soft_dirty(ol=
d_pmd);<br>&gt; &gt;<br>&gt; &gt; =C2=A0 =C2=A0 =C2=A0 /*<br>&gt; &gt; =C2=
=A0 =C2=A0 =C2=A0 =C2=A0* Withdraw the table only after we mark the pmd ent=
ry invalid.<br>&gt; &gt; --<br>&gt; &gt; 2.17.1<br>&gt; &gt;<br>&gt;<br>&gt=
; Regards,<br>&gt;<br>&gt; --<br>&gt; Peter Xu<br>&gt;</div></div>

--00000000000037eb46057cadc521--
