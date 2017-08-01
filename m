Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1814E6B04DB
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 21:26:29 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q66so1406859qki.1
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 18:26:29 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r4si9210364qtr.537.2017.07.31.18.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 18:26:28 -0700 (PDT)
Date: Mon, 31 Jul 2017 21:25:42 -0400
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: Re: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for
 reclaiming hugepages on OOM events.
Message-ID: <20170801012542.i2exb4ehuk2l6wfe@oracle.com>
References: <20170728064602.GC2274@dhcp22.suse.cz>
 <20170728113347.rrn5igjyllrj3z4n@node.shutemov.name>
 <20170728122350.GM2274@dhcp22.suse.cz>
 <20170728124443.GO2274@dhcp22.suse.cz>
 <20170729015638.lnazqgf5isjqqkqg@oracle.com>
 <20170731091025.GH15767@dhcp22.suse.cz>
 <20170731135647.wpzk56m5qrmz3xht@oracle.com>
 <20170731140810.GD4829@dhcp22.suse.cz>
 <20170731143735.GI15980@bombadil.infradead.org>
 <20170731144932.GF4829@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731144932.GF4829@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com

* Michal Hocko <mhocko@kernel.org> [170731 10:49]:
> On Mon 31-07-17 07:37:35, Matthew Wilcox wrote:
> > On Mon, Jul 31, 2017 at 04:08:10PM +0200, Michal Hocko wrote:
> > > On Mon 31-07-17 09:56:48, Liam R. Howlett wrote:
> [...]
> > > > My focus on hugetlb is that it can stop the automatic recovery of the
> > > > system.
> > > 
> > > How?
> > 
> > Let me try to explain the situation as I understand it.
> > 
> > The customer has purchased a 128TB machine in order to run a database.
> > They reserve 124TB of memory for use by the database cache.  Everything
> > works great.  Then a 4TB memory module goes bad.  The machine reboots
> > itself in order to return to operation, now having only 124TB of memory
> > and having 124TB of memory reserved.  It OOMs during boot.  The current
> > output from our OOM machinery doesn't point the sysadmin at the kernel
> > command line parameter as now being the problem.  So they file a priority
> > 1 problem ticket ...
> 
> Well, I would argue that the oom report is quite clear that the hugetlb
> memory has consumed the large part if not whole usable memory and that
> should give a clue...

Can you please show me where it's clear?  Are you referring to these
messages?

Node 0 hugepages_total=15999 hugepages_free=15999 hugepages_surp=0
hugepages_size=8192kB
Node 1 hugepages_total=16157 hugepages_free=16157 hugepages_surp=0
hugepages_size=8192kB

I'm not trying to be obtuse, I'm just not sure what message in which you
are referring.

> 
> Nevertheless, I can see some merit here, but I am arguing that there
> is simply no good way to handle this without admin involvement
> unless we want to risk other and much more subtle breakage where the
> application really expects it can consume the preallocated hugetlb pool
> completely. And I would even argue that the later is more probable than
> unintended memory failure reboot cycle.  If somebody can tune hugetlb
> pool dynamically I would recommend doing so from an init script.

I agree that an admin involvement is necessary for a full recovery but
I'm trying to make the best of a bad situation.

Why can't it consume the preallocated hugetlb pool completely? I'm just
trying to make the pool a little smaller.  I thought that when the
application fails to allocate a hugetlb it would receive a failure and
need to cope with the allocation failure?

Thanks,
Liam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
