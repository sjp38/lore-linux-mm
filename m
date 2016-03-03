Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id F1C076B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 09:01:21 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 124so15536945pfg.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 06:01:21 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id k81si5750442pfj.154.2016.03.03.06.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 06:01:20 -0800 (PST)
Date: Thu, 3 Mar 2016 16:58:34 +0300
From: Roman Kagan <rkagan@virtuozzo.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160303135833.GA9100@rkaganb.sw.ru>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: quintela@redhat.com, amit.shah@redhat.com, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, ehabkost@redhat.com, kvm@vger.kernel.org, mst@redhat.com, dgilbert@redhat.com, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, pbonzini@redhat.com, akpm@linux-foundation.org, rth@twiddle.net

On Thu, Mar 03, 2016 at 06:44:24PM +0800, Liang Li wrote:
> The current QEMU live migration implementation mark the all the
> guest's RAM pages as dirtied in the ram bulk stage, all these pages
> will be processed and that takes quit a lot of CPU cycles.
> 
> From guest's point of view, it doesn't care about the content in free
> pages. We can make use of this fact and skip processing the free
> pages in the ram bulk stage, it can save a lot CPU cycles and reduce
> the network traffic significantly while speed up the live migration
> process obviously.
> 
> This patch set is the QEMU side implementation.
> 
> The virtio-balloon is extended so that QEMU can get the free pages
> information from the guest through virtio.
> 
> After getting the free pages information (a bitmap), QEMU can use it
> to filter out the guest's free pages in the ram bulk stage. This make
> the live migration process much more efficient.
> 
> This RFC version doesn't take the post-copy and RDMA into
> consideration, maybe both of them can benefit from this PV solution
> by with some extra modifications.
> 
> Performance data
> ================
> 
> Test environment:
> 
> CPU: Intel (R) Xeon(R) CPU ES-2699 v3 @ 2.30GHz
> Host RAM: 64GB
> Host Linux Kernel:  4.2.0           Host OS: CentOS 7.1
> Guest Linux Kernel:  4.5.rc6        Guest OS: CentOS 6.6
> Network:  X540-AT2 with 10 Gigabit connection
> Guest RAM: 8GB
> 
> Case 1: Idle guest just boots:
> ============================================
>                     | original  |    pv    
> -------------------------------------------
> total time(ms)      |    1894   |   421
> --------------------------------------------
> transferred ram(KB) |   398017  |  353242
> ============================================
> 
> 
> Case 2: The guest has ever run some memory consuming workload, the
> workload is terminated just before live migration.
> ============================================
>                     | original  |    pv    
> -------------------------------------------
> total time(ms)      |   7436    |   552
> --------------------------------------------
> transferred ram(KB) |  8146291  |  361375
> ============================================

Both cases look very artificial to me.  Normally you migrate VMs which
have started long ago and which can't have their services terminated
before the migration, so I wouldn't expect any useful amount of free
pages obtained this way.

OTOH I don't see why you can't just inflate the balloon before the
migration, and really optimize the amount of transferred data this way?
With the recently proposed VIRTIO_BALLOON_S_AVAIL you can have a fairly
good estimate of the optimal balloon size, and with the recently merged
balloon deflation on OOM it's a safe thing to do without exposing the
guest workloads to OOM risks.

Roman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
