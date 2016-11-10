Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2776E280253
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:35:33 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id rf5so89066834pab.3
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 01:35:33 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id n10si3258410pay.49.2016.11.10.01.35.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 01:35:32 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 07/12] mm: thp: check pmd migration entry in common
 path
Date: Thu, 10 Nov 2016 09:34:10 +0000
Message-ID: <20161110093410.GA28070@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-8-git-send-email-n-horiguchi@ah.jp.nec.com>
 <013801d23b31$f47a7cb0$dd6f7610$@alibaba-inc.com>
 <20161110092134.GD9173@hori1.linux.bs1.fc.nec.co.jp>
 <014b01d23b34$c7a71600$56f54200$@alibaba-inc.com>
In-Reply-To: <014b01d23b34$c7a71600$56f54200$@alibaba-inc.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6AA315CD6D56A24E9208831D9CB53163@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Hugh Dickins' <hughd@google.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Dave Hansen' <dave.hansen@intel.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Michal Hocko' <mhocko@kernel.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Zi Yan' <zi.yan@cs.rutgers.edu>, 'Balbir Singh' <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 'Naoya Horiguchi' <nao.horiguchi@gmail.com>, 'Anshuman Khandual' <khandual@linux.vnet.ibm.com>

On Thu, Nov 10, 2016 at 05:28:20PM +0800, Hillf Danton wrote:
> On Thursday, November 10, 2016 5:22 PM Naoya Horiguchi wrote:
> > On Thu, Nov 10, 2016 at 05:08:07PM +0800, Hillf Danton wrote:
> > > On Tuesday, November 08, 2016 7:32 AM Naoya Horiguchi wrote:
> > > >
> > > > @@ -1013,6 +1027,9 @@ int do_huge_pmd_wp_page(struct fault_env *fe,=
 pmd_t orig_pmd)
> > > >  	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
> > > >  		goto out_unlock;
> > > >
> > > > +	if (unlikely(!pmd_present(orig_pmd)))
> > > > +		goto out_unlock;
> > > > +
> > >
> > > Can we encounter a migration entry after acquiring ptl ?
> >=20
> > I think we can. thp migration code releases ptl after converting pmd in=
to
> > migration entry, so other code can see it even within ptl.
> >=20
> But we have a pmd_same check there, you see.=20

You're right. So we can omit this pmd_present check.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
