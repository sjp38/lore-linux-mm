Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBEFtS0v015288
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 10:55:28 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBEFv7GC068198
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 08:57:08 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jBEFtQkm016780
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 08:55:27 -0700
Message-ID: <43A0406C.8020108@us.ibm.com>
Date: Wed, 14 Dec 2005 07:55:24 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/6] Critical Page Pool
References: <439FCECA.3060909@us.ibm.com> <20051214100841.GA18381@elf.ucw.cz>
In-Reply-To: <20051214100841.GA18381@elf.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: linux-kernel@vger.kernel.org, andrea@suse.de, Sridhar Samudrala <sri@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Pavel Machek wrote:
> Hi!
> 
> 
>>The overall purpose of this patch series is to all a system administrator
>>to reserve a number of pages in a 'critical pool' that is set aside for
>>situations when the system is 'in emergency'.  It is up to the individual
>>administrator to determine when his/her system is 'in emergency'.  This is
>>not meant to (necessarily) anticipate OOM situations, though that is
>>certainly one possible use.  The purpose this was originally designed for
>>is to allow the networking code to keep functioning despite the sytem
>>losing its (potentially networked) swap device, and thus temporarily
>>putting the system under exreme memory pressure.
> 
> 
> I don't see how this can ever work.
> 
> How can _userspace_ know about what allocations are critical to the
> kernel?!

Well, it isn't userspace that is determining *which* allocations are
critical to the kernel.  That is statically determined at compile time by
using the flag __GFP_CRITICAL on specific *kernel* allocations.  Sridhar,
cc'd on this mail, has a set of patches that sprinkle the __GFP_CRITICAL
flag throughout the networking code to take advantage of this pool.
Userspace is in charge of determining *when* we're in an emergency
situation, and should thus use the critical pool, but not *which*
allocations are critical to surviving this emergency situation.


> And as you noticed, it does not work for your original usage case,
> because reserved memory pool would have to be "sum of all network
> interface bandwidths * ammount of time expected to survive without
> network" which is way too much.

Well, I never suggested it didn't work for my original usage case.  The
discussion we had is that it would be incredibly difficult to 100%
iron-clad guarantee that the pool would NEVER run out of pages.  But we can
size the pool, especially given a decent workload approximation, so as to
make failure far less likely.


> If you want few emergency pages for some strange hack you are doing
> (swapping over network?), just put swap into ramdisk and swapon() it
> when you are in emergency, or use memory hotplug and plug few more
> gigabytes into your machine. But don't go introducing infrastructure
> that _can't_ be used right.

Well, that's basically the point of posting these patches as an RFC.  I'm
not quite so delusional as to think they're going to get picked up right
now.  I was, however, hoping for feedback to figure out how to design
infrastructure that *can* be used right, as well as trying to find other
potential users of such a feature.

Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
