Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id F22B46B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:38:57 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id q3so11524874qtf.4
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:38:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f15si446056qta.220.2017.01.18.07.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 07:38:57 -0800 (PST)
Date: Wed, 18 Jan 2017 17:38:53 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v6 kernel 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Message-ID: <20170118173139-mutt-send-email-mst@kernel.org>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
 <2a32f616-25a8-ba5a-f74c-d619fc8ab333@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2a32f616-25a8-ba5a-f74c-d619fc8ab333@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Liang Li <liang.z.li@intel.com>, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, amit.shah@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, pbonzini@redhat.com, aarcange@redhat.com, dgilbert@redhat.com, quintela@redhat.com

On Wed, Jan 18, 2017 at 11:09:30AM +0100, David Hildenbrand wrote:
> Am 21.12.2016 um 07:52 schrieb Liang Li:
> > This patch set contains two parts of changes to the virtio-balloon.
> > 
> > One is the change for speeding up the inflating & deflating process,
> > the main idea of this optimization is to use {pfn|length} to present
> > the page information instead of the PFNs, to reduce the overhead of
> > virtio data transmission, address translation and madvise(). This can
> > help to improve the performance by about 85%.
> > 
> > Another change is for speeding up live migration. By skipping process
> > guest's unused pages in the first round of data copy, to reduce needless
> > data processing, this can help to save quite a lot of CPU cycles and
> > network bandwidth. We put guest's unused page information in a
> > {pfn|length} array and send it to host with the virt queue of
> > virtio-balloon. For an idle guest with 8GB RAM, this can help to shorten
> > the total live migration time from 2Sec to about 500ms in 10Gbps network
> > environment. For an guest with quite a lot of page cache and with little
> > unused pages, it's possible to let the guest drop it's page cache before
> > live migration, this case can benefit from this new feature too.
> 
> I agree that both changes make sense (although the second change just smells
> very racy, as you also pointed out in the patch description),
> however I am not sure if virtio-balloon is really the right place for
> the latter change.
> 
> virtio-balloon is all about ballooning, nothing else. What you're doing
> is using it as a way to communicate balloon-unrelated data from/to the
> hypervisor. Yes, it is also about guest memory, but completely unrelated
> to the purpose of the balloon device.
> 
> Maybe using virtio-balloon for this purpose is okay - I have mixed
> feelings (especially as I can't tell where else this could go). I would
> like to get a second opinion on this.

As long as the interface is similar, it seems to make
sense for me - why invent a completely new device that
looks very much like the old one?

So this boils down to whether the speedup patches are merged.


> -- 
> 
> David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
