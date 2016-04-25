Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id 748876B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 07:04:13 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id b14so240150548qge.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 04:04:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l30si10420330qge.78.2016.04.25.04.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 04:04:12 -0700 (PDT)
Date: Mon, 25 Apr 2016 14:04:06 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH kernel 0/2] speed up live migration by skipping free pages
Message-ID: <20160425135642-mutt-send-email-mst@redhat.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
 <20160425060641.GC4735@grmbl.mre>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160425060641.GC4735@grmbl.mre>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amit Shah <amit.shah@redhat.com>
Cc: Liang Li <liang.z.li@intel.com>, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, quintela@redhat.com, pbonzini@redhat.com, dgilbert@redhat.com, linux-mm@kvack.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, agraf@suse.de, borntraeger@de.ibm.com

On Mon, Apr 25, 2016 at 11:36:41AM +0530, Amit Shah wrote:
> On (Tue) 19 Apr 2016 [22:34:32], Liang Li wrote:
> > Current QEMU live migration implementation mark all guest's RAM pages
> > as dirtied in the ram bulk stage, all these pages will be processed
> > and it consumes quite a lot of CPU cycles and network bandwidth.
> > 
> > From guest's point of view, it doesn't care about the content in free
> > page. We can make use of this fact and skip processing the free
> > pages, this can save a lot CPU cycles and reduce the network traffic
> > significantly while speed up the live migration process obviously.
> > 
> > This patch set is the kernel side implementation.
> > 
> > The virtio-balloon driver is extended to send the free page bitmap
> > from guest to QEMU.
> > 
> > After getting the free page bitmap, QEMU can use it to filter out
> > guest's free pages. This make the live migration process much more
> > efficient.
> > 
> > In order to skip more free pages, we add an interface to let the user
> > decide whether dropping the cache in guest during live migration.
> 
> So if virtio-balloon is the way to go (i.e. speed is acceptable), I
> just have one point then.  My main concern with using (or not using)
> virtio-balloon was that a guest admin is going to disable the
> virtio-balloon driver entirely because the admin won't want the guest
> to give away pages to the host, esp. when the guest is to be a
> high-performant one.

The result will be the reverse of high-performance.

If you don't want to inflate a balloon, don't.

If you do but guest doesn't respond to inflate requests,
it's quite reasonable for host to kill it -
there is no way to distinguish between that and
guest being malicious.

I don't know of management tools doing that but
it's rather reasonable. What does happen is
some random guest memory is pushed it out to swap,
which is likely much worse than dropping unused memory
by moving it into the balloon.

> In this case, if a new command can be added to the balloon spec where
> a guest driver indicates it's not going to participate in ballooning
> activity (ie a guest will ignore any ballooning requests from the
> host), but use the driver just for stats-sharing purposes, that can be
> a workable solution here as well.  In that case, we can keep the
> MM-related stuff inside the balloon driver, and also get the benefit
> of the guest having control over how it uses its memory,
> disincentivising guest admins from disabling the balloon entirely (it
> will also benefit the guest to keep this driver loaded in such a
> state, if migration is faster!).
> 
> 		Amit

If there actually are people doing that, we should
figure out the reasons.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
