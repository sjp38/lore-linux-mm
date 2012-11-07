Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 1BCA06B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 15:16:46 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 8 Nov 2012 06:15:46 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA7K6F4X63635596
	for <linux-mm@kvack.org>; Thu, 8 Nov 2012 07:06:15 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA7KGcVd013148
	for <linux-mm@kvack.org>; Thu, 8 Nov 2012 07:16:39 +1100
Message-ID: <509AC164.1050403@linux.vnet.ibm.com>
Date: Thu, 08 Nov 2012 01:45:32 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 6/8] mm: Demarcate and maintain pageblocks in region-order
 in the zones' freelists
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121106195342.6941.94892.stgit@srivatsabhat.in.ibm.com> <509985DE.8000508@linux.vnet.ibm.com>
In-Reply-To: <509985DE.8000508@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/07/2012 03:19 AM, Dave Hansen wrote:
> On 11/06/2012 11:53 AM, Srivatsa S. Bhat wrote:
>> This is the main change - we keep the pageblocks in region-sorted order,
>> where pageblocks belonging to region-0 come first, followed by those belonging
>> to region-1 and so on. But the pageblocks within a given region need *not* be
>> sorted, since we need them to be only region-sorted and not fully
>> address-sorted.
>>
>> This sorting is performed when adding pages back to the freelists, thus
>> avoiding any region-related overhead in the critical page allocation
>> paths.
> 
> It's probably _better_ to do it at free time than alloc, but it's still
> pretty bad to be doing a linear walk over a potentially 256-entry array
> holding the zone lock.  The overhead is going to show up somewhere.  How
> does this do with a kernel compile?  Looks like exit() when a process
> has a bunch of memory might get painful.
> 

As I mentioned in the cover-letter, kernbench numbers haven't shown any
observable performance degradation. On the contrary, (as unbelievable as it
may sound), they actually indicate a slight performance *improvement* with my
patchset! I'm trying to figure out what could be the reason behind that.

Going forward, we could try to optimize the sorting logic in the free()
part, but in any case, IMHO that's the right place to push the overhead to,
since the performance of free() is not expected to be _that_ critical (unlike
alloc()) for overall system performance.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
