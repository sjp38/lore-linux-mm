Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A52166B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 10:26:27 -0500 (EST)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.1/8.13.1) with ESMTP id o1PFQLAl009292
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 15:26:21 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1PFQLgJ1577074
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 16:26:21 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o1PFQLAc026408
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 16:26:21 +0100
Message-ID: <4B869682.9010709@linux.vnet.ibm.com>
Date: Thu, 25 Feb 2010 16:25:54 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/15] readahead: limit readahead size for small memory
 systems
References: <20100224031001.026464755@intel.com> <20100224031054.307027163@intel.com>
In-Reply-To: <20100224031054.307027163@intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Matt Mackall <mpm@selenic.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>



Wu Fengguang wrote:
 > When lifting the default readahead size from 128KB to 512KB,
 > make sure it won't add memory pressure to small memory systems.
 >
 > For read-ahead, the memory pressure is mainly readahead buffers consumed
 > by too many concurrent streams. The context readahead can adapt
 > readahead size to thrashing threshold well.  So in principle we don't
 > need to adapt the default _max_ read-ahead size to memory pressure.
 >
 > For read-around, the memory pressure is mainly read-around misses on
 > executables/libraries. Which could be reduced by scaling down
 > read-around size on fast "reclaim passes".
 >
 > This patch presents a straightforward solution: to limit default
 > readahead size proportional to available system memory, ie.
 >                 512MB mem => 512KB readahead size
 >                 128MB mem => 128KB readahead size
 >                  32MB mem =>  32KB readahead size (minimal)
 >
 > Strictly speaking, only read-around size has to be limited.  However we
 > don't bother to seperate read-around size from read-ahead size for now.
 >
 > CC: Matt Mackall <mpm@selenic.com>
 > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

What I state here is for read ahead in a "multi iozone sequential" 
setup, I can't speak for real "read around" workloads.
So probably your table is fine to cover read-around+read-ahead in one 
number.

I have tested 256MB mem systems with 512kb readahead quite a lot.
On those 512kb is still by far superior to smaller readaheads and I 
didn't see major trashing or memory pressure impact.

Therefore I would recommend a table like:
                >=256MB mem => 512KB readahead size
                  128MB mem => 128KB readahead size
                   32MB mem =>  32KB readahead size (minimal)

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
