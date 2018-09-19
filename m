Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 37CDC8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 22:43:09 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 123-v6so2897845qkl.3
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 19:43:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e1-v6si3980710qvo.202.2018.09.18.19.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 19:43:08 -0700 (PDT)
Date: Tue, 18 Sep 2018 22:43:06 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <900140442.13987264.1537324986294.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180919105505.GA43643@tiger-server>
References: <cover.1536342881.git.yi.z.zhang@linux.intel.com> <20180919105505.GA43643@tiger-server>
Subject: Re: [PATCH V5 0/4] Fix kvm misconceives NVDIMM pages as reserved
 mmio
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yi Zhang <yi.z.zhang@linux.intel.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, dave jiang <dave.jiang@intel.com>, yu c zhang <yu.c.zhang@intel.com>, david@redhat.com, jack@suse.cz, hch@lst.de, linux-mm@kvack.org, rkrcmar@redhat.com, jglisse@redhat.com, yi z zhang <yi.z.zhang@intel.com>


Hello Yi,

> Any comments?
> 
> Hi Pankaj and Paolo,

I am just helping with the review. Paolo & Dan probably will decide.

Thanks,
Pankaj

> 
> Can we Queue this to merge list since there no other comments last 2
> weeks?
> 
> Regards
> Yi.
> 
> On 2018-09-08 at 02:03:02 +0800, Zhang Yi wrote:
> > For device specific memory space, when we move these area of pfn to
> > memory zone, we will set the page reserved flag at that time, some of
> > these reserved for device mmio, and some of these are not, such as
> > NVDIMM pmem.
> > 
> > Now, we map these dev_dax or fs_dax pages to kvm for DIMM/NVDIMM
> > backend, since these pages are reserved. the check of
> > kvm_is_reserved_pfn() misconceives those pages as MMIO. Therefor, we
> > introduce 2 page map types, MEMORY_DEVICE_FS_DAX/MEMORY_DEVICE_DEV_DAX,
> > to indentify these pages are from NVDIMM pmem. and let kvm treat these
> > as normal pages.
> > 
> > Without this patch, Many operations will be missed due to this
> > mistreatment to pmem pages. For example, a page may not have chance to
> > be unpinned for KVM guest(in kvm_release_pfn_clean); not able to be
> > marked as dirty/accessed(in kvm_set_pfn_dirty/accessed) etc.
> > 
> > V1:
> > https://lkml.org/lkml/2018/7/4/91
> > 
> > V2:
> > https://lkml.org/lkml/2018/7/10/135
> > 
> > V3:
> > https://lkml.org/lkml/2018/8/9/17
> > 
> > V4:
> > https://lkml.org/lkml/2018/8/22/17
> > 
> > V5:
> > [PATCH V3 1/4] Reviewed-by: David / Acked-by: Pankaj
> > [PATCH V3 2/4] Reviewed-by: Jan
> > [PATCH V3 3/4] Acked-by: Jan
> > [PATCH V3 4/4] Added "Acked-by: Pankaj", Added in-line comments: Dave
> > 
> > Zhang Yi (4):
> >   kvm: remove redundant reserved page check
> >   mm: introduce memory type MEMORY_DEVICE_DEV_DAX
> >   mm: add a function to differentiate the pages is from DAX device
> >     memory
> >   kvm: add a check if pfn is from NVDIMM pmem.
> > 
> >  drivers/dax/pmem.c       |  1 +
> >  include/linux/memremap.h |  8 ++++++++
> >  include/linux/mm.h       | 12 ++++++++++++
> >  virt/kvm/kvm_main.c      | 24 ++++++++++++++++--------
> >  4 files changed, 37 insertions(+), 8 deletions(-)
> > 
> > --
> > 2.7.4
> > 
> 
