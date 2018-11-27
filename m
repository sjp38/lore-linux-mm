Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC7C6B486B
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:31:29 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id bj3so4053463plb.17
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 06:31:29 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 206si3731411pga.240.2018.11.27.06.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 06:31:27 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wARETt9n088807
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:31:27 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p17j30kdm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:31:25 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 27 Nov 2018 14:31:19 -0000
Date: Tue, 27 Nov 2018 15:31:14 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 3/3] s390/mm: fix mis-accounting of pgtable_bytes
In-Reply-To: <20181127073411.GA3625@osiris>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
	<1539621759-5967-4-git-send-email-schwidefsky@de.ibm.com>
	<CAEemH2cHNFsiDqPF32K6TNn-XoXCRT0wP4ccAeah4bKHt=FKFA@mail.gmail.com>
	<20181031073149.55ddc085@mschwideX1>
	<20181031100944.GA3546@osiris>
	<20181031103623.6ykzsjdenrpeth7x@kshutemo-mobl1>
	<20181127073411.GA3625@osiris>
MIME-Version: 1.0
Message-Id: <20181127153114.0a6193d3@mschwideX1>
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, 27 Nov 2018 08:34:12 +0100
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> On Wed, Oct 31, 2018 at 01:36:23PM +0300, Kirill A. Shutemov wrote:
> > On Wed, Oct 31, 2018 at 11:09:44AM +0100, Heiko Carstens wrote: =20
> > > On Wed, Oct 31, 2018 at 07:31:49AM +0100, Martin Schwidefsky wrote: =
=20
> > > > Thanks for testing. Unfortunately Heiko reported another issue yest=
erday
> > > > with the patch applied. This time the other way around:
> > > >=20
> > > > BUG: non-zero pgtables_bytes on freeing mm: -16384
> > > >=20
> > > > I am trying to understand how this can happen. For now I would like=
 to
> > > > keep the patch on hold in case they need another change. =20
> > >=20
> > > FWIW, Kirill: is there a reason why this "BUG:" output is done with
> > > pr_alert() and not with VM_BUG_ON() or one of the WARN*() variants?
> > >=20
> > > That would to get more information with DEBUG_VM and / or
> > > panic_on_warn=3D1 set. At least for automated testing it would be nice
> > > to have such triggers. =20
> >=20
> > Stack trace is not helpful there. It will always show the exit path whi=
ch
> > is useless. =20
>=20
> So, even with the updated version of these patches I can flood dmesg
> and the console with
>=20
> BUG: non-zero pgtables_bytes on freeing mm: 16384
>=20
> messages with this complex reproducer on s390:
>=20
> echo "void main(void) {}" | gcc -m31 -xc -o compat - && ./compat

Forgot a hunk in the fix.. I claim not enough coffee :-/
Patch is queued and I will send a please pull by the end of the week.
--
=46rom c0499f2aa853939984ecaf0d393012486e56c7ce Mon Sep 17 00:00:00 2001
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Tue, 27 Nov 2018 14:04:04 +0100
Subject: [PATCH] s390/mm: correct pgtable_bytes on page table downgrade

The downgrade of a page table from 3 levels to 2 levels for a 31-bit compat
process removes a pmd table which has to be counted against pgtable_bytes.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/mm/pgalloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/s390/mm/pgalloc.c b/arch/s390/mm/pgalloc.c
index 814f26520aa2..6791562779ee 100644
--- a/arch/s390/mm/pgalloc.c
+++ b/arch/s390/mm/pgalloc.c
@@ -131,6 +131,7 @@ void crst_table_downgrade(struct mm_struct *mm)
 	}
=20
 	pgd =3D mm->pgd;
+	mm_dec_nr_pmds(mm);
 	mm->pgd =3D (pgd_t *) (pgd_val(*pgd) & _REGION_ENTRY_ORIGIN);
 	mm->context.asce_limit =3D _REGION3_SIZE;
 	mm->context.asce =3D __pa(mm->pgd) | _ASCE_TABLE_LENGTH |
--=20
2.16.4
--=20
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
