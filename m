Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5AC6B0133
	for <linux-mm@kvack.org>; Wed, 13 May 2009 18:11:36 -0400 (EDT)
Date: Wed, 13 May 2009 15:11:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Physical Memory Management [0/1]
Message-Id: <20090513151142.5d166b92.akpm@linux-foundation.org>
In-Reply-To: <op.utu26hq77p4s8u@amdc030>
References: <op.utu26hq77p4s8u@amdc030>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: =?ISO-8859-1?Q?Micha=5F=5F?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


(cc linux-mm)

(please keep the emails to under 80 columns)

On Wed, 13 May 2009 11:26:31 +0200
Micha__ Nazarewicz <m.nazarewicz@samsung.com> wrote:

> In the next message a patch which allows allocation of large continuous blocks of physical memory will be sent.  This functionality makes it similar to bigphysarea, however PMM has many more features:
>  
> 1. Each allocated block of memory has a reference counter so different kernel modules may share the same buffer with a well known get/put semantics.
>  
> 2. It aggregates physical memory allocating and management API in one place. This is good because there is a single place to debug and test for all devices. Moreover, because each device does not need to reserve it's own area of physical memory a total size of reserved memory is smaller. Say, we have 3 accelerators. Each of them can operate on 1MiB blocks, so each of them would have to reserve 1MiB for itself (this means total of 3MiB of reserved memory). However, if at most two of those devices can be used at once, we could reserve 2MiB saving 1MiB.
>  
> 3. PMM has it's own allocator which runs in O(log n) bound time where n is total number of areas and free spaces between them -- the upper time limit may be important when working on data sent in real time (for instance an output of a camera).  Currently a best-fit algorithm is used but you can easily replace it if it does not meet your needs. 
>  
> 4. Via a misc char device, the module allows allocation of continuous blocks from user space. Such solution has several advantages. In particular, other option would be to add a allocation calls for each individual devices (think hardware accelerators) -- this would double the same code in several drivers plus it would lead to inconsistent API for doing the very same think. Moreover, when creating pipelines (ie. encoded image --[decoder]--> decoded image --[scaler]--> scaled image) devices would have to develop a method of sharing buffers. With PMM user space program allocates a block and passes it as an output buffer for the first device and input buffer for the other.
>  
> 5. PMM is integrated with System V IPC, so that user space programs may "convert" allocated block into a segment of System V shared memory. This makes it possible to pass PMM buffers to PMM-unaware but SysV-aware applications. Notable example are X11. This makes it possible to deploy a zero-copy scheme when communicating with X11. For instance, image scaled in previous example could be passed directly to X server without the need to copy it to a newly created System V shared memory.
>  
> 6. PMM has a notion of memory types. In attached patch only a general memory type is defined but you can easily add more types for a given platform. To understand what in PMM terms is memory type we can use an example: a general memory may be a main RAM memory which we have a lot but it is quite slow and another type may be a portion of L2 cache configured to act as fast memory. Because PMM may be aware of those, again, allocation of different kinds of memory has a common, consistent API.

OK, let's pretend we didn't see an implementation.

What are you trying to do here?  What problem(s) are being solved? 
What are the requirements and the use cases?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
