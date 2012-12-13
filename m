Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 912906B0075
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 08:52:34 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 13 Dec 2012 08:52:33 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 595E16E803C
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 08:52:29 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBDDqIDN45613132
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 08:52:18 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBDDqGJX017099
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 08:52:17 -0500
Date: Thu, 13 Dec 2012 18:51:48 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121213132148.GD29086@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Mel Gorman <mgorman@suse.de> [2012-12-07 10:23:03]:

> This is a full release of all the patches so apologies for the flood.  V9 was
> just a MIPS build fix and did not justify a full release. V10 includes Ingo's
> scalability patches because even though they increase system CPU usage,
> they also helped in a number of test cases. It would be worthwhile trying
> to reduce the system CPU usage by looking closer at how rwsem works and
> dealing with the contended case a bit better. Otherwise the rate of change
> in the last few weeks has been tiny as the preliminary objectives had been
> met and I did not want to invalidate any testing other people had conducted.
> 
> git tree: git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git mm-balancenuma-v10r3
> git tag:  git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git mm-balancenuma-v10

Here are the specjbb results on a 2 node 24 GB machine.
vm_1 was allocated 12 GB, while vm_2 and vm_3 were allocated 6 GB each
All vms were running specjbb2005 workload

All numbers presented are improvements/regression from v3.7-rc8

----------------------------------------------------------------------------------------------
|                      |     |                          nofit|                            fit|
----------------------------------------------------------------------------------------------
|                      |     |          noksm|            ksm|          noksm|            ksm|
----------------------------------------------------------------------------------------------
|                      |     |  nothp|    thp|  nothp|    thp|  nothp|    thp|  nothp|    thp|
----------------------------------------------------------------------------------------------
| autonuma-mels-rebase | vm_1|   2.48|  14.25|   1.80|  15.59|   8.16|  14.62|   8.56|  17.49|
| autonuma-mels-rebase | vm_2|  23.59|  18.67|  14.20|  23.25|  10.73|  13.18|  17.94|  21.72|
| autonuma-mels-rebase | vm_3|  16.19|  19.40|  14.42|  22.54|  11.08|  12.04|   9.79|  20.34|
----------------------------------------------------------------------------------------------
| mel-balancenuma v10r3| vm_1|   0.10|   1.49|   1.78|   4.00|  -1.01|  -1.16|  -1.02|  -0.60|
| mel-balancenuma v10r3| vm_2|   3.45|  -0.67|  -1.54|   2.65|  -2.83|  -7.10|   0.10|  -2.41|
| mel-balancenuma v10r3| vm_3|   0.56|   5.49|  -0.63|   0.09|  -7.41|  -4.52|  -0.77|  -1.80|
----------------------------------------------------------------------------------------------
| tip-master 11-dec    | vm_1|  -5.68|  12.34|  35.96|  13.33|  10.79|  15.22|   9.65|  12.80|
| tip-master 11-dec    | vm_2|  14.70|  15.54|  77.45|  15.10|  12.82|  11.20|  12.66|  na   |
| tip-master 11-dec    | vm_3|   6.66|  19.26|  na   |  14.93|   7.62|  14.72|  14.73|  12.34|
----------------------------------------------------------------------------------------------


there are couple na's .. In those case, the testlog for some wierd
reason didnt have any data. this somehow seems to happen with tip/master
kernel only. May be its just coincidence.

-- 
Thanks and Regards
Srikar

PS: benchmark was run under non-standard conditions run only for the
purpose of relative comparision of different kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
