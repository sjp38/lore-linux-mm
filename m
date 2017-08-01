Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9836B04B6
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 10:42:51 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id f72so28870045ywb.4
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 07:42:51 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d4si1671089ybe.164.2017.08.01.07.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 07:42:50 -0700 (PDT)
Date: Tue, 1 Aug 2017 10:41:56 -0400
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: Re: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for
 reclaiming hugepages on OOM events.
Message-ID: <20170801144155.ouavtheapvslpqvc@oracle.com>
References: <20170728064602.GC2274@dhcp22.suse.cz>
 <20170728113347.rrn5igjyllrj3z4n@node.shutemov.name>
 <20170728122350.GM2274@dhcp22.suse.cz>
 <20170728124443.GO2274@dhcp22.suse.cz>
 <20170729015638.lnazqgf5isjqqkqg@oracle.com>
 <20170731091025.GH15767@dhcp22.suse.cz>
 <20170731135647.wpzk56m5qrmz3xht@oracle.com>
 <20170731140810.GD4829@dhcp22.suse.cz>
 <20170801011124.co373mej7o6u7flu@oracle.com>
 <20170801082952.GB15774@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170801082952.GB15774@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com, willy@infradead.org

* Michal Hocko <mhocko@kernel.org> [170801 04:30]:
> On Mon 31-07-17 21:11:25, Liam R. Howlett wrote:
> > * Michal Hocko <mhocko@kernel.org> [170731 10:08]:
> > > On Mon 31-07-17 09:56:48, Liam R. Howlett wrote:
> [...]
> > > > No,  I'm talking about failed memory for whatever reason.  The system
> > > > reboots by a hardware means (I believe the memory controller) and
> > > > removes the memory on that failed module from the pool.  Now you
> > > > effectively have a system with less memory than before which invalidates
> > > > your configuration.  Is it worth while to have Linux successfully boot
> > > > when the system attempts to recover from a failure?
> > > 
> > > Cetainly yes but if you boot with much less memory and you want to use
> > > hugetlb pages then you have to reconsider and maybe even reconfigure
> > > your workload to reflect new conditions. So I am not really sure this
> > > can be fully automated.
> > > 
> > 
> > I agree.  A reconfiguration or repair is required to have optimum
> > performance.  Would you agree that having functioning system better than
> > a reboot loop or hang on a panic?  It's also easier to reconfigure a
> > system that's booting.
> 
> Absolutely. The thing is that I am not even sure that the hugetlb
> problem is real. Using hugetlb reservation from the boot command line
> parameter is easily fixable (just update the boot comand line from the
> boot loader). From my experience the init time hugetlb initialization
> is usually trying to be portable and as such configures a certain
> percentage of the available memory for hugetlb (some of them even on per
> NUMA node basis). Even if somebody uses hard coded values then this is
> something that is fixable during recovery.

This was my thought when I was first assigned the bug for my last patch
for adding the log message of the hugetlb allocation failure but during
our discussion I was assigned two more near-identical bugs.  From what I
can tell the people following a setup guide do not know how to edit the
grub command line easily once in a boot loop or don't have a decent
enough console setup to do so.  Worse yet, all three of the bugs were
filed as kernel bugs because people didn't even realise it was a setup
issue.  I think the sysctl way of setting the hugetlb is the safest.
But since we provide a kernel command line way of setting the hugetlb,
it seems reasonable to make the user error as transparent as possible.
This RFC was an extension of looking at how people arrive at an OOM
error on boot when using hugetlb.

> 
> That being said I am not sure you are focusing on a real problem while
> the solution you are proposing might break an existing userspace. Please
> try to play with your memory recovery feature some more with real
> hugetlb usecases (Oracle DB is a heavy user AFAIR) and see what the real
> life problems might happen and we can revisit potential solutions with
> more data in hands.


Okay, thank you.  I will re-examine the issue and see about a different
approach.  I appreciate the time you have taken to look at my RFC.

Thanks,
Liam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
