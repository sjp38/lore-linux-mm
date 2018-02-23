Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E83216B0007
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 11:56:09 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id t67so2573710lfe.21
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 08:56:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d20sor695445ljd.35.2018.02.23.08.56.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Feb 2018 08:56:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180223085547.3kkbo5lbt3orkqqn@hz-desktop>
References: <151937026001.18973.12034171121582300402.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180223085547.3kkbo5lbt3orkqqn@hz-desktop>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 23 Feb 2018 08:56:06 -0800
Message-ID: <CAPcyv4hmzhY6paR+AayNMmbdM3Fg2Rg2dKwH7NoYAQA25GcgSg@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] vfio, dax: prevent long term filesystem-dax pins
 and other fixes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Alex Williamson <alex.williamson@redhat.com>, Gerd Rausch <gerd.rausch@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, kbuild test robot <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>

On Fri, Feb 23, 2018 at 12:55 AM, Haozhong Zhang
<haozhong.zhang@intel.com> wrote:
> On 02/22/18 23:17 -0800, Dan Williams wrote:
>> Changes since v1 [1]:
>>
>> * Fix the detection of device-dax file instances in vma_is_fsdax().
>>   (Haozhong, Gerd)
>>
>> * Fix compile breakage in the FS_DAX=n and DEV_DAX=y case. (0day robot)
>>
>> [1]: https://lists.01.org/pipermail/linux-nvdimm/2018-February/014046.html
>>
>> ---
>>
>> The vfio interface, like RDMA, wants to setup long term (indefinite)
>> pins of the pages backing an address range so that a guest or userspace
>> driver can perform DMA to the with physical address. Given that this
>> pinning may lead to filesystem operations deadlocking in the
>> filesystem-dax case, the pinning request needs to be rejected.
>>
>> The longer term fix for vfio, RDMA, and any other long term pin user, is
>> to provide a 'pin with lease' mechanism. Similar to the leases that are
>> hold for pNFS RDMA layouts, this userspace lease gives the kernel a way
>> to notify userspace that the block layout of the file is changing and
>> the kernel is revoking access to pinned pages.
>>
>> ---
>>
>> Dan Williams (5):
>>       dax: fix vma_is_fsdax() helper
>>       dax: fix dax_mapping() definition in the FS_DAX=n + DEV_DAX=y case
>>       dax: fix S_DAX definition
>>       dax: short circuit vma_is_fsdax() in the CONFIG_FS_DAX=n case
>>       vfio: disable filesystem-dax page pinning
>>
>>
>>  drivers/vfio/vfio_iommu_type1.c |   18 +++++++++++++++---
>>  include/linux/dax.h             |    9 ++++++---
>>  include/linux/fs.h              |    6 ++++--
>>  3 files changed, 25 insertions(+), 8 deletions(-)
>
> Tested on QEMU with fs-dax and device-dax as vNVDIMM backends
> respectively with vfio passthrough. The fs-dax case fails QEMU as
> expected, and the device-dax case works normally now.
>
> Tested-by: Haozhong Zhang <haozhong.zhang@intel.com>
>

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
