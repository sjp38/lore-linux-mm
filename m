Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4056B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 03:55:53 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id s17so3893152pfm.23
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 00:55:53 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j61-v6si1485730plb.395.2018.02.23.00.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 00:55:51 -0800 (PST)
Date: Fri, 23 Feb 2018 16:55:47 +0800
From: Haozhong Zhang <haozhong.zhang@intel.com>
Subject: Re: [PATCH v2 0/5] vfio, dax: prevent long term filesystem-dax pins
 and other fixes
Message-ID: <20180223085547.3kkbo5lbt3orkqqn@hz-desktop>
References: <151937026001.18973.12034171121582300402.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151937026001.18973.12034171121582300402.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, Gerd Rausch <gerd.rausch@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, kbuild test robot <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>

On 02/22/18 23:17 -0800, Dan Williams wrote:
> Changes since v1 [1]:
> 
> * Fix the detection of device-dax file instances in vma_is_fsdax().
>   (Haozhong, Gerd)
> 
> * Fix compile breakage in the FS_DAX=n and DEV_DAX=y case. (0day robot)
> 
> [1]: https://lists.01.org/pipermail/linux-nvdimm/2018-February/014046.html
> 
> ---
> 
> The vfio interface, like RDMA, wants to setup long term (indefinite)
> pins of the pages backing an address range so that a guest or userspace
> driver can perform DMA to the with physical address. Given that this
> pinning may lead to filesystem operations deadlocking in the
> filesystem-dax case, the pinning request needs to be rejected.
> 
> The longer term fix for vfio, RDMA, and any other long term pin user, is
> to provide a 'pin with lease' mechanism. Similar to the leases that are
> hold for pNFS RDMA layouts, this userspace lease gives the kernel a way
> to notify userspace that the block layout of the file is changing and
> the kernel is revoking access to pinned pages.
> 
> ---
> 
> Dan Williams (5):
>       dax: fix vma_is_fsdax() helper
>       dax: fix dax_mapping() definition in the FS_DAX=n + DEV_DAX=y case
>       dax: fix S_DAX definition
>       dax: short circuit vma_is_fsdax() in the CONFIG_FS_DAX=n case
>       vfio: disable filesystem-dax page pinning
> 
> 
>  drivers/vfio/vfio_iommu_type1.c |   18 +++++++++++++++---
>  include/linux/dax.h             |    9 ++++++---
>  include/linux/fs.h              |    6 ++++--
>  3 files changed, 25 insertions(+), 8 deletions(-)

Tested on QEMU with fs-dax and device-dax as vNVDIMM backends
respectively with vfio passthrough. The fs-dax case fails QEMU as
expected, and the device-dax case works normally now.

Tested-by: Haozhong Zhang <haozhong.zhang@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
