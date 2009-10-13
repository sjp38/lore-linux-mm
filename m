Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 44C7E6B00C2
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 11:49:15 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9DFlgYv023030
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 11:47:42 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9DFn1fD227206
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 11:49:01 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9DFmiYY024441
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 11:49:00 -0400
Date: Tue, 13 Oct 2009 10:48:41 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2][v2] mm: add notifier in pageblock isolation for
	balloon drivers
Message-ID: <20091013154841.GB18305@austin.ibm.com>
References: <20091002184458.GC4908@austin.ibm.com> <20091008163449.00dce972.akpm@linux-foundation.org> <20091009202304.GB19114@austin.ibm.com> <20091009204326.GH24845@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091009204326.GH24845@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Gerald Schaefer <geralds@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 09, 2009 at 21:43:26 +0100, Mal Gorman wrote:
> As you have tested this recently, would you be willing to post the
> results? While it's not a requirement of the patch, it would be nice to have
> an idea of how the effectiveness of memory hot-remove is improved when used
> with the powerpc balloon. This might convince others developers for balloons
> to register with the notifier.

I did ten test runs without my patches and ten test runs with my patches
on a 2.6.32-rc3 kernel.

Without the patch:
6 out of 10 memory-remove operations without the patch removed 1 LMB
(64Mb), the rest of the memory-remove attempts failed to remove any LMBs.

With the patch:
All of the memory-remove operations removed some LMBs.  The average
removed was just over 11 LMBs (704Mb) per attempt.

Linux was given 2Gb of memory.  During the test runs the average memory in
use was 140Mb, not including cache and buffers, and the average amount
consumed by the balloon was 1217Mb.  The system was idle while the
memory remove operation was performed.  After each attempt the system
was rebooted and allowed ~10 minutes to settle after boot.

With a 2Gb configuration on POWER the LMB size is 64Mb.  The drmgr command
(part of powerpc-utils) was used to remove memory by LBM, just as an
end-user would.  Below is a list of the runs and the number of LMBs
removed.

Stock kernel (v2.6.32-rc3)
--------------------------
LMBs	Used kb	Loaned kb
removed
0	135232	1257280
0	151168	1231744
1	152128	1234176
1	150976	1239232
1	151808	1232064
0	136064	1249152
0	137088	1246976
1	135296	1289984
1	136384	1263104
1	152960	1243904
=======================
0.60	143910	1248762 Average
0.49	  7929	  16960 StdDev

Patched kernel
--------------------------
LMBs	Used kb	Loaned kb
removed
12	134336	1294336
10	152192	1250432
 9	152832	1235520
15	153152	1237952
12	152320	1232704
13	135360	1252224
11	154176	1237056
10	153920	1243264
10	150720	1236416
13	151040	1230848
=======================
11.50	149005  1245075 Average
 1.75	  7158	  17738 StdDev


Regards,
Robert Jennings

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
