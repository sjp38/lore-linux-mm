Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B64696B03BD
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 10:37:39 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u199so259874691pgb.13
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 07:37:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q2si16505888pgd.227.2017.07.31.07.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 07:37:38 -0700 (PDT)
Date: Mon, 31 Jul 2017 07:37:35 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for
 reclaiming hugepages on OOM events.
Message-ID: <20170731143735.GI15980@bombadil.infradead.org>
References: <20170727180236.6175-1-Liam.Howlett@Oracle.com>
 <20170727180236.6175-2-Liam.Howlett@Oracle.com>
 <20170728064602.GC2274@dhcp22.suse.cz>
 <20170728113347.rrn5igjyllrj3z4n@node.shutemov.name>
 <20170728122350.GM2274@dhcp22.suse.cz>
 <20170728124443.GO2274@dhcp22.suse.cz>
 <20170729015638.lnazqgf5isjqqkqg@oracle.com>
 <20170731091025.GH15767@dhcp22.suse.cz>
 <20170731135647.wpzk56m5qrmz3xht@oracle.com>
 <20170731140810.GD4829@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731140810.GD4829@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Liam R. Howlett" <Liam.Howlett@Oracle.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com

On Mon, Jul 31, 2017 at 04:08:10PM +0200, Michal Hocko wrote:
> On Mon 31-07-17 09:56:48, Liam R. Howlett wrote:
> > * Michal Hocko <mhocko@kernel.org> [170731 05:10]:
> > > On Fri 28-07-17 21:56:38, Liam R. Howlett wrote:
> > > > The case I raise is a correctly configured system which has a memory
> > > > module failure.
> > > 
> > > So you are concerned about MCEs due to failing memory modules? If yes
> > > why do you care about hugetlb in particular?
> > 
> > No,  I am concerned about a failed memory module.  The system will
> > detect certain failures, mark the memory as bad and automatically
> > reboot.  Up on rebooting, that module will not be used.
> 
> How do you detect/configure this? We do have HWPoison infrastructure
> 
> > My focus on hugetlb is that it can stop the automatic recovery of the
> > system.
> 
> How?

Let me try to explain the situation as I understand it.

The customer has purchased a 128TB machine in order to run a database.
They reserve 124TB of memory for use by the database cache.  Everything
works great.  Then a 4TB memory module goes bad.  The machine reboots
itself in order to return to operation, now having only 124TB of memory
and having 124TB of memory reserved.  It OOMs during boot.  The current
output from our OOM machinery doesn't point the sysadmin at the kernel
command line parameter as now being the problem.  So they file a priority
1 problem ticket ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
