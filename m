Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEFE36B057D
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 21:57:45 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k14so64843056qkl.7
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 18:57:45 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 31si19171716qtm.342.2017.07.28.18.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 18:57:44 -0700 (PDT)
Date: Fri, 28 Jul 2017 21:56:38 -0400
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: Re: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for
 reclaiming hugepages on OOM events.
Message-ID: <20170729015638.lnazqgf5isjqqkqg@oracle.com>
References: <20170727180236.6175-1-Liam.Howlett@Oracle.com>
 <20170727180236.6175-2-Liam.Howlett@Oracle.com>
 <20170728064602.GC2274@dhcp22.suse.cz>
 <20170728113347.rrn5igjyllrj3z4n@node.shutemov.name>
 <20170728122350.GM2274@dhcp22.suse.cz>
 <20170728124443.GO2274@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170728124443.GO2274@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com, willy@infradead.org

* Michal Hocko <mhocko@kernel.org> [170728 08:44]:
> On Fri 28-07-17 14:23:50, Michal Hocko wrote:
> > On Fri 28-07-17 14:33:47, Kirill A. Shutemov wrote:
> > > On Fri, Jul 28, 2017 at 08:46:02AM +0200, Michal Hocko wrote:
> > > > On Thu 27-07-17 14:02:36, Liam R. Howlett wrote:
> > > > > When a system runs out of memory it may be desirable to reclaim
> > > > > unreserved hugepages.  This situation arises when a correctly configured
> > > > > system has a memory failure and takes corrective action of rebooting and
> > > > > removing the memory from the memory pool results in a system failing to
> > > > > boot.  With this change, the out of memory handler is able to reclaim
> > > > > any pages that are free and not reserved.
> > > > 
> > > > I am sorry but I have to Nack this. You are breaking the basic contract
> > > > of hugetlb user API. Administrator configures the pool to suit a
> > > > workload. It is a deliberate and privileged action. We allow to
> > > > overcommit that pool should there be a immediate need for more hugetlb
> > > > pages and we do remove those when they are freed. If we don't then this
> > > > should be fixed.

This is certainly a work in progress and I appreciate you taking the
time to point out the issues.  I didn't mean to suggest merging this it
is today.

> > > > Other than that hugetlb pages are not reclaimable by design and users
> > > > do rely on that. Otherwise they could consider using THP instead.
> > > > 
> > > > If somebody configures the initial pool too high it is a configuration
> > > > bug. Just think about it, we do not want to reset lowmem reserves
> > > > configured by admin just because we are hitting the oom killer and yes
> > > > insanely large lowmem reserves might lead to early OOM as well.

The case I raise is a correctly configured system which has a memory
module failure.  Modern systems will reboot and remove the memory from
the memory pool.  Linux will start to load and run out of memory.  I get
that this code has the side effect of doing what you're saying.  Do you
see this as a worth while feature and if so, do you know of a better way
for me to trigger the behaviour?

> > > > 
> > > > Nacked-by: Michal Hocko <mhocko@suse.com>
> > > 
> > > Hm. I'm not sure it's fully justified. To me, reclaiming hugetlb is
> > > something to be considered as last resort after all other measures have
> > > been tried.
> > 
> > System can recover from the OOM killer in most cases and there is no
> > real reason to break contracts which administrator established. On the
> > other hand you cannot assume correct operation of the SW which depends
> > on hugetlb pages in general. Such a SW might get unexpected crashes/data
> > corruptions and what not.

My question about allowing the reclaim to happen all the time was like
Kirill said, if there's memory that's not being used then why panic (or
kill a task)?  I see that Michal has thought this through though.  My
intent was to add this as a config option, but it sounds like that's
also a bad plan.

> 
> And to be clear. The memory hotpug currently does the similar thing via
> dissolve_free_huge_pages and I believe that is wrong as well although
> one could argue that the memory offline is an admin action as well so
> reducing hugetlb pages is a reasonable thing to do. This would be for a
> separate discussion though.
> 
> But OOM can happen for entirely different reasons and hugetlb might be
> configured properly while this change would simply break that setup.
> This is simply nogo.
> 

Yes, this patch is certainly not the final version for that specific
reason.  I didn't see a good way to plug in to the OOM and was looking
for suggestions.  Sorry if that was not clear.

The root problem I'm trying to solve isn't a misconfiguration but to
cover off the case of the system recovering from a failure while Linux
will not.

Here are a few other ideas that may or may not be better (or sane):

Would perhaps specifying a percentage of memory instead of a specific
number be a better approach than reclaiming?  That would still leave
those who use hard values vulnerable but at least provide an alternative
that was safer.  It's also a pretty brutal interface for someone to use.

We could figure out there's a bad memory module and enable this on boot
only?  I am unclear on how to do either of those, but in combination it
would allow the issue to be detected and avoid failures.  I have looked
in to detecting when we're booting and I've not had much luck there.  I
believe dmidecode can pick up disabled modules so that part should be
plausible?  Would enabling this code when a disabled module exists and
during boot be acceptable?

Disable all hugepages passed when there's a disabled memory module and
throw a WARN?

Is there any other options?

Thank you both for your comments and time,
Liam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
