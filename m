Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3C78E6B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 04:56:48 -0500 (EST)
Date: Tue, 4 Jan 2011 10:56:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC]
 /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
Message-ID: <20110104095641.GA8651@tiehlicka.suse.cz>
References: <1060163918.101411.1293793346203.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <617041603.101416.1293793701124.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <617041603.101416.1293793701124.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri 31-12-10 06:08:21, CAI Qian wrote:
> Hi,

Hi,

> 
> Problem: nr_overcommit_hugepages for 1gb hugepage went crazy.
> 
> Symptom:
> 1) setup 1gb hugepages.
> # cat /proc/cmdline
> default_hugepagesz=1g hugepagesz=1g hugepages=1
> # cat /proc/meminfo
> ...
> HugePages_Total:       1
> HugePages_Free:        1
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:    1048576 kB
> ...
> 
> 2) set nr_overcommit_hugepages
> # echo 1 >/sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
> # cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
> 1
> 
> 3) overcommit 2gb hugepages.
> mmap(NULL, 18446744071562067968, PROT_READ|PROT_WRITE, MAP_SHARED, 3, 0) = -1 ENOMEM (Cannot allocate memory)

Hmm, you are trying to reserve/mmap a lot of memory (17179869182 1GB huge
pages).

> # cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
> 18446744071589420672
> 
> As you can see from the above, it did not allow overcommit despite nr_overcommit_hugepages value.

You are trying to allocate much more than your overcommit allows.

> Also, nr_overcommit_hugepages was overwritten with such a strange
> value after overcommit failure. Should we just remove this file from
> sysfs for simplicity?

This is strange. The value is set only in hugetlb_overcommit_handler
which is a sysctl handler.

Are you sure that you are not changing the value by the /sys interface
somewhere (there is no check for the value so you can set what-ever
value you like)? I fail to see any mmap code path which would change
this value.

Btw. which kernel version are you using.

> 
> Thanks.
> 
> CAI Qian

Regards
-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
