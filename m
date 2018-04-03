Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8323F6B0007
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 06:54:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v8so6197534wmv.1
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 03:54:53 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d2sor1317030edi.55.2018.04.03.03.54.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 03:54:52 -0700 (PDT)
Date: Tue, 3 Apr 2018 13:54:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1] mm: consider non-anonymous thp as unmovable page
Message-ID: <20180403105411.hknofkbn6rzs26oz@node.shutemov.name>
References: <1522730788-24530-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180403075928.GC5501@dhcp22.suse.cz>
 <20180403082405.GA23809@hori1.linux.bs1.fc.nec.co.jp>
 <20180403083451.GG5501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180403083451.GG5501@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Apr 03, 2018 at 10:34:51AM +0200, Michal Hocko wrote:
> On Tue 03-04-18 08:24:06, Naoya Horiguchi wrote:
> > On Tue, Apr 03, 2018 at 09:59:28AM +0200, Michal Hocko wrote:
> > > On Tue 03-04-18 13:46:28, Naoya Horiguchi wrote:
> > > > My testing for the latest kernel supporting thp migration found out an
> > > > infinite loop in offlining the memory block that is filled with shmem
> > > > thps.  We can get out of the loop with a signal, but kernel should
> > > > return with failure in this case.
> > > >
> > > > What happens in the loop is that scan_movable_pages() repeats returning
> > > > the same pfn without any progress. That's because page migration always
> > > > fails for shmem thps.
> > >
> > > Why does it fail? Shmem pages should be movable without any issues.
> > 
> > .. because try_to_unmap_one() explicitly skips unmapping for migration.
> > 
> >   #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> >                   /* PMD-mapped THP migration entry */
> >                   if (!pvmw.pte && (flags & TTU_MIGRATION)) {
> >                           VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page), page);
> >   
> >                           if (!PageAnon(page))
> >                                   continue;
> >   
> >                           set_pmd_migration_entry(&pvmw, page);
> >                           continue;
> >                   }
> >   #endif
> > 
> > When I implemented this code, I felt hard to work on both of anon thp
> > and shmem thp at one time, so I separated the proposal into smaller steps.
> > Shmem uses pagecache so we need some non-trivial effort (including testing)
> > to extend thp migration for shmem. But I think it's a reasonable next step.
> 
> OK, I see. I have forgot about this part. Please be explicit about that
> in the changelog. Also the proper fix is to not use movable zone for
> shmem page THP rather than hack around it in the hotplug specific code
> IMHO.

No. We should just split the page before running
try_to_unmap(TTU_MIGRATION) on the page.

-- 
 Kirill A. Shutemov
