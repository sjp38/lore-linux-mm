Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 06E2B6B006C
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 12:16:12 -0400 (EDT)
Received: by oblw8 with SMTP id w8so94967284obl.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 09:16:11 -0700 (PDT)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com. [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id b5si11159910obt.89.2015.04.08.09.15.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 09:15:57 -0700 (PDT)
Received: by obbfy7 with SMTP id fy7so145547043obb.2
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 09:15:57 -0700 (PDT)
Date: Wed, 8 Apr 2015 11:15:39 -0500
From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: HugePages_Rsvd leak
Message-ID: <20150408161539.GA29546@sbohrermbp13-local.rgmadvisors.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

I've noticed on a number of my systems that after shutting down my
application that uses huge pages that I'm left with some pages still
in HugePages_Rsvd.  It is possible that I still have something using
huge pages that I'm not aware of but so far my attempts to find
anything using huge pages have failed.  I've run some simple tests
using map_hugetlb.c from the kernel source and can see that pages that
have been reserved but not allocated still show up in
/proc/<pid>/smaps and /proc/<pid>/numa_maps.  Are there any cases
where this is not true?

[root@dev106 ~]# grep HugePages /proc/meminfo
AnonHugePages:    241664 kB
HugePages_Total:     512
HugePages_Free:      512
HugePages_Rsvd:      384
HugePages_Surp:        0
Hugepagesize:       2048 kB
[root@dev106 ~]# grep "KernelPageSize:.*2048" /proc/*/smaps
[root@dev106 ~]# grep "VmFlags:.*ht" /proc/*/smaps
[root@dev106 ~]# grep huge /proc/*/numa_maps
[root@dev106 ~]# grep Huge /proc/meminfo
AnonHugePages:    241664 kB
HugePages_Total:     512
HugePages_Free:      512
HugePages_Rsvd:      384
HugePages_Surp:        0
Hugepagesize:       2048 kB

So here I have 384 pages reserved and I can't find anything that is
using them.  This is on a machine running 3.14.33.  I can possibly try
running a newer kernel if there is a belief that this has been fixed.
I'm also happy to provide more information or try some debug patches
if there are ideas on how to track this down.  I'm not entirely sure
how hard this is to reproduce but nearly every machine I've looked at
is in this state so it must not be too hard.

Thanks,
Shawn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
