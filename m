Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA1A6B0537
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 08:44:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x64so14981863wmg.11
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 05:44:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e13si5073429wmc.10.2017.07.28.05.44.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 05:44:46 -0700 (PDT)
Date: Fri, 28 Jul 2017 14:44:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for
 reclaiming hugepages on OOM events.
Message-ID: <20170728124443.GO2274@dhcp22.suse.cz>
References: <20170727180236.6175-1-Liam.Howlett@Oracle.com>
 <20170727180236.6175-2-Liam.Howlett@Oracle.com>
 <20170728064602.GC2274@dhcp22.suse.cz>
 <20170728113347.rrn5igjyllrj3z4n@node.shutemov.name>
 <20170728122350.GM2274@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170728122350.GM2274@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Liam R. Howlett" <Liam.Howlett@Oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com, willy@infradead.org

On Fri 28-07-17 14:23:50, Michal Hocko wrote:
> On Fri 28-07-17 14:33:47, Kirill A. Shutemov wrote:
> > On Fri, Jul 28, 2017 at 08:46:02AM +0200, Michal Hocko wrote:
> > > On Thu 27-07-17 14:02:36, Liam R. Howlett wrote:
> > > > When a system runs out of memory it may be desirable to reclaim
> > > > unreserved hugepages.  This situation arises when a correctly configured
> > > > system has a memory failure and takes corrective action of rebooting and
> > > > removing the memory from the memory pool results in a system failing to
> > > > boot.  With this change, the out of memory handler is able to reclaim
> > > > any pages that are free and not reserved.
> > > 
> > > I am sorry but I have to Nack this. You are breaking the basic contract
> > > of hugetlb user API. Administrator configures the pool to suit a
> > > workload. It is a deliberate and privileged action. We allow to
> > > overcommit that pool should there be a immediate need for more hugetlb
> > > pages and we do remove those when they are freed. If we don't then this
> > > should be fixed.
> > > Other than that hugetlb pages are not reclaimable by design and users
> > > do rely on that. Otherwise they could consider using THP instead.
> > > 
> > > If somebody configures the initial pool too high it is a configuration
> > > bug. Just think about it, we do not want to reset lowmem reserves
> > > configured by admin just because we are hitting the oom killer and yes
> > > insanely large lowmem reserves might lead to early OOM as well.
> > > 
> > > Nacked-by: Michal Hocko <mhocko@suse.com>
> > 
> > Hm. I'm not sure it's fully justified. To me, reclaiming hugetlb is
> > something to be considered as last resort after all other measures have
> > been tried.
> 
> System can recover from the OOM killer in most cases and there is no
> real reason to break contracts which administrator established. On the
> other hand you cannot assume correct operation of the SW which depends
> on hugetlb pages in general. Such a SW might get unexpected crashes/data
> corruptions and what not.

And to be clear. The memory hotpug currently does the similar thing via
dissolve_free_huge_pages and I believe that is wrong as well although
one could argue that the memory offline is an admin action as well so
reducing hugetlb pages is a reasonable thing to do. This would be for a
separate discussion though.

But OOM can happen for entirely different reasons and hugetlb might be
configured properly while this change would simply break that setup.
This is simply nogo.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
