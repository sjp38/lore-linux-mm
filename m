Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92BC56B0503
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 04:28:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w63so1342547wrc.5
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 01:28:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 91si28224306wra.135.2017.08.01.01.28.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 01:28:45 -0700 (PDT)
Date: Tue, 1 Aug 2017 10:28:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for
 reclaiming hugepages on OOM events.
Message-ID: <20170801082841.GA15774@dhcp22.suse.cz>
References: <20170728113347.rrn5igjyllrj3z4n@node.shutemov.name>
 <20170728122350.GM2274@dhcp22.suse.cz>
 <20170728124443.GO2274@dhcp22.suse.cz>
 <20170729015638.lnazqgf5isjqqkqg@oracle.com>
 <20170731091025.GH15767@dhcp22.suse.cz>
 <20170731135647.wpzk56m5qrmz3xht@oracle.com>
 <20170731140810.GD4829@dhcp22.suse.cz>
 <20170731143735.GI15980@bombadil.infradead.org>
 <20170731144932.GF4829@dhcp22.suse.cz>
 <20170801012542.i2exb4ehuk2l6wfe@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170801012542.i2exb4ehuk2l6wfe@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com

On Mon 31-07-17 21:25:42, Liam R. Howlett wrote:
> * Michal Hocko <mhocko@kernel.org> [170731 10:49]:
> > On Mon 31-07-17 07:37:35, Matthew Wilcox wrote:
> > > On Mon, Jul 31, 2017 at 04:08:10PM +0200, Michal Hocko wrote:
> > > > On Mon 31-07-17 09:56:48, Liam R. Howlett wrote:
> > [...]
> > > > > My focus on hugetlb is that it can stop the automatic recovery of the
> > > > > system.
> > > > 
> > > > How?
> > > 
> > > Let me try to explain the situation as I understand it.
> > > 
> > > The customer has purchased a 128TB machine in order to run a database.
> > > They reserve 124TB of memory for use by the database cache.  Everything
> > > works great.  Then a 4TB memory module goes bad.  The machine reboots
> > > itself in order to return to operation, now having only 124TB of memory
> > > and having 124TB of memory reserved.  It OOMs during boot.  The current
> > > output from our OOM machinery doesn't point the sysadmin at the kernel
> > > command line parameter as now being the problem.  So they file a priority
> > > 1 problem ticket ...
> > 
> > Well, I would argue that the oom report is quite clear that the hugetlb
> > memory has consumed the large part if not whole usable memory and that
> > should give a clue...
> 
> Can you please show me where it's clear?  Are you referring to these
> messages?
> 
> Node 0 hugepages_total=15999 hugepages_free=15999 hugepages_surp=0
> hugepages_size=8192kB
> Node 1 hugepages_total=16157 hugepages_free=16157 hugepages_surp=0
> hugepages_size=8192kB
> 
> I'm not trying to be obtuse, I'm just not sure what message in which you
> are referring.

Yes the above is the part of the oom report I had in mind.

> > Nevertheless, I can see some merit here, but I am arguing that there
> > is simply no good way to handle this without admin involvement
> > unless we want to risk other and much more subtle breakage where the
> > application really expects it can consume the preallocated hugetlb pool
> > completely. And I would even argue that the later is more probable than
> > unintended memory failure reboot cycle.  If somebody can tune hugetlb
> > pool dynamically I would recommend doing so from an init script.
> 
> I agree that an admin involvement is necessary for a full recovery but
> I'm trying to make the best of a bad situation.

Is this situation so common to risk breaking an existing userspace which
rely on having all hugetlb pages availble once they are configured?

> Why can't it consume the preallocated hugetlb pool completely?

Because it is not so unrealistic to assume that some userspace might
_rely_ on having the pool available at any time with the capacity
configured during the initialization. The hugetlb API basically
guarantee that once the pool is preallocated it will never get reclaimed
unless administrator intervene.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
