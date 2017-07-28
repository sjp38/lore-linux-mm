Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83ADD6B0529
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 07:33:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e204so12537449wma.2
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 04:33:51 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id j189si12745614wmd.191.2017.07.28.04.33.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 04:33:50 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id y206so4030385wmd.5
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 04:33:50 -0700 (PDT)
Date: Fri, 28 Jul 2017 14:33:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for
 reclaiming hugepages on OOM events.
Message-ID: <20170728113347.rrn5igjyllrj3z4n@node.shutemov.name>
References: <20170727180236.6175-1-Liam.Howlett@Oracle.com>
 <20170727180236.6175-2-Liam.Howlett@Oracle.com>
 <20170728064602.GC2274@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170728064602.GC2274@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Liam R. Howlett" <Liam.Howlett@Oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com, willy@infradead.org

On Fri, Jul 28, 2017 at 08:46:02AM +0200, Michal Hocko wrote:
> On Thu 27-07-17 14:02:36, Liam R. Howlett wrote:
> > When a system runs out of memory it may be desirable to reclaim
> > unreserved hugepages.  This situation arises when a correctly configured
> > system has a memory failure and takes corrective action of rebooting and
> > removing the memory from the memory pool results in a system failing to
> > boot.  With this change, the out of memory handler is able to reclaim
> > any pages that are free and not reserved.
> 
> I am sorry but I have to Nack this. You are breaking the basic contract
> of hugetlb user API. Administrator configures the pool to suit a
> workload. It is a deliberate and privileged action. We allow to
> overcommit that pool should there be a immediate need for more hugetlb
> pages and we do remove those when they are freed. If we don't then this
> should be fixed.
> Other than that hugetlb pages are not reclaimable by design and users
> do rely on that. Otherwise they could consider using THP instead.
> 
> If somebody configures the initial pool too high it is a configuration
> bug. Just think about it, we do not want to reset lowmem reserves
> configured by admin just because we are hitting the oom killer and yes
> insanely large lowmem reserves might lead to early OOM as well.
> 
> Nacked-by: Michal Hocko <mhocko@suse.com>

Hm. I'm not sure it's fully justified. To me, reclaiming hugetlb is
something to be considered as last resort after all other measures have
been tried.

I think we can allow hugetlb reclaim just to keep system alive, taint
kernel and indicate that "reboot needed".

The situation is somewhat similar to BUG() vs. WARN().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
