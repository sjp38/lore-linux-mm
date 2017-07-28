Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD3356B0575
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 19:01:49 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q198so83230775qke.13
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 16:01:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c76si8170855qkh.349.2017.07.28.16.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 16:01:49 -0700 (PDT)
Date: Sat, 29 Jul 2017 02:01:35 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v12 5/8] virtio-balloon: VIRTIO_BALLOON_F_SG
Message-ID: <20170729020006-mutt-send-email-mst@kernel.org>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-6-git-send-email-wei.w.wang@intel.com>
 <597AF4EF.4020705@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <597AF4EF.4020705@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, mhocko@kernel.org, willy@infradead.org, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Fri, Jul 28, 2017 at 04:25:19PM +0800, Wei Wang wrote:
> On 07/12/2017 08:40 PM, Wei Wang wrote:
> > Add a new feature, VIRTIO_BALLOON_F_SG, which enables to
> > transfer a chunk of ballooned (i.e. inflated/deflated) pages using
> > scatter-gather lists to the host.
> > 
> > The implementation of the previous virtio-balloon is not very
> > efficient, because the balloon pages are transferred to the
> > host one by one. Here is the breakdown of the time in percentage
> > spent on each step of the balloon inflating process (inflating
> > 7GB of an 8GB idle guest).
> > 
> > 1) allocating pages (6.5%)
> > 2) sending PFNs to host (68.3%)
> > 3) address translation (6.1%)
> > 4) madvise (19%)
> > 
> > It takes about 4126ms for the inflating process to complete.
> > The above profiling shows that the bottlenecks are stage 2)
> > and stage 4).
> > 
> > This patch optimizes step 2) by transferring pages to the host in
> > sgs. An sg describes a chunk of guest physically continuous pages.
> > With this mechanism, step 4) can also be optimized by doing address
> > translation and madvise() in chunks rather than page by page.
> > 
> > With this new feature, the above ballooning process takes ~491ms
> > resulting in an improvement of ~88%.
> > 
> 
> 
> I found a recent mm patch, bb01b64cfab7c22f3848cb73dc0c2b46b8d38499
> , zeros all the ballooned pages, which is very time consuming.
> 
> Tests show that the time to balloon 7G pages is increased from ~491 ms to
> 2.8 seconds with the above patch.

Sounds like it should be reverted. Post a revert pls and
we'll discuss.

> How about moving the zero operation to the hypervisor? In this way, we
> will have a much faster balloon process.
> 
> 
> Best,
> Wei

Or in other words hypervisors should not be stupid and
should not try to run ksm on DONTNEED pages.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
