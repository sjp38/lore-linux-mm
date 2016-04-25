Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4268F6B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 02:06:46 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id x7so385961125qkd.2
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 23:06:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 7si9651780qks.215.2016.04.24.23.06.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Apr 2016 23:06:45 -0700 (PDT)
Date: Mon, 25 Apr 2016 11:36:41 +0530
From: Amit Shah <amit.shah@redhat.com>
Subject: Re: [PATCH kernel 0/2] speed up live migration by skipping free pages
Message-ID: <20160425060641.GC4735@grmbl.mre>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: mst@redhat.com, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, quintela@redhat.com, pbonzini@redhat.com, dgilbert@redhat.com, linux-mm@kvack.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, agraf@suse.de, borntraeger@de.ibm.com

On (Tue) 19 Apr 2016 [22:34:32], Liang Li wrote:
> Current QEMU live migration implementation mark all guest's RAM pages
> as dirtied in the ram bulk stage, all these pages will be processed
> and it consumes quite a lot of CPU cycles and network bandwidth.
> 
> From guest's point of view, it doesn't care about the content in free
> page. We can make use of this fact and skip processing the free
> pages, this can save a lot CPU cycles and reduce the network traffic
> significantly while speed up the live migration process obviously.
> 
> This patch set is the kernel side implementation.
> 
> The virtio-balloon driver is extended to send the free page bitmap
> from guest to QEMU.
> 
> After getting the free page bitmap, QEMU can use it to filter out
> guest's free pages. This make the live migration process much more
> efficient.
> 
> In order to skip more free pages, we add an interface to let the user
> decide whether dropping the cache in guest during live migration.

So if virtio-balloon is the way to go (i.e. speed is acceptable), I
just have one point then.  My main concern with using (or not using)
virtio-balloon was that a guest admin is going to disable the
virtio-balloon driver entirely because the admin won't want the guest
to give away pages to the host, esp. when the guest is to be a
high-performant one.

In this case, if a new command can be added to the balloon spec where
a guest driver indicates it's not going to participate in ballooning
activity (ie a guest will ignore any ballooning requests from the
host), but use the driver just for stats-sharing purposes, that can be
a workable solution here as well.  In that case, we can keep the
MM-related stuff inside the balloon driver, and also get the benefit
of the guest having control over how it uses its memory,
disincentivising guest admins from disabling the balloon entirely (it
will also benefit the guest to keep this driver loaded in such a
state, if migration is faster!).

		Amit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
