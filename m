Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 164D46B0609
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 09:57:47 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id t139so424668954ywg.6
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 06:57:47 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id m127si7079498ywf.538.2017.07.31.06.57.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 06:57:46 -0700 (PDT)
Date: Mon, 31 Jul 2017 09:56:48 -0400
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: Re: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for
 reclaiming hugepages on OOM events.
Message-ID: <20170731135647.wpzk56m5qrmz3xht@oracle.com>
References: <20170727180236.6175-1-Liam.Howlett@Oracle.com>
 <20170727180236.6175-2-Liam.Howlett@Oracle.com>
 <20170728064602.GC2274@dhcp22.suse.cz>
 <20170728113347.rrn5igjyllrj3z4n@node.shutemov.name>
 <20170728122350.GM2274@dhcp22.suse.cz>
 <20170728124443.GO2274@dhcp22.suse.cz>
 <20170729015638.lnazqgf5isjqqkqg@oracle.com>
 <20170731091025.GH15767@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731091025.GH15767@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com, willy@infradead.org

* Michal Hocko <mhocko@kernel.org> [170731 05:10]:
> On Fri 28-07-17 21:56:38, Liam R. Howlett wrote:
> > * Michal Hocko <mhocko@kernel.org> [170728 08:44]:
> > > On Fri 28-07-17 14:23:50, Michal Hocko wrote:
> > > > > > Other than that hugetlb pages are not reclaimable by design and users
> > > > > > do rely on that. Otherwise they could consider using THP instead.
> > > > > > 
> > > > > > If somebody configures the initial pool too high it is a configuration
> > > > > > bug. Just think about it, we do not want to reset lowmem reserves
> > > > > > configured by admin just because we are hitting the oom killer and yes
> > > > > > insanely large lowmem reserves might lead to early OOM as well.
> > 
> > The case I raise is a correctly configured system which has a memory
> > module failure.
> 
> So you are concerned about MCEs due to failing memory modules? If yes
> why do you care about hugetlb in particular?

No,  I am concerned about a failed memory module.  The system will
detect certain failures, mark the memory as bad and automatically
reboot.  Up on rebooting, that module will not be used.

My focus on hugetlb is that it can stop the automatic recovery of the
system.  Are there other reservations that should also be considered?

> 
> > Modern systems will reboot and remove the memory from
> > the memory pool.  Linux will start to load and run out of memory.  I get
> > that this code has the side effect of doing what you're saying.  Do you
> > see this as a worth while feature and if so, do you know of a better way
> > for me to trigger the behaviour?
> 
> I do not understand your question. Could you elaborate more please? Are
> you talking about system going into OOM because of too many MCEs?

No,  I'm talking about failed memory for whatever reason.  The system
reboots by a hardware means (I believe the memory controller) and
removes the memory on that failed module from the pool.  Now you
effectively have a system with less memory than before which invalidates
your configuration.  Is it worth while to have Linux successfully boot
when the system attempts to recover from a failure?

> 
> > > > > > Nacked-by: Michal Hocko <mhocko@suse.com>
> > > > > 
> > > > > Hm. I'm not sure it's fully justified. To me, reclaiming hugetlb is
> > > > > something to be considered as last resort after all other measures have
> > > > > been tried.
> > > > 
> > > > System can recover from the OOM killer in most cases and there is no
> > > > real reason to break contracts which administrator established. On the
> > > > other hand you cannot assume correct operation of the SW which depends
> > > > on hugetlb pages in general. Such a SW might get unexpected crashes/data
> > > > corruptions and what not.
> > 
> > My question about allowing the reclaim to happen all the time was like
> > Kirill said, if there's memory that's not being used then why panic (or
> > kill a task)?  I see that Michal has thought this through though.  My
> > intent was to add this as a config option, but it sounds like that's
> > also a bad plan.
> 
> You cannot reclaim something that the administrator has asked for to be
> available. Sure we can reclaim the excess if there is any but that is
> not what your patch does

I'm looking at the free_huge_pages vs the resv_huge_pages.  I thought
the resv_huge_pages were the free pages that are already requested, so
if there were more free than reserved then they would be excess?

>  
> > > And to be clear. The memory hotpug currently does the similar thing via
> > > dissolve_free_huge_pages and I believe that is wrong as well although
> > > one could argue that the memory offline is an admin action as well so
> > > reducing hugetlb pages is a reasonable thing to do. This would be for a
> > > separate discussion though.
> > > 
> > > But OOM can happen for entirely different reasons and hugetlb might be
> > > configured properly while this change would simply break that setup.
> > > This is simply nogo.
> > > 
> > 
> > Yes, this patch is certainly not the final version for that specific
> > reason.  I didn't see a good way to plug in to the OOM and was looking
> > for suggestions.  Sorry if that was not clear.
> > 
> > The root problem I'm trying to solve isn't a misconfiguration but to
> > cover off the case of the system recovering from a failure while Linux
> > will not.
> 
> Please be more specific what you mean by the "failure". It is hard to
> comment on further things without a clear definition what is the problem
> you are trying to address.

The failure is when you have a memory module which is detected as bad
for any reason by the hardware which causes the memory as being marked
bad and removed from the memory pool on an automatic reboot.  Sorry for
not being clear here, I thought my comments would have been clear from
what I stated in RFC PATCH 0/1.

I hope this helps clarify things.

Thanks,
Liam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
