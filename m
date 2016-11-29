Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6BC26B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 02:09:45 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 3so412894323pgd.3
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 23:09:45 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id t67si58735864pfk.141.2016.11.28.23.09.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 23:09:45 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 10/12] mm: mempolicy: mbind and migrate_pages support
 thp migration
Date: Tue, 29 Nov 2016 07:07:34 +0000
Message-ID: <20161129070734.GB8686@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-11-git-send-email-n-horiguchi@ah.jp.nec.com>
 <58382E28.9060706@linux.vnet.ibm.com>
In-Reply-To: <58382E28.9060706@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <36C2641DB6F1824ABD83048884B48EDB@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Nov 25, 2016 at 05:57:20PM +0530, Anshuman Khandual wrote:
> On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
...
> > @@ -497,30 +541,15 @@ static int queue_pages_pte_range(pmd_t *pmd, unsi=
gned long addr,
> >  	struct page *page;
> >  	struct queue_pages *qp =3D walk->private;
> >  	unsigned long flags =3D qp->flags;
> > -	int nid, ret;
> > +	int ret;
> >  	pte_t *pte;
> >  	spinlock_t *ptl;
> > =20
> > -	if (pmd_trans_huge(*pmd)) {
> > -		ptl =3D pmd_lock(walk->mm, pmd);
> > -		if (pmd_trans_huge(*pmd)) {
> > -			page =3D pmd_page(*pmd);
> > -			if (is_huge_zero_page(page)) {
> > -				spin_unlock(ptl);
> > -				__split_huge_pmd(vma, pmd, addr, false, NULL);
> > -			} else {
> > -				get_page(page);
> > -				spin_unlock(ptl);
> > -				lock_page(page);
> > -				ret =3D split_huge_page(page);
> > -				unlock_page(page);
> > -				put_page(page);
> > -				if (ret)
> > -					return 0;
> > -			}
> > -		} else {
> > -			spin_unlock(ptl);
> > -		}
> > +	ptl =3D pmd_trans_huge_lock(pmd, vma);
> > +	if (ptl) {
> > +		ret =3D queue_pages_pmd(pmd, ptl, addr, end, walk);
> > +		if (ret)
> > +			return 0;
> >  	}
>=20
> I wonder if we should introduce pte_entry function along with pmd_entry
> function as we are first looking for trans huge PMDs either for direct
> addition into the migration list or splitting it before looking for PTEs.

Most of pagewalk users don't define pte_entry because of performance reason
(to avoid the overhead of PTRS_PER_PMD function calls).
But that could be a nice cleanup if we have a workaround.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
