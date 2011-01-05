Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 00E976B0088
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 10:02:26 -0500 (EST)
Date: Wed, 5 Jan 2011 10:02:01 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1047497160.139161.1294239721941.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <20110104175630.GC3190@mgebm.net>
Subject: Re: [PATCH] hugetlb: remove overcommit sysfs for 1GB pages
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm <linux-mm@kvack.org>, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>


----- Original Message -----
> On Tue, 04 Jan 2011, CAI Qian wrote:
> 
> > 1GB pages cannot be over-commited, attempting to do so results in
> > corruption,
> > so remove those files for simplicity.
> >
> > Symptoms:
> > 1) setup 1gb hugepages.
> >
> > cat /proc/cmdline
> > ...default_hugepagesz=1g hugepagesz=1g hugepages=1...
> >
> > cat /proc/meminfo
> > ...
> > HugePages_Total: 1
> > HugePages_Free: 1
> > HugePages_Rsvd: 0
> > HugePages_Surp: 0
> > Hugepagesize: 1048576 kB
> > ...
> >
> > 2) set nr_overcommit_hugepages
> >
> > echo 1
> > >/sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
> > cat
> > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
> > 1
> >
> > 3) overcommit 2gb hugepages.
> >
> > mmap(NULL, 18446744071562067968, PROT_READ|PROT_WRITE, MAP_SHARED,
> > 3,
> > 	   0) = -1 ENOMEM (Cannot allocate memory)
> >
> > cat
> > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
> > 18446744071589420672
> >
> > Signed-off-by: CAI Qian <caiqian@redhat.com>
> 
> There are a couple of issues here: first, I think the overcommit value
> being overwritten
> is a bug and this needs to be addressed and fixed before we cover it
> by removing the sysfs
> file.
> 
> Second, will it be easier for userspace to work with some huge page
> sizes having the
> overcommit file and others not or making the kernel hand EINVAL back
> when nr_overcommit is
> is changed for an unsupported page size?
> 
> Finally, this is a problem for more than 1GB pages on x86_64. It is
> true for all pages >
> 1 << MAX_ORDER. Once the overcommit bug is fixed and the second issue
> is answered, the
> solution that is used (either EINVAL or no overcommit file) needs to
> happen for all cases
> where it applies, not just the 1GB case.
I have a new patch ready to return EINVAL for both sysfs/procfs, and will
reject changing of nr_hugepages. Do you know if nr_hugepages_mempolicy
is supposed to be able to change in this case? It is not possible currently.

# cat /proc/sys/vm/nr_hugepages_mempolicy
1
# echo 0 >/proc/sys/vm/nr_hugepages_mempolicy 
# cat /proc/sys/vm/nr_hugepages_mempolicy
1

Thanks.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
