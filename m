Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id F40BD6B0035
	for <linux-mm@kvack.org>; Sun, 19 Jan 2014 20:05:55 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id 10so3021390ykt.5
        for <linux-mm@kvack.org>; Sun, 19 Jan 2014 17:05:55 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id 69si19069790yhc.66.2014.01.19.17.05.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 19 Jan 2014 17:05:54 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so4003771pab.24
        for <linux-mm@kvack.org>; Sun, 19 Jan 2014 17:05:53 -0800 (PST)
Date: Mon, 20 Jan 2014 09:05:33 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [Resend] Puzzling behaviour with multiple swap targets
Message-ID: <20140120010533.GA24605@kernel.org>
References: <52D9248F.6030901@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52D9248F.6030901@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Eberhard Pasch <epasch@de.ibm.com>

On Fri, Jan 17, 2014 at 01:39:43PM +0100, Christian Ehrhardt wrote:
> Hi,
> 
> /*
>  * RESEND - due the vacation time we all hopefully shared this might
>  * have slipped through mail filters and mass deletes - so I wanted to
>  * give the question another chance.
>  */
> 
> I've analyzed swapping for a while now. I made some progress tuning
> my system for better, faster and more efficient swapping. However
> one thing still eludes me.
> I think by asking here we can only win. Either it is trivial to you
> and I get a better understanding or you can take it as brain teaser
> over Christmas time :-)
> 
> Long Story Short - the Issue:
> The more Swap targets I use, the slower the swapping becomes.
> 
> 
> Details - Issue:
> As mentioned before I made a lot of analysis already including
> simplifications of the testcase.
> Therefore I only describe the most simplified setup and scenario.
> I run a testcase (see below) accessing overcommitted (1.25:1) memory
> in 4k chunks selecting the offset randomly.
> When swapping to a single disk I achieve about 20% more throughput
> compared to just taking this disk, partitioning it into 4 equal
> pieces and activate those as swap.
> The workload does read only in that overcommitted memory.
> 
> According to my understanding for read only the exact location
> shouldn't matter.
> The fault will find a page that was swapped out and discarded, start
> the I/O to bring it back going via the swap extends.
> There is just no code caring a lot about the partitions in the
> fault-IN path.
> Also as the workload is uniform random locality on disk should be
> irrelevant as the accesses to the four partitions will be mapped to
> just the same disk.
> 
> Still the number of partitions on the same physical resource changes
> the throughput I can achieve on memory.
> 
> 
> 
> Details - Setup
> My Main System is a System zEnterprise zEC12 s390 machine with 10GB Memory.
> I have 2 CPUs (FYI the issue appears no matter how much cpus - tested 1-64).
> The working set of the workload is 12.5 GB,so the overcommit ratio
> is a light 1.25:1 (also tested from 1.02 up to 3:1 - it was visible
> in each case, but 1.25:1 was the most stable)
> As swap device I use 1 FCP attached Disk served by a IBM DS8870
> attached via 8x8Gb FCP adapters on Server and Storage Server.
> The disk holds 256GB which leaves my case far away from 50% swap.
> Initially I used multiple disks, but the problem is more puzzling
> (as it leaves less room for speculation) when just changing the
> #partitions on the same physical resource.
> 
> I verified it on an IBM X5 (Xeon X7560) and while the (local raid 5)
> disk devices there are much slower, they still show the same issue
> when comparing 1 disk 1 partition vs the same 1 disk 4 partitions.
> 
> 
> 
> Remaining Leads:
> Using iostat to compare swap disk activity vs what my testcase can
> achieve in memory identified that the "bad case" is less efficient.
> That means it doesn't have less/slower disk I/O, no in fact it has
> usually slightly more disk I/O at about the same performance
> characteristics than the "good case".
> That implies that the "efficiency" in the good case is better
> meaning that it is more likely to have the "correct next page" at
> hand and in swap cache.
> That is confirmed by the fact that setting page_cluster to 0
> eliminates the difference of 1 to many partitions.
> Unfortunately the meet at the lower throughput level.
> Also I don't see what the mm/swap code can make right/wrong for a
> workload accessing 4k pages in a randomized way.
> There should be no statistically relevant value in the locality of
> the workload that can be handled right.
> 
> 
> 
> Rejected theories:
> I tested a lot of things already and some made it into tunings (IO
> scheduler, page_cluster, ...), but non of them fixed the "more swap
> targets -> slower" issue.
> - locking: Lockstat showed nothing changing a lot between 1 and 4
> partitions. In fact the 5 most busy locks were related to huge pages
> and disabling those got rid of the locks in lockstat, but didn't
> affect the throughput at all.
> - scsi/blkdev: as complex multipath setups can often be a source of
> issues I used a special s390 only memory device called xpram. It
> essentially is a block device that fulfils I/O requests at
> make_request level at memory speed. That sped up my test a lot, but
> taking the same xpram memory once in one chunk and once broken into
> 4 pieces it still was worse with the four pieces.
> - already fixed: there was an upstream patch commit ec8acf20 "swap:
> add per-partition lock for swapfile" from "Shaohua Li
> <shli@kernel.org>" that pretty much sounds like the same issue. But
> it was already applied.
> - Kernel Versions: while the majority of my tests were on 3.10.7 I
> tested up to 3.12.2 and still saw the same issue.
> - Scaling in general: when I go from 1 to 4 partitions on a single
> disk I see the mentioned ~20% drop in throughput.
>   But going further like 6 disks with 4 partitions each is at almost
> the same level.
>   So it gets a bit worse, but the black magic seems to happen between 1->4.

Is the swap disk a SSD? If not, there is no point to partition the disk. Do you
see any changes in iostat in the bad/good case, for example, request size,
iodepth? 

There is one patch can avoid swapin reads more than swapout for random case,
but still not in upstream yet. You can try it here:
https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/mm/swap_state.c?id=5d19b04a2dae73382fb607f16e2acfb594d1c63f

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
