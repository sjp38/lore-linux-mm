Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3C5F8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 14:58:56 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a23so10893632pfo.2
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 11:58:56 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t75si5263219pfi.193.2019.01.18.11.58.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 11:58:55 -0800 (PST)
Subject: Re: [PATCH 2/4] mm/memory-hotplug: allow memory resources to be
 children
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <20190116181902.670EEBC3@viggo.jf.intel.com>
 <20190116191635.GD3617@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <c6df9b8d-571d-3b4f-c528-dc176f8577e2@intel.com>
Date: Fri, 18 Jan 2019 11:58:54 -0800
MIME-Version: 1.0
In-Reply-To: <20190116191635.GD3617@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: dave@sr71.net, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de

On 1/16/19 11:16 AM, Jerome Glisse wrote:
>> We *could* also simply truncate the existing top-level
>> "Persistent Memory" resource and take over the released address
>> space.  But, this means that if we ever decide to hot-unplug the
>> "RAM" and give it back, we need to recreate the original setup,
>> which may mean going back to the BIOS tables.
>>
>> This should have no real effect on the existing collision
>> detection because the areas that truly conflict should be marked
>> IORESOURCE_BUSY.
> 
> Still i am worrying that this might allow device private to register
> itself as a child of some un-busy resource as this patch obviously
> change the behavior of register_memory_resource()
> 
> What about instead explicitly providing parent resource to add_memory()
> and then to register_memory_resource() so if it is provided as an
> argument (!NULL) then you can __request_region(arg_res, ...) otherwise
> you keep existing code intact ?

We don't have the locking to do this, do we?  For instance, all the
locking is done below register_memory_resource(), so any previous
resource lookup is invalid by the time we get to register_memory_resource().
