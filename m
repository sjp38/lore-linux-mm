Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76CAA6B0292
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 13:38:04 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id w1so4132746qtg.6
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 10:38:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h187si2599221qkc.171.2017.06.07.10.38.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 10:38:03 -0700 (PDT)
Date: Wed, 7 Jun 2017 13:38:00 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <1169495863.31360420.1496857080560.JavaMail.zimbra@redhat.com>
In-Reply-To: <20170607170651.exful7yvxvrjaolz@node.shutemov.name>
References: <1496846780-17393-1-git-send-email-jglisse@redhat.com> <20170607170325.65ex46hoqjalprnu@black.fi.intel.com> <20170607170651.exful7yvxvrjaolz@node.shutemov.name>
Subject: Re: [PATCH] x86/mm/hotplug: fix BUG_ON() after hotremove by not
 freeing pud v2
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Logan Gunthorpe <logang@deltatee.com>

> On Wed, Jun 07, 2017 at 08:03:25PM +0300, Kirill A. Shutemov wrote:
> > On Wed, Jun 07, 2017 at 10:46:20AM -0400, jglisse@redhat.com wrote:
> > > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > >=20
> > > With commit af2cf278ef4f we no longer free pud so that we do not
> > > have synchronize all pgd on hotremove/vfree. But the new 5 level
> > > page table patchset reverted that for 4 level page table.
> > >=20
> > > This patch restore af2cf278ef4f and disable free_pud() if we are
> > > in the 4 level page table case thus avoiding BUG_ON() after hot-
> > > remove.
> > >=20
> > > af2cf278ef4f x86/mm/hotplug: Don't remove PGD entries in
> > > remove_pagetable()
> > >=20
> > > Changed since v1:
> > >   - make free_pud() conditional on the number of page table
> > >     level
> > >   - improved commit message
> > >=20
> > > Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > > Cc: Andy Lutomirski <luto@kernel.org>
> > > Cc: Ingo Molnar <mingo@kernel.org>
> > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Cc: Logan Gunthorpe <logang@deltatee.com>
> > > > thus we now trigger a BUG_ON() l128 in sync_global_pgds()
> > > >
> > > > This patch remove free_pud() like in af2cf278ef4f
> > > ---
> > >  arch/x86/mm/init_64.c | 11 +++++++++++
> > >  1 file changed, 11 insertions(+)
> > >=20
> > > diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> > > index 95651dc..61028bc 100644
> > > --- a/arch/x86/mm/init_64.c
> > > +++ b/arch/x86/mm/init_64.c
> > > @@ -771,6 +771,16 @@ static void __meminit free_pmd_table(pmd_t
> > > *pmd_start, pud_t *pud)
> > >  =09spin_unlock(&init_mm.page_table_lock);
> > >  }
> > > =20
> > > +/*
> > > + * For 4 levels page table we do not want to free puds but for 5 lev=
els
> > > + * we should free them. This code also need to change to adapt for b=
oot
> > > + * time switching between 4 and 5 level.
> > > + */
> > > +#if CONFIG_PGTABLE_LEVELS =3D=3D 4
> > > +static inline void free_pud_table(pud_t *pud_start, p4d_t *p4d)
> > > +{
> > > +}
> >=20
> > Just "if (CONFIG_PGTABLE_LEVELS > 4)" before calling free_pud_table(), =
but
> > okay -- I'll rework it anyway for boot-time switching.
>=20
> Err. "if (CONFIG_PGTABLE_LEVELS =3D=3D 4)" obviously.

You want me to respawn a v3 or is that good enough until you finish
boot time 5 level page table ?

Cheers,
J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
