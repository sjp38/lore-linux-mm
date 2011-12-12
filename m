Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 3C4196B0198
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 11:15:32 -0500 (EST)
Message-ID: <4EE62744.30001@mellanox.com>
Date: Mon, 12 Dec 2011 18:09:40 +0200
From: Sagi Grimberg <sagig@mellanox.com>
MIME-Version: 1.0
Subject: page-able RDMA
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Or Gerlitz <ogerlitz@mellanox.com>, Shachar Raindel <raindel@mellanox.com>

Hey all,

InfiniBand allows remote host to access the memory of a local process, 
without involvement of the local CPU. This is called "RDMA". Currently, 
this is implemented by the task registering the address-space region 
that will be accessible through the network using a special API call ( 
ibv_reg_mr ). This API pins the address space area into RAM space (using 
get_user_pages), makes it DMA mappable, and adds a device specific 
mapping for this region. The memory area is pinned in memory until the 
user chooses to remove the registration, through another API call 
(ibv_dereg_mr).

I am working on a prototype enabling page able memory for an InfiniBand 
driver using mmu_notifier.
Such a task requires one to be able to manage a secondary PT for all 
relevant pages of a certain process,
This can be done using the mmu_notifier invalidation callback mechanism.

The pages will _NOT_ be pinned in RAM space, and all MMU actions will be 
reflected to the device's secondary PT, on the other hand the device 
will initiate page-fault events towards the driver when trying to 
operate on an unmapped page. the driver then will request mapping the 
relevant pages.
Once the pages are in memory, the driver will update the device's 
secondary PT.

The work on the prototype has raised several fundamental questions:

Since the device needs to stop any ongoing operations regarding that 
page, one should make sure that the device is sync with the page going 
to be freed upon return from the invalidation callback, and halted any 
read/write to the page. this flushing action is somewhat expensive since 
it is blocked by HW possibly for a long (10s of milliseconds) time.
* Are the invalidation callbacks sleep able (invalidate_page 
specifically)? thus allowing a scheduling HW sync?

Another goal to batch invalidations for performance improvement. Being 
able to delay a page invalidation can donate a major acceleration to our 
performance.
So, One should be aware of when it is OK to delay invalidations. upon a 
swap based invalidation - it's probably OK to delay, but for a user 
unmap action - delaying the invalidation can lead to bad results.
* Can one refuse an invalidation initiated on a page? what is the state 
of such a page?
* What is your opinion about providing the notifiers with extra 
information regarding the invalidation cause (swap, unmap, 
page-migration etc...)?
   or splitting the notifier to "invalidation that we can postpone" and 
"invalidation that must happen now"?

I had some short private email exchange on the matter with Andrea, which 
now naturally is moved here,
so to sync people on that correspondence I added this short intro. The 
original thread will be followed by this mail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
