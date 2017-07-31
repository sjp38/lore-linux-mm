Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BFCB6B02B4
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 10:08:15 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r7so46808293wrb.0
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 07:08:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b26si27062748wra.97.2017.07.31.07.08.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 07:08:13 -0700 (PDT)
Date: Mon, 31 Jul 2017 16:08:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for
 reclaiming hugepages on OOM events.
Message-ID: <20170731140810.GD4829@dhcp22.suse.cz>
References: <20170727180236.6175-1-Liam.Howlett@Oracle.com>
 <20170727180236.6175-2-Liam.Howlett@Oracle.com>
 <20170728064602.GC2274@dhcp22.suse.cz>
 <20170728113347.rrn5igjyllrj3z4n@node.shutemov.name>
 <20170728122350.GM2274@dhcp22.suse.cz>
 <20170728124443.GO2274@dhcp22.suse.cz>
 <20170729015638.lnazqgf5isjqqkqg@oracle.com>
 <20170731091025.GH15767@dhcp22.suse.cz>
 <20170731135647.wpzk56m5qrmz3xht@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731135647.wpzk56m5qrmz3xht@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com, willy@infradead.org

On Mon 31-07-17 09:56:48, Liam R. Howlett wrote:
> * Michal Hocko <mhocko@kernel.org> [170731 05:10]:
> > On Fri 28-07-17 21:56:38, Liam R. Howlett wrote:
> > > * Michal Hocko <mhocko@kernel.org> [170728 08:44]:
> > > > On Fri 28-07-17 14:23:50, Michal Hocko wrote:
> > > > > > > Other than that hugetlb pages are not reclaimable by design and users
> > > > > > > do rely on that. Otherwise they could consider using THP instead.
> > > > > > > 
> > > > > > > If somebody configures the initial pool too high it is a configuration
> > > > > > > bug. Just think about it, we do not want to reset lowmem reserves
> > > > > > > configured by admin just because we are hitting the oom killer and yes
> > > > > > > insanely large lowmem reserves might lead to early OOM as well.
> > > 
> > > The case I raise is a correctly configured system which has a memory
> > > module failure.
> > 
> > So you are concerned about MCEs due to failing memory modules? If yes
> > why do you care about hugetlb in particular?
> 
> No,  I am concerned about a failed memory module.  The system will
> detect certain failures, mark the memory as bad and automatically
> reboot.  Up on rebooting, that module will not be used.

How do you detect/configure this? We do have HWPoison infrastructure

> My focus on hugetlb is that it can stop the automatic recovery of the
> system.

How?

> Are there other reservations that should also be considered?

What about any other memory reservations by memmap= kernel command line?
 
> > > Modern systems will reboot and remove the memory from
> > > the memory pool.  Linux will start to load and run out of memory.  I get
> > > that this code has the side effect of doing what you're saying.  Do you
> > > see this as a worth while feature and if so, do you know of a better way
> > > for me to trigger the behaviour?
> > 
> > I do not understand your question. Could you elaborate more please? Are
> > you talking about system going into OOM because of too many MCEs?
> 
> No,  I'm talking about failed memory for whatever reason.  The system
> reboots by a hardware means (I believe the memory controller) and
> removes the memory on that failed module from the pool.  Now you
> effectively have a system with less memory than before which invalidates
> your configuration.  Is it worth while to have Linux successfully boot
> when the system attempts to recover from a failure?

Cetainly yes but if you boot with much less memory and you want to use
hugetlb pages then you have to reconsider and maybe even reconfigure
your workload to reflect new conditions. So I am not really sure this
can be fully automated.

> > > > > > > Nacked-by: Michal Hocko <mhocko@suse.com>
> > > > > > 
> > > > > > Hm. I'm not sure it's fully justified. To me, reclaiming hugetlb is
> > > > > > something to be considered as last resort after all other measures have
> > > > > > been tried.
> > > > > 
> > > > > System can recover from the OOM killer in most cases and there is no
> > > > > real reason to break contracts which administrator established. On the
> > > > > other hand you cannot assume correct operation of the SW which depends
> > > > > on hugetlb pages in general. Such a SW might get unexpected crashes/data
> > > > > corruptions and what not.
> > > 
> > > My question about allowing the reclaim to happen all the time was like
> > > Kirill said, if there's memory that's not being used then why panic (or
> > > kill a task)?  I see that Michal has thought this through though.  My
> > > intent was to add this as a config option, but it sounds like that's
> > > also a bad plan.
> > 
> > You cannot reclaim something that the administrator has asked for to be
> > available. Sure we can reclaim the excess if there is any but that is
> > not what your patch does
> 
> I'm looking at the free_huge_pages vs the resv_huge_pages.  I thought
> the resv_huge_pages were the free pages that are already requested, so
> if there were more free than reserved then they would be excess?

The terminology is little be confusing here. Hugetlb memory we have
committed into is reserved (e.g. by mmap) and we surely can have free
pages on top of resv_huge_pages but that is not an excess yet. We can
have surplus pages which would be an excess over what admin configured
initially. See Documentation/vm/{hugetlbpage.txt,hugetlbfs_reserv.txt}
for more information.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
