Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D9D506B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 02:25:38 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e93-v6so6577172plb.5
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 23:25:38 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id h23-v6si1077338pgl.373.2018.07.19.23.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 23:25:37 -0700 (PDT)
Subject: Re: [PATCH V2 0/4] Fix kvm misconceives NVDIMM pages as reserved mmio
References: <cover.1531241281.git.yi.z.zhang@linux.intel.com>
From: "Zhang,Yi" <yi.z.zhang@linux.intel.com>
Message-ID: <c4e1c527-a372-bd6a-a101-5a8e9026e7c1@linux.intel.com>
Date: Fri, 20 Jul 2018 22:11:30 +0800
MIME-Version: 1.0
In-Reply-To: <cover.1531241281.git.yi.z.zhang@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com, dave.jiang@intel.com
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com

Added Jiang,Dave,

Ping for further review, comments.

Thanks All

Regards
Yi.


On 2018a1'07ae??11ae?JPY 01:01, Zhang Yi wrote:
> For device specific memory space, when we move these area of pfn to
> memory zone, we will set the page reserved flag at that time, some of
> these reserved for device mmio, and some of these are not, such as
> NVDIMM pmem.
>
> Now, we map these dev_dax or fs_dax pages to kvm for DIMM/NVDIMM
> backend, since these pages are reserved. the check of
> kvm_is_reserved_pfn() misconceives those pages as MMIO. Therefor, we
> introduce 2 page map types, MEMORY_DEVICE_FS_DAX/MEMORY_DEVICE_DEV_DAX,
> to indentify these pages are from NVDIMM pmem. and let kvm treat these
> as normal pages.
>
> Without this patch, Many operations will be missed due to this
> mistreatment to pmem pages. For example, a page may not have chance to
> be unpinned for KVM guest(in kvm_release_pfn_clean); not able to be
> marked as dirty/accessed(in kvm_set_pfn_dirty/accessed) etc.
>
> V1:
> https://lkml.org/lkml/2018/7/4/91
>
> V2:
> *Add documentation for MEMORY_DEVICE_DEV_DAX memory type in comment block
> *Add is_dax_page() in mm.h to differentiate the pages is from DAX device.
> *Remove the function kvm_is_nd_pfn().
>
> Zhang Yi (4):
>   kvm: remove redundant reserved page check
>   mm: introduce memory type MEMORY_DEVICE_DEV_DAX
>   mm: add a function to differentiate the pages is from DAX device
>     memory
>   kvm: add a check if pfn is from NVDIMM pmem.
>
>  drivers/dax/pmem.c       |  1 +
>  include/linux/memremap.h |  9 +++++++++
>  include/linux/mm.h       | 12 ++++++++++++
>  virt/kvm/kvm_main.c      | 16 ++++++++--------
>  4 files changed, 30 insertions(+), 8 deletions(-)
>
