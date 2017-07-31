Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E56D66B03A1
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 10:49:37 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a186so23739088wmh.9
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 07:49:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s78si648305wma.251.2017.07.31.07.49.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 07:49:35 -0700 (PDT)
Date: Mon, 31 Jul 2017 16:49:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for
 reclaiming hugepages on OOM events.
Message-ID: <20170731144932.GF4829@dhcp22.suse.cz>
References: <20170727180236.6175-2-Liam.Howlett@Oracle.com>
 <20170728064602.GC2274@dhcp22.suse.cz>
 <20170728113347.rrn5igjyllrj3z4n@node.shutemov.name>
 <20170728122350.GM2274@dhcp22.suse.cz>
 <20170728124443.GO2274@dhcp22.suse.cz>
 <20170729015638.lnazqgf5isjqqkqg@oracle.com>
 <20170731091025.GH15767@dhcp22.suse.cz>
 <20170731135647.wpzk56m5qrmz3xht@oracle.com>
 <20170731140810.GD4829@dhcp22.suse.cz>
 <20170731143735.GI15980@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731143735.GI15980@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Liam R. Howlett" <Liam.Howlett@Oracle.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com

On Mon 31-07-17 07:37:35, Matthew Wilcox wrote:
> On Mon, Jul 31, 2017 at 04:08:10PM +0200, Michal Hocko wrote:
> > On Mon 31-07-17 09:56:48, Liam R. Howlett wrote:
[...]
> > > My focus on hugetlb is that it can stop the automatic recovery of the
> > > system.
> > 
> > How?
> 
> Let me try to explain the situation as I understand it.
> 
> The customer has purchased a 128TB machine in order to run a database.
> They reserve 124TB of memory for use by the database cache.  Everything
> works great.  Then a 4TB memory module goes bad.  The machine reboots
> itself in order to return to operation, now having only 124TB of memory
> and having 124TB of memory reserved.  It OOMs during boot.  The current
> output from our OOM machinery doesn't point the sysadmin at the kernel
> command line parameter as now being the problem.  So they file a priority
> 1 problem ticket ...

Well, I would argue that the oom report is quite clear that the hugetlb
memory has consumed the large part if not whole usable memory and that
should give a clue...

Nevertheless, I can see some merit here, but I am arguing that there
is simply no good way to handle this without admin involvement
unless we want to risk other and much more subtle breakage where the
application really expects it can consume the preallocated hugetlb pool
completely. And I would even argue that the later is more probable than
unintended memory failure reboot cycle. If somebody can tune hugetlb
pool dynamically I would recommend doing so from an init script.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
