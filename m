Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 851836B3F7E
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:07:05 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id m21-v6so13958887oic.7
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 01:07:05 -0700 (PDT)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id o25-v6si8839622oic.115.2018.08.27.01.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 01:07:04 -0700 (PDT)
Subject: Re: [PATCH v2 13/40] vfio: Add support for Shared Virtual Addressing
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-14-jean-philippe.brucker@arm.com>
From: Xu Zaibo <xuzaibo@huawei.com>
Message-ID: <5B83B11E.7010807@huawei.com>
Date: Mon, 27 Aug 2018 16:06:54 +0800
MIME-Version: 1.0
In-Reply-To: <20180511190641.23008-14-jean-philippe.brucker@arm.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com, =?UTF-8?B?57Gz57Gz?= <kenneth-lee-2012@foxmail.com>, wangzhou1 <wangzhou1@hisilicon.com>, liguozhu <liguozhu@hisilicon.com>, fanghao11 <fanghao11@huawei.com>

Hi Jean,

On 2018/5/12 3:06, Jean-Philippe Brucker wrote:
> diff --git a/include/uapi/linux/vfio.h b/include/uapi/linux/vfio.h
> index 1aa7b82e8169..dc07752c8fe8 100644
> --- a/include/uapi/linux/vfio.h
> +++ b/include/uapi/linux/vfio.h
> @@ -665,6 +665,82 @@ struct vfio_iommu_type1_dma_unmap {
>   #define VFIO_IOMMU_ENABLE	_IO(VFIO_TYPE, VFIO_BASE + 15)
>   #define VFIO_IOMMU_DISABLE	_IO(VFIO_TYPE, VFIO_BASE + 16)
>   
> +/*
> + * VFIO_IOMMU_BIND_PROCESS
> + *
> + * Allocate a PASID for a process address space, and use it to attach this
> + * process to all devices in the container. Devices can then tag their DMA
> + * traffic with the returned @pasid to perform transactions on the associated
> + * virtual address space. Mapping and unmapping buffers is performed by standard
> + * functions such as mmap and malloc.
> + *
> + * If flag is VFIO_IOMMU_BIND_PID, @pid contains the pid of a foreign process to
> + * bind. Otherwise the current task is bound. Given that the caller owns the
> + * device, setting this flag grants the caller read and write permissions on the
> + * entire address space of foreign process described by @pid. Therefore,
> + * permission to perform the bind operation on a foreign process is governed by
> + * the ptrace access mode PTRACE_MODE_ATTACH_REALCREDS check. See man ptrace(2)
> + * for more information.
> + *
> + * On success, VFIO writes a Process Address Space ID (PASID) into @pasid. This
> + * ID is unique to a process and can be used on all devices in the container.
> + *
> + * On fork, the child inherits the device fd and can use the bonds setup by its
> + * parent. Consequently, the child has R/W access on the address spaces bound by
> + * its parent. After an execv, the device fd is closed and the child doesn't
> + * have access to the address space anymore.
> + *
> + * To remove a bond between process and container, VFIO_IOMMU_UNBIND ioctl is
> + * issued with the same parameters. If a pid was specified in VFIO_IOMMU_BIND,
> + * it should also be present for VFIO_IOMMU_UNBIND. Otherwise unbind the current
> + * task from the container.
> + */
> +struct vfio_iommu_type1_bind_process {
> +	__u32	flags;
> +#define VFIO_IOMMU_BIND_PID		(1 << 0)
> +	__u32	pasid;
As I am doing some works on the SVA patch set. I just consider why the 
user space need this pasid.
Maybe, is it much more reasonable to set the pasid into all devices 
under the vfio container by
a call back function from 'vfio_devices'  while 
'VFIO_IOMMU_BIND_PROCESS' CMD is executed
in kernel land? I am not sure because there exists no suitable call back 
in 'vfio_device' at present.

Thanks,
Zaibo
> +	__s32	pid;
> +};
> +
> +/*
> + * Only mode supported at the moment is VFIO_IOMMU_BIND_PROCESS, which takes
> + * vfio_iommu_type1_bind_process in data.
> + */
> +struct vfio_iommu_type1_bind {
> +	__u32	argsz;
> +	__u32	flags;
> +#define VFIO_IOMMU_BIND_PROCESS		(1 << 0)
> +	__u8	data[];
> +};
> +
> +/*
> + * VFIO_IOMMU_BIND - _IOWR(VFIO_TYPE, VFIO_BASE + 22, struct vfio_iommu_bind)
> + *
> + * Manage address spaces of devices in this container. Initially a TYPE1
> + * container can only have one address space, managed with
> + * VFIO_IOMMU_MAP/UNMAP_DMA.
> + *
> + * An IOMMU of type VFIO_TYPE1_NESTING_IOMMU can be managed by both MAP/UNMAP
> + * and BIND ioctls at the same time. MAP/UNMAP acts on the stage-2 (host) page
> + * tables, and BIND manages the stage-1 (guest) page tables. Other types of
> + * IOMMU may allow MAP/UNMAP and BIND to coexist, where MAP/UNMAP controls
> + * non-PASID traffic and BIND controls PASID traffic. But this depends on the
> + * underlying IOMMU architecture and isn't guaranteed.
> + *
> + * Availability of this feature depends on the device, its bus, the underlying
> + * IOMMU and the CPU architecture.
> + *
> + * returns: 0 on success, -errno on failure.
> + */
> +#define VFIO_IOMMU_BIND		_IO(VFIO_TYPE, VFIO_BASE + 22)
> +
> +/*
> + * VFIO_IOMMU_UNBIND - _IOWR(VFIO_TYPE, VFIO_BASE + 23, struct vfio_iommu_bind)
> + *
> + * Undo what was done by the corresponding VFIO_IOMMU_BIND ioctl.
> + */
> +#define VFIO_IOMMU_UNBIND	_IO(VFIO_TYPE, VFIO_BASE + 23)
> +
>   /* -------- Additional API for SPAPR TCE (Server POWERPC) IOMMU -------- */
>   
>   /*
