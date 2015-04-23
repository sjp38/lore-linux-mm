Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id C80F56B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 10:38:19 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so24629824igb.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 07:38:17 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id c101si6891919iod.46.2015.04.23.07.38.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 07:38:16 -0700 (PDT)
Date: Thu, 23 Apr 2015 09:38:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <1429756456.4915.22.camel@kernel.crashing.org>
Message-ID: <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <1429663372.27410.75.camel@kernel.crashing.org> <20150422005757.GP5561@linux.vnet.ibm.com> <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org> <20150422163135.GA4062@gmail.com> <alpine.DEB.2.11.1504221206080.25607@gentwo.org> <1429756456.4915.22.camel@kernel.crashing.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Jerome Glisse <j.glisse@gmail.com>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, 23 Apr 2015, Benjamin Herrenschmidt wrote:

> In fact I'm quite surprised, what we want to achieve is the most natural
> way from an application perspective.

Well the most natural thing would be if the beast would just do what I
tell it in plain english. But then I would not have my job anymore.

> You have something in memory, whether you got it via malloc, mmap'ing a file,
> shmem with some other application, ... and you want to work on it with the
> co-processor that is residing in your address space. Even better, pass a pointer
> to it to some library you don't control which might itself want to use the
> coprocessor ....

Yes that works already. Whats new about this? This seems to have been
solved on the Intel platform f.e.

> What you propose can simply not provide that natural usage model with any
> efficiency.

There is no effiecency anymore if the OS can create random events in a
computational stream that is highly optimized for data exchange of
multiple threads at defined time intervals. If transparency or the natural
usage model can avoid this then ok but what I see here proposed is some
behind-the-scenes model that may severely degrate performance. And this
does seem to go way beyond CAPI. At leasdt the way I so far thought about
this as a method for cache coherency at the cache line level and about a
way to simplify the coordination of page tables and TLBs across multiple
divergent architectures.

I think these two things need to be separated. The shift-the-memory-back-
and-forth approach should be separate and if someone wants to use the
thing then it should also work on other platforms like ARM and Intel.

CAPI needs to be implemented as a way to potentially improve the existing
communication paths between devices and the main processor. F.e the
existing Infiniband MMU synchronization issues and RDMA registration
problems could be addressed with this. The existing mechanisms for GPU
communication could become much cleaner and easier to handle. This is all
good but independant of any "transparent" memory implementation.

> It might not be *your* model based on *your* application but that doesn't mean
> it's not there, and isn't relevant.

Sadly this is the way that an entire industry does its thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
