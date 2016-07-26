Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA4E36B025F
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 14:55:18 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id q83so45724434iod.2
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 11:55:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n21si2530068ita.71.2016.07.26.11.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 11:55:18 -0700 (PDT)
Date: Tue, 26 Jul 2016 21:55:13 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Message-ID: <20160726215256-mutt-send-email-mst@kernel.org>
References: <1467196340-22079-1-git-send-email-liang.z.li@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467196340-22079-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, virtio-dev@lists.oasis-open.org, dgilbert@redhat.com, quintela@redhat.com, linux-mm@kvack.org

On Wed, Jun 29, 2016 at 06:32:13PM +0800, Liang Li wrote:
> This patch set contains two parts of changes to the virtio-balloon. 
> 
> One is the change for speeding up the inflating & deflating process,
> the main idea of this optimization is to use bitmap to send the page
> information to host instead of the PFNs, to reduce the overhead of
> virtio data transmission, address translation and madvise(). This can
> help to improve the performance by about 85%.
> 
> Another change is for speeding up live migration. By skipping process
> guest's free pages in the first round of data copy, to reduce needless
> data processing, this can help to save quite a lot of CPU cycles and
> network bandwidth. We put guest's free page information in bitmap and
> send it to host with the virt queue of virtio-balloon. For an idle 8GB
> guest, this can help to shorten the total live migration time from 2Sec
> to about 500ms in the 10Gbps network environment.  

So I'm fine with this patchset, but I noticed it was not
yet reviewed by MM people. And that is not surprising since
you did not copy memory management mailing list on it.

I added linux-mm@kvack.org Cc on this mail but this might not be enough.

Please repost (e.g. [PATCH v2 repost]) copying the relevant mailing list
so we can get some reviews.


> 
> Changes from v1 to v2:
>     * Abandon the patch for dropping page cache.
>     * Put some structures to uapi head file.
>     * Use a new way to determine the page bitmap size.
>     * Use a unified way to send the free page information with the bitmap 
>     * Address the issues referred in MST's comments
> 
> Liang Li (7):
>   virtio-balloon: rework deflate to add page to a list
>   virtio-balloon: define new feature bit and page bitmap head
>   mm: add a function to get the max pfn
>   virtio-balloon: speed up inflate/deflate process
>   virtio-balloon: define feature bit and head for misc virt queue
>   mm: add the related functions to get free page info
>   virtio-balloon: tell host vm's free page info
> 
>  drivers/virtio/virtio_balloon.c     | 306 +++++++++++++++++++++++++++++++-----
>  include/uapi/linux/virtio_balloon.h |  41 +++++
>  mm/page_alloc.c                     |  52 ++++++
>  3 files changed, 359 insertions(+), 40 deletions(-)
> 
> -- 
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
