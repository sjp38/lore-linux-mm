Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE1746B0003
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 03:41:13 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u15-v6so4057315ita.8
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 00:41:13 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id m192-v6si2403199itb.140.2018.04.12.00.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 00:41:12 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1 0/2] mm: migrate: vm event counter for hugepage
 migration
Date: Thu, 12 Apr 2018 07:40:41 +0000
Message-ID: <20180412074039.GA3340@hori1.linux.bs1.fc.nec.co.jp>
References: <1523434167-19995-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180412061859.GR23400@dhcp22.suse.cz>
In-Reply-To: <20180412061859.GR23400@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <26566DB56A5F954CB0641A6E02F3BC84@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Zi Yan <zi.yan@sent.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Apr 12, 2018 at 08:18:59AM +0200, Michal Hocko wrote:
> On Wed 11-04-18 17:09:25, Naoya Horiguchi wrote:
> > Hi everyone,
> >=20
> > I wrote patches introducing separate vm event counters for hugepage mig=
ration
> > (both for hugetlb and thp.)
> > Hugepage migration is different from normal page migration in event fre=
quency
> > and/or how likely it succeeds, so maintaining statistics for them in mi=
xed
> > counters might not be helpful both for develors and users.
>=20
> This is quite a lot of code to be added se we should better document
> what it is intended for. Sure I understand your reasonaning about huge
> pages are more likely to fail but is this really worth a separate
> counter? Do you have an example of how this would be useful?

Our customers periodically collect some log info to understand what
happened after system failures happen.  Then if we have separate counters
for hugepage migration and the values show some anomaly, that might
help admins and developers understand the issue more quickly.
We have other ways to get this info like checking /proc/pid/pagemap and
/proc/kpageflags, but they are costly and most users decide not to
collect them in periodical logging.

>=20
> If we are there then what about different huge page sizes (for hugetlb)?
> Do we need per-hstate stats?

Yes, per-hstate counters are better. And existing hugetlb counters
htlb_buddy_alloc_* are also affected by this point.

>=20
> In other words, is this really worth it?

Actually, I'm not sure at this point.

Thanks,
Naoya Horiguchi

>=20
> >  include/linux/vm_event_item.h |   7 +++
> >  mm/migrate.c                  | 103 ++++++++++++++++++++++++++++++++++=
+-------
> >  mm/vmstat.c                   |   8 ++++
> >  3 files changed, 102 insertions(+), 16 deletions(-)
>=20
> --=20
> Michal Hocko
> SUSE Labs
> =
