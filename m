Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAL5wQ0o009488
	for <linux-mm@kvack.org>; Mon, 21 Nov 2005 00:58:26 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAL5wQX1119884
	for <linux-mm@kvack.org>; Mon, 21 Nov 2005 00:58:26 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jAL5wPcB023206
	for <linux-mm@kvack.org>; Mon, 21 Nov 2005 00:58:25 -0500
Message-ID: <43816200.9060303@us.ibm.com>
Date: Sun, 20 Nov 2005 21:58:24 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/8] Critical Page Pool
References: <437E2C69.4000708@us.ibm.com> <20051120230456.GE2556@spitz.ucw.cz>
In-Reply-To: <20051120230456.GE2556@spitz.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Pavel Machek wrote:
> On Fri 18-11-05 11:32:57, Matthew Dobson wrote:
> 
>>We have a clustering product that needs to be able to guarantee that the
>>networking system won't stop functioning in the case of OOM/low memory
>>condition.  The current mempool system is inadequate because to keep the
>>whole networking stack functioning, we need more than 1 or 2 slab caches to
>>be guaranteed.  We need to guarantee that any request made with a specific
>>flag will succeed, assuming of course that you've made your "critical page
>>pool" big enough.
>>
>>The following patch series implements such a critical page pool.  It
>>creates 2 userspace triggers:
>>
>>/proc/sys/vm/critical_pages: write the number of pages you want to reserve
>>for the critical pool into this file
>>
>>/proc/sys/vm/in_emergency: write a non-zero value to tell the kernel that
>>the system is in an emergency state and authorize the kernel to dip into
>>the critical pool to satisfy critical allocations.
>>
>>We mark critical allocations with the __GFP_CRITICAL flag, and when the
>>system is in an emergency state, we are allowed to delve into this pool to
>>satisfy __GFP_CRITICAL allocations that cannot be satisfied through the
>>normal means.
> 
> 
> Ugh, relying on userspace to tell you that you need to dip into emergency
> pool seems to be racy and unreliable. How can you guarantee that userspace
> is scheduled soon enough in case of OOM?
> 							Pavel

It's not really for userspace to tell us that we're about to OOM, as the
kernel is in a far better position to determine that.  It is to let the
kernel know that *something* has gone wrong, and we've got to keep
networking (or any other user of __GFP_CRITICAL) up for a few minutes, *no
matter what*.  We may not ever OOM, or even run terribly low on memory, but
the trigger allows the use of the pool IF that happens.

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
