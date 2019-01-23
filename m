Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E70698E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:03:56 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id f69so2556940pff.5
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:03:56 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x18si18270323pfm.39.2019.01.23.12.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 12:03:55 -0800 (PST)
Subject: Re: [PATCH 2/4] mm/memory-hotplug: allow memory resources to be
 children
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <20190116181902.670EEBC3@viggo.jf.intel.com>
 <20190116191635.GD3617@redhat.com>
 <2b52778d-f120-eec7-3e7a-3a9c182170f0@intel.com>
 <20190116233849.GE3617@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b1f22eda-b52f-af20-637f-b45971a12d33@intel.com>
Date: Wed, 23 Jan 2019 12:03:54 -0800
MIME-Version: 1.0
In-Reply-To: <20190116233849.GE3617@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dave@sr71.net, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de

On 1/16/19 3:38 PM, Jerome Glisse wrote:
> So right now i would rather that we keep properly reporting this
> hazard so that at least we know it failed because of that. This
> also include making sure that we can not register private memory
> as a child of an un-busy resource that does exist but might not
> have yet been claim by its rightful owner.

I can definitely keep the warning in.  But, I don't think there's a
chance of HMM registering a IORES_DESC_DEVICE_PRIVATE_MEMORY region as
the child of another.  The region_intersects() check *should* find that:

>         for (; addr > size && addr >= iomem_resource.start; addr -= size) {
>                 ret = region_intersects(addr, size, 0, IORES_DESC_NONE);
>                 if (ret != REGION_DISJOINT)
>                         continue;
