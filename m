Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD31F6B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 08:08:35 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id l137so393468475ywe.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 05:08:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o138si10330905qke.94.2016.04.25.05.08.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 05:08:34 -0700 (PDT)
Date: Mon, 25 Apr 2016 17:38:30 +0530
From: Amit Shah <amit.shah@redhat.com>
Subject: Re: [PATCH kernel 0/2] speed up live migration by skipping free pages
Message-ID: <20160425120830.GD4735@grmbl.mre>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
 <20160425060641.GC4735@grmbl.mre>
 <20160425135642-mutt-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160425135642-mutt-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Liang Li <liang.z.li@intel.com>, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, quintela@redhat.com, pbonzini@redhat.com, dgilbert@redhat.com, linux-mm@kvack.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, agraf@suse.de, borntraeger@de.ibm.com

On (Mon) 25 Apr 2016 [14:04:06], Michael S. Tsirkin wrote:
> On Mon, Apr 25, 2016 at 11:36:41AM +0530, Amit Shah wrote:
> > On (Tue) 19 Apr 2016 [22:34:32], Liang Li wrote:
> > > Current QEMU live migration implementation mark all guest's RAM pages
> > > as dirtied in the ram bulk stage, all these pages will be processed
> > > and it consumes quite a lot of CPU cycles and network bandwidth.
> > > 
> > > From guest's point of view, it doesn't care about the content in free
> > > page. We can make use of this fact and skip processing the free
> > > pages, this can save a lot CPU cycles and reduce the network traffic
> > > significantly while speed up the live migration process obviously.
> > > 
> > > This patch set is the kernel side implementation.
> > > 
> > > The virtio-balloon driver is extended to send the free page bitmap
> > > from guest to QEMU.
> > > 
> > > After getting the free page bitmap, QEMU can use it to filter out
> > > guest's free pages. This make the live migration process much more
> > > efficient.
> > > 
> > > In order to skip more free pages, we add an interface to let the user
> > > decide whether dropping the cache in guest during live migration.
> > 
> > So if virtio-balloon is the way to go (i.e. speed is acceptable), I
> > just have one point then.  My main concern with using (or not using)
> > virtio-balloon was that a guest admin is going to disable the
> > virtio-balloon driver entirely because the admin won't want the guest
> > to give away pages to the host, esp. when the guest is to be a
> > high-performant one.
> 
> The result will be the reverse of high-performance.
> 
> If you don't want to inflate a balloon, don't.
> 
> If you do but guest doesn't respond to inflate requests,
> it's quite reasonable for host to kill it -
> there is no way to distinguish between that and
> guest being malicious.

With the new command I'm suggesting, the guest will let the host know
that it has enabled this option, and it won't free up any RAM for the
host.

Also, just because a guest doesn't release some memory (which the
guest owns anyway) doesn't make it malicious, and killing such guests
is never going to end well for that hosting provider.

> I don't know of management tools doing that but
> it's rather reasonable. What does happen is
> some random guest memory is pushed it out to swap,
> which is likely much worse than dropping unused memory
> by moving it into the balloon.

Even if the host (admin) gave a guarantee that there won't be any
ballooning activity involved that will slow down the guest, a guest
admin can be paranoid enough to disable ballooning.  If, however, this
is made known to the host, it's likely a win-win situation because the
host knows the guest needs its RAM, and the guest can still use the
driver to send stats which the host can use during migration for
speedups.


		Amit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
