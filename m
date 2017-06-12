Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D53CD6B02C3
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 14:52:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 56so24608971wrx.5
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 11:52:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l193si8425382wmg.30.2017.06.12.11.52.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 11:52:16 -0700 (PDT)
Date: Mon, 12 Jun 2017 20:52:08 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
Message-ID: <20170612185208.GC23493@dhcp22.suse.cz>
References: <20170603005413.10380-1-Liam.Howlett@Oracle.com>
 <20170605045725.GA9248@dhcp22.suse.cz>
 <20170605151541.avidrotxpoiekoy5@oracle.com>
 <20170606054917.GA1189@dhcp22.suse.cz>
 <20170606060147.GB1189@dhcp22.suse.cz>
 <20170612172829.bzjfmm7navnobh4t@oracle.com>
 <20170612174911.GA23493@dhcp22.suse.cz>
 <20170612183717.qgcusdfvdfcj7zr7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170612183717.qgcusdfvdfcj7zr7@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mike.kravetz@Oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

On Mon 12-06-17 14:37:18, Liam R. Howlett wrote:
> * Michal Hocko <mhocko@suse.com> [170612 13:49]:
> > On Mon 12-06-17 13:28:30, Liam R. Howlett wrote:
> > > * Michal Hocko <mhocko@suse.com> [170606 02:01]:
> > [..]
> > > > And just to be more clear. I do not _object_ to the warning I just
> > > > _think_ it is not very useful actually. If somebody misconfigure so
> > > > badly that hugetlb allocations fail during the boot then it will be
> > > > very likely visible. But if somebody misconfigures slightly less to not
> > > > fail the system is very likely to not work properly and there will be no
> > > > warning that this might be the source of problems. So is it worth adding
> > > > more code with that limited usefulness?
> > > 
> > > I think telling the user that something failed is very useful.  This
> > > obviously does not cover off all failure cases as you have pointed out,
> > > but it is certainly better than silently continuing as is the case
> > > today.
> > > 
> > > Are you suggesting that the error message be provided if the failure
> > > happens after boot as well?
> > 
> > No, I am just suggesting that the warning as proposed is not useful and
> > it is worth the additional (aleit little) code. It doesn't cover many
> > other miscofigurations which might be even more serious because there
> > would be still _some_ memory left while the system would crawl to death.
> 
> There is already some memory left as long as the huge page size doesn't
> work out to be exactly the amount of free pages.  This is why it's so
> annoying as the OOM kicks in much later in the boot process and leaves
> it up to the user to debug a kernel dump with zero error or warning
> messages about what happened before things went bad.

Exactly. And I my argument is that this won't get handled by your patch.

> Worse yet, I've
> seen several pages of OOMs scroll by as each processor takes turns
> telling the user it is out of memory.

This is not how the oom report works. We only report when _killing_ a
task. And the reason you have seen so many of them is that killing any
number of processes will not help. Yes this is quite subtimal and it
would be great to see that the OOM is due to hugetlb configuration or
e.g. too large ramdisk or unreclaimable shmem. Fixing that would be much
more reasonable than sticking a warning that will almost never trigger
unless somebody messed up royally.

> If there's no message stating any
> configuration issue, then many admins would probably think something is
> seriously broken and it's not just a simple typo of K vs M.
> 
> Even though this doesn't catch all errors, I think it's a worth while
> change since this is currently a silent failure which results in a
> system crash.

Seriously, this warning just doesn't help in _most_ miscofigurations. It
just focuses on one particular which really requires to misconfigure
really badly. And there are way too many other ways to screw your system
that way, yet we do not warn about many of those. So just try to step
back and think whether this is something we actually do care about and
if yes then try to come up with a more reasonable warning which would
cover a wider range of misconfigurations.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
