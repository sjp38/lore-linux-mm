Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A60776B000D
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 05:49:56 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b12-v6so10603520plr.17
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 02:49:56 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id l6-v6si17629793pfc.298.2018.08.13.02.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Aug 2018 02:49:55 -0700 (PDT)
Subject: Re: [PATCH V3 0/4] Fix kvm misconceives NVDIMM pages as reserved mmio
References: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
 <20180809090208.GD5069@quack2.suse.cz>
From: "Zhang,Yi" <yi.z.zhang@linux.intel.com>
Message-ID: <154a783f-5aff-c910-b252-5a6a36b37907@linux.intel.com>
Date: Tue, 14 Aug 2018 01:33:57 +0800
MIME-Version: 1.0
In-Reply-To: <20180809090208.GD5069@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, hch@lst.de, yu.c.zhang@intel.com, linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com



On 2018a1'08ae??09ae?JPY 17:02, Jan Kara wrote:
> On Thu 09-08-18 18:52:48, Zhang Yi wrote:
>> For device specific memory space, when we move these area of pfn to
>> memory zone, we will set the page reserved flag at that time, some of
>> these reserved for device mmio, and some of these are not, such as
>> NVDIMM pmem.
>>
>> Now, we map these dev_dax or fs_dax pages to kvm for DIMM/NVDIMM
>> backend, since these pages are reserved. the check of
>> kvm_is_reserved_pfn() misconceives those pages as MMIO. Therefor, we
>> introduce 2 page map types, MEMORY_DEVICE_FS_DAX/MEMORY_DEVICE_DEV_DAX,
>> to indentify these pages are from NVDIMM pmem. and let kvm treat these
>> as normal pages.
>>
>> Without this patch, Many operations will be missed due to this
>> mistreatment to pmem pages. For example, a page may not have chance to
>> be unpinned for KVM guest(in kvm_release_pfn_clean); not able to be
>> marked as dirty/accessed(in kvm_set_pfn_dirty/accessed) etc.
>>
>> V1:
>> https://lkml.org/lkml/2018/7/4/91
>>
>> V2:
>> https://lkml.org/lkml/2018/7/10/135
>>
>> V3:
>> [PATCH V3 1/4] Needs Comments.
>> [PATCH V3 2/4] Update the description of MEMORY_DEVICE_DEV_DAX: Jan
>> [PATCH V3 3/4] Acked-by: Jan in V2
> Hum, but it is not the the patch...
>
> 								Honza
Sorry, I missed that, will add in the next version, thanks for your review
