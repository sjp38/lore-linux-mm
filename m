Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28A1B6B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 04:26:35 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p131-v6so7441432oig.10
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 01:26:35 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id 42-v6si758983otu.545.2018.04.03.01.26.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 01:26:34 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: consider non-anonymous thp as unmovable page
Date: Tue, 3 Apr 2018 08:24:06 +0000
Message-ID: <20180403082405.GA23809@hori1.linux.bs1.fc.nec.co.jp>
References: <1522730788-24530-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180403075928.GC5501@dhcp22.suse.cz>
In-Reply-To: <20180403075928.GC5501@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <95C456C3C9681E43A23D653F1A98C7B7@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Apr 03, 2018 at 09:59:28AM +0200, Michal Hocko wrote:
> On Tue 03-04-18 13:46:28, Naoya Horiguchi wrote:
> > My testing for the latest kernel supporting thp migration found out an
> > infinite loop in offlining the memory block that is filled with shmem
> > thps.  We can get out of the loop with a signal, but kernel should
> > return with failure in this case.
> >
> > What happens in the loop is that scan_movable_pages() repeats returning
> > the same pfn without any progress. That's because page migration always
> > fails for shmem thps.
>
> Why does it fail? Shmem pages should be movable without any issues.

.. because try_to_unmap_one() explicitly skips unmapping for migration.

  #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
                  /* PMD-mapped THP migration entry */
                  if (!pvmw.pte && (flags & TTU_MIGRATION)) {
                          VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompou=
nd(page), page);
 =20
                          if (!PageAnon(page))
                                  continue;
 =20
                          set_pmd_migration_entry(&pvmw, page);
                          continue;
                  }
  #endif

When I implemented this code, I felt hard to work on both of anon thp
and shmem thp at one time, so I separated the proposal into smaller steps.
Shmem uses pagecache so we need some non-trivial effort (including testing)
to extend thp migration for shmem. But I think it's a reasonable next step.

Thanks,
Naoya Horiguchi=
