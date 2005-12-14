Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBEG3Dkx014261
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 11:03:13 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBEG4rGC087922
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 09:04:53 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jBEG3Cch011730
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 09:03:12 -0700
Message-ID: <43A0423E.60104@us.ibm.com>
Date: Wed, 14 Dec 2005 08:03:10 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/6] Critical Page Pool
References: <439FCECA.3060909@us.ibm.com> <20051214100841.GA18381@elf.ucw.cz> <20051214120152.GB5270@opteron.random>
In-Reply-To: <20051214120152.GB5270@opteron.random>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Pavel Machek <pavel@suse.cz>, linux-kernel@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Wed, Dec 14, 2005 at 11:08:41AM +0100, Pavel Machek wrote:
> 
>>because reserved memory pool would have to be "sum of all network
>>interface bandwidths * ammount of time expected to survive without
>>network" which is way too much.
> 
> 
> Yes, a global pool isn't really useful. A per-subsystem pool would be
> more reasonable...

Which is an idea that I toyed with, as well.  The problem that I ran into
is how to tag an allocation as belonging to a specific subsystem.  For
example, in our code we need networking to use the critical pool.  How do
we let __alloc_pages() know what allocations belong to networking?
Networking needs named slab allocations, kmalloc allocations, and whole
page allocations to function.  Should each subsystem get it's own GFP flag
(GFP_NETWORKING, GFP_SCSI, GFP_SOUND, GFP_TERMINAL, ad nauseum)?  Should we
create these pools dynamically and pass a reference to which pool each
specific allocation uses (thus adding a parameter to all memory allocation
functions in the kernel)?  I realize that per-subsystem pools would be
better, but I thought about this for a while and couldn't come up with a
reasonable way to do it.


>>gigabytes into your machine. But don't go introducing infrastructure
>>that _can't_ be used right.
> 
> 
> Agreed, the current design of the patch can't be used right.

Well, it can for our use, but I recognize that isn't going to be a huge
selling point! :)  As I mentioned in my reply to Pavel, I'd really like to
find a way to design something that WOULD be generally useful.

Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
