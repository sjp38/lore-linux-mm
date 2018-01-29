Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 89F826B0006
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 05:23:15 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id f8so4577633wmi.9
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 02:23:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 93si10148049wri.328.2018.01.29.02.23.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 02:23:14 -0800 (PST)
Date: Mon, 29 Jan 2018 10:54:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: hwpoison: disable memory error handling on 1GB
 hugepage
Message-ID: <20180129095425.GA21609@dhcp22.suse.cz>
References: <1517207283-15769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180129063054.GA5205@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180129063054.GA5205@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon 29-01-18 06:30:55, Naoya Horiguchi wrote:
> My apology, I forgot to CC to the mailing lists.
> 
> On Mon, Jan 29, 2018 at 03:28:03PM +0900, Naoya Horiguchi wrote:
> > Recently the following BUG was reported:
> > 
> >     Injecting memory failure for pfn 0x3c0000 at process virtual address 0x7fe300000000
> >     Memory failure: 0x3c0000: recovery action for huge page: Recovered
> >     BUG: unable to handle kernel paging request at ffff8dfcc0003000
> >     IP: gup_pgd_range+0x1f0/0xc20
> >     PGD 17ae72067 P4D 17ae72067 PUD 0
> >     Oops: 0000 [#1] SMP PTI
> >     ...
> >     CPU: 3 PID: 5467 Comm: hugetlb_1gb Not tainted 4.15.0-rc8-mm1-abc+ #3
> >     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-1.fc25 04/01/2014
> > 
> > You can easily reproduce this by calling madvise(MADV_HWPOISON) twice on
> > a 1GB hugepage. This happens because get_user_pages_fast() is not aware
> > of a migration entry on pud that was created in the 1st madvise() event.

Do pgd size pages work properly?

> > I think that conversion to pud-aligned migration entry is working,
> > but other MM code walking over page table isn't prepared for it.
> > We need some time and effort to make all this work properly, so
> > this patch avoids the reported bug by just disabling error handling
> > for 1GB hugepage.

Can we also get some documentation which would describe all requirements
for HWPoison pages to work properly please?

> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Michal Hocko <mhocko@suse.com>

We probably want a backport to stable as well. Although regular process
cannot get giga pages easily without admin help it is still not nice to
oops like this.

> > ---
> >  include/linux/mm.h  | 1 +
> >  mm/memory-failure.c | 7 +++++++
> >  2 files changed, 8 insertions(+)
> > 
> > diff --git v4.15-rc8-mmotm-2018-01-18-16-31/include/linux/mm.h v4.15-rc8-mmotm-2018-01-18-16-31_patched/include/linux/mm.h
> > index 63f7ba1..166864e 100644
> > --- v4.15-rc8-mmotm-2018-01-18-16-31/include/linux/mm.h
> > +++ v4.15-rc8-mmotm-2018-01-18-16-31_patched/include/linux/mm.h
> > @@ -2607,6 +2607,7 @@ enum mf_action_page_type {
> >  	MF_MSG_POISONED_HUGE,
> >  	MF_MSG_HUGE,
> >  	MF_MSG_FREE_HUGE,
> > +	MF_MSG_GIGANTIC,
> >  	MF_MSG_UNMAP_FAILED,
> >  	MF_MSG_DIRTY_SWAPCACHE,
> >  	MF_MSG_CLEAN_SWAPCACHE,
> > diff --git v4.15-rc8-mmotm-2018-01-18-16-31/mm/memory-failure.c v4.15-rc8-mmotm-2018-01-18-16-31_patched/mm/memory-failure.c
> > index d530ac1..c497588 100644
> > --- v4.15-rc8-mmotm-2018-01-18-16-31/mm/memory-failure.c
> > +++ v4.15-rc8-mmotm-2018-01-18-16-31_patched/mm/memory-failure.c
> > @@ -508,6 +508,7 @@ static const char * const action_page_types[] = {
> >  	[MF_MSG_POISONED_HUGE]		= "huge page already hardware poisoned",
> >  	[MF_MSG_HUGE]			= "huge page",
> >  	[MF_MSG_FREE_HUGE]		= "free huge page",
> > +	[MF_MSG_GIGANTIC]		= "gigantic page",
> >  	[MF_MSG_UNMAP_FAILED]		= "unmapping failed page",
> >  	[MF_MSG_DIRTY_SWAPCACHE]	= "dirty swapcache page",
> >  	[MF_MSG_CLEAN_SWAPCACHE]	= "clean swapcache page",
> > @@ -1090,6 +1091,12 @@ static int memory_failure_hugetlb(unsigned long pfn, int trapno, int flags)
> >  		return 0;
> >  	}
> >  
> > +	if (hstate_is_gigantic(page_hstate(head))) {
> > +		action_result(pfn, MF_MSG_GIGANTIC, MF_IGNORED);
> > +		res = -EBUSY;
> > +		goto out;
> > +	}
> > +
> >  	if (!hwpoison_user_mappings(p, pfn, trapno, flags, &head)) {
> >  		action_result(pfn, MF_MSG_UNMAP_FAILED, MF_IGNORED);
> >  		res = -EBUSY;
> > -- 
> > 2.7.0
> > 
> > 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
