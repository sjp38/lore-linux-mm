Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 67FB26B006C
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 18:53:05 -0400 (EDT)
Received: by pactp5 with SMTP id tp5so65230768pac.1
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 15:53:05 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id td9si4729933pac.213.2015.04.01.15.53.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Apr 2015 15:53:04 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t31Mr0QL002875
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 2 Apr 2015 07:53:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: numa: disable change protection for vma(VM_HUGETLB)
Date: Wed, 1 Apr 2015 04:14:27 +0000
Message-ID: <20150401041426.GA16703@hori1.linux.bs1.fc.nec.co.jp>
References: <1427708426-31610-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150330102802.GQ4701@suse.de> <55192885.5010608@gmail.com>
 <20150330115901.GR4701@suse.de>
 <20150331014554.GA8128@hori1.linux.bs1.fc.nec.co.jp>
 <20150331143521.652d655e396d961410179d4d@linux-foundation.org>
In-Reply-To: <20150331143521.652d655e396d961410179d4d@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <1248571FEC3F644894A7F2606ACC02AA@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <nao.horiguchi@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Mar 31, 2015 at 02:35:21PM -0700, Andrew Morton wrote:
> On Tue, 31 Mar 2015 01:45:55 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > Currently when a process accesses to hugetlb range protected with PROTN=
ONE,
> > unexpected COWs are triggered, which finally put hugetlb subsystem into
> > broken/uncontrollable state, where for example h->resv_huge_pages is su=
btracted
> > too much and wrapped around to a very large number, and free hugepage p=
ool
> > is no longer maintainable.
> >=20
> > This patch simply stops changing protection for vma(VM_HUGETLB) to fix =
the
> > problem. And this also allows us to avoid useless overhead of minor fau=
lts.
> >=20
> > ...
> >
> > --- a/kernel/sched/fair.c
> > +++ b/kernel/sched/fair.c
> > @@ -2161,8 +2161,10 @@ void task_numa_work(struct callback_head *work)
> >  		vma =3D mm->mmap;
> >  	}
> >  	for (; vma; vma =3D vma->vm_next) {
> > -		if (!vma_migratable(vma) || !vma_policy_mof(vma))
> > +		if (!vma_migratable(vma) || !vma_policy_mof(vma) ||
> > +			is_vm_hugetlb_page(vma)) {
> >  			continue;
> > +		}
> > =20
> >  		/*
> >  		 * Shared library pages mapped by multiple processes are not
>=20
> Which kernel version(s) need this patch?

I don't bisect completely, but the problem this patch is mentioning is visi=
ble
since v4.0-rc1 (not reproduced at v3.19).

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
