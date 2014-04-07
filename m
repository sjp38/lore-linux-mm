Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A75686B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 11:24:29 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ld10so6886968pab.12
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 08:24:29 -0700 (PDT)
Received: from fujitsu24.fnanic.fujitsu.com (fujitsu24.fnanic.fujitsu.com. [192.240.6.14])
        by mx.google.com with ESMTPS id j4si8504418pad.432.2014.04.07.08.24.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 08:24:28 -0700 (PDT)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Mon, 7 Apr 2014 08:22:12 -0700
Subject: RE: [PATCH v2 1/1] mm: hugetlb: fix stalling when a large number of
 hugepages are freed
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E3097FD1003@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <534260A3.6030807@jp.fujitsu.com>
 <1396876864-vnrouoxp@n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1396876864-vnrouoxp@n-horiguchi@ah.jp.nec.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "m.mizuma@jp.fujitsu.com" <m.mizuma@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "mhocko@suse.cz" <mhocko@suse.cz>, "liwanp@linux.vnet.ibm.com" <liwanp@linux.vnet.ibm.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>



> -----Original Message-----
> From: Naoya Horiguchi [mailto:n-horiguchi@ah.jp.nec.com]
> Sent: Monday, April 07, 2014 9:21 AM
> To: m.mizuma@jp.fujitsu.com
> Cc: linux-mm@kvack.org; akpm@linux-foundation.org; iamjoonsoo.kim@lge.com=
; mhocko@suse.cz; liwanp@linux.vnet.ibm.com;
> aneesh.kumar@linux.vnet.ibm.com; Motohiro Kosaki JP
> Subject: Re: [PATCH v2 1/1] mm: hugetlb: fix stalling when a large number=
 of hugepages are freed
>=20
> On Mon, Apr 07, 2014 at 05:24:03PM +0900, Masayoshi Mizuma wrote:
> > When I decrease the value of nr_hugepage in procfs a lot, a long
> > stalling happens. It is because there is no chance of context switch du=
ring this process.
> >
> > On the other hand, when I allocate a large number of hugepages, there
> > is some chance of context switch. Hence the long stalling doesn't
> > happen during this process. So it's necessary to add the context
> > switch in the freeing process as same as allocating process to avoid th=
e long stalling.
> >
> > When I freed 12 TB hugapages with kernel-2.6.32-358.el6, the freeing
> > process occupied a CPU over 150 seconds and following softlockup
> > message appeared twice or more.
> >
> > --
> > $ echo 6000000 > /proc/sys/vm/nr_hugepages $ cat
> > /proc/sys/vm/nr_hugepages
> > 6000000
> > $ grep ^Huge /proc/meminfo
> > HugePages_Total:   6000000
> > HugePages_Free:    6000000
> > HugePages_Rsvd:        0
> > HugePages_Surp:        0
> > Hugepagesize:       2048 kB
> > $ echo 0 > /proc/sys/vm/nr_hugepages
> >
> > BUG: soft lockup - CPU#16 stuck for 67s! [sh:12883] ...
> > Pid: 12883, comm: sh Not tainted 2.6.32-358.el6.x86_64 #1 Call Trace:
> >  [<ffffffff8115a438>] ? free_pool_huge_page+0xb8/0xd0
> > [<ffffffff8115a578>] ? set_max_huge_pages+0x128/0x190
> > [<ffffffff8115c663>] ? hugetlb_sysctl_handler_common+0x113/0x140
> >  [<ffffffff8115c6de>] ? hugetlb_sysctl_handler+0x1e/0x20
> > [<ffffffff811f3097>] ? proc_sys_call_handler+0x97/0xd0
> > [<ffffffff811f30e4>] ? proc_sys_write+0x14/0x20  [<ffffffff81180f98>]
> > ? vfs_write+0xb8/0x1a0  [<ffffffff81181891>] ? sys_write+0x51/0x90
> > [<ffffffff810dc565>] ? __audit_syscall_exit+0x265/0x290
> > [<ffffffff8100b072>] ? system_call_fastpath+0x16/0x1b
> > --
> > I have not confirmed this problem with upstream kernels because I am
> > not able to prepare the machine equipped with 12TB memory now.
> > However I confirmed that the amount of decreasing hugepages was
> > directly proportional to the amount of required time.
> >
> > I measured required times on a smaller machine. It showed 130-145
> > hugepages decreased in a millisecond.
> >
> > Amount of decreasing     Required time      Decreasing rate
> > hugepages                     (msec)         (pages/msec)
> > ------------------------------------------------------------
> > 10,000 pages =3D=3D 20GB         70 -  74          135-142
> > 30,000 pages =3D=3D 60GB        208 - 229          131-144
> >
> > It means decrement of 6TB hugepages will trigger a long stalling
> > (about 20sec), in this decreasing rate.
> >
> > * Changes in v2
> > - Adding cond_resched_lock() in return_unused_surplus_pages()
> >   Because when freeing a number of surplus pages, same problems happen.
> >
> > Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> > Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> Thanks,
> Naoya Horiguchi

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
